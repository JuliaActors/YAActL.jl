# YAActL.jl

*Yet another Actor Library*: concurrent programming in Julia.

[![stable docs](https://img.shields.io/badge/docs-stable-blue.svg)](https://juliaactors.github.io/YAActL.jl/stable/)
[![dev docs](https://img.shields.io/badge/docs-dev-blue.svg)](https://juliaactors.github.io/YAActL.jl/dev)
[![Build Status](https://travis-ci.com/pbayer/YAActL.jl.svg?branch=master)](https://travis-ci.com/pbayer/YAActL.jl)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/pbayer/YAActL.jl?svg=true)](https://ci.appveyor.com/project/pbayer/YAActL-jl)
[![Coverage](https://codecov.io/gh/pbayer/YAActL.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/pbayer/YAActL.jl)
[![Coverage Status](https://coveralls.io/repos/github/pbayer/YAActL.jl/badge.svg?branch=master)](https://coveralls.io/github/pbayer/YAActL.jl?branch=master)

`YAActL` is based on the [Actor model](https://en.wikipedia.org/wiki/Actor_model). An actor

- is a *task* running on a thread or a remote node which
- receives *messages* over a *channel* and with it
- dispatches a *behavior* function or one of its methods.

Actors can represent concurrently different and changing behaviors of real world or computational objects *interacting* with each other. This makes an actor system.

## One Single Actor

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

julia> cast!(myactor, "Something else")     # send again a message
Next: Something else

julia> become!(myactor, pr, "New behavior") # change the behavior to another one

julia> cast!(myactor, "bla bla bla")        # and send again a message
New behavior: bla bla bla
```

The actor can also change to a completely different behavior and do some arithmetic:

```julia
julia> become!(myactor, calc, +, 10);       # now become a machine for adding to 10

julia> call!(myactor, 5)                    # send a request to add 5 to it and to return the result
15

julia> become!(myactor, ^);                 # become an exponentiation machine

julia> call!(myactor, 123, 456)             # try it
2409344748064316129
```

## Rationale

1. Actors are an important concept for [concurrent computing](https://en.wikipedia.org/wiki/Concurrent_computing).
2. There is no [actor library](https://en.wikipedia.org/wiki/Actor_model#Actor_libraries_and_frameworks) in Julia. 
3. Julia allows to condense the actor-concept into a  smart and fast library.
4. A community effort is needed to do it.

If you agree with those points, please help with  `YAActL`'s development.
