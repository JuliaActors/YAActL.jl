# YAActL

Yet another Actor Library in Julia

[![Build Status](https://travis-ci.com/pbayer/YAActL.jl.svg?branch=master)](https://travis-ci.com/pbayer/YAActL.jl)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/pbayer/YAActL.jl?svg=true)](https://ci.appveyor.com/project/pbayer/YAActL-jl)
[![Coverage](https://codecov.io/gh/pbayer/YAActL.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/pbayer/YAActL.jl)
[![Coverage](https://coveralls.io/repos/github/pbayer/YAActL.jl/badge.svg?branch=master)](https://coveralls.io/github/pbayer/YAActL.jl?branch=master)

Follows Agha's classic text *Actors: A Model of Concurrent Computation in Distributed Systems*, 1986, MIT Press

```julia
using YAActL, Printf

struct Print <: Message        # define a message
    txt::String
end

# define two behaviors accepting a msg::Message as their last argument
function pr(msg::Print)
    print(@sprintf("%s\n", msg.txt))
    become(pr, "Next") # change behavior
end
pr(info, msg::Print) = print(@sprintf("%s: %s\n", info, msg.txt))

# start an actor with the first behavior and save the returned link
myactor = Actor(pr)
```

now we can interact with it:

```julia
julia> send!(myactor, Print("My first actor"));  # send a message to it
My first actor

julia> send!(myactor, Print("Something else"));  # send again a message
Next: Something else

julia> become!(myactor, pr, "New behavior");     # change the behavior to another one

julia> send!(myactor, Print("bla bla bla"));     # and send again a message
New behavior: bla bla bla
```
