# Actors

> An Actor is a computational entity that, in response to a message it receives, can concurrently:
>
> - send a finite number of messages to other actors;
> - create a finite number of new actors;
> - designate the behavior to be used for the next message it receives. [^1]

`YAActL` provides a library for *messages*, *links* (message channels), *behaviors* and *actors* which enables us to implement actor systems in Julia.

## Start

`Actor` starts an actor on a behavior and returns a link to it.

```@docs
Actor
```

### Example

In the following [code snippet](@ref stack_example) we start an actor with a `stack_node` behavior function and one of its arguments (an empty `StackNode`).

```julia
mystack = Actor(stack_node, StackNode(nothing, Link()))
```

We saved the returned link in `mystack` and can now [`send!`](@ref) messages to it.

## Operation

If an actor gets a message, it executes its behavior function with it.

Actors can switch their behavior function with [`become`](@ref) or we can cause them to switch it with [`become!`](@ref). Thereby an actor can represent a state machine.

We can stop an Actor.

```@docs
stopActor
stopActor!
```

[^1]:   See: The [Actor Model](https://en.wikipedia.org/wiki/Actor_model) on Wikipedia.
