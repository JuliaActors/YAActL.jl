module YAActL

include("types.jl")
include("actors.jl")

export  Link, LinkParams, parallel, Message, Stop,
        Actor, send!, become!, become, self

end
