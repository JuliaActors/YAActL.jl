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

_match(msg::M, ::Nothing, ::Nothing) where M<:Message = true
_match(msg::M, Msg::Type{<:Message}, ::Nothing) where M<:Message = msg isa Msg
function _match(msg::M, ::Nothing, from::LK) where {M<:Message,LK<:LINK} 
    :from in fieldnames(typeof(msg)) ? msg.from == from : false
end
function _match(msg::M, Msg::Type{<:Message}, from::LK) where {M<:Message,LK<:LINK}
    if :from in fieldnames(typeof(msg))
        return msg isa Msg && msg.from == from
    else
        return false
    end
end

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
- `from::LINK`: local or remote link of sender. Tf `from` is
    provided, only messages with a `from` field can be matched.
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
            _match(fetch(lk), Msg, from) && break
            done[1] || push!(stash, take!(lk))
        end
        notify(ev)
    end

    wait(ev)
    done[1] = true
    isready(lk) && (msg = take!(lk))
    while !isempty(stash) && isready(lk)
        push!(stash, take!(lk))
    end
    foreach(x->put!(lk,x), stash)
    return msg
end

"""
```
request!(lk::LINK, msg::Message; full=false, timeout::Real=5.0)
request!(lk::LINK, Msg::Type{<:Message}, args...; kwargs...)
```
Send a message to an actor, block, receive and return the result.

# Arguments
- `lk::LINK`: actor link,
- `msg::Message`: a message,
- `Msg::Type{<:Message}`: a message type,
- `args...`: optional arguments to `Msg`, 
- `full`: if `true` return the full [`Response`](@ref) message.
- `timeout::Real=5.0`: timeout in seconds after which a 
    [`Timeout`](@ref) is returned,
- `kwargs...`: `full` or `timeout`.

"""
function request!(lk::LK, msg::M; full=false, timeout::Real=5.0) where {LK<:LINK,M<:Message}
    send!(lk, msg)
    resp = receive!(msg.from, timeout=timeout)
    if resp isa Timeout || full
        return resp
    elseif resp.y isa Tuple
        return length(resp.y) == 1 ? resp.y[1] : resp.y
    else
        return resp.y
    end
end
function request!(lk::LK, Msg::Type{<:Message}, args...; kwargs...) where LK<:LINK 
    me = lk isa Link ? Link(1) : RemoteChannel(()->Link(1))
    request!(lk, isempty(args) ? Msg(me) : Msg(args, me); kwargs...)
end
