using Oxygen
using Oxygen: html
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
  
  notify(obs)
  return HTTP.Response(201)
end

@swagger """
"/register/{reg}/untag":
  post:
    summary: Remove tags from register slots
    description: Finds and removes tags (untag) for the register `reg` 
    parameters:
        - in: path
          name: reg
          schema:
            type: integer
          required: true
          description: Register for the untagging operation
          example: 1

    responses:
      '201':
        description: Untagged the register slots
"""
@post "/register/{reg}/untag" function(req::HTTP.Request, reg::Int)
  @info "Received request to untag a register"
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
    untag!(regref, Tag(tag...))
  end
  
  notify(obs)
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

  notify(obs)
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
  notify(obs)
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
  current_time = now()
  return current_time
end

@swagger """
"/register/{reg}/traceout":
  post:
    summary: Delete the register slots state
    description: Delete the given slots of the given register
    parameters:
        - in: path
          name: reg
          schema:
            type: integer
          required: true
          description: Register for the traceout operation
          example: 1

    responses:
      '201':
        description: Successfully deleted the register slots
"""
@post "/register/{reg}/traceout" function (req::HTTP.Request, reg::Int)  
  @info "Received request to initialize register"
  params = queryparams(req)
  slots = [parse(Int, s) for s in split(params["slots"], ",")]
  regrefs = [reg_net[reg, s] for s in slots]
  traceout!(regrefs...)
  notify(obs)
  return HTTP.Response(201)
end

@swagger """
"/register/{reg}/project-traceout":
  post:
    summary: Projective traceout on the register slots
    description: Does a projective traceout on the register slots to the given basis
    parameters:
        - in: path
          name: reg
          schema:
            type: integer
          required: true
          description: Register for the project-traceout operation
          example: 1

    responses:
      '201':
        description: Projective traceout the register slots
"""
@post "/register/{reg}/project-traceout" function(req::HTTP.Request, reg::Int)
  @info "Received request to project-traceout register"
  params = queryparams(req)
  slots = [parse(Int, s) for s in split(params["slots"], ",")]
  regrefs = [reg_net[reg, s] for s in slots]
  basis = [statemap[s] for s in split(params["basis"], ",")]
  
  for regref in regrefs
    project_traceout!(regref, basis)
  end
  notify(obs)
  return HTTP.Response(201)
end


@swagger """
"/register/{reg}/queryall":
  get:
    summary: Query the register to find all slots with the tags
    description: Finds all the slots in the given register `reg` with the given tags
    parameters:
        - in: path
          name: reg
          schema:
            type: integer
          required: true
          description: Register for the queryall operation
          example: 1

    responses:
      '200':
        description: Returns all slots with the given tag
"""
@get "/register/{reg}/queryall" function(req::HTTP.Request, reg::Int)
  @info "Received request to queryall register"
  params = queryparams(req)
  tagitems = split(params["tag"], ",")

  idx = 1
  query_items = []
  for tag in tagitems
    if idx == 1
      push!(query_items, Symbol(tag))
    else
      if tag == "?" || tag == "W"
        push!(query_items, ❓)
      elseif tag[1] == '<'
        push!(query_items, <(parse(Int, tag[2:end])))
      elseif tag[1] == '>'
        push!(query_items, >(parse(Int, tag[2:end])))
      else
        push!(query_items, parse(Int, tag))
      end
    end
    idx += 1
  end
  
  result = queryall(reg_net[reg], query_items...)
  slots = [res.slot.idx for res in result]
  return HTTP.Response(200, ["Content-Type" => "application/json"], body=JSON3.write(Dict("slots" => slots)))
end

@swagger """
"/register/{reg}/query":
  get:
    summary: Query the register to find the first slot with the tags
    description: Finds the first slot in the given register `reg` with the given tags
    parameters:
        - in: path
          name: reg
          schema:
            type: integer
          required: true
          description: Register for the queryall operation
          example: 1

    responses:
      '200':
        description: Returns the first slots with the given tag
"""
@get "/register/{reg}/query" function(req::HTTP.Request, reg::Int)
  @info "Received request to query register"
  params = queryparams(req)
  tagitems = split(params["tag"], ",")

  idx = 1
  query_items = []
  for tag in tagitems
    if idx == 1
      push!(query_items, Symbol(tag))
    else
      if tag == "?" || tag == "W" 
        push!(query_items, ❓)
      elseif tag[1] == '<'
        push!(query_items, <(parse(Int, tag[2:end])))
      elseif tag[1] == '>'
        push!(query_items, >(parse(Int, tag[2:end])))
      else
        push!(query_items, parse(Int, tag))
      end
    end
    idx += 1
  end
  
  result = query(reg_net[reg], query_items...)
  response = isnothing(result) ? nothing : result.slot.idx
  return HTTP.Response(200, ["Content-Type" => "application/json"], body=JSON3.write(Dict("slot" => response)))
end

@swagger """
"/register/{reg}/channel":
  post:
    summary: Send a classical message from register `reg`
    description: Sends a classical message from register `reg`
    parameters:
        - in: path
          name: reg
          schema:
            type: integer
          required: true
          description: Source Register for the classical message
          example: 1

    responses:
      '201':
        description: Successfully send the message
"""
@post "/register/{reg}/channel" function (req::HTTP.Request, reg::Int)  
  @info "Received request to send a classical message from register"
  params = queryparams(req)
  # slots = [parse(Int, s) for s in split(params["slots"], ",")]
  # regrefs = [reg_net[reg, s] for s in slots]
  dest = parse(Int64, params["dest"])
  tagitems = split(params["tag"], ",")
  tag = []
  push!(tag, Symbol(tagitems[1])) 
  for item in tagitems[2:end]
    push!(tag, parse(Int, item))
  end

  put!(channel(reg_net, reg=>dest), Tag(tag...))
  return HTTP.Response(201)
end

@swagger """
"/register/{reg}/channel":
  get:
    summary: Retrieve a classical message from destination register `reg`
    description: Retrieves the classical message from register `reg` by using query on the assosiated message buffer
    parameters:
        - in: path
          name: reg
          schema:
            type: integer
          required: true
          description: Destination register for the classical message
          example: 1

    responses:
      '201':
        description: Successfully send the message
"""
@get "/register/{reg}/channel" function (req::HTTP.Request, reg::Int)  
  @info "Received request to retrieve a classical message from register"
  params = queryparams(req)
  tagitems = split(params["tag"], ",")
  
  idx = 1
  query_items = []
  for tag in tagitems
    if idx == 1
      push!(query_items, Symbol(tag))
    else
      if tag == "?" || tag == "W" 
        push!(query_items, ❓)
      elseif tag[1] == '<'
        push!(query_items, <(parse(Int, tag[2:end])))
      elseif tag[1] == '>'
        push!(query_items, >(parse(Int, tag[2:end])))
      else
        push!(query_items, parse(Int, tag))
      end
    end
    idx += 1
  end

  mb = messagebuffer(reg_net, reg)
  run(get_time_tracker(reg_net))
  result = query(mb, query_items...)
  return HTTP.Response(200, body=JSON3.write(result))
end

@swagger """
"/plot":
  get:
    summary: Plot a view of the register network
    description: Plots the register network and returns html for it

    responses:
      '200':
        description: Successfully received the plot
"""
@get "/plot" function (req::HTTP.Request)  
  @info "Received request to plot the register network"
  return html(f)
end