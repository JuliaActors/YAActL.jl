#
# This file is part of the YAActL.jl Julia package, MIT license
#
# Paul Bayer, 2020
#

"Abstract type for messages to actors."
abstract type Message end

"""
A `Channel{Message}` type for communicating with local actors.

!!! warn

    In actor systems we always use buffered links to avoid blocking.
    Responding on an unbuffered or full link causes an actor to block.
    `Link()` creates an unbuffered Channel, use `Link(32)` or
    [`newLink()`](@ref newLink) instead!

# Example

```julia
julia> response = Link(32)
Channel{Message}(sz_max:32,sz_curr:0)
```
"""
const Link = Channel{Message}

"""
A `RemoteChannel{Link}` type for communicating with remote actors.
"""
const RLink = RemoteChannel{Link}

"""
A `Union{Link, RLink}` type for communicating with actors. 
"""
const LINK = Union{Link, RLink}

# define promote rule
Base.promote_rule(::Type{Link}, ::Type{RLink}) = LINK
