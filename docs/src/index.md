# YAActL.jl

*Yet Another Actor Library* (in Julia)

`YAActL` aims to be a tiny smart actor library for parallel and distributed computing. It is in early development and uses native Julia tasks and channels to implement actors.

## Quick Intro

An [`Actor`](@ref) reads a [`Message`](@ref) from a [`Link`](@ref) and passes it to a function implementing its behavior. It can change the behavior with [`become`](@ref). To setup an actor system you need to define messages and to implement some behaviors:

```julia
using YAActL, Printf

struct Prt <: Message        # define a message
    txt::String
end

# define two behaviors accepting a msg::Message as their last argument
function pr(msg::Prt)
    print(@sprintf("%s\n", msg.txt))
    become(pr, "Next") # change behavior
end
pr(info, msg::Prt) = print(@sprintf("%s: %s\n", info, msg.txt))

# a behavior for doing arithmetic
function calc(op::F, v::U, msg::Request) where {F<:Function,U<:Number}
    send!(msg.lk, Response(op(v,msg.x)))
end

# start an actor with the first behavior and save the returned link
myactor = Actor(pr)
```

now we can interact with it:

```julia
julia> send!(myactor, Prt("My first actor"));  # send a message to it
My first actor

julia> send!(myactor, Prt("Something else"));  # send again a message
Next: Something else

julia> become!(myactor, pr, "New behavior");   # change the behavior to another one

julia> send!(myactor, Prt("bla bla bla"));     # and send again a message
New behavior: bla bla bla
```

Our actor can also change to a completely different behavior and do some arithmetic:

```julia
julia> become!(myactor, calc, +, 10);         # now become a adding machine

julia> send!(myactor, Request(5, USR));       # send a request to add 5

julia> take!(USR)                             # take the result
Response{Int64}(15)
```

## Why YAActl?

I could not find a suitable actor library for implementing reactive state machines in Julia. So I am writing one. Please join me to develop it.

## References

- Gul Agha: Actors, A Model of Concurrent Computation in Distributed Systems.- 1986, MIT Press
- Vaughn Vernon: Reactive Messaging Patterns with the Actor Model, Applications and Integrations in Scala and Akka.- 2016, Pearson

## Author(s)

- [Paul Bayer](https://github.com/pbayer)

## License

`YAActL` is licensed under the [MIT License](https://github.com/pbayer/YAActL.jl/blob/master/LICENSE).
