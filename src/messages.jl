#
# This is part of YAActL.jl, 2020, P.Bayer, License MIT
#

"internal message `Become(f::Function, args...; kwargs...)` for behavior change."
struct Become <: Message
    f::Function
    args::Tuple
    kwargs::Base.Iterators.Pairs
end

"message `Stop()` causes an actor to stop."
struct Stop <: Message end

"""
    Request(x, u::Link)

A message to represent a request of `x` by customer `u`.
"""
struct Request{T} <: Message
    x::T
    u::Link
end

"""
    Response(y)

A message to represent a response of `y` to a request.
"""
struct Response{T} <: Message
    y::T
end
