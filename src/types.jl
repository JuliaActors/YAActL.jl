

abstract type Message end

const Link = Channel{Message}

struct LinkParams
    size::UInt
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
