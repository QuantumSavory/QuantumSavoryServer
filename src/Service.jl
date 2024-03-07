using UUIDs
using QuantumSavory
using Dates


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
function create_register_net(req::HTTP.Request)
  create_register = json(req, CreateRegisterRequest)
  
  register_vector::Vector{RegisterRequest} = []
  for c in create_register.registers
    push!(register_vector, Register(c))
  end
  
  reg_net = RegisterNet(register_vector)
  @info "Created register net: $(reg_net)"

  return reg_net

end

function create_tag!(req::HTTP.Request)
  tag_req = json(req, TagRequest)
  status::Dict{Symbol, Vector{RegisterRequest}} = Dict(:success => [], :error => [])
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

function initialize_register!(req::HTTP.Request)
  initialize_req = json(req, InitializeRequest)
  status::Dict{Symbol, Vector{RegisterRequest}} = Dict(:success => [], :error => [])

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
      @error error
      push!(status[:error], register)
    end
  end

  if isempty(status[:error])
    return Response(:success, status, EMPTY_STRING, STATUS_OK)
  else
    return Response(:error, status, "Some initialize requests were unsuccessful", STATUS_INTERNAL_ERROR)
  end
end

# TODO: Mapping of other operator types
function apply_operation!(req::HTTP.Request)
  apply_req = json(req, ApplyRequest)
  reg_ref::Vector{RegRef} = []
  for reg in apply_req.registers
    push!(reg_ref, reg_net[reg.reg_idx, reg.slot_idx])
  end

  try
    apply!(reg_ref, CNOT)
    return Response(:success, apply_req, EMPTY_STRING, STATUS_OK)
  catch error 
    throw(error)
    @error "Error occurred while apply operation for $(apply_req.registers)"
    @error error
    return Response(:error, EMPTY_DATA, string(error), STATUS_INTERNAL_ERROR)
  end
end

function get_current_time(req::HTTP.Request) 
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