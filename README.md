# Quantum Savory Server

A user-friendly server providing a RESTful Api interface for a model quantum testbed simulator ([QuantumSavory.jl](https://github.com/QuantumSavory/QuantumSavory.jl))

## Code structure

\- `src` <br>
&emsp;\- `controller`<br>
&emsp;&emsp;\- `Controller.jl` - the available API endpoints for the simulator<br> 
&emsp;\- `service`<br>
&emsp;&emsp;\- `Service.jl` - contains the methods for each endpoint<br>
&emsp;\- `utils`<br>
&emsp;&emsp;\- `Constants.jl` - contains frequently used constants<br>
&emsp;\- `Config.toml` - server configuration <br> 
&emsp;\- `app.jl` - starting point of the application


# Setting up the server
Clone the repository to local
```bash
> git clone git@github.com:krishna-praneet/QuantumSavoryServer.git
```

Inside the downloaded folder, run
```bash
> julia --project src/app.jl 
```

or if using julia REPL in package mode
```bash
pkg> activate .
julia> include("src/App.jl")
```
You should be able to see the following 
```bash
   ____                            
  / __ \_  ____  ______ ____  ____ 
 / / / / |/_/ / / / __ `/ _ \/ __ \
/ /_/ />  </ /_/ / /_/ /  __/ / / /
\____/_/|_|\__, /\__, /\___/_/ /_/ 
          /____//____/   

[ Info: 📦 Version 1.4.9 (2024-02-07)
[ Info: ✅ Started server: http://0.0.0.0:8080
[ Info: 📖 Documentation: http://0.0.0.0:8080/docs
[ Info: 📊 Metrics: http://0.0.0.0:8080/docs/metrics
[ Info: Listening on: 0.0.0.0:8080, thread id: 1
```

The server should start at `http://0.0.0.0:8080`

# Running the APIs
The Swagger documentation for the server is available at `http://0.0.0.0:8080/docs` which displays a list of available endpoints and examples. 