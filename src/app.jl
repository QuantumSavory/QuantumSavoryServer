using Oxygen
using HTTP
import TOML

include("Controller.jl")
include("Constants.jl")
include("Model.jl")


config = TOML.parsefile(SERVER_CONFIG_PATH)

const reg_net = RegisterNet([Register(3), Register(4), Register(3)])

# start the web server
serve(host=config[SERVER][HOST], port=config[SERVER][PORT])  
