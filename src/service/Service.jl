using UUIDs

"""
Creates a new UUID for a request
"""
function new_request_uuid()
  request_uuid = uuid1()

  @info "Generated new request id: $(request_id)"
  return request_uuid
end 


"""
Generates a register network
"""
function create_register_net(req::HTTP.Request)
  create_register = json(req, CreateRegisterRequest)
  
  register_vector::Vector{Register} = []
  for c in create_register.registers
    push!(register_vector, Register(c))
  end
  
  reg_net = RegisterNet(register_vector)
  @info "Created register net: $(reg_net)"

  return reg_net

end


struct TagRequest 
  register::Int
  slot::Int
  tag::Union{Int, String}
end

struct TagRequestList
  request_id::String
  tags::Vector{TagRequest}
end



function create_tag!(req::HTTP.Request, dict::Dict{Any, Any})
  tags = json(req, TagRequestList)
  if !haskey(dict, tags.request_id)
    return HTTP.Response(400, "Register/slot was not found!")
  end

  net = dict[tags.request_id]
  for tag in tags.tags
    tag!(net[tag.register, tag.slot], :symbol, tag.tag)
  end

  return HTTP.Response(400, "Success!")
end