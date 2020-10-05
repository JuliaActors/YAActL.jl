# [Actor State](@id state)

```@meta
CurrentModule = YAActL
```

`YAActL` follows Julia's philosophy in giving the user responsibility for access to internals and implementing correct programs:

> You are entirely responsible for ensuring that your program is data-race free, and nothing promised here can be assumed if you do not observe that requirement. The observed results may be highly unintuitive. [^1]

> When using multi-threading we have to be careful when using functions that are not pure as we might get a wrong answer. [^2]

Since concurrency is the overarching theme of actor programming and behavior functions must access data to do their job, [data-race](https://en.wikipedia.org/wiki/Race_condition#Data_race) freedom is a major concern in working with actors. As a ground rule **actors don't share state**.

## Internal State

Actors have an internal mutable state variable: 

```@docs
_ACT
```

Functions executed by an actor can access their actor's internal `ACT` variable via `task_local_storage("ACT")`. 
Normally this is not needed.

We must express two important concerns regarding actor state:

!!! note "Actor state is multifaceted!"

    Actor state is not a single value but includes behavior functions, arguments and an explicit mutable state variable, which is used for `state` [`Dispatch`](@ref) or for representing agents.

!!! warning "Sharing state can cause critical race conditions!"

    You must be careful **not to share** any of the state variables between actors in order to avoid critical [race conditions](https://en.wikipedia.org/wiki/Race_condition).

## Create Private Actor State

The returned value of the [`init!`](@ref) function is saved as an actors state `sta`. It is a good practice to have an init function to create a private actor state with defined initial parameters.

Be careful to [`update!`](@ref) the actor's state since it overwrites it. Don't update it with a shared variable.

## Update Actor State

Only the actor itself is allowed to update its state in a strictly sequential manner by processing message after message.

Other actors or users can cause an actor to update its state by sending it a message, which is done implicitly by using the [API](@ref api) functions.

## Behavior Function Arguments

Julia functions accept mutable types as parameters and  can change their values. If your behavior functions get mutable types as parameters, you must ensure that

- either you don't share those variables between actors
- or you don't change them by using only [pure functions](https://en.wikipedia.org/wiki/Pure_function) as behavior.

## Global State

Race conditions can happen if actors in parallel use or modify global variables. The best advice is not to use global variables or at least not to share them between actors.

If for some reason you want to use global variables and share them between actors, you must use the [lock pattern](https://docs.julialang.org/en/v1/manual/multi-threading/#Data-race-freedom) or [atomic operations](https://docs.julialang.org/en/v1/manual/multi-threading/#Atomic-Operations) described in the Julia manual. But both approaches **block** an actor until it succeeds to access the variable.

[^1]: see: [Data-race freedom](https://docs.julialang.org/en/v1/manual/multi-threading/#Data-race-freedom) in the Julia manual.
[^2]: see: [Side effects and mutable function arguments](https://docs.julialang.org/en/v1/manual/multi-threading/#Side-effects-and-mutable-function-arguments) in the Julia manual.
