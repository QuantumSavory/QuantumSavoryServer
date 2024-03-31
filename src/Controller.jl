using Oxygen
using HTTP
using Distributed
using UUIDs
using StructTypes
using JSON3
using QuantumSavory
using Dates
using SwaggerMarkdown

statemap = Dict("X1" => X1, "X2" => X2, "Y1" => Y1, "Y2" => Y2, "Z1" => Z1, "Z2" => Z2)              
operatormap = Dict("X" => X, "Y" => Y, "Z" => Z, "σ₋" => Pm, "σ₊" => Pp, "Pm" => Pm, "Pp" => Pp, "H" => H, "CNOT" => CNOT, "CPHASE" => CPHASE)              

@swagger """
"/register/{reg}/tag":
  post:
    summary: Create tags for registers
    description: Creates tags for the register `reg` that will be available while querying
    parameters:
        - in: path
          name: reg
          schema:
            type: integer
          required: true
          description: Register for the tagging operation
          example: 1

    responses:
      '201':
        description: Created the tags
"""
@post "/register/{reg}/tag" function(req::HTTP.Request, reg::Int)
  @info "Received request to add register tag"
  params = queryparams(req)
  slots = [parse(Int, s) for s in split(params["slots"], ",")]
  regrefs = [reg_net[reg, s] for s in slots]
  tagitems = split(params["tag"], ",")
  
  tag = []
  push!(tag, Symbol(tagitems[1])) 
  for item in tagitems[2:end]
    push!(tag, parse(Int, item))
  end

  for regref in regrefs
    tag!(regref, tag...)
  end
  
  return HTTP.Response(201)
end

@swagger """
"/register/{reg}/initialize":
  post:
    summary: Initialize the register slots
    description: Initialize the registers with a state
    parameters:
        - in: path
          name: reg
          schema:
            type: integer
          required: true
          description: Register for the initialize operation
          example: 1

    responses:
      '201':
        description: Initialized the slots
"""
@post "/register/{reg}/initialize" function (req::HTTP.Request, reg::Int)  
  @info "Received request to initialize register"
  params = queryparams(req)
  slots = [parse(Int, s) for s in split(params["slots"], ",")]
  regrefs = [reg_net[reg, s] for s in slots]
  
  if haskey(params, "state")
    state = statemap[params["state"]]
    for regref in regrefs 
      initialize!(regref, state)
    end
  else
    for regref in regrefs 
      initialize!(regref)
    end
  end

  return HTTP.Response(201)
end

@swagger """
"/register/{reg}/apply":
  post:
    summary: Apply an operation
    description: Applies the operator on registers
    parameters:
        - in: path
          name: reg
          schema:
            type: integer
          required: true
          description: Register for the apply operation
          example: 1

    responses:
      '201':
        description: Applied the operator
"""
@post "/register/{reg}/apply" function (req::HTTP.Request, reg::Int)
  @info "Received request to apply operation"
  params = queryparams(req)
  slots = [parse(Int, s) for s in split(params["slots"], ",")]
  regrefs = [reg_net[reg, s] for s in slots]
  operator = operatormap[params["operator"]]
  apply!(regrefs, operator)  
  return HTTP.Response(201)
end

@swagger """
"/time":
  get:
    summary: Returns the current system time
    description: Returns current system time in ISO 8601 format
    
    responses:
      '200':
        description: Successfully returned the system time
"""
@get "/time" function (req::HTTP.Request)
  @info "Received request to get time"
  response::Response{DateTime} = get_current_time()
  return response
end