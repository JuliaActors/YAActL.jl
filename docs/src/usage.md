# Usage

> An Actor is a computational entity that, in response to a message it receives, can concurrently:
>
> - send a finite number of messages to other actors;
> - create a finite number of new actors;
> - designate the behavior to be used for the next message it receives. [^1]

`YAActL` provides a library for *messages*, *links* (message channels), *behaviors* and *actors* which enables us to implement actor systems in Julia.

## Messages

Messages in `YAActL` have a common abstract type. This enables actors to [dispatch](https://docs.julialang.org/en/v1/manual/methods/#Methods-1) their behavior functions on message types.

Some basic message types are for setting up the type hierarchy and for controlling the actors themselves:

```@docs
Message
Stop
YAActL.Become
```

The following message types are for executing and dispatching standard behaviors:

```@docs
Request
Response
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

With dispatch on message types we can easily implement state machines.

## Links

We send messages to actors and they can send them to others over links. In fact, an actor is only represented by its link. If we want a response from an actor, we must send it our own link together with a request message.

```@docs
Link
newLink
LinkParams
parallel
```

## Behaviors

When a message arrives, the actor executes a behavior function on it. Therefore the behavior function must take a `Message` as its last argument.

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

Actors change their behavior with `become`. They also can create other actors. They can send messages to themselves and other actors.

## Actors

`Actor` starts an actor on a behavior and returns a link to it.

```julia
mystack = Actor(stack_node, StackNode(nothing, Link()))
```

We pass the behavior function and its arguments (an empty `StackNode` but without the last `msg` argument!) to the actor.

Over the returned link we can `send!` messages to it.

```@docs
Actor
self
send!
become
become!
stopActor
stopActor!
```

With `become` actors can switch their behavior function (e.g. between different state machines) or `become!` causes them to switch.Thereby an actor can represent a state machine.

## Diagnosis

In order to develop actor programs, it is useful to have access to the actor tasks and eventually to their stack traces. You can `register!` an actor channel to a `Vector{Link}` in order to get access to the tasks.

```@docs
register!
istaskfailed(::Link)
istaskfailed(::Vector{Link})
taskstate
```

[^1]:   See: The [Actor Model](https://en.wikipedia.org/wiki/Actor_model) on Wikipedia.
