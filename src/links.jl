#
# This is part of YAActL.jl, 2020, P.Bayer, License MIT
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
    LinkParams(size=32; taskref=nothing, spawn=false)

Set the parameters for setting up an [`Actor`](@ref). 

# Parameters
- `pid::Int`: process identification,
- `size::Int`: channel buffer size, must be `size ≥ 10`,
- `taskref::Union{Nothing, Ref{Task}}`: If you need a reference to the created task,
    pass a `Ref{Task}` object via the keyword argument `taskref`.
- `spawn::Bool`: If spawn = true, the Task created may be scheduled on another
    thread in parallel, equivalent to creating a task via `Threads.@spawn`.
- `persistent::Bool`: if persistent = false, the 
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
"""
parallel(size=32; taskref=nothing) = LinkParams(size, taskref=taskref, spawn=true)
