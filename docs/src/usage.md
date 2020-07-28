# Usage

## Links and messages

We communicate with actors and actors can communicate with each other (and with themselves) over links and messages.

```@docs
Link
LinkParams
parallel
Message
Stop
```

To setup an actor system we have to specify the messages. For example:

```julia
using YAActL, Printf

struct Pop <: Message
    customer::Link
end

struct Push{T} <: Message
    content::T
end

struct Response{T} <: Message
    content::T
end
```

## Actors and their behaviors

Actors are Julia tasks executing functions as behaviors. If a message arrives, the actor loop passes the message to the behavior function as the last argument. In Julia we want the behavior functions to dispatch on messages. In the following example we define two behaviors `forward!` and `stack_node`. There are two methods for `stack_node`, dispatching on `Push` and `Pop`. With `become` actors can change their behavior. Actors can generate other actors.

```julia
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
mystack = Actor(lk, stack_node, StackNode(nothing, Link()))
```

!!! note
    If we setup an actor we don't pass the last message argument of the behavior
    function to `Actor`.

```@docs
Actor
become
self
send!
become!
```

## Internal

```@docs
YAActL.Become
```
