struct CreateRegisterRequest
  request_id::String
  registers::Vector{Int}
end

struct Response{T}
  status::Symbol
  data::T
  message::Union{String, Exception}
  code::Int
end

abstract type Request end

struct RegisterRequest
  reg_idx::Int 
  slot_idx::Int 
  tag::Union{Nothing,Vector{Union{Symbol, Int}}}
  operation::Union{Nothing,String}
  state::Union{Nothing,String}
end

# TODO: operation::T where T <: QuantumInterface.AbstractSuperOperator
struct ApplyRequest <: Request
  registers::Vector{RegisterRequest}
  operation::String
end


struct TagRequest <: Request
  registers::Vector{RegisterRequest}
end

struct InitializeRequest <: Request
  registers::Vector{RegisterRequest}
end
