#
# This is part of YAActL.jl, 2020, P.Bayer, License MIT
#

"`Become(f::Function, args...; kwargs...)`: internal message for behavior change."
struct Become <: Message
    f::Function
    args::Tuple
    kwargs::Base.Iterators.Pairs
end

"`Stop()`: a message causing an actor to stop."
struct Stop <: Message end

"`Request(x, u::Link)`: a message representing a request of `x` by customer `u`."
struct Request{T} <: Message
    x::T
    u::Link
end

"`Response(y)`: a message representing a response of `y` to a request."
struct Response{T} <: Message
    y::T
end
