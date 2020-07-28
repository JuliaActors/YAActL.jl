#
# This is part of YAActL.jl, 2020, P.Bayer, License MIT
#
"Type for messages to actors."
abstract type Message end

"Establish a message channel used to communicate with actors."
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

"shortcut for [`LinkParams`](@ref) with `spawn=true`."
parallel(size=32; taskref=nothing) = LinkParams(size, taskref=taskref, spawn=true)

"internal message `Become(f::Function, args...; kwargs...)` for behavior change."
struct Become <: Message
    f::Function
    args::Tuple
    kwargs::Base.Iterators.Pairs
end

"message `Stop()` causes an actor to stop."
struct Stop <: Message end
