#
# This file is part of the YAActL.jl Julia package, MIT license
#
# Paul Bayer, 2020
#
# It implements the Actor-model
#

"""
    YAActL

Yet Another Actor Library (in Julia `VERSION ≥ v"1.3"`).

The current stable, registered version is installed with
```julia
pkg> add YAActL
```

The development version is installed with:
```julia
pkg> add("https://github.com/pbayer/YAActL.jl")
```
"""
module YAActL

"Gives the package version."
const version = v"0.1.1"

using Distributed

include("types.jl")
include("messages.jl")
include("links.jl")
include("actors.jl")
include("diag.jl")

export  Message, Request, Response, Stop,
        Link, RLink, LINK, newLink, LinkParams, parallel, USR,
        Actor, self, send!, become!, become, stopActor!, stopActor,
        register!, taskstate

end
