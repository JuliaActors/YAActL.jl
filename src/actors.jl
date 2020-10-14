#
# This file is part of the YAActL.jl Julia package, MIT license
#
# Paul Bayer, 2020
#

"""
    _ACT(lk::LINK)

Internal actor status variable.

# Fields

1. `dsp::Dispatch`: dispatch mode,
2. `sta::Tuple`: the actor's status variable,
3. `res::Tuple`: the result of the last behavior execution,
4. `bhv::Func` : the behavior function and its internal arguments,
5. `init::Func`: the init function and its arguments,
6. `term::Func`: the terminate function and its arguments,
7. `link::LINK`: the actors (local or remote) link.

see also: [`Dispatch`](@ref), [`Func`](@ref), [`LINK`](@ref)
"""
mutable struct _ACT
    dsp::Dispatch   
    sta::Any
    res::Any
    bhv::Func
    init::Union{Nothing,Func}
    term::Union{Nothing,Func}
    link::LINK

    _ACT(lk::LK) where LK<:LINK = 
        new(full, nothing, nothing, Func(), nothing, nothing, lk)
end

_terminate!(A::_ACT, code) = !isnothing(A.term) && A.term.f((A.term.args..., code)...; kwargs...)

# actor dispatch on messages
_act(A::_ACT, msg::Set)    = _act(A, msg, msg.x)
_act(A::_ACT, msg::Become) = A.bhv = msg.x
_act(A::_ACT, msg::Exec)   = send!(msg.from, Response(msg.func.f(msg.func.args...; msg.func.kwargs...), A.link))
_act(A::_ACT, msg::Update) = _act(A, msg, Val(msg.s))
_act(A::_ACT, msg::Query)  = _act(A, msg, Val(msg.x))
_act(A::_ACT, msg::Diag)   = send!(msg.from, Response(A, A.link))
function _act(A::_ACT, msg::Init)
    A.init = msg.x
    A.sta  = A.init.f(A.init.args...; A.init.kwargs...)
end
_act(A::_ACT, msg::Stop) = _terminate!(A, msg.x)
_act(A::_ACT, msg::M) where M<:Message = _act(A, Val(A.dsp), msg)

# dispatch on Query message
_act(A::_ACT, msg::Query, ::Val{:sta}) = send!(msg.from, Response(A.sta, A.link))
_act(A::_ACT, msg::Query, ::Val{:res}) = send!(msg.from, Response(A.res, A.link))
_act(A::_ACT, msg::Query, ::Val{:bhv}) = send!(msg.from, Response(A.bhv.f, A.link))
_act(A::_ACT, msg::Query, ::Val{:dsp}) = send!(msg.from, Response(A.dsp, A.link))
_act(A::_ACT, msg::Query, x) = send!(msg.from, Response("$x not available", A.link))

# dispatch on Update message
_act(A::_ACT, msg::Update, ::Val{:sta}) = A.sta = msg.x
_act(A::_ACT, msg::Update, ::Val{:dsp}) = A.dsp = msg.x
_act(A::_ACT, msg::Update, ::Val{:lnk}) = A.link = msg.x
_act(A::_ACT, msg::Update, ::Val{:arg}) =
    A.bhv = Func(A.bhv.f, msg.x.args...;
        pairs((; merge(A.bhv.kwargs, msg.x.kwargs)...))...)
_act(A::_ACT, msg::Update, x) = nothing

_tuple(x) = applicable(length, x) ? Tuple(x) : (x,)

# dispatch on Call message
function _act(A::_ACT, ::Val{full}, msg::Call)
    res = A.bhv.f((A.bhv.args..., msg.x...)...; A.bhv.kwargs...)
    A.res = res
    send!(msg.from, Response(res, A.link))
end
function _act(A::_ACT, ::Val{state}, msg::Call)
    res = A.bhv.f((A.sta, msg.x...)...; A.bhv.kwargs...)
    A.res = res
    !isnothing(res) && (A.sta = A.res)
    send!(msg.from, Response(res, A.link))
end
# dispatch on Cast message
function _act(A::_ACT, ::Val{full},  msg::Cast)
    res = A.bhv.f((A.bhv.args..., msg.x...)...; A.bhv.kwargs...)
    A.res = res
end
function _act(A::_ACT, ::Val{state}, msg::Cast)
    res = A.bhv.f((A.sta, msg.x...)...; A.bhv.kwargs...)
    A.res = res
    !isnothing(res) && (A.sta = A.res)
end
# dispatch on other user defined messages
function _act(A::_ACT, ::Val{full}, msg::M) where M<:Message
    res = A.bhv.f((A.bhv.args..., msg)...; A.bhv.kwargs...)
    A.res = res
end
function _act(A::_ACT, ::Val{state}, msg::M) where M<:Message
    res = A.bhv.f((A.sta, msg)...; A.bhv.kwargs...)
    A.res = res
    !isnothing(res) && (A.sta = A.res)
end

# this is the actor loop
function _act(lk::Link)
    A = _ACT(lk)
    task_local_storage("ACT",A)
    while true
        msg = take!(lk)
        _act(A, msg)
        msg isa Stop && break
        yield()
    end
end

"""
```
Actor([lp::LinkParams], bhv::Function, args1...; kwargs...)
Actor(pid::Int, bhv::Function, args1...; kwargs...)
```
Create a new actor. Start a task listening to messages `msg` 
sent over the returned link and executing `bhv(args1..., msg; kwargs...)` 
for each message. The actor stops if sent [`Stop()`](@ref).

# Arguments
- `[lp::LinkParams]`: parameters for creating the actor,
- `pid::Int`: process `pid` to create the actor on, this can 
    also be given with `lp`,
- `bhv`: a function implementing the actor's behavior,
- `args1...`: first arguments to `bhv` (without possible `msg` arguments),
- `kwargs...`: keyword arguments to `bhv`.

# Returns
- a [`Link`](@ref) to a locally created actor or 
- an [`RLink`](@ref) to a remote actor.

see also: [`LinkParams`](@ref)
"""
function Actor(lp::LinkParams, bhv::F, args::Vararg{Any, N}; kwargs...) where {F<:Function,N}
    if lp.pid == myid()
        lk = Link(_act, lp.size, taskref=lp.taskref, spawn=lp.spawn)
    else
        lk = RemoteChannel(()->Link(_act, lp.size, taskref=lp.taskref, spawn=lp.spawn), lp.pid)
        update!(lk, lk, s=:lnk) # set its link entry to remote
    end
    become!(lk, bhv, args...; kwargs...)
    return lk
end
Actor(bhv::F, args...; kwargs...) where {F<:Function} =
    Actor(LinkParams(), bhv, args..., kwargs...)
Actor(pid::Int, bhv::F, args...; kwargs...) where {F<:Function} =
    Actor(LinkParams(pid), bhv, args..., kwargs...)

"""
    become(bhv::Function, args...; kwargs...)

Cause your actor to take on a new behavior. This can only be
called from inside an actor/behavior.

# Arguments
- `bhv::Function`: function implementing the new behavior,
- `args...`: arguments to `bhv` (without `msg`),
- `kwargs...`: keyword arguments to `bhv`.
"""
function become(bhv::F, args::Vararg{Any, N}; kwargs...) where {F<:Function,N}
    act = task_local_storage("ACT")
    act.bhv = Func(bhv, args...; kwargs...)
end

"""
    stop(code=0)

Cause your actor to exit with `code`.
"""
stop(code=0) = send!(_self(), Stop(code))
