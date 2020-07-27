module YAActL

include("types.jl")
include("actors.jl")

export  Link, LinkParams, Message, Become, Stop,
        Actor, send!, become!, become

end
