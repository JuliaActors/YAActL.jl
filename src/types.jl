#
# This is part of YAActL.jl, 2020, P.Bayer, License MIT
#
"Abstract type for messages to actors."
abstract type Message end

"""
    Link

A `Channel{Message}` type for communicating with actors.

!!! warn

    In actor systems we always use buffered links to avoid blocking.
    Responding on an unbuffered or full link causes blocking. `Link()` creates
    an unbuffered Channel, use `Link(32)` or [`newLink()`](@ref newLink)
    instead!

# Example

```julia
julia> response = Link(32)
Channel{Message}(sz_max:32,sz_curr:0)
```
"""
const Link = Channel{Message}

"""
    newLink(sz::Integer=32)

Create a link of buffer size `sz` used to communicate with actors.
Buffer sizes `sz < 10` are not allowed. This is used only for response links
from actors.

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

Set the parameters for setting up an [`Actor`](@ref). See also: [`Channel`](https://docs.julialang.org/en/v1/base/parallel/#Base.Channel-Tuple{Function}).

# Parameters
- `size::Int`: channel buffer size, must be `size ≥ 10`,
- `taskref::Union{Nothing, Ref{Task}}`: If you need a reference to the created task,
    pass a `Ref{Task}` object via the keyword argument `taskref`.
- `spawn::Bool`: If spawn = true, the Task created may be scheduled on another
    thread in parallel, equivalent to creating a task via `Threads.@spawn`.
"""
struct LinkParams
    size::Int
    taskref::Union{Nothing, Ref{Task}}
    spawn::Bool

    function LinkParams(size=32; taskref=nothing, spawn=false)
        @assert size ≥ 10 "Link buffer size < 10 not allowed"
        new(size, taskref, spawn)
    end
end

"""
    parallel(size=32; taskref=nothing)

Return [`LinkParams`](@ref) with `spawn=true`.
"""
parallel(size=32; taskref=nothing) = LinkParams(size, taskref=taskref, spawn=true)

"internal message `Become(f::Function, args...; kwargs...)` for behavior change."
struct Become <: Message
    f::Function
    args::Tuple
    kwargs::Base.Iterators.Pairs
end

"message `Stop()` causes an actor to stop."
struct Stop <: Message end
