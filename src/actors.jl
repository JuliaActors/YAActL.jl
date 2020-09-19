#
# This file is part of the YAActL.jl Julia package, MIT license
#
# Paul Bayer, 2020
#

# implements the actor loop
function act(lk::Link)
    B = Become(+,(),Base.Iterators.pairs(()))
    while true
        msg = take!(lk)
        if msg isa Become
            B = msg
        elseif msg isa Stop
            break
        else
            B.f((B.args..., msg)..., B.kwargs...)
        end
        yield()
    end
end

"""
```
Actor([lp::LinkParams], bhv::Function, args...; kwargs...)
Actor(pid::Int, bhv::Function, args...; kwargs...)
```
Create a new actor. Start a task executing repeatedly the behavior `bhv`. The actor
listens to messages `msg` sent over the returned link and executes
`bhv(args..., msg, kwargs)` for each message. The actor stops if sent `Stop()`.

# Arguments
- `[lp::LinkParams]`: optional parameters for creating the actor,
- `pid::Int`: create the actor on process `pid`,
- `bhv::Function`: function implementing the actor's behavior,
- `args...`: arguments to `bhv`, (without `msg`)
- `kwargs...`: keyword arguments to `bhv`.

# Returns
- a [`Link`](@ref) to a locally created actor or 
- an [`RLink`](@ref) to a remote actor.
"""
function Actor(lp::LinkParams, bhv::F, args::Vararg{Any, N}; kwargs...) where {F<:Function,N}
    if lp.pid == myid()
        lk = Link(act, lp.size, taskref=lp.taskref, spawn=lp.spawn)
    else
        lk = RemoteChannel(()->Link(act, lp.size, taskref=lp.taskref, spawn=lp.spawn), lp.pid)
    end
    become!(lk, bhv, args..., kwargs...)
    return lk
end
Actor(bhv::F, args...; kwargs...) where {F<:Function} =
    Actor(LinkParams(), bhv, args..., kwargs...)
Actor(pid::Int, bhv::F, args...; kwargs...) where {F<:Function} =
    Actor(LinkParams(pid), bhv, args..., kwargs...)

"""
    send!(lk::LINK, m::Message)

Send a message `m` to an actor over a [`LINK`](@ref) `lk`.
"""
function send!(lk::Link, m::M) where M<:Message
    # reimplements Base.put_buffered with a modification
    lock(lk)
    try
        while length(lk.data) ≥ lk.sz_max  # modification: allow buffer overflow
            Base.check_channel_state(lk)
            wait(lk.cond_put)
        end
        push!(lk.data, m)
        # notify all, since some of the waiters may be on a "fetch" call.
        notify(lk.cond_take, nothing, true, false)
    finally
        unlock(lk)
    end
    return m
end
send!(lk::RLink, m::M) where M<:Message = put!(lk, m)

"""
```
send!(lks::Tuple{LINK,Vararg{LINK}}, m::M) where M<:Message
send!(lks::Vector{LINK}, m::M) where M<:Message
```
Send a message `m` to a `Vector` or `Tuple` of [`LINK`](@ref)s.
"""
send!(lks::Tuple{LINK,Vararg{LINK}}, m::M) where M<:Message =
    map(x->send!(x, m), lks)
send!(lks::Vector{LINK}, m::M) where M<:Message =
    map(x->send!(x, m), lks)

"""
    become!(lk::LINK, bhv::Function, args...; kwargs...)

Cause another actor to assume a new behavior.

# Arguments
- `lk::Link`: Link to an actor,
- `bhv::Function`: function implementing the new behavior,
- `args...`: arguments to `bhv` (without `msg`),
- `kwargs...`: keyword arguments to `bhv`.
"""
become!(lk::LK, bhv::F, args::Vararg{Any, N}; kwargs...) where {LK<:LINK, F<:Function,N} =
    send!(lk, Become(bhv, args, kwargs))

"""
    self()

Get a local [`Link`](@ref) to yourself from inside an actor.
"""
self() = current_task().code.chnl :: Link

"""
    become(bhv::Function, args...; kwargs...)

Cause yourself to take on a new behavior. Called from inside an actor/behavior.

# Arguments
- `bhv::Function`: function implementing the new behavior,
- `args...`: arguments to `bhv` (without `msg`),
- `kwargs...`: keyword arguments to `bhv`.
"""
function become(bhv::F, args::Vararg{Any, N}; kwargs...) where {F<:Function,N}
    lk = self()
    lock(lk)
    try
        Base.check_channel_state(lk)
        pushfirst!(lk.data, Become(bhv, args, kwargs))
    finally
        unlock(lk)
    end
end

"`stopActor()`: an actor terminates."
stopActor() = send!(self(), Stop())

"`stopActor!(lk::LINK)`: terminate an actor with link `lk`."
stopActor!(lk::LK) where LK<:LINK = send!(lk, Stop())
