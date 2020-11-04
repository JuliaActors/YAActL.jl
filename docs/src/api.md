# Actor API

```@meta
CurrentModule = YAActL
```

## Installation

```@docs
YAActL
YAActL.version
```

```@repl
using YAActL
YAActL.version
```

The following functions provide a user interface to actors:

## Start

```@docs
Actor
```

## [Links](@id links)

An actor is only represented by its link which it returns upon creation:

```@docs
Link
islocal
```

Actors correspond with other actors over links. There is a default link for users to communicate with actors.

```@docs
USR
```

For setting up links explicitly we have the following functions.

```@docs
LinkParams
parallel
```

Actors can [`send!`](@ref) and [`receive!`](@ref) messages over links.

## Messages

Messages in `YAActL` have a common abstract type. Only a few predefined messages are exported:

```@docs
Message
Response
Request
Timeout
```

Actors operate with [internal messages](messages.md). Further messages can be implemented by a user. If an actor receives a `Request` or a user implemented message, it passes it as last argument to the behavior function.

## Send and Receive

Messages are sent and received using the following basic functions:

```@docs
send!
receive!
```

```julia
julia> myactor = Actor(parallel(), threadid);

julia> send!(myactor, YAActL.Call(USR)); # the same as call!(myactor, USR)

julia> receive!(USR).y                   # receive the result
2

julia> receive!(USR)                     # gives after some seconds ...
Timeout()
```

## Dispatch mode

Actors have a dispatch mode:

```@docs
Dispatch
```

```julia
julia> set!(myactor, state)              # set state dispatch
YAActL.Update{Dispatch}(:dsp, state)

julia> set!(myactor, full)               # set full dispatch
YAActL.Update{Dispatch}(:dsp, full)
```

## Actor Control

The following functions control actor behavior and state by sending implicit messages. Actors don't send a `Response` to those.

```@docs
become!
cast!
exit!
set!
update!
```

If a behavior function wants to control its own actor, it can use the following functions:

```@docs
become
self
stop
```

## Bidirectional Messaging

Some messages to actors cause them to send a [`Response`](@ref) [^1]. The exchange of messages may be carried out asynchronously, or may use a synchronous "rendezvous" style in which the sender blocks until the message is received.

`YAActL` has a primitive for synchronous communication:

```@docs
request!
```

The following functions support both messaging styles:

1. Send a message with an explicit `from`-link to an actor and it will respond to this link. Then you can  asynchronously [`receive!`](@ref) the response from it.
2. Send a message with an implicit link to an actor, block, wait for the response and return it.

```@docs
call!
exec!
query!
```

## Actor Registry

Actors can be registered with `Symbol`s to a registry. API functions on actors can then be called with their registered names.

```@docs
register
unregister
whereis
registered
```

The registry works transparently over distributed worker processes such that local links are transformed to remote links when shared between workers.

## Actor Supervision

This is not yet implemented.

```@docs
init!
term!
```

[^1]: bidirectional [messages](messages.md) are `Call`, `Get`, `Exec` and `Query`.
