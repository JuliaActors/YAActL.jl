module YAActL

include("types.jl")
include("messages.jl")
include("links.jl")
include("actors.jl")

export  Message, Request, Response, Stop,
        Link, newLink, LinkParams, parallel,
        Actor, self, send!, become!, become, stop!, stop

end
