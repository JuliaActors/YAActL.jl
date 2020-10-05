#
# This file is part of the YAActL.jl Julia package, MIT license
#
# Paul Bayer, 2020
#

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
    request!(lk::LINK, Msg::Type{<:Message}, args...; full=false)

Send a message of type `Msg` with optional `args...` to an 
actor over a given [`LINK`](@ref) `lk`, block, receive and 
return the result.

If `full==true` return the full [`Response`](@ref) message.
"""
function request!(lk::LK, Msg::Type{<:Message}, args...; full=false) where LK<:LINK
    me = lk isa Link ? Link(1) : RemoteChannel(()->Link(1))
    send!(lk, isempty(args) ? Msg(me) : Msg(args, me))
    resp = take!(me)
    if full
        return resp
    elseif resp.y isa Tuple
        return length(resp.y) == 1 ? resp.y[1] : resp.y
    else
        return resp.y
    end
end

matches(msg::M, ::Nothing, ::Nothing) where M<:Message = true
matches(msg::M, Msg::Type{<:Message}, ::Nothing) where M<:Message = msg isa Msg
matches(msg::M, ::Nothing, from::LK) where {M<:Message,LK<:LINK} = msg.from == from
matches(msg::M, Msg::Type{<:Message}, from::LK) where {M<:Message,LK<:LINK} = msg isa Msg && msg.from == from

"""
```
receive!(lk; timeout=5.0)
receive!(lk, from; timeout=5.0)
receive!(lk, Msg; timeout=5.0)
receive!(lk, Msg, from; timeout=5.0)
```
Receive a message over a link `lk`.

If `Msg` or `from` are provided, `receive!` returns only a 
matching message.

# Parameters
- `lk::LINK`: local or remote link over which the message is sent,
- `Msg::Type{<:Message}`: [`Message`](@ref) type,
- `from::LINK`: local or remote link of sender,
- `timeout::Real`: maximum waiting time in seconds.

# Returns
- received message or `Timeout()`.
"""
receive!(lk::LK; kwargs...) where LK<:LINK = receive!(lk, nothing, nothing; kwargs...)
receive!(lk::L1, from::L2; kwargs...) where {L1<:LINK,L2<:LINK} = receive!(lk, nothing, from; kwargs...)
receive!(lk::LK, Msg::Type{<:Message}; kwargs...) where LK<:LINK = receive!(lk, Msg, nothing; kwargs...)
function receive!(lk::L1, Msg::M, from::L2; 
    timeout::Real=5.0) where {L1<:LINK,M<:Union{Nothing,Type{<:Message}},L2<:Union{Nothing,LINK}}

    done = [false]
    msg = Timeout()
    stash = Message[]
    ev = Base.Event()
    timeout > 0 && Timer(x->notify(ev), timeout)

    @async begin
        while !done[1]
            timeout == 0 && !isready(lk) && break
            matches(fetch(lk), Msg, from) && break
            push!(stash, take!(lk))
        end
        notify(ev)
    end
    yield()
    wait(ev)
    done[1] = true
    isready(lk) && (msg = take!(lk))
    while !isempty(stash) && isready(lk)
        push!(stash, take!(lk))
    end
    foreach(x->put!(lk,x), stash)
    return msg
end
