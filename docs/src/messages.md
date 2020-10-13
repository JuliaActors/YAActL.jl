# Messages

```@meta
CurrentModule = YAActL
```

Messages to `YAActL` actors have [`Message`](@ref) as a common abstract type. Only three predefined messages are exported:

- [`Response`](@ref): response message type from actor to any synchronous message (requiring a response),
- [`Request`](@ref): predefined message type for implementing requests to actors.
- [`Timeout`](@ref): answer of [`receive!`](@ref) when a timeout occurs.

Messages other than the predefined ones can be implemented by a user.

## Functions and Arguments

There are two types needed for transmitting functions and function arguments to actors with messages:

```@docs
Func
Args
```

## Internal Messages

Actors recognize and react to the following predefined internal messages:

```@docs
Become
Call
Cast
Diag
Exec
Init
Query
Stop
Term
Update
```

Those messages are interfaced by the functions in the `YAActL` [API](api.md).

If an actor receives another subtype of `Message`, it calls its behavior function with it as last argument.
