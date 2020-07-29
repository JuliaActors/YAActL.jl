# Usage

## Messages

Messages to `YAActL` actors have a common abstract type: `Message`. This may seem first as a limitation but it enables the actor to dispatch on different message types. Some basic message types are provided

```@docs
Message
Request
Response
Stop
YAActL.Become
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

## Links

We send messages to actors and actors can send them to others over links. In fact, an actor is only represented by its link. If we want a response from an actor, we must send it our own link together with a request.

```@docs
Link
newLink
LinkParams
parallel
```

## Actors and their behaviors

Actors are Julia tasks executing functions as behaviors. If a message arrives, the actor loop passes the message to the behavior function as the last argument. In Julia we want the behavior functions to dispatch on messages. In the following example we define two behaviors `forward!` and `stack_node`. There are two methods for `stack_node`, dispatching on `Push` and `Pop`. Actors can change their behavior with `become`. They can also generate other actors. For example:

```julia
# implement behaviors
forward!(lk::L, msg::M) where {L<:Link, M<:Message} = send!(lk, msg)

function stack_node(sn::StackNode, msg::Pop)
    isnothing(sn.content) || become(forward!, sn.link)
    send!(msg.customer, Response(sn.content))
end

function stack_node(sn::StackNode, msg::Push)
    P = Actor(stack_node, sn)
    become(stack_node, StackNode(msg.content, P))
end
```

With `Actor` we can setup actors, with `send!` we can send them messages, with `become!` we can cause them to change their behaviors.

```julia
# setup an actor with a defined behavior
mystack = Actor(lk, stack_node, StackNode(nothing, Link()))
```

!!! note
    Don't pass the last `msg` argument of the behavior function to the `Actor`
    setup!

```@docs
Actor
become
self
send!
become!
```
