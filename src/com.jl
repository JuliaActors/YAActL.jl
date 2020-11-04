#
# This file is part of the YAActL.jl Julia package, MIT license
#
# Paul Bayer, 2020
#

function _send!(chn::Channel, m::Message)
    # reimplements Base.put_buffered with a modification
    lock(chn)
    try
        while length(chn.data) ≥ chn.sz_max  # modification: allow buffer overflow
            Base.check_channel_state(chn)
            wait(chn.cond_put)
        end
        push!(chn.data, m)
        # notify all, since some of the waiters may be on a "fetch" call.
        notify(chn.cond_take, nothing, true, false)
    finally
        unlock(chn)
    end
    return m
end
function _send!(rch::RemoteChannel, m::Message)
    if rch.where != myid()
        # change any local links in m to remote links
        m = typeof(m)((_rlink(getfield(m,i)) for i in fieldnames(typeof(m)))...)
    end
    put!(rch, m)
end

"""
    send!(lk::Link, m::Message)

Send a message `m` to an actor over a [`Link`](@ref) `lk`.
"""
send!(lk::L, m::Message) where L<:Link = _send!(lk.chn, m)

# """
# ```
# send!(lks::Tuple{Link,Vararg{Link}}, m::M) where M<:Message
# send!(lks::Vector{Link}, m::M) where M<:Message
# ```
# Send a message `m` to a `Vector` or `Tuple` of [`Link`](@ref)s.
# """
# send!(lks::Tuple{Link,Vararg{Link}}, m::M) where M<:Message =
#     map(x->send!(x, m), lks)
# send!(lks::Vector{Link}, m::M) where M<:Message =
#     map(x->send!(x, m), lks)

_match(msg::Message, ::Nothing, ::Nothing) = true
_match(msg::Message, Msg::Type{<:Message}, ::Nothing) = msg isa Msg
_match(msg::Message, ::Nothing, from::Link) =
    :from in fieldnames(typeof(msg)) ? msg.from == from : false
function _match(msg::Message, Msg::Type{<:Message}, from::Link)
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
matching message. Other messages in `lk` are restored to it in their
previous order.

# Parameters
- `lk::Link`: local or remote link over which the message is received,
- `Msg::Type{<:Message}`: [`Message`](@ref) type,
- `from::Link`: local or remote link of sender. If `from` is
    provided, only messages with a `from` field can be matched.
- `timeout::Real=5.0`: maximum waiting time in seconds.
    - If `timeout==0`, `lk` is scanned only for existing messages.
    - Set `timeout=Inf` if you don't want to timeout. 

# Returns
- received message or `Timeout()`.
"""
receive!(lk::L; kwargs...) where L<:Link = receive!(lk, nothing, nothing; kwargs...)
receive!(lk::L, from::Link; kwargs...) where L<:Link = receive!(lk, nothing, from; kwargs...)
receive!(lk::L, Msg::Type{<:Message}; kwargs...) where L<:Link = receive!(lk, Msg, nothing; kwargs...)
function receive!(lk::L1, Msg::M, from::L2; 
    timeout::Real=5.0) where {L1<:Link,M<:Union{Nothing,Type{<:Message}},L2<:Union{Nothing,Link}}

    done = [false]
    msg = Timeout()
    stash = Message[]
    ev = Base.Event()
    timeout > 0 && !isinf(timeout) && Timer(x->notify(ev), timeout)

    @async begin
        while !done[1]
            timeout == 0 && !isready(lk.chn) && break
            _match(fetch(lk.chn), Msg, from) && break
            done[1] || push!(stash, take!(lk.chn))
        end
        notify(ev)
    end

    wait(ev)
    done[1] = true
    isready(lk.chn) && (msg = take!(lk.chn))
    while !isempty(stash) && isready(lk.chn)
        push!(stash, take!(lk.chn))
    end
    foreach(x->put!(lk.chn, x), stash)
    return msg
end

"""
```
request!(lk::Link, msg::Message; full=false, timeout::Real=5.0)
request!(lk::Link, Msg::Type{<:Message}, args...; kwargs...)
```
Send a message to an actor, block, receive and return the result.

# Arguments
- `lk::Link`: actor link,
- `msg::Message`: a message,
- `Msg::Type{<:Message}`: a message type,
- `args...`: optional arguments to `Msg`, 
- `full`: if `true` return the full [`Response`](@ref) message.
- `timeout::Real=5.0`: timeout in seconds after which a 
    [`Timeout`](@ref) is returned,
- `kwargs...`: `full` or `timeout`.

"""
function request!(lk::L, msg::Message; 
                full=false, timeout::Real=5.0) where L<:Link
    send!(lk, msg)
    resp = receive!(msg.from, timeout=timeout)
    return resp isa Timeout || full ? resp : resp.y
end
function request!(lk::L, Msg::Type{<:Message}, args...; kwargs...)  where L<:Link
    me = lk isa Link{Channel{Message}} ?
            Link(1) : 
            Link(RemoteChannel(()->Channel{Message}(1)), myid(), :remote)
    return Msg in (Exec, Query) ?
        request!(lk, Msg(args..., me); kwargs...) :
        request!(lk, isempty(args) ? Msg(me) : Msg(args, me); kwargs...)
end
