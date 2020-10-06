# Behaviors

```@meta
CurrentModule = YAActL
```

An actor's behavior is a ...

> ... function to express what an actor does when it processes a message. [^1]

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

In the above example the actor dispatches the `stack_node` methods depending on whether the incoming message is a `Pop` or a `Push`. 

1. On its creation as `Actor(stack_node, sn)` it gets only the first argument `sn` to the `stack_node` function. 
2. With a message `msg` it gets the second argument, **composes** it with the first and calls  the behavior as `stack_node(sn, msg)`.

If the actor tries to pass another message than `Pop` or `Push` to `stacknode(sn, msg)`, it will fail with an `ArgumentError` since only two methods are implemented.

You can implement an ``\epsilon`` default method – if you mind – returning `nothing` on every other [`Message`](@ref). Then the actor will do nothing and not fail.

## [Argument Composition](@id composition)

`YAActL` actors have two ways

- to compose the arguments to the behavior function and
- to use its returned value.

This is determined by their dispatch mode:

```@docs
Dispatch
```

You can set the dispatch mode with [`set!`](@ref).

## Full Dispatch

Above we used `full` dispatch. With `Actor(stack_node, sn)` the actor got `sn` as the first argument and can use that to represent state. If `sn` is mutable, a behavior function can even change its content. When a message `msg` arrives, the actor takes it as the second argument and composes both to execute the behavior.

The `YAActL` [API](@ref api) allows arbitrary arguments to a behavior function. You install a behavior `bhv` and deliver the *first part* of the arguments `args1...` with

- [`act = Actor(bhv, args1...)`](@ref Actor) or
- [`become!(act, bhv, args1...)`](@ref become!).

The second part `args2...` gets delivered with

- [`call!(act, args2...)`](@ref call!) or
- [`cast!(act, args2...)`](@ref cast!) or
- [`send!(act, msg)`](@ref send!).

The actor then calls 

- `bhv((args1..., args2...)...)` or
- `bhv((args1..., msg)...)` respectively. 

Empty arguments `args1...` or `args2...` are allowed as long as their composition can used to dispatch the behavior function `bhv`.

## State Dispatch

In `state` dispatch an actor uses its internal state [`sta`](@ref _ACT) as first argument to the behavior function. When a message `msg` arrives, it calls the behavior as `bhv(sta, msg)` and saves the returned value in its internal state variable `sta`. Thus it operates as a [finite-state machine](https://en.wikipedia.org/wiki/Finite-state_machine). This is a more functional approach. 

A behavior `bhv` is installed without arguments[^3] as

- [`act = Actor(bhv)`](@ref Actor) or
- [`become!(act, bhv)`](@ref become!).

Actor state [`sta`](@ref _ACT) can be set with

- [`init!(act, args1...)`](@ref init!) and
- [`update!(act, args1...)`](@ref update!).

As above the second part `args2...` gets delivered with

- [`call!(act, args2...)`](@ref call!) or
- [`cast!(act, args2...)`](@ref cast!) or
- [`send!(act, msg)`](@ref send!).

and the actor calls

- `bhv((sta..., args2...)...)` or
- `bhv((sta..., msg)...)` respectively

and updates `sta` with the returned value. At the next call the behavior `bhv` gets dispatched with the updated status and the new message.

## Keyword Arguments

In both modes actor passes keyword arguments `kwargs...` to the behavior function. Those are not dispatched on but they too represent state.

## Control of Actor Behavior

The described mechanisms allow a fine-grained control of an actor's behavior:

1. An actor's behavior function can be set at its start or by switching behavior.
2. If a behavior function has multiple methods, they are dynamically dispatched with the argument types. Those depend on
    - the dispatch mode,
    - the first arguments delivered with the behavior function,
    - eventually the current actor state and
    - the incoming message.
3. The values of arguments and keyword arguments usually are not dispatched on[^4] but change a behavior function's outcome.

This allows the use of the full range of possibilities offered by Julia's functions with actors.

[^1]: see the [Actor Model](https://en.wikipedia.org/wiki/Actor_model#Behaviors) on Wikipedia.
[^2]: see also [JuliaCon 2019 | The Unreasonable Effectiveness of Multiple Dispatch | Stefan Karpinski](https://www.youtube.com/watch?v=kc9HwsxE1OY).
[^3]: arguments `arg1...` to the behavior function are simply ignored in `state` dispatch.
[^4]: you can dispatch on values by using [`Val`](https://docs.julialang.org/en/v1/base/base/#Base.Val)
