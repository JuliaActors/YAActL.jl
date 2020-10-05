# Behaviors

```@meta
CurrentModule = YAActL
```

An actor's behavior is a

> function to express what an actor does when it processes a message [^1]

In the following example we define two behaviors `forward!` and `stack_node`. There are two methods for `stack_node`, dispatching on `Push` and `Pop`.

```julia
forward!(lk::L, msg::M) where {L<:Link, M<:Message} = send!(lk, msg)

function stack_node(sn::StackNode, msg::Pop)
    isnothing(sn.content) || become(forward!, sn.link)
    send!(msg.customer, Response(sn.content))
end

function stack_node(sn::StackNode, msg::Push)
    P = Actor(stack_node, sn)
    become(stack_node, StackNode(msg.content, P))
end
```

## [Behavior Dispatch](@id dispatch)

A behavior function can be implemented with different methods. Then Julia [dispatches the methods](https://docs.julialang.org/en/v1/manual/methods/) based on the function arguments [^2].

`YAActL` actors use multiple dispatch of behavior methods by passing the incoming message as last argument to the behavior function.

In the above example the actor dispatches the `stack_node` methods regarding to whether the incoming message is a `Pop` or a `Push`. On its creation as `Actor(stack_node, sn)` it gets only the first argument `sn` to the `stack_node` function. When a message `msg` arrives, it gets the second argument and can **compose** the arguments to the behavior and call it as `stack_node(sn, msg)`.

If the actor tries to pass another message than `Pop` or `Push` to `stacknode(sn, msg)` it will fail with an `ArgumentError`.

## Dispatch Mode

An actor's dispatch mode determines how it

1. composes the arguments to the behavior function and
2. uses the function's returned value.

```@docs
Dispatch
```

Above we used `full` dispatch. With `Actor(stack_node, sn)` the actor got `sn` as the first argument and can use that to represent state. If it is mutable, a behavior function can even change its content.

With `state` dispatch mode we use the actors internal state [`sta`](@ref _ACT) as first argument to the behavior function. When a message `msg` arrives, the actor calls its behavior function as `bhv(sta, msg)` and saves the returned value in its internal state variable `sta`. Thus it is possible to implement a [finite-state machine](https://en.wikipedia.org/wiki/Finite-state_machine). This is a more functional approach.

Note that actor state can be set with [`init!`](@ref) and [`update!`](@ref).

## [More on Argument Composition](@id composition)

The `YAActL` [API](@ref api) allows to send arbitrary arguments to a behavior function. First you install an actor behavior `bhv` with

- [`act = Actor(bhv, args1...)`](@ref Actor) or
- [`become!(act, bhv, args1...)`](@ref become!).

Then you deliver the second part of the arguments with 

- [`call!(act, args2...)`](@ref call!) or
- [`cast!(act, args2...)`](@ref cast!) or
- [`send!(act, msg`](@ref send!).

The `act` actor then executes `bhv((args1..., args2...)...)` or `bhv((args1..., msg)...)` respectively. Also empty arguments `args1...` or `args2...` are allowed as long as their composition is understood by the behavior function `bhv`.

The actor eventually passes keyword arguments `kwargs...` to the behavior function. But those are not dispatched on.

As programmer of an actor system you influence this mechanism in three ways:

- First you implement the needed behavior methods with the full number of arguments.
- In setting the actor's dispatch mode with [`set!`](@ref) and by delivering the first part of arguments to the behavior function in [`Actor`](@ref) and [`become!`](@ref) you determine the state-dependent arguments.
- In delivering messages with [`call!`](@ref), [`cast!`](@ref) and [`send!`](@ref) you determine the (message-dependent) second part of arguments.

All this can be used to implement quite complex actor behavior

## Changing Behavior

An actor's behavior can be set with [`become!`](@ref) and respectively behavior functions can cause their actor to switch to another behavior with [`become`](@ref).

[^1]: see the [Actor Model](https://en.wikipedia.org/wiki/Actor_model#Behaviors) on Wikipedia
[^2]: see also [JuliaCon 2019 | The Unreasonable Effectiveness of Multiple Dispatch | Stefan Karpinski](https://www.youtube.com/watch?v=kc9HwsxE1OY)
