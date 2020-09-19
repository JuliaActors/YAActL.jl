# Messages

Messages in `YAActL` have a common abstract type. This enables actors to [dispatch](https://docs.julialang.org/en/v1/manual/methods/#Methods-1) their behavior functions on message types.

Some basic message types are for setting up the type hierarchy and for controlling the actors themselves:

```@docs
Message
Stop
YAActL.Become
```

The following message types are for executing and dispatching standard behaviors:

```@docs
Request
Response
```

Other message types can be implemented by the user, for example:

```julia
struct Pop <: Message
    customer::Link
end

struct Push{T} <: Message
    content::T
end
```

With dispatch on message types we can easily implement state machines.
