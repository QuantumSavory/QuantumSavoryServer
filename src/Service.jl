using UUIDs
using QuantumSavory
using Dates
using SwaggerMarkdown
using QuantumSymbolics: PauliM, PauliP


operatormap = Dict(:X => X, :Y => Y, :Z => Z, :σ₋ => Pm, :σ₊ => Pp, :H => H, :CNOT => CNOT, :CPHASE => CPHASE)              
"""
Creates a new UUID for a request
"""
function new_request_uuid()
  request_uuid = uuid1()

  @info "Generated new request id: $(request_uuid)"
  return request_uuid
end 


"""
Generates a register network
"""
function create_register_net(regnet_request::CreateRegisterRequest)
  register_vector::Vector{RegisterRequest} = []
  for c in regnet_request.registers
    push!(register_vector, Register(c))
  end
  
  reg_net = RegisterNet(register_vector)
  @info "Created register net: $(reg_net)"

  return reg_net

end

"""
Creates tags for the slots of the register

# Arguments
*`tag_req`: Request that contains the register, slots and tag

# Examples
```jldoctest

julia> reg_net = RegisterNet([Register(3), Register(4), Register(3)]);

julia> tag = TagRegisterRequest(1, 1, [:sometag, 1, 2])
TagRegisterRequest(1, 1, Union{Int64, Symbol}[:sometag, 1, 2])

julia> req = TagRequest([tag])
TagRequest(TagRegisterRequest[TagRegisterRequest(1, 1, Union{Int64, Symbol}[:sometag, 1, 2])])

julia> create_tag!(req)
Response{Dict{Symbol, Vector{Any}}}(:success, Dict{Symbol, Vector{Any}}(:success => [TagRegisterRequest(1, 1, Union{Int64, Symbol}[:sometag, 1, 2])], :error => []), "", 200)
```
"""
function create_tag!(tag_req::TagRequest)
  status = Dict(:success => [], :error => [])
  for register in tag_req.registers
    try 
      tag!(reg_net[register.reg_idx, register.slot_idx], register.tag...)
      push!(status[:success], register)
    catch error
      @error "Error occurred while tagging request for : $(register)"
      @error error
      push!(status[:error], register)
    end
  end
  
  if isempty(status[:error])
    return Response(:success, status, EMPTY_STRING, STATUS_OK)
  else
    return Response(:error, status, "Some tag requests were unsuccessful", STATUS_INTERNAL_ERROR)
  end
end

"""
Initializes the slots of the register based on the state

# Arguments
*`initialize_req`: Request that contains the register, slots and state

# Examples
```jldoctest
julia> reg_net = RegisterNet([Register(3), Register(4), Register(3)]);

julia> reqA = InitializeRegisterRequest(1, 1, "X1")
InitializeRegisterRequest(1, 1, "X1")

julia> reqB = InitializeRegisterRequest(1, 2, "Z1")
InitializeRegisterRequest(1, 2, "Z1")

julia> ir = InitializeRequest([reqA, reqB]);

julia> ir = InitializeRequest([reqA, reqB])
InitializeRequest(InitializeRegisterRequest[InitializeRegisterRequest(1, 1, "X1"), InitializeRegisterRequest(1, 2, "Z1")])

julia> initialize_register!(ir)
Response{Dict{Symbol, Vector{Any}}}(:success, Dict{Symbol, Vector{Any}}(:success => [InitializeRegisterRequest(1, 1, "X1"), InitializeRegisterRequest(1, 2, "Z1")], :error => []), "", 200)
```
"""
function initialize_register!(initialize_req::InitializeRequest)
  status = Dict(:success => [], :error => [])
  for register in initialize_req.registers
    args = [reg_net[register.reg_idx, register.slot_idx]]
    
    if (STATE in fieldnames(typeof(register))) && (!isempty(register.state))
      push!(args, register.state)
    end

    try
      initialize!(args...)
      push!(status[:success], register)
    catch error 
      @error "Error occurred while initialize request for : $(register)"
      @error string(error)
      push!(status[:error], register)
    end
  end

  if isempty(status[:error])
    return Response(:success, status, EMPTY_STRING, STATUS_OK)
  else
    return Response(:error, status, "Some initialize requests were unsuccessful", STATUS_INTERNAL_ERROR)
  end
end

"""
Applies the operation on the registers

# Arguments
* `apply_req`: The request that contains the registers, slots and operator

# Examples
```jldoctest

julia> reg_net = RegisterNet([Register(3), Register(4), Register(3)]);

julia> reqA = InitializeRegisterRequest(1, 1, "X1")
InitializeRegisterRequest(1, 1, "X1")

julia> reqB = InitializeRegisterRequest(1, 2, "Z1")
InitializeRegisterRequest(1, 2, "Z1")

julia> ir = InitializeRequest([reqA, reqB]);

julia> ir = InitializeRequest([reqA, reqB])
InitializeRequest(InitializeRegisterRequest[InitializeRegisterRequest(1, 1, "X1"), InitializeRegisterRequest(1, 2, "Z1")])

julia> initialize_register!(ir)
Response{Dict{Symbol, Vector{Any}}}(:success, Dict{Symbol, Vector{Any}}(:success => [InitializeRegisterRequest(1, 1, "X1"), InitializeRegisterRequest(1, 2, "Z1")], :error => []), "", 200)

julia> reg_req_A = ApplyRegisterRequest(1,1;);
julia> reg_req_B = ApplyRegisterRequest(1,2;);

julia> ar = ApplyRequest([reg_req_A, reg_req_B], :CNOT)
ApplyRequest(ApplyRegisterRequest[ApplyRegisterRequest(1, 1), ApplyRegisterRequest(1, 2)], :CNOT)

julia> apply_operation!(ar)
Response{ApplyRequest}(:success, ApplyRequest(ApplyRegisterRequest[ApplyRegisterRequest(1, 1), ApplyRegisterRequest(1, 2)], :CNOT), "", 200)
```
"""
function apply_operation!(apply_req::ApplyRequest)
  reg_ref::Vector{RegRef} = []
  for reg in apply_req.registers
    push!(reg_ref, reg_net[reg.reg_idx, reg.slot_idx])
  end

  if haskey(operatormap, apply_req.operator)
    operator = operatormap[apply_req.operator]
  else
    return Response(:error, EMPTY_DATA, "Operator not supported", STATUS_BAD_REQUEST)
  end
  
  try
    apply!(reg_ref, operator)
    return Response(:success, apply_req, EMPTY_STRING, STATUS_OK)
  catch error 
    @error "Error occurred while apply operation for $(apply_req.registers)"
    @error error
    return Response(:error, EMPTY_DATA, string(error), STATUS_INTERNAL_ERROR)
  end
end

"""
Returns the current system time

# Examples
```jldoctest
julia> response = QuantumSavoryServer.get_current_time();

julia> typeof(response)
Response{DateTime}
```
"""
function get_current_time() 
  try
    current_time = now()
    return Response(:success, current_time, EMPTY_STRING, STATUS_OK)
  catch error 
    @error "Error occurred while get current time"
    @error error
    return Response(:error, EMPTY_DATA, string(error), STATUS_INTERNAL_ERROR)
  end
  return response 
end