using Oxygen
using HTTP
using Distributed
using UUIDs
using StructTypes
using JSON3
using QuantumSavory
using Dates
using SwaggerMarkdown

@swagger """
$CREATE_TAG_URL:
  post:
    summary: Create tags for registers
    description: Creates tags for the registers that will be available while querying
    responses:
      '200':
        description: OK
"""
@post CREATE_TAG_URL function(req::HTTP.Request)
  @info "Received request to add register tag"
  local tag_req
  try
    tag_req = json(req, TagRequest)
  catch error
    return HTTP.Response(400, "Could not deserialize request due to : $(string(error))")
  end
    response = create_tag!(tag_req)
  return response
end

@swagger """
$INITIALIZE_REGISTER_URL:
  post:
    summary: Initialize the register slots
    description: Initialize the registers with a state
    responses:
      '200':
        description: OK
"""
@post INITIALIZE_REGISTER_URL function (req::HTTP.Request)
  @info "Received request to initialize register"
  local initialize_req
  try
    initialize_req = json(req, InitializeRequest)
  catch error
    return HTTP.Response(400, "Could not deserialize request due to : $(string(error))")
  end
  response::Response = initialize_register!(initialize_req)
  return response
end

@swagger """
$APPLY_OPERATION_URL:
  post:
    summary: Apply an operation
    description: Applies the operator on registers
          
    responses:
      '200':
        description: OK
"""
@post APPLY_OPERATION_URL function (req::HTTP.Request)
  @info "Received request to apply operation"
  local apply_req
  try
    apply_req = json(req, ApplyRequest)
  catch error
    return HTTP.Response(400, "Could not deserialize request due to : $(string(error))")
  end
  response::Response = apply_operation!(apply_req)
  return response
end

@swagger """
$GET_TIME_URL:
  get:
    summary: Returns the current system time
    description: Returns current system time in ISO 8601 format
    
    responses:
      '200':
        description: Successfully returned the system time
"""
@get GET_TIME_URL function (req::HTTP.Request)
  @info "Received request to get time"
  response::Response{DateTime} = get_current_time()
  return response
end