using Oxygen
using HTTP
using Distributed
using UUIDs
using StructTypes
using JSON3
using QuantumSavory

struct CreateRegisterRequest
  request_id::String
  registers::Vector{Int}
end

dict = Dict()

# StructTypes.StructType(::Type{RegisterNet}) = StructTypes.Struct()

function worker(id, channel)
  while true
      data = take!(channel)
      if data == :end
          println("Worker $id exiting.")
          break
      else
          println("Worker $id received: $data")
      end
  end
end

# for i in 2:4
#   c = @spawn worker(i, RemoteChannel(()->Channel()))
#   println(c)
# end

# channels = [fetch(@spawnat i getfield(Main, :channel)) for i in 2:4]

# for (i, channel) in enumerate(channels)
#     put!(channel, "Hello from process 1 to worker $i")
# end

@get "/id" function(req::HTTP.Request)
  new_request_id = uuid1()
  return new_request_id
end

@post "/register/create" function(req::HTTP.Request)
  create_register = json(req, CreateRegisterRequest)
  register_vector::Vector{Register} = []
  for c in create_register.registers
    push!(register_vector, Register(c))
  end

  @info "Register Vector:"
  println(register_vector)
  
  net = RegisterNet(register_vector)
  @info "Register Net: " 
  @info net

  dict[create_register.request_id] = net
  # f = Figure()
  # _,_,_,obs = registernetplot_axis(f[1,1], net)
  
  return "Success!"
end

@get "/requests/active" function (req::HTTP.Request)
  @info dict
  return HTTP.Response(200)
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

@patch "/register/tag" function(req::HTTP.Request)
  tags = json(req, TagRequestList)
  if !haskey(dict, tags.request_id)
    return HTTP.Response(400)
  end

  net = dict[tags.request_id]
  for tag in tags.tags
    # tag = tags[i]
    tag!(net[tag.register, tag.slot], :symbol, tag.tag)
  end

  return "Success!"
end

# Todo query

# @post "/one" function(req::HTTP.Request)   
#   return fetch(req.body)
# end

# @get "/two" function(req::HTTP.Request)
#   return p
# end
