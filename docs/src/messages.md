# Messages

```@meta
CurrentModule = YAActL
```

Messages to `YAActL` actors have [`Message`](@ref) as a common abstract type. Below the predefined messages are explained. Only two of them are exported:

- [`Response`](@ref): response message type from actor to any synchronous message (requiring a response),
- [`Request`](@ref): predefined message type for implementing requests to actors.

Messages other than the predefined ones can be implemented by a user.

## Functions and Arguments

There are two predefined types for messages with functions and function arguments:

```@docs
Func
Args
```

## Internal Messages

Actors recognize and react to the following predefined messages:

```@docs
Become
Call
Cast
Diag
Exec
Get
Init
Query
Set
Stop
Term
Update
```

If an actor receives another subtype of `Message`, it calls its behavior function with it as last argument.
