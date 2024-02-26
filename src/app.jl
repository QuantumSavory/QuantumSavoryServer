using Oxygen
using HTTP

include("controller/Controller.jl")
include("service/Service.jl")


# start the web server
serve(port=8000)