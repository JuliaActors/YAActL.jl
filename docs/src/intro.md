# Introduction

An [`Actor`](@ref) reads a [`Message`](@ref) from a [`Link`](@ref) and passes it to a function implementing its behavior. It can change its own behavior with [`become`](@ref). To setup an actor system you need to define messages and to implement some behaviors:

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
