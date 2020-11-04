#
# This file is part of the YAActL.jl Julia package, MIT license
#
# Paul Bayer, 2020
#

"Abstract type for messages to actors."
abstract type Message end

"""
    Dispatch

Depending on its `Dispatch` mode an actor composes the arguments 
to the behavior function:

- `full`: from the [`Become`](@ref) `args...` and the `msg.x...`.
    This is the default dispatch mode.
- `state`: from the actor state and the `msg.x...`. In this case the 
    actor updates its state with the result of the behavior
    function. The result is saved in a `Tuple`. 
"""
@enum Dispatch full state

"""
    Link{C}(chn::C, pid::Int, type::Symbol)

A mailbox for communicating with actors.

# Fields/Parameters
- `chn::C`: 
- `pid::Int`: 
- `type::Symbol`: 
"""
struct Link{C}
    chn::C
    pid::Int
    type::Symbol
end
