struct CreateRegisterRequest
  request_id::String
  registers::Vector{Int}
end

struct Response{T}
  status::Symbol
  data::T
  message::String
  code::Int
end

abstract type Request end

struct ApplyRegisterRequest
  reg_idx::Int 
  slot_idx::Int 
end

struct ApplyRequest <: Request
  registers::Vector{ApplyRegisterRequest}
  operator::Symbol
end

struct TagRegisterRequest
  reg_idx::Int 
  slot_idx::Int 
  tag::Vector{Union{Symbol, Int}}
end

struct TagRequest <: Request
  registers::Vector{TagRegisterRequest}
end

struct InitializeRegisterRequest
  reg_idx::Int 
  slot_idx::Int 
  state::Union{Nothing,String}
end

struct InitializeRequest <: Request
  registers::Vector{InitializeRegisterRequest}
end
