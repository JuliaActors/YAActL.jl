#
# This is part of YAActL.jl, 2020, P.Bayer, License MIT
#
"Abstract type for messages to actors."
abstract type Message end

"""
A `Channel{Message}` type for communicating with actors.

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
