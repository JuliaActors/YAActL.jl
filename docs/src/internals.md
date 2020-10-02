# [Actor State](@id state)

```@meta
CurrentModule = YAActL
```

Actors have an internal state variable where they store behavior and state.

```@docs
_ACT
```

Functions executed by an actor have access to their actor's `ACT` variable via `task_local_storage("ACT")`.

Normally this is not needed. For accessing the actor's link there is [`self()`](@ref self).

## Updating State

To avoid critical [race conditions](https://en.wikipedia.org/wiki/Race_condition) in multithreaded programs actors don't share their internal state with the environment. Only the actor itself is allowed to update its state in a strictly sequential manner by processing message after message.

Other actors or users therefore can cause an actor to update its state only by sending it a message, which is done implicitly by using the [API](@ref api) functions.
