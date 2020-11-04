# Actors

```@meta
CurrentModule = YAActL
```

> An Actor is a computational entity that, in response to a message it receives, can concurrently:
>
> - send a finite number of messages to other actors;
> - create a finite number of new actors;
> - designate the behavior to be used for the next message it receives. [^1]

`YAActL` actors are Julia tasks running on a computer or in a network, represented by local or remote [`Link`](@ref)s, channels over which they receive and send [messages](messages.md) [^2]. They:

- *react* to those messages,
- *execute* user defined [behavior functions](behavior.md) when receiving certain messages,
- *change* their behavior upon request,
- *update* their [internal state](@ref state) which influences how they behave.

The following provides an overview of `YAActL` actors:

## Start

In the simplest case with [`Actor`](@ref) we start an actor with a [behavior](behavior.md) function. The following actor when called sends its `threadid`:

```julia
julia> using YAActL, .Threads

julia> act1 = Actor(threadid)               # start an actor who gives its threadid
Link{Channel{Message}}(Channel{Message}(sz_max:32,sz_curr:0), 1, :local)

julia> call!(act1)                          # call it
1

julia> act2 = Actor(parallel(), threadid)   # start a parallel actor
Link{Channel{Message}}(Channel{Message}(sz_max:32,sz_curr:0), 1, :local)

julia> call!(act2)                          # and call it
2

julia> using Distributed

julia> addprocs(1);

julia> @everywhere using YAActL

julia>  act3 = Actor(2, println)            # start a remote actor on pid 2 with a println behavior
Link{RemoteChannel{Channel{Message}}}(RemoteChannel{Channel{Message}}(2, 1, 11), 2, :remote)

julia> call!(act3, "Tell me where you are!") # and call it with an argument
      From worker 2:    Tell me where you are!
```

## Links

When we started our first actor, we got a [link](@ref links) variable `act1` to it. This represents a local channel over which actors can receive and send messages. Our third actor got a `RemoteChannel`. Actors are only represented by their links.

## Messages

`YAActL` actors communicate and act asynchronously on messages. Basically they use only two functions to interact:

- [`send!`](@ref): send a message to an actor,
- [`receive!`](@ref): receive a message from an actor.

They operate on [internal messages](messages.md), all of type [`Message`](@ref), used by the [API](api.md) functions described below.

A user can also implement his own message types and dispatch the actor behavior based on them. For [example](examples/stack.md) a user may implement:

```julia
struct Pop <: Message
    customer::Link
end

struct Push{T} <: Message
    content::T
end
```

Then he can write a function [dispatching](@ref dispatch) on them, start an actor with this behavior and send it `Pop` or `Push` messages.

## Behavior

When actors receive

- arguments from [`cast!`](@ref) or [`call!`](@ref) or
- a [`Request`](@ref) or a user implemented message

they [compose](@ref composition) their owned arguments with the received ones and [dispatch](@ref dispatch) their [behavior](behavior.md) function. Then they store the return value in their internal [`res`](@ref _ACT) variable. 

Following further [our example](examples/stack.md):

```julia
julia> mystack = Actor(stack_node, StackNode(nothing, Link())); # start an actor with a first argument

```

`mystack` represents an actor with a `stack_node` behavior and first argument `StackNode(nothing, Link())`. When it eventually receives a message ...

```julia
julia> send!(mystack, Push(1))        # push 1 on the stack

```

..., it executes `stack_node(StackNode(nothing, Link()), Push(1))`.

## Actor Control

Actors can be controlled with the following functions:

- [`become!`](@ref): cause an actor to switch its behavior,
- [`cast!`](@ref): cause an actor to execute its behavior function,
- [`exit!`](@ref): cause an actor to terminate,
- [`init!`](@ref): tell an actor to execute a function at startup,
- [`set!`](@ref): set an actor's dispatch mode,
- [`term!`](@ref): tell an actor to execute a function when it terminates,
- [`update!`](@ref): update an actor's internal state.

Those functions are wrappers to [internal messages](messages.md) and to [`send!`](@ref).

Actors can also operate on themselves, or rather they send messages to themselves:

- [`become`](@ref): an actor switches its own behavior,
- [`self`](@ref): an actor gets a link to itself,
- [`stop`](@ref): an actor stops.

## Bidirectional Messages

What if you want to receive a reply from an actor? Then there are two possibilities:

1. [`send!`](@ref) a message to an actor and then [`receive!`](@ref) the [`Response`](@ref) asynchronously,
2. [`request!`](@ref): send a message to an actor, **block** and [`receive!`](@ref) the result synchronously.

The following functions do this for specific duties:

- [`call!`](@ref) an actor to execute its behavior function and to send the result,
- [`exec!`](@ref): tell an actor to execute a function and to send the result,
- [`query!`](@ref) tell an actor's to send one of its internal state variables.

If you don't provide those functions with a return link, they will block and return the result. Note that you should not use blocking when you need to be strictly responsive.

## Using the API

The [API](api.md) functions allow to work with actors without using messages explicitly:

```@repl
using YAActL, .Threads # hide
act4 = Actor(parallel(), +, 4) # start an actor adding to 4
exec!(act4, Func(threadid))    # ask it its threadid
cast!(act4, 4)                 # cast it 4
query!(act4, :res)             # query the result
become!(act4, *, 4);           # switch the behavior to *
call!(act4, 4)                 # call it with 4
exec!(act4, Func(broadcast, cos, pi .* (-2:2))) # tell it to exec any function
exit!(act4)                    # stop it
act4.state
```

## Actor Registry

If a parent actor or worker process creates actors, its link is only locally known. It has to be sent to all other actors that want to communicate with it.

Alternatively an actor link can be registered under a name (a `Symbol`). Then any actor in the system can communicate with it by using its name.

## Actor State

An actor stores the behavior function and arguments to it, results of computations and more. Thus it has [state](@ref state) and this influences how it behaves.

But it does **not share** its state variables with its environment (only for [diagnostic](diagnosis.md) purposes). The [API](api.md) functions above are a safe way to access actor state via messaging.

## Actor Local Dictionary

Since actors are Julia tasks, they have a local dictionary in which you can store values. You can use [`task_local_storage`](https://docs.julialang.org/en/v1/base/parallel/#Base.task_local_storage-Tuple{Any}) to access it in behavior functions. But normally the state variable [`sta`](@ref _ACT) and argument passing should be enough to handle values in actors.

[^1]: See: The [Actor Model](https://en.wikipedia.org/wiki/Actor_model) on Wikipedia.
[^2]: They build on Julia's concurrency primitives  `@spawn`, `put!` and `take!` on `Channel`s.
