# Actors

> An Actor is a computational entity that, in response to a message it receives, can concurrently:
>
> - send a finite number of messages to other actors;
> - create a finite number of new actors;
> - designate the behavior to be used for the next message it receives. [^1]

`YAActL` actors are Julia tasks represented by a local or remote [`LINK`](@ref), a channel over which they receive and send [messages](messages.md) [^2]. They:

- *react* to those messages,
- *execute* a user defined [behavior function](behavior.md) when receiving certain messages,
- *change* their behavior upon request,
- *update* their [internal state](@ref state) influencing how they behave.

`YAActL` provides [various commands](@ref api) to set, control, trigger and query actor behavior and state.

## Start

In the simplest case we start an `Actor` with a predefined [behavior](behavior.md) and get a [link](links.md) to it.

```@docs
Actor
```

The following [code](@ref stack_example) starts an actor with a `stack_node` behavior function and some arguments to it.

```julia
mystack = Actor(stack_node, StackNode(nothing, Link()))
```

We can now [`send!`](@ref) messages to `mystack` or do other operations on it.

## Operation

An actor recognizes and operates on [predefined messages](messages.md). Basically there are only two functions to interact with an actor:

- [`send!`](@ref): send a message to an actor,
- [`receive!`](@ref): receive a message,
- [`request!`](@ref): send a message to an actor, block, receive and return the result.

```@docs
send!
receive!
request!
```

## Message API

Users can interact with actors with explicit messages:

```@docs
Message
Response
Request
Timeout
```

If an actor receives a `Request` message or any other not [predefined message](messages.md), it executes its [behavior function](behavior.md) with this message as the last argument.

This mechanism can be employed to extend the actor's behavior. A user can implement further message types. For example:

```julia
struct Pop <: Message
    customer::Link
end

struct Push{T} <: Message
    content::T
end
```

## [User API](@id api)

The following interface to actors is for common use:

- [`become!`](@ref): cause an actor to switch its behavior,
- [`call!`](@ref): call an actor to execute its behavior function and to return the result,
- [`cast!`](@ref): cause an actor to execute its behavior function,
- [`get`](@ref): get an actor's internal state,
- [`init!`](@ref): tell an actor to execute a function at startup,
- [`query`](@ref): prompt for the result of the last call to the behavior function,
- [`self`](@ref): get your actor's link,
- [`set!`](@ref): set the actor's dispatch mode,
- [`stopActor!`](@ref): terminate an actor,
- [`terminate!`](@ref): tell an actor to execute a function when it terminates.
- [`update!`](@ref): update an actor's internal state,

Those functions are wrappers to the [predefined messages](messages.md) and to the `send!` or `request!` functions. They all involve a communication.

```@docs
become!
call!
cast!
Base.get
init!
query
update!
set!
stopActor!
terminate!
```

Actors can also operate on themselves or rather they send messages to themselves:

- [`become`](@ref): and actor switches its own behavior,
- [`self`](@ref): an actor gets a link to itself,
- [`stopActor`](@ref): an actor stops.

```@docs
become
self
stopActor
```

## Actor State

The [actor state](@ref state) is internal and is shared with its environment only for diagnostic purposes. The [API](@ref api) functions above are a safe way to access actor state.


[^1]: See: The [Actor Model](https://en.wikipedia.org/wiki/Actor_model) on Wikipedia.
[^2]: They build on Julia's concurrency primitives  `@spawn`, `put!` and `take!` (to/from `Channel`s).
