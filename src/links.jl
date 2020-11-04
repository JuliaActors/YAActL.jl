#
# This file is part of the YAActL.jl Julia package, MIT license
#
# Paul Bayer, 2020
#
# It implements the Actor-model
#

"""
    LinkParams(pid=myid(), size=32; taskref=nothing, spawn=false)

Parameters for setting up an [`Actor`](@ref). 

- `pid::Int`: process identification,
- `size::Int`: channel buffer size, must be `size ≥ 10`,
- `taskref::Union{Nothing, Ref{Task}}`: If you need a reference to the created task,
    pass a `Ref{Task}` object via the keyword argument `taskref`.
- `spawn::Bool`: If spawn = true, the Task created may be scheduled on another
    thread in parallel, equivalent to creating a task via `Threads.@spawn`.
"""
struct LinkParams
    pid::Int
    size::Int
    taskref::Union{Nothing, Ref{Task}}
    spawn::Bool

    function LinkParams(pid=myid(), size=32; taskref=nothing, spawn=false)
        @assert size ≥ 10 "Link buffer size < 10 not allowed"
        new(pid, size, taskref, spawn)
    end
end

"""
    parallel(size=32; taskref=nothing)

Return [`LinkParams`](@ref) with `spawn=true`.

# Example

```julia
julia> using YAActL, .Threads

julia> myactor = Actor(parallel(), threadid);

julia> call!(myactor)
2
```
"""
parallel(size=32; taskref=nothing) = LinkParams(myid(), size, taskref=taskref, spawn=true)

"""
    Link(size=32)

Create a local Link with a buffered `Channel` `size ≥ 1`.
"""
Link(size=32) = Link(Channel{Message}(max(1, size)), myid(), :local)

# create a local Link
function _link(  func::Function, type::Symbol=:local; 
                size=32, taskref=nothing, spawn=false)
    Link(
        Channel{Message}(func, size, taskref=taskref, spawn=spawn),
        myid(),
        type
        )
end

# create a remote Link
function _link(  pid::Int, func::Function;
    size=32, taskref=nothing, spawn=false)
    Link(
        RemoteChannel(()->Channel{Message}(func, size, taskref=taskref, spawn=spawn), pid),
        pid,
        :remote
    )
end

# make a remote link from a local one
_rlink(lk::Link) = lk.chn isa Channel ?
        Link(RemoteChannel(()->lk.chn),myid(),:remote) : lk
_rlink(x) = x

"User remote channel for interacting with actors."
USR = nothing

# Get the local channel to yourself from inside an actor.
_self() = current_task().code.chnl

"""
```
islocal(lk::Link)
islocal(name::Symbol)
```
Returns `true` if the actor `lk` or `name` has the same
pid as the caller, else false.
"""
islocal(lk::Link) = lk.pid == myid()
function islocal(name::Symbol)
    lk = whereis(name)
    return !ismissing(lk) ? islocal(lk) : lk
end
