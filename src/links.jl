#
# This file is part of the YAActL.jl Julia package, MIT license
#
# Paul Bayer, 2020
#
# It implements the Actor-model
#

"""
    newLink(sz::Integer=32)

Create a link of buffer size `sz` to get responses from actors.
Buffer sizes `sz < 10` are not allowed.

# Example
```julia
julia> response = newLink()
Channel{Message}(sz_max:32,sz_curr:0)
```
"""
function newLink(sz::Integer=32)
    @assert sz ≥ 10 "Link buffer size < 10 not allowed"
    Link(sz)
end

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

"User remote channel for interacting with actors."
const USR = RemoteChannel(()->newLink())

# Get a local link to yourself from inside an actor.
_self() = current_task().code.chnl :: Link
