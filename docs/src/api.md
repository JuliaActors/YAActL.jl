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
RLink
LINK
```

Actors correspond with other actors over links. There is a default link for users to communicate with actors.

```@docs
USR
```

For setting up links explicitly we have the following functions.

```@docs
newLink
LinkParams
parallel
```

We send messages to actors and they can send them to others over links.

## Messages

Messages in `YAActL` have a common abstract type. Only a few predefined messages are exported:

```@docs
Message
Response
Request
Timeout
```

Actors operate with [internal messages](messages.md). Further messages can be implemented by a user. If an actor receives a message other than an internal one, it passes the message as last argument to the behavior function.

## Send and Receive

Messages are sent and received using the following basic functions:

```@docs
send!
receive!
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

1. Send a message with an explicit `from`-link to an actor and it will respond to it. Then you can asynchronously [`receive!`](@ref) the response.
2. Send a message with an implicit link to an actor, block, wait for the response and return it.

```@docs
call!
exec!
query!
```

## Actor Supervision

This is not yet implemented.

```@docs
init!
term!
```

[^1]: bidirectional [messages](messages.md) are `Call`, `Get`, `Exec` and `Query`.
