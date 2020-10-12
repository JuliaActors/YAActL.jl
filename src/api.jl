#
# This file is part of the YAActL.jl Julia package, MIT license
#
# Paul Bayer, 2020
#

"""
    become!(lk::LINK, bhv::Function, args1...; kwargs...)

Cause an actor to change behavior.

# Arguments
- `lk::Link`: Link to an actor,
- `bhv`: function implementing the new behavior,
- `args1...`: first arguments to `bhv` (without a possible `msg` argument),
- `kwargs...`: keyword arguments to `bhv`.
"""
become!(lk::LK, bhv::F, args::Vararg{Any, N}; kwargs...) where {LK<:LINK, F<:Function,N} =
    send!(lk, Become(Func(bhv, args...; kwargs...)))

"""
```
call!(lk::LINK, from::LINK, args2...)
call!(lk::LINK, args2...; timeout::Real=5.0)
```
Call the `lk` actor to execute its behavior function with 
`args2...` and to send a [`Response`](@ref) with the result 
to `from`. 

If `from` is omitted, `call!` blocks and returns the result. 
In that case there is a `timeout`.

# Examples

```julia
```
"""
call!(lk::L1, from::L2, args...) where {L1<:LINK, L2<:LINK} = send!(lk, Call(args, from))
call!(lk::LK, args...; timeout::Real=5.0) where LK<:LINK = request!(lk, Call, args...; timeout=timeout)

"""
    cast!(lk::LINK, args2...)

Cast a message to the `lk` actor to execute its behavior 
function with `args2...` without sending a response. 

*Note:* you can prompt the returned value with [`query!`](@ref).
"""
cast!(lk::LK, args...) where LK<:LINK = send!(lk, Cast(args))

"""
```
exec!(lk::LINK, from::LINK, f::Function, args...; kwargs...)
exec!(lk::LINK, from::LINK, fu::Func)
exec!(lk::LINK, fu::Func; timeout::Real=5.0)
```

Ask an actor to execute an arbitrary function and to 
send the returned value as [`Response`](@ref).

# Arguments
- `lk::LINK`: link to the actor,
- `from::LINK`: the link a `Response` should be sent to.
    If `from` is ommitted, `exec!` blocks, waits and returns 
    the result. In that case there is a `timeout`.
- `f::Function, args...; kwargs...` or
- `fu::Func`: function arguments,
- `timeout::Real=5.0`: timeout in seconds. Set `timeout=Inf` 
    if you don't want a timeout.

# Examples

```julia
```
"""
exec!(lk::L1, from::L2, f::F, args...; kwargs...) where {L1<:LINK,L2<:LINK,F<:Function} =
    send!(lk, Exec(Func(f, args...; kwargs...), from))
exec!(lk::L1, from::L2, fu::Func) where {L1<:LINK,L2<:LINK} =
    send!(lk, Exec(fu, from))
exec!(lk::LK, fu::Func; timeout::Real=5.0) where LK<:LINK =
    request!(lk, Exec, fu; timeout=timeout)

"""
    exit!(lk::LINK, code=0)

Tell an actor `lk` to exit. If it has a [`term`](@ref _ACT) 
function, it calls it with `code` as last argument. 

!!! note "This behavior is not yet fully implemented!"

    It is needed for supervision.

"""
exit!(lk::LK, code=0) where LK<:LINK = send!(lk, Stop(code))

"""
```
get!(lk::LINK, from::LINK)
get!(lk::LINK; timeout::Real=5.0)
```

Ask the `lk` actor to send a [`Response`](@ref) message to
`from` with its internal state [`sta`](@ref _ACT). 

If `from` is omitted, `get!` blocks and returns the response.
In that case there is a `timeout`.
"""
Base.get!(lk::L1, from::L2) where {L1<:LINK, L2<:LINK} = send!(lk, Get(from))
Base.get!(lk::LK; timeout::Real=5.0) where LK<:LINK = request!(lk, Get, timeout=timeout)

"""
    init!(lk::LINK, f::Function, args...; kwargs...)

Tell an actor `lk` to save the function `f` with the given 
arguments as an [`init`](@ref _ACT) function, to execute it 
and to save the returned value as state [`sta`](@ref _ACT) 
variable.

The `init` function will be called at actor restart.

!!! note "This behavior is not yet implemented!"

    It is needed for supervision.

"""
init!(lk::LK, f::F, args...; kwargs...) where {LK<:LINK, F<:Function} = 
    send!(lk, Init(Func(f, args...; kwargs...)))

"""
```
query!(lk::LINK, [from::LINK])
query!(lk::LINK; timeout::Real=5.0)
```
Ask the `lk` actor to send a [`Response`](@ref) with the 
last result of the behavior function to `from`.

If `from` is omitted `query!` blocks and returns the response.
In that case there is a `timeout`.
"""
query!(lk::L1, from::L2) where {L1<:LINK, L2<:LINK} = send!(lk, Query(from))
query!(lk::LK; timeout::Real=5.0) where LK<:LINK = request!(lk, Query, timeout=timeout)

"""
    self()

Get the [`LINK`](@ref) of your actor.
"""
self() = task_local_storage("ACT").link

"""
    set!(lk::LINK, dsp::Dispatch)

Set the `lk` actor's [`Dispatch`](@ref) to `dsp`.

# Example

```julia
```
"""
set!(lk::LK, dsp::Dispatch) where LK<:LINK = send!(lk, Set(dsp))
set!(lk::LK) where LK<:LINK = send!(lk, Set(lk))

"""
    term!(lk::LINK, f::Function, args1...; kwargs...)

Tell an actor `lk` to execute a function `f` with the given
arguments when it terminates. `f` must accept a `code=0` 
as last argument. This is added by the actor to `args1...` 
when it [`exit!`](@ref)s.

!!! note "This behavior is not yet implemented!"

    It is needed for supervision.
"""
term!(lk::LK, f::F, args...; kwargs...) where {LK<:LINK, F<:Function} = 
    send!(lk, Term(Func(f, args...; kwargs...)))

"""
    update!(lk::LK, args...)

Update the `lk` actor's internal state with `args...`.

It can be called with [`Args`](@ref) to update the stored
arguments to the behavior function. If `Args` has keyword 
arguments, they are merged with existing keyword arguments 
to the behavior function.

# Example

```julia
```
"""
update!(lk::LK, args...) where LK<:LINK = send!(lk, Update(args))
