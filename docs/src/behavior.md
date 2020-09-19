# Behaviors

Actors are created with a behavior function. When a message arrives, they execute their behavior reacting to it.

Therefore the behavior function must take a `Message` as its last argument.

In the following example we define two behaviors `forward!` and `stack_node`. There are two methods for `stack_node`, dispatching on `Push` and `Pop`.

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

## Dispatching on Messages

## Changing Behavior

Actors can change their own behavior or cause other actors to switch behavior.

```@docs
become
become!
```
