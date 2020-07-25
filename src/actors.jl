
# implements the actor loop
function act(ch::Link)
    bhv = Become(+,(),Base.Iterators.pairs(()))
    while true
        msg = take!(ch)
        if msg isa Become
            bhv = msg
        elseif msg isa Stop
            break
        else
            bhv.f(bhv.args..., bhv.kwargs...)
        end
    end
end

"""
```
Actor([lp::LinkParams], bhv::F, args::Vararg{Any, N}; kwargs...) where {F<:Function,N}
```
Create a new actor. Start a task executing the behavior `bhv` and return a link
to it.

# Arguments
- `[lp::LinkParams]`: optional parameters for creating the link,
- `bhv::Function`: function implementing the actor's behavior,
- `args...`: arguments to `bhv`,
- `kwargs...`: keyword arguments to `bhv`.
"""
function Actor(lp::LinkParams, bhv::F, args::Vararg{Any, N}; kwargs...) where {F<:Function,N}
    ch = Channel{Message}(act, lp.size, taskref=lp.taskref, spawn=lp.spawn)
    become!(ch, bhv, args..., kwargs...)
    return ch
end
Actor(bhv::F, args::Vararg{Any, N}; kwargs...) where {F<:Function,N} =
    Actor(LinkParams(), bhv, args..., kwargs...)

"Send a message `m` to an actor over a link `lnk`."
send!(lnk::Link, m::Message) = put!(lnk, m)

"""
    become!(lnk::Link, bhv::F, args::Vararg{Any, N}; kwargs...) where {F<:Function,N}

Cause an actor to assume a new behavior.

# Arguments
- `lnk::Link`: Link to an actor,
- `bhv::Function`: function implementing the new behavior,
- `args...`: arguments to `bhv`,
- `kwargs...`: keyword arguments to `bhv`.
"""
become!(lnk::Link, bhv::F, args::Vararg{Any, N}; kwargs...) where {F<:Function,N} =
    send!(lnk, Become(bhv, args, kwargs))
