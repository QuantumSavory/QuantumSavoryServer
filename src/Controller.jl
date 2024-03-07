using Oxygen
using HTTP
using Distributed
using UUIDs
using StructTypes
using JSON3
using QuantumSavory
using Dates

include("URL.jl")
include("Service.jl")

# StructTypes.StructType(::Type{RegisterNet}) = StructTypes.Struct()

@get CREATE_REQUEST_ID_URL function(req::HTTP.Request)
  @info "Received request to generate a new request UUID"
  return new_request_uuid()
end

@post CREATE_REGISTER_NET_URL function(req::HTTP.Request)
  @info "Received request to create a register network"
  create_register_net(req)
  return HTTP.Response(200, "Success")
end

@post CREATE_TAG_URL function(req::HTTP.Request)
  @info "Received request to add register tag"
  response::Response = create_tag!(req)
  return response
end

@post INITIALIZE_REGISTER_URL function (req::HTTP.Request)
  @info "Received request to initialize register"
  response::Response = initialize_register!(req)
  return response
end

@post APPLY_OPERATION_URL function (req::HTTP.Request)
  @info "Received request to apply operation"
  response::Response = apply_operation!(req)
  return response
end

@get GET_TIME_URL function (req::HTTP.Request)
  @info "Received request to get time"
  response::Response{DateTime} = get_current_time(req)
  return response
end