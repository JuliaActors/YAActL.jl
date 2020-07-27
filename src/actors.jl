
# implements the actor loop
function act(ch::Link)
    B = Become(+,(),Base.Iterators.pairs(()))
    while true
        msg = take!(ch)
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
Actor([lp::LinkParams], bhv::F, args::Vararg{Any, N}; kwargs...) where {F<:Function,N}
```
Create a new actor. Start a task executing repeatedly the behavior `bhv`. The actor
listens to messages `msg` sent over the returned link and executes
`bhv(args..., self, msg, kwargs)` for each message. The actor stops if sent `Stop()`.

# Arguments
- `[lp::LinkParams]`: optional parameters for creating the link,
- `bhv::Function`: function implementing the actor's behavior,
- `args...`: arguments to `bhv`, (without `msg`)
- `kwargs...`: keyword arguments to `bhv`.

return a link to the created actor, a `Channel{Message}` object.
"""
function Actor(lp::LinkParams, bhv::F, args::Vararg{Any, N}; kwargs...) where {F<:Function,N}
    ch = Channel{Message}(act, lp.size, taskref=lp.taskref, spawn=lp.spawn)
    yield()
    become!(ch, bhv, args..., kwargs...)
    return ch
end
Actor(bhv::F, args::Vararg{Any, N}; kwargs...) where {F<:Function,N} =
    Actor(LinkParams(), bhv, args..., kwargs...)

"""
    send!(lnk::Link, m::Message)
Send a message `m` to an actor over a link `lnk`.
"""
send!(lnk::Link, m::Message) = (put!(lnk, m); yield())

"""
    become!(lnk::Link, bhv::Function, args...; kwargs...)

Cause another actor to assume a new behavior.

# Arguments
- `lnk::Link`: Link to an actor,
- `bhv::Function`: function implementing the new behavior,
- `args...`: arguments to `bhv` (without `msg`),
- `kwargs...`: keyword arguments to `bhv`.
"""
become!(lnk::Link, bhv::F, args::Vararg{Any, N}; kwargs...) where {F<:Function,N} =
    send!(lnk, Become(bhv, args, kwargs))

"""
    become(bhv::Function, args...; kwargs...)

Cause yourself to take on a new behavior. Called from inside an actor/behavior.

# Arguments
- `bhv::Function`: function implementing the new behavior,
- `args...`: arguments to `bhv` (without `msg`),
- `kwargs...`: keyword arguments to `bhv`.
"""
become(bhv::F, args::Vararg{Any, N}; kwargs...) where {F<:Function,N} =
    pushfirst!(current_task().code.chnl.data, Become(bhv, args, kwargs))
