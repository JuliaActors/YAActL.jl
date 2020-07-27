#
# This is part of YAActL.jl, 2020, P.Bayer, License MIT
#
abstract type Message end

const Link = Channel{Message}

"""
    LinkParams(size=32; taskref=nothing, spawn=false)

Set the parameters for establishing a link (a channel) to an actor. Those are
forwarded to [`Channel`](https://docs.julialang.org/en/v1/base/parallel/#Base.Channel-Tuple{Function}).

# Parameters
- `size::Int`: channel buffer size,
- `taskref::Union{Nothing, Ref{Task}}`: If you need a reference to the created task,
    pass a `Ref{Task}` object via the keyword argument `taskref`.
- `spawn::Bool`: If spawn = true, the Task created may be scheduled on another
    thread in parallel, equivalent to creating a task via `Threads.@spawn`.
"""
struct LinkParams
    size::Int
    taskref::Union{Nothing, Ref{Task}}
    spawn::Bool

    LinkParams(size=32; taskref=nothing, spawn=false) = new(size,taskref, spawn)
end

struct Become <: Message
    f::Function
    args::Tuple
    kwargs::Base.Iterators.Pairs
end

struct Stop <: Message end
