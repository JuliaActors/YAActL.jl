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
query!(lk::LINK, from::LINK, s::Symbol)
query!(lk::LINK, s::Symbol; timeout::Real=5.0)
```

Ask the `lk` actor to send a [`Response`](@ref) message to
`from` with an internal state variable `s`. 

If `from` is omitted, `query!` blocks and returns the response.
In that case there is a `timeout`.

- `s::Symbol` can be one of `:sta`, `:res`, `:bhv`, `:dsp`.

# Examples

```julia
julia> f(x, y; u=0, v=0) = x+y+u+v  # implement a behavior
f (generic function with 1 method)

julia> fact = Actor(f, 1)     # start an actor with it
Channel{Message}(sz_max:32,sz_curr:0)

julia> cast!(fact, 1)         # cast a second parameter to it
YAActL.Cast{Tuple{Int64}}((1,))

julia> query!(fact, :res)     # query the result
2

julia> query!(fact, :bhv)     # query the behavior
f (generic function with 1 method)

julia> set!(fact, state)      # set dispatch mode
YAActL.Update{Dispatch}(:dsp, state)

julia> query!(fact, :dsp)     # query the dispatch mode
state::Dispatch = 1

julia> update!(fact, 10)      # update the state
YAActL.Update{Int64}(:sta, 10)

julia> query!(fact)           # query the state variable
10

julia> call!(fact, 1)
11
```
"""
query!(lk::L1, from::L2, s::Symbol=:sta) where {L1<:LINK, L2<:LINK} = send!(lk, Query(s, from))
query!(lk::LK, s::Symbol=:sta; timeout::Real=5.0) where LK<:LINK = request!(lk, Query, s, timeout=timeout)
    
"""
    self()

Get the [`LINK`](@ref) of your actor.
"""
self() = task_local_storage("ACT").link

"""
    set!(lk::LINK, dsp::Dispatch)

Set the `lk` actor's [`Dispatch`](@ref) to `dsp`.
"""
set!(lk::LK, dsp::Dispatch) where LK<:LINK = update!(lk, dsp, s=:dsp)

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
```
update!(lk::LINK, x; s::Symbol=:sta)
update!(lk::LINK, arg::Args)
```
Update the `lk` actor's internal state `s` with `args...`.

# Arguments
- `x`: value/variable to update the choosen state with,
- `arg::Args`: arguments to update,
- `s::Symbol`: can be one of `:sta`, `:dsp`, `:arg`, `:lnk`.

*Note:* If you want to update the stored arguments to the 
behavior function with `s=:arg`, you must pass an [`Args`](@ref) 
to `arg`. If `Args` has keyword arguments, they are merged 
with existing keyword arguments to the behavior function.

# Example
```julia
julia> update!(fact, 5)       # note that fact is in state dispatch
YAActL.Update{Int64}(:sta, 5)

julia> call!(fact, 5)         # call it with 5
10

julia> update!(fact, Args(0, u=5));  # update arguments

julia> call!(fact, 5)         # add the last result, 5 and u=5
20
```
"""
update!(lk::LK, x; s::Symbol=:sta) where LK<:LINK = 
    send!(lk, Update(s, x))
update!(lk::LK, arg::Args) where LK<:LINK =
    send!(lk, Update(:arg, arg))
