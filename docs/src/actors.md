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

`YAActL` provides [various commands](api.md) to set, control, trigger and query actor behavior and state.

## Start

In the simplest case we use [`Actor`](@ref) to start an actor with a previously implemented [behavior](behavior.md) and get a [link](links.md) to it.

The following [code](@ref stack_example) starts an actor with a `stack_node` behavior function and some arguments to it.

```julia
mystack = Actor(stack_node, StackNode(nothing, Link()))
```

We can now [`send!`](@ref) messages to `mystack` or do other operations on it.

## Messages

`YAActL` actors operate on [predefined messages](messages.md) all of type [`Message`](@ref). Basically there are only two functions to interact with an actor:

- [`send!`](@ref): send a message to an actor,
- [`receive!`](@ref): receive a message,

Actors process messages asynchronously.

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

Actors execute their behavior function when they receive a `Request` message or another user implemented message [^3].

They pass those messages as the last argument to the behavior function. How actors compose arguments is explained in [Behaviors](behavior.md).

The actor will store the return value in its internal [`res`](@ref _ACT) variable. It can be queried from the actor with [`query!`](@ref).

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

What if you want to receive a reply from an actor? On top of the asynchronous messaging between actors there is an interface with bidirectional synchronous messages:

- [`request!`](@ref): send a message to an actor and receive the result.

The following functions use `request!` and do specific things with it:

- [`call!`](@ref): call an actor to execute its behavior function and to return the result,
- [`get!`](@ref): get an actor's internal state,
- [`exec!`](@ref): tell an actor to execute a function,
- [`query!`](@ref): prompt for the result of the last call to the behavior function.

All those functions - if you don't provide a response link - will establish a private link to an actor, **block**, receive the result and return it. You should not use blocking when you need to be strictly responsive.

## Actor State

The [actor state](@ref state) is internal and is shared with its environment only for diagnostic purposes. The [API](api.md) functions above are a safe way to access actor state.


[^1]: See: The [Actor Model](https://en.wikipedia.org/wiki/Actor_model) on Wikipedia.
[^2]: They build on Julia's concurrency primitives  `@spawn`, `put!` and `take!` (to/from `Channel`s).
[^3]: Actors also execute behavior when they get the [internal messages](messages.md) `Call` or `Cast`.
