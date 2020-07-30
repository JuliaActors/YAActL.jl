# YAActL

*Yet Another Actor Library* (in Julia)

`YAActL` is in early development. It uses native Julia tasks and channels to implement actors.

## Installation

```julia
] add "https://github.com/pbayer/YAActL.jl"
```

## Quick Intro

An [`Actor`](@ref) reads a [`Message`](@ref) from a [`Link`](@ref) and passes it to a function implementing his behavior. He can change his behavior with [`become`](@ref). Basically we have to define the messages and to implement the behaviors.

```julia
using YAActL, Printf

struct Print <: Message        # define a message
    txt::String
end

# define two behaviors accepting a msg::Message as their last argument
function pr(msg::Print)
    print(@sprintf("%s\n", msg.txt))
    become(pr, "Next") # change behaviour
end
pr(info, msg::Print) = print(@sprintf("%s: %s\n", info, msg.txt))

# start an actor with the first behaviour and save the returned link
myactor = Actor(pr)
```

We can interact with the actor over the returned link.

```julia
julia> send!(myactor, Print("My first actor"));  # send a message to it
My first actor

julia> send!(myactor, Print("Something else"));  # send again a message
Next: Something else

julia> become!(myactor, pr, "New behavior");     # cause the actor to change the behavior to another one

julia> send!(myactor, Print("bla bla bla"));     # and send again a message
New behavior: bla bla bla
```

## Why YAActl?

I could not find a suitable actor library for implementing reactive state machines in [`DiscreteEvents`](https://github.com/pbayer/DiscreteEvents.jl) and [`StateMachines`](https://github.com/pbayer/StateMachines.jl). So I am writing my own. Likewise it helps me to learn the actor concept. Please join me to develop it.

## References

- Gul Agha: Actors, A Model of Concurrent Computation in Distributed Systems.- 1986, MIT Press
- Vaughn Vernon: Reactive Messaging Patterns with the Actor Model, Applications and Integrations in Scala and Akka.- 2016, Pearson

## Author(s)

- [Paul Bayer](https://github.com/pbayer)

## License

`YAActL` is licensed under the [MIT License](https://github.com/pbayer/YAActL.jl/blob/master/LICENSE).