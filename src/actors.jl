#
# This is part of YAActL.jl, 2020, P.Bayer, License MIT
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
```
Create a new actor. Start a task executing repeatedly the behavior `bhv`. The actor
listens to messages `msg` sent over the returned link and executes
`bhv(args..., msg, kwargs)` for each message. The actor stops if sent `Stop()`.

# Arguments
- `[lp::LinkParams]`: optional parameters for creating the actor,
- `bhv::Function`: function implementing the actor's behavior,
- `args...`: arguments to `bhv`, (without `msg`)
- `kwargs...`: keyword arguments to `bhv`.

return a [`Link`](@ref) to the created actor, a `Channel{Message}` object.
"""
function Actor(lp::LinkParams, bhv::F, args::Vararg{Any, N}; kwargs...) where {F<:Function,N}
    lk = Link(act, lp.size, taskref=lp.taskref, spawn=lp.spawn)
    become!(lk, bhv, args..., kwargs...)
    return lk
end
Actor(bhv::F, args::Vararg{Any, N}; kwargs...) where {F<:Function,N} =
    Actor(LinkParams(), bhv, args..., kwargs...)

"""
    send!(lk::Link, m::Message)

Send a message `m` to an actor over a link `lk`.
"""
function send!(lk::Link, m::M) where {M<:Message}
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

"""
```
send!(lks::Tuple{Link,Vararg{Link}}, m::M) where M<:Message
send!(lks::Vector{Link}, m::M) where M<:Message
```
Send a message `m` to a `Vector` or `Tuple` of `Link`s.
"""
send!(lks::Tuple{Link,Vararg{Link}}, m::M) where M<:Message =
    map(x->send!(x, m), lks)
send!(lks::Vector{Link}, m::M) where M<:Message =
    map(x->send!(x, m), lks)

"""
    become!(lk::Link, bhv::Function, args...; kwargs...)

Cause another actor to assume a new behavior.

# Arguments
- `lk::Link`: Link to an actor,
- `bhv::Function`: function implementing the new behavior,
- `args...`: arguments to `bhv` (without `msg`),
- `kwargs...`: keyword arguments to `bhv`.
"""
become!(lk::Link, bhv::F, args::Vararg{Any, N}; kwargs...) where {F<:Function,N} =
    send!(lk, Become(bhv, args, kwargs))

"""
    self()
Get a [`Link`](@ref) to yourself from inside an actor.
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

"`stop()`: an actor terminates."
stopActor() = send!(self(), Stop())

"`stop!(lk::Link)`: terminate an actor with link `lk`."
stopActor!(lk::Link) = send!(lk, Stop())
