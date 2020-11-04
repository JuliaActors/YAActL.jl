#
# This file is part of the YAActL.jl Julia package, MIT license
#
# Paul Bayer, 2020
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
const version = v"0.2.1"

using Distributed

include("types.jl")
include("messages.jl")
include("links.jl")
include("com.jl")
include("actors.jl")
include("api.jl")
include("registry.jl")
include("diag.jl")
include("init.jl")

export  Message, Response, Request, Timeout, Func, Args,
        Link, LinkParams, parallel, USR, islocal,
         send!, request!, receive!,
        Actor, become, stop,  
        Dispatch, full, state,
        become!, call!, cast!, exec!, exit!, init!, 
        query!, self, set!, term!, update!, 
        register, unregister, whereis, registered,
        register!, info

end
