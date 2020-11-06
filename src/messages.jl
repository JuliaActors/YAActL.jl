#
# This file is part of the YAActL.jl Julia package, MIT license
#
# Paul Bayer, 2020
#

"""
    Func(f, args...; kwargs...)

A structure for passing a function `f` and its arguments
to an actor.
"""
struct Func{X,Y,Z}
    f::X
    args::Y
    kwargs::Z

    Func(f::F, args...; kwargs...) where F<:Function =
        new{typeof(f),typeof(args),typeof(kwargs)}(f, args, kwargs)
    Func() = new{typeof(+),typeof(()),typeof(pairs(()))}(+,(),pairs(()))
end

"""
    Args(args...; kwargs...)

A structure for updating arguments to an actor's behavior.
"""
struct Args{A,B}
    args::A
    kwargs::B

    Args(args...; kwargs...) = new{typeof(args),typeof(kwargs)}(args, kwargs)
end

"""
    Become(x::Func)

An asynchronous [`Message`](@ref) to an actor to change its 
behavior.
"""
struct Become <: Message
    x::Func
end

"""
    Call(arg, from::Link)

A synchronous [`Message`](@ref) to an actor to execute its 
behavior with `arg...` and to send the result as a [`Response`](@ref) 
message to `from`.

If the actor is set to `state` dispatch, it updates its internal 
state with the result. 
"""
struct Call <: Message
    x
    from::Link
end
Call(from) = Call((),from)

"""
    Cast(arg)

An asynchronous [`Message`](@ref) to an actor to execute 
its behavior with `arg...` without sending a response.

If the actor is set to `state` dispatch, it updates its internal 
state with the result. 
"""
struct Cast <: Message
    x
end
Cast() = Cast(())

"""
    Diag(from::Link)

A synchronous [`Message`](@ref) to an actor to send a 
`Response` message with its internal `_ACT` variable to `from`.
"""
struct Diag <: Message 
    from::Link
end

"""
    Exec(func::Func, from::Link)

A synchronous [`Message`](@ref) to an actor to execute `func`
and to send a `Response` message with the return value to `from`.
"""
struct Exec <: Message
    func
    from::Link
end

"""
    Init(f::Func)

A [`Message`](@ref) to an actor to execute the given
[`Func`](@ref) and to register it in the [`_ACT`](@ref)
variable.
"""
struct Init <: Message
    x::Func
end

"""
    Query(s::Symbol, from::Link)

A [`Message`](@ref) to an actor to send a 
`Response` message with one of its internal state 
variables `s` to `from`.

- `s::Symbol` can be one of `:sta`, `:res`, `:bhv`, `:dsp`.
"""
struct Query <: Message
    x::Symbol
    from::Link
end

"""
    Request(x, from::Link)

A generic [`Message`](@ref) for user requests.
"""
struct Request <: Message
    x
    from::Link
end

"""
    Response(y, from::Link=self())

A [`Message`](@ref) representing a response to requests.

# Fields
- `y`: response content,
- `from::Link`: sender link.
"""
struct Response <: Message
    y
    from::Link
end
Response(y) = Response(y, self())

"""
    Stop(code=0)

A [`Message`](@ref) causing an actor to stop with an exit
`code`. If present, it calls its [`term!`](@ref) function with
`code` as last argument.
"""
struct Stop <: Message 
    x::Int
end
Stop() = Stop(0)

"""
    Term(x::Func)

A [`Message`](@ref) to an actor to save the given [`Func`](@ref) 
and to execute it upon termination.
"""
struct Term <: Message
    x::Func
end

"""
    Timeout()

A return value to signal that a timeout has occurred.
"""
struct Timeout <: Message end

"""
    Update(s::Symbol, x)

An asynchronous [`Message`](@ref) to an actor to update its 
internal state `s` to `x`.

- `s::Symbol` can be one of `:sta`, `:dsp`, `:arg`, `:lnk`.
"""
struct Update <: Message
    s::Symbol
    x
end
