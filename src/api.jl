#
# This file is part of the YAActL.jl Julia package, MIT license
#
# Paul Bayer, 2020
#

"""
```
become!(lk::Link, bhv::Function, args1...; kwargs...)
become!(name::Symbol, ....)
```
Cause an actor to change behavior.

# Arguments
- `lk::Link`: Link to an actor,
- `bhv`: function implementing the new behavior,
- `args1...`: first arguments to `bhv` (without a possible `msg` argument),
- `kwargs...`: keyword arguments to `bhv`.
"""
become!(lk::Link, bhv::F, args::Vararg{Any, N}; kwargs...) where {F<:Function,N} =
    send!(lk, Become(Func(bhv, args...; kwargs...)))
become!(name::Symbol, args...; kwargs...) = become!(whereis(name), args...; kwargs...)

"""
```
call!(lk::Link, from::Link, args2...)
call!(lk::Link, args2...; timeout::Real=5.0)
call!(name::Symbol, ....)
```
Call an actor to execute its behavior function  
and to send a [`Response`](@ref) with the result. 

# Arguments
- `lk::Link` or `name::Symbol`of [`registered`](@ref) actor, 
- `from::Link`: sender link; If `from` is omitted, `call!` 
    blocks and returns the result. 
- `args2...`: second arguments to the actor.
- `timeout::Real=5.0`: timeout in seconds.
"""
call!(lk::Link, from::Link, args...) = send!(lk, Call(args, from))
call!(lk::Link, args...; timeout::Real=5.0) = request!(lk, Call, args...; timeout=timeout)
call!(name::Symbol, args...; kwargs...) = call!(whereis(name), args...; kwargs...)

"""
```
cast!(lk::Link, args2...)
cast!(name::Symbol, args2...)
```
Cast a message to the `lk` actor to execute its behavior 
function with `args2...` without sending a response. 

*Note:* you can prompt the returned value with [`query!`](@ref).
"""
cast!(lk::Link, args...) = send!(lk, Cast(args))
cast!(name::Symbol, args...) = cast!(whereis(name), args...)

"""
```
exec!(lk::Link, from::Link, f::Function, args...; kwargs...)
exec!(lk::Link, from::Link, fu::Func)
exec!(lk::Link, fu::Func; timeout::Real=5.0)
exec!(name::Symbol, ....)
```

Ask an actor to execute an arbitrary function and to 
send the returned value as [`Response`](@ref).

# Arguments
- `lk::Link` or `name::Symbol` of the actor,
- `from::Link`: the link a `Response` should be sent to.
    If `from` is ommitted, `exec!` blocks, waits and returns 
    the result. In that case there is a `timeout`.
- `f::Function, args...; kwargs...` or
- `fu::Func`: function arguments,
- `timeout::Real=5.0`: timeout in seconds. Set `timeout=Inf` 
    if you don't want a timeout.
"""
exec!(lk::Link, from::Link, f::F, args...; kwargs...) where F<:Function =
    send!(lk, Exec(Func(f, args...; kwargs...), from))
exec!(lk::Link, from::Link, fu::Func) = send!(lk, Exec(fu, from))
exec!(lk::Link, fu::Func; timeout::Real=5.0) =
    request!(lk, Exec, fu; timeout=timeout)
exec!(name::Symbol, args...; kwargs...) = exec!(whereis(name), args...; kwargs...)

"""
```
exit!(lk::Link, code=0)
exit!(name::Symbol, code=0)
```
Tell an actor `lk` to exit. If it has a [`term`](@ref _ACT) 
function, it calls it with `code` as last argument. 

!!! note "This behavior is not yet fully implemented!"

    It is needed for supervision.

"""
exit!(lk::Link, code=0) = send!(lk, Stop(code))
exit!(name::Symbol, code=0) = exit!(whereis(name), code)

"""
```
init!(lk::Link, f::Function, args...; kwargs...)
init!(name::Symbol, ....)
```
Tell an actor `lk` to save the function `f` with the given 
arguments as an [`init`](@ref _ACT) function, to execute it 
and to save the returned value as state [`sta`](@ref _ACT) 
variable.

The `init` function will be called at actor restart.

!!! note "This behavior is not yet implemented!"

    It is needed for supervision.
"""
init!(lk::Link, f::F, args...; kwargs...) where F<:Function = 
    send!(lk, Init(Func(f, args...; kwargs...)))
init!(name::Symbol, args...; kwargs...) = init!(whereis(name), args...; kwargs...)

"""
```
query!(lk::Link, from::Link, s::Symbol)
query!(lk::Link, s::Symbol; timeout::Real=5.0)
query!(name::Symbol, ....)
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
query!(lk::Link, from::Link, s::Symbol=:sta) = send!(lk, Query(s, from))
query!(lk::Link, s::Symbol=:sta; timeout::Real=5.0) = request!(lk, Query, s, timeout=timeout)
query!(name::Symbol, args...; kwargs...) = query!(whereis(name), args...; kwargs...)
    
"""
    self()

Get the [`Link`](@ref) of your actor.
"""
self() = task_local_storage("_ACT").self

"""
```
set!(lk::Link, dsp::Dispatch)
set!(name::Symbol, dsp::Dispatch)
```
Set the `lk` actor's [`Dispatch`](@ref) to `dsp`.
"""
set!(lk::Link, dsp::Dispatch) = update!(lk, dsp, s=:dsp)
set!(name::Symbol, dsp::Dispatch) = set!(whereis(name), dsp)

"""
```
term!(lk::Link, f::Function, args1...; kwargs...)
term!(name::Symbol, ....)
```
Tell an actor `lk` to execute a function `f` with the given
arguments when it terminates. `f` must accept a `code=0` 
as last argument. This is added by the actor to `args1...` 
when it [`exit!`](@ref)s.

!!! note "This behavior is not yet implemented!"

    It is needed for supervision.
"""
term!(lk::Link, f::F, args...; kwargs...) where F<:Function = 
    send!(lk, Term(Func(f, args...; kwargs...)))
term!(name::Symbol, args...; kwargs...) = term!(whereis(name), args...; kwargs...)

"""
```
update!(lk::Link, x; s::Symbol=:sta)
update!(lk::Link, arg::Args)
update!(name::Symbol, ....)
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
update!(lk::Link, x; s::Symbol=:sta) = send!(lk, Update(s, x))
update!(lk::Link, arg::Args) = send!(lk, Update(:arg, arg))
update!(name::Symbol, args...; kwargs...) = update!(whereis(name), args...; kwargs...)
