# Actor API

The following functions provide a user interface to actors:

## Start

```@docs
Actor
```

## Messages

Messages in `YAActL` have a common abstract type. Only a few predefined messages are exported:

```@docs
Message
Response
Request
Timeout
```

Actors operate with [internal messages](messages.md). Further messages can be implemented by a user. If an actor receives a message other than an internal one, it passes the message as last argument to the behavior function.

Messages are sent and received using the following  primitives:

```@docs
send!
receive!
```

## Actor Control

The following functions control actor behavior and state.

```@docs
become!
cast!
exit!
init!
update!
set!
term!
```

If a behavior function wants to control its own actor, it can use the following functions:

```@docs
become
self
stop
```

## Synchronous Messaging

The following functions send messages to actors causing them to respond. There is one function primitive for this:

```@docs
request!
```

The other functions use it to do specific things:

```@docs
call!
Base.get!
exec!
query!
```

Note that all those functions **block** if you don't provide a response channel.
