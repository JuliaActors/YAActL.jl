# YAActL.jl

*Yet another Actor Library* (built in Julia)

[![stable docs](https://img.shields.io/badge/docs-stable-blue.svg)](https://pbayer.github.io/YAActL.jl/stable/)
[![dev docs](https://img.shields.io/badge/docs-dev-blue.svg)](https://pbayer.github.io/YAActL.jl/dev)
[![Build Status](https://travis-ci.com/pbayer/YAActL.jl.svg?branch=master)](https://travis-ci.com/pbayer/YAActL.jl)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/pbayer/YAActL.jl?svg=true)](https://ci.appveyor.com/project/pbayer/YAActL-jl)
[![Coverage](https://codecov.io/gh/pbayer/YAActL.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/pbayer/YAActL.jl)
[![Coverage](https://coveralls.io/repos/github/pbayer/YAActL.jl/badge.svg?branch=master)](https://coveralls.io/github/pbayer/YAActL.jl?branch=master)

`YAActL` aims to be a smart actor library for parallel and distributed computing. It builds on Julia's multiple dispatch and uses tasks and channels to implement actors.

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
    send!(msg.from, Response(op(v,msg.x)))
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
julia> become!(myactor, calc, +, 10);         # now become a machine for adding to 10

julia> send!(myactor, Request(5, USR));       # send a request to add 5

julia> take!(USR)                             # take the result
Response{Int64}(15)
```

## Rationale

1. Actors are exciting.
2. Actors are needed for parallel computing.
3. There is no [actor library](https://en.wikipedia.org/wiki/Actor_model#Actor_libraries_and_frameworks) in Julia. 
4. Building on Julia's existing strengths it is possible to condense the actor-concept into a tiny smart and fast library.
5. A community effort is needed to do it.

If you agree with those points, please join `YAActL`'s development.
