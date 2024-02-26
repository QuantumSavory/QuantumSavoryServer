using Oxygen
using HTTP
import TOML

include("controller/Controller.jl")
include("utils/Constants.jl")


config = TOML.parsefile(SERVER_CONFIG_PATH)

# start the web server
serve(host=config[SERVER][HOST], port=config[SERVER][PORT])  
