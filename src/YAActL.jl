module YAActL

include("types.jl")
include("messages.jl")
include("links.jl")
include("actors.jl")

export  Message, Request, Response, Stop,
        Link, newLink, LinkParams, parallel,
        Actor, send!, become!, become, self

end
