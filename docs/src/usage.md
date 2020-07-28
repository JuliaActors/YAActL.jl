# Usage

## Links and Messages

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

## Actors and Behaviors

Actors are Julia tasks executing functions as behaviors. If a message arrives, the actor loop passes the message to the behavior function as the last argument. In Julia we want the behavior functions to dispatch on the messages. In the following example we define two behaviors `forward!` and `stack_node`. With `become` actors can change their behaviors.

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

With `Actor` we can setup actors, with `send!` we can send messages to them, with `become!` we can cause to change their behaviors. 

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
