# Actors

```@meta
CurrentModule = YAActL
```

> An Actor is a computational entity that, in response to a message it receives, can concurrently:
>
> - send a finite number of messages to other actors;
> - create a finite number of new actors;
> - designate the behavior to be used for the next message it receives. [^1]

`YAActL` actors are Julia tasks represented by local or remote [`LINK`](@ref)s, channels over which they receive and send [messages](messages.md) [^2]. They:

- *react* to those messages,
- *execute* user defined [behavior functions](behavior.md) when receiving certain messages,
- *change* their behavior upon request,
- *update* their [internal state](@ref state) influencing how they behave.

The following provides an overview of `YAActL` actors:

## Start

In the simplest case we use [`Actor`](@ref) to start an actor with a previously implemented [behavior](behavior.md). The following [code](@ref stack_example) starts an actor with a `stack_node` behavior function and some arguments to it.

```julia
mystack = Actor(stack_node, StackNode(nothing, Link()))
```

## Links

When we started our actor, we got a [link](@ref links) variable `mystack` to it. This is a local or remote channel from which actors can receive messages. We can also send messages to it.

## Messages

`YAActL` actors operate on [predefined messages](messages.md), all of type [`Message`](@ref). They process messages asynchronously. Basically there are only two functions to interact with an actor:

- [`send!`](@ref): send a message to an actor,
- [`receive!`](@ref): receive a message from an actor.

A user can implement further message types. For example:

```julia
struct Pop <: Message
    customer::Link
end

struct Push{T} <: Message
    content::T
end
```

Those are forwarded by the actor as last arguments to its behavior function.

## Behavior

Actors execute a behavior function when they receive a `Request` or another user implemented message [^3]. They pass those messages as the last argument to their behavior function. Argument composition is explained in [Behaviors](behavior.md). The actor stores the return value in its internal [`res`](@ref _ACT) variable. This can be queried from the actor with [`query!(lk, :res)`](@ref query!).

## Actor Control

Actors can be controlled with the following functions:

- [`become!`](@ref): cause an actor to switch its behavior,
- [`cast!`](@ref): cause an actor to execute its behavior function,
- [`exit!`](@ref): cause an actor to terminate,
- [`init!`](@ref): tell an actor to execute a function at startup,
- [`set!`](@ref): set an actor's dispatch mode,
- [`term!`](@ref): tell an actor to execute a function when it terminates.
- [`update!`](@ref): update an actor's internal state,

Those functions are wrappers to [predefined messages](messages.md) and to `send!`.

Actors can also operate on themselves or rather they send messages to themselves:

- [`become`](@ref): and actor switches its own behavior,
- [`self`](@ref): an actor gets a link to itself,
- [`stop`](@ref): an actor stops.

## Bidirectional Messages

What if you want to receive a reply from an actor? Then there are two possibilities:

1. [`send!`](@ref) a message to an actor and then [`receive!`] the `Response` asynchronously,
2. [`request!`](@ref): send a message to an actor, **block** and receive the result synchronously.

The following functions do this for specific duties:

- [`call!`](@ref) an actor to execute its behavior function and to return the result,
- [`exec!`](@ref): execute an arbitrary function,
- [`query!`](@ref) an actor's internal state variable.

Note that you should not use blocking when you need to be strictly responsive.

## Actor State

An actor stores a behavior function and arguments to it, results of computations and more. Thus it has [state](@ref state) and its state influences how it behaves.

But it does **not share** state with its environment (only for [diagnostic](diagnosis.md) purposes). The [API](api.md) functions above are a safe way to access actor state.

[^1]: See: The [Actor Model](https://en.wikipedia.org/wiki/Actor_model) on Wikipedia.
[^2]: They build on Julia's concurrency primitives  `@spawn`, `put!` and `take!` (to/from `Channel`s).
[^3]: Actors also execute behavior when they get the [internal messages](messages.md) `Call` or `Cast`.
