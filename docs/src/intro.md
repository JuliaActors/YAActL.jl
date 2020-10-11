# Introduction

A `YAActL` [actor](actors.md)

- is a *task* running on a thread or a remote node which
- receives [*messages*](messages.md) over a [*channel*](@ref links) and with it
- dispatches a [*behavior*](behavior.md) function or one of of its methods.

```julia
using YAActL, Printf

# define two functions for printing a message
function pr(msg)
    print(@sprintf("%s\n", msg))
    become(pr, "Next") # change behavior
end
pr(info, msg) = print(@sprintf("%s: %s\n", info, msg))

# a function for doing arithmetic
calc(op::F, x, y) where F<:Function = op(x, y)

# start an actor with the first behavior
myactor = Actor(pr)
```

Now we can interact with it:

```julia
julia> cast!(myactor, "My first actor")     # send a message to it
My first actor
```

Our actor has executed its behavior function `pr` with the message as argument. You may have noticed above that `pr(msg)` causes the actor to change its behavior to `pr("Next:", msg)`. Now we send it something else:

```julia
julia> cast!(myactor, "Something else")     # send again a message
Next: Something else

julia> become!(myactor, pr, "New behavior") # change the behavior to another one

julia> cast!(myactor, "bla bla bla")        # and send again a message
New behavior: bla bla bla
```

Our actor can also change to a completely different behavior and do some arithmetic:

```julia
julia> become!(myactor, calc, +, 10);       # now become a machine for adding to 10

julia> call!(myactor, 5)                    # send a request to add 5 to it and to return the result
15

julia> become!(myactor, ^);                 # become an exponentiation machine

julia> call!(myactor, 123, 456)             # try it
2409344748064316129
```

Actors thus can represent different and changing [*behaviors*](behavior.md) of real world or computational objects.

If we implement and start multiple actors *interacting* with each other, we get an *actor system*.
