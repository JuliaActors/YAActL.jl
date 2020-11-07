# Actors

```@meta
CurrentModule = YAActL
```

> An Actor is a computational entity that, in response to a message it receives, can concurrently:
>
> - send a finite number of messages to other actors;
> - create a finite number of new actors;
> - designate the behavior to be used for the next message it receives. [^1]

`YAActL` actors are Julia `Task`s running on a computer or in a network, represented by local or remote [`Link`](@ref)s, channels over which they receive and send [messages](messages.md) [^2]. They:

- *react* to those messages,
- *execute* a user defined [behavior function](behavior.md) when they receive certain messages,
- *change* their behavior upon request,
- *update* their [internal state](@ref state) which influences how they behave.

The following provides an overview of `YAActL` actors:

## Start

In the simplest case we start an [`Actor`](@ref) with a [behavior](behavior.md) function:

```@repl
using YAActL, .Threads
act1 = Actor(threadid)               # start an actor who gives its threadid
call!(act1)                          # call it
act2 = Actor(parallel(), threadid)   # start a parallel actor
call!(act2)                          # and call it
using Distributed
addprocs(1);
@everywhere using YAActL
act3 = Actor(2, println)            # start a remote actor on pid 2 with a println behavior
call!(act3, "Tell me where you are!") # and call it with an argument
```

## Links

When we started our first actor, we got a [`Link`](@ref) to it. This represents a local `Channel` over which actors can receive and send messages. Our third actor got a link with a `RemoteChannel`. Actors are only represented by their links.

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
2. [`request!`](@ref): send a message to an actor, **block** and receive the result synchronously.

The following functions do this for specific duties:

- [`call!`](@ref) an actor to execute its behavior function and to send the result,
- [`exec!`](@ref): tell an actor to execute a function and to send the result,
- [`query!`](@ref) tell an actor's to send one of its internal state variables.

If you provide those functions with a return link, they will use [`send!`](@ref) and you can then [`receive!`](@ref) the [`Response`](@ref) from the return link. If you 
don't provide a return link, they will use [`request!`](@ref) to block and return the result. Note that you should not use blocking when you need to be strictly responsive.

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

If a parent actor or worker process creates a new actor, the link to it is only locally known. It has to be sent to all other actors that want to communicate with it.

Alternatively an actor link can be registered under a name (a `Symbol`). Then any actor in the system can communicate with it using that name.

```julia
julia> using YAActL, Distributed

julia> addprocs(1);

julia> @everywhere using YAActL

julia> @everywhere function ident(id, from)
           id == from ?
               ("local actor",  id, from) :
               ("remote actor", id, from)
       end

julia> register(:act1, Actor(ident, 1))       # a registered local actor
true

julia> call!(:act1, myid())                   # call! it
("local actor", 1, 1)

julia> register(:act2, Actor(2, ident, 2))    # a registered remote actor on pid 2
true

julia> call!(:act2, myid())                   # call! it
("remote actor", 2, 1)

julia> fetch(@spawnat 2 call!(:act1, myid())) # call! :act1 on pid 2
("remote actor", 1, 2)

julia> fetch(@spawnat 2 call!(:act2, myid())) # call! :act2 on pid 2
("local actor", 2, 2)

julia> whereis(:act1)                         # get a link to :act1
Link{Channel{Message}}(Channel{Message}(sz_max:32,sz_curr:0), 1, :local)

julia> whereis(:act2)                         # get a link to :act2
Link{RemoteChannel{Channel{Message}}}(RemoteChannel{Channel{Message}}(2, 1, 383), 2, :remote)

julia> fetch(@spawnat 2 whereis(:act1))       # get a link to :act1 on pid 2
Link{RemoteChannel{Channel{Message}}}(RemoteChannel{Channel{Message}}(1, 1, 407), 1, :remote)

julia> registered()                           # get a list of registered actors
2-element Array{Pair{Symbol,Link},1}:
 :act2 => Link{RemoteChannel{Channel{Message}}}(RemoteChannel{Channel{Message}}(2, 1, 383), 2, :remote)
 :act1 => Link{Channel{Message}}(Channel{Message}(sz_max:32,sz_curr:0), 1, :local)

julia> fetch(@spawnat 2 registered())         # get it on pid 2
2-element Array{Pair{Symbol,Link{RemoteChannel{Channel{Message}}}},1}:
 :act2 => Link{RemoteChannel{Channel{Message}}}(RemoteChannel{Channel{Message}}(2, 1, 383), 2, :remote)
 :act1 => Link{RemoteChannel{Channel{Message}}}(RemoteChannel{Channel{Message}}(1, 1, 413), 1, :remote)
```

The registry works transparently across workers. All workers have access to registered actors on other workers via remote links.

## Actor Isolation

In order to avoid race conditions actors have to be strongly isolated from each other:

1. they do not share state,
2. they must not share mutable variables.

An actor stores the behavior function and arguments to it, results of computations and more. Thus it has [state](@ref state) and this influences how it behaves.

But it does **not share** its state variables with its environment (only for [diagnostic](diagnosis.md) purposes). The [API](api.md) functions above are a safe way to access actor state via messaging.

Mutable variables in Julia can be sent over local channels without being copied. Accessing those variables from multiple threads can cause race conditions. The programmer has to be careful to avoid those situations either by

- not sharing them between actors,
- copying them when sending them to actors or
- acquiring a lock around any access to data that can be observed from multiple threads. [^3]

When sending mutable variables over remote links, they are automatically copied.

## Actor Local Dictionary

Since actors are Julia tasks, they have a local dictionary in which you can store values. You can use [`task_local_storage`](https://docs.julialang.org/en/v1/base/parallel/#Base.task_local_storage-Tuple{Any}) to access it in behavior functions. But normally the state variable [`sta`](@ref _ACT) and argument passing should be enough to handle values in actors.

[^1]: See: The [Actor Model](https://en.wikipedia.org/wiki/Actor_model) on Wikipedia.
[^2]: They build on Julia's concurrency primitives  `@spawn`, `put!` and `take!` on `Channel`s.
[^3]: see [Data race freedom](https://docs.julialang.org/en/v1/manual/multi-threading/#Data-race-freedom) in the Julia manual.
