#
# This file is part of the YAActL.jl Julia package, MIT license
#
# Paul Bayer, 2020
#

"""
    become!(lk::LINK, bhv::Function, args...; kwargs...)

Cause an actor to switch its behavior.

# Arguments
- `lk::Link`: Link to an actor,
- `bhv::Function`: function implementing the new behavior,
- `args...`: arguments to `bhv` (without `msg`),
- `kwargs...`: keyword arguments to `bhv`.
"""
become!(lk::LK, bhv::F, args::Vararg{Any, N}; kwargs...) where {LK<:LINK, F<:Function,N} =
    send!(lk, Become(Func(bhv, args...; kwargs...)))

"""
    call!(lk::LINK, [from::LINK], args...)

Call the `lk` actor`s behavior function with `args...` and get
a [`Response`](@ref) to the `from` channel. If `from` is 
omitted, `call` **blocks** and returns the response.

# Examples

```julia
```
"""
call!(lk::L1, from::L2, args...) where {L1<:LINK, L2<:LINK} = send!(lk, Call(args, from))
call!(lk::LK, args...) where LK<:LINK = request!(lk, Call, args...)

"""
    cast!(lk::LINK, args...)

Cast `args...` to the `lk` actor's behavior function. 
This is an asynchronous message without a response.
"""
cast!(lk::LK, args...) where LK<:LINK = send!(lk, Cast(args))

"""
    get(lk::LINK, [from::LINK])

Get a [`Response`](@ref) message from the `lk` actor with its 
internal state to the `from` channel. If `from` is omitted, 
`get` **blocks** and returns the response.
"""
Base.get(lk::L1, from::L2) where {L1<:LINK, L2<:LINK} = send!(lk, Get(from))
Base.get(lk::LK) where LK<:LINK = request!(lk, Get)

"""
init!(lk::LINK, f::Function, args...; kwargs...)

Tell an actor `lk` to execute the init function `f` with the 
given arguments at startup.
"""
init!(lk::LK, f::F, args...; kwargs...) where {LK<:LINK, F<:Function} = 
    send!(lk, Init(Func(f, args...; kwargs...)))

"""
    query(lk::LINK, [from::LINK])

Query the result of the last call to the behavior function 
from the `lk` actor. The [`Response`](@ref) is sent to the
`from` channel. If `from` is omitted `query` **blocks** and 
returns the response.
"""
query(lk::L1, from::L2) where {L1<:LINK, L2<:LINK} = send!(lk, Query(from))
query(lk::LK) where LK<:LINK = request!(lk, Query)

"""
    self()

Get the [`LINK`](@ref) of your actor.
"""
self() = task_local_storage("ACT").link
# self() = _self()

"""
    set!(lk::LINK, dsp::Dispatch)

Set the `lk` actor's [`Dispatch`](@ref) to `dsp`.
"""
set!(lk::LK, dsp::Dispatch) where LK<:LINK = send!(lk, Set(dsp))
set!(lk::LK) where LK<:LINK = send!(lk, Set(lk))

"""
    stopActor!(lk::LINK)

Terminate an actor with link `lk`.
This is an asynchronous message without a response.
"""
stopActor!(lk::LK) where LK<:LINK = send!(lk, Stop())

"""
    terminate!(lk::LINK, f::Function, args...; kwargs...)

Tell an actor `lk` to execute a function `f` when it terminates.
"""
terminate!(lk::LK, f::F, args...; kwargs...) where {LK<:LINK, F<:Function} = 
    send!(lk, Term(Func(f, args...; kwargs...)))

"""
    update!(lk::LK, args...)

Update the `lk` actor's internal state with `args...`.
This is an asynchronous message without a response.

If called with [`Args`](@ref), it updates the arguments to 
the behavior function. If `Args` has keyword arguments, they 
are merged with existing keyword arguments to the behavior.
"""
update!(lk::LK, args...) where LK<:LINK = send!(lk, Update(args))
