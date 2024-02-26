using Oxygen
using HTTP
using Distributed
using UUIDs
using StructTypes
using JSON3
using QuantumSavory

include("../service/Service.jl")

struct CreateRegisterRequest
  request_id::String
  registers::Vector{Int}
end

dict = Dict()

# StructTypes.StructType(::Type{RegisterNet}) = StructTypes.Struct()

@get "/id" function(req::HTTP.Request)
  @info "Received request to generate a new request UUID"
  return new_request_uuid()
end

@post "/register/create" function(req::HTTP.Request)
  @info "Received request to create a register network"
  reg_net = create_register_net(req)
  dict[create_register.request_id] = net
  return HTTP.Response(200, "Created!")
end

@get "/requests/active" function (req::HTTP.Request)
  @info "Received request to retrieve active requests"
  return dict
end


@patch "/register/tag" function(req::HTTP.Request)
  @info "Received request to add register tag"
  return create_tag!(req, dict)
end

