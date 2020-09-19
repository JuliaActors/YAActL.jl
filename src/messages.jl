#
# This file is part of the YAActL.jl Julia package, MIT license
#
# Paul Bayer, 2020
#

"""
    Become(f::Function, args...; kwargs...)

Internal message for behavior change.
"""
struct Become <: Message
    f::Function
    args::Tuple
    kwargs::Base.Iterators.Pairs
end

"""
    Stop()

A message causing an actor to stop.
"""
struct Stop <: Message end

"""
    Request(x, lk::LINK)

A message representing a request of `x` by customer `lk`.
"""
struct Request{T} <: Message
    x::T
    lk::LINK
end

"""
    Response(y)

A message representing a response of `y` to a request.
"""
struct Response{T} <: Message
    y::T
end
