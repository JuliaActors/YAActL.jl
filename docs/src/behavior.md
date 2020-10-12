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

For controlling actor behavior `YAActL` uses Julia's multiple dispatch [^2].

## [Behavior Dispatch](@id dispatch)

A behavior function can be implemented with different methods. Then the methods are dispatched ...

> based on the number of arguments given, and on the types of all of the function's arguments [^3].

`YAActL` actors pass the incoming message as last argument to the behavior function.   

1. Our behavior function call is `stack_node(sn, msg)`.
2. After its creation as `Actor(stack_node, sn)` the actor has only the first argument `sn` to the behavior.
3. With a message `msg` it gets the second argument and calls the behavior as `stack_node(sn, msg)`.
4. Depending on whether the incoming message is a `Pop` or a `Push` one of the two implemented methods is dispatched.

If the actor tries to pass another message to `stacknode`, it will fail with an `ArgumentError` since only two methods are implemented.

You can implement an ``\epsilon`` default method – if you mind – returning `nothing` on every other [`Message`](@ref). Then the actor will do nothing with an unknown message and not fail.

## [Argument Composition](@id composition)

`YAActL` actors have two modes to compose the arguments to the behavior function and to use its returned value:

```@docs
Dispatch
```

You can set the dispatch mode with [`set!`](@ref).

## Full Dispatch

Above we used `full` dispatch. With `Actor(stack_node, sn)` the actor got `sn` as the first argument and can use that to represent state. If `sn` is mutable, a behavior function can even change its content. When a message `msg` arrives, the actor takes it as the second argument and composes them to execute the behavior.

The `YAActL` [API](api.md) allows arbitrary arguments to a behavior function. To install a predefined behavior function `bhv` and to deliver the *first part* of its arguments `args1...` we have

- [`act = Actor(bhv, args1...)`](@ref Actor) or
- [`become!(act, bhv, args1...)`](@ref become!).

The second part `args2...` gets delivered with

- [`call!(act, args2...)`](@ref call!) or
- [`cast!(act, args2...)`](@ref cast!) or
- [`send!(act, msg)`](@ref send!).

The actor then calls

- `bhv((args1..., args2...)...)` or
- `bhv((args1..., msg)...)` respectively. 

Empty arguments `args1...` or `args2...` are allowed as long as their composition can be used to dispatch the behavior function `bhv`.

## State Dispatch

In `state` dispatch an actor uses its internal state [`sta`](@ref _ACT) as first argument to the behavior function. On a message `msg` it calls the behavior as `bhv(sta, msg)` and saves the returned value in its internal state variable `sta`. Thus it operates as a [finite-state machine](https://en.wikipedia.org/wiki/Finite-state_machine). This is a more functional approach.

A behavior `bhv` is installed without arguments[^4] as

- [`act = Actor(bhv)`](@ref Actor) or
- [`become!(act, bhv)`](@ref become!).

Actor state [`sta`](@ref _ACT) can be set with

- [`init!(act, args1...)`](@ref init!) and
- [`update!(act, args1...)`](@ref update!).

The second part `args2...` gets delivered with

- [`call!(act, args2...)`](@ref call!) or
- [`cast!(act, args2...)`](@ref cast!) or
- [`send!(act, msg)`](@ref send!).

and the actor calls

- `bhv((sta..., args2...)...)` or
- `bhv((sta..., msg)...)` respectively

and updates `sta` with the returned value `y`. At the next call the behavior `bhv` gets dispatched with the updated status and the new message.

!!! note "Update occurs only if `!isnothing(y)`."

    The actor updates `sta` only if its behavior function returns something rather than `nothing`. If you want to avoid updating `sta`, let it `return nothing`. 

## Keyword Arguments

In both modes an actor passes keyword arguments `kwargs...` to the behavior function. Those are not dispatched on but they too represent state and therefore can change the function result.

## Control of Actor Behavior

The described mechanisms allow a fine-grained control of an actor's behavior:

1. Set an actor's *behavior function* at startup or by `become!`.
2. Control the *dynamic dispatch* of implemented behavior methods with
    - the actor's *dispatch mode*,
    - the *first arguments* delivered 
        - either with the behavior function in `full` dispatch,
        - or by setting the actor state in `state` dispatch,
    - the *second arguments* delivered with the incoming message.
3. Control the *outcome* of the dispatched function or method by setting the *values* of arguments and keyword arguments[^5].

This allows actors to use Julia's full expressiveness with functions and methods.

[^1]: see the [Actor Model](https://en.wikipedia.org/wiki/Actor_model#Behaviors) on Wikipedia.
[^2]: see also [JuliaCon 2019 | The Unreasonable Effectiveness of Multiple Dispatch | Stefan Karpinski](https://www.youtube.com/watch?v=kc9HwsxE1OY).
[^3]: from [Methods](https://docs.julialang.org/en/v1/manual/methods/) in the Julia manual.
[^4]: arguments `arg1...` to the behavior function are simply ignored in `state` dispatch.
[^5]: you can also dispatch on values by using [`Val`](https://docs.julialang.org/en/v1/base/base/#Base.Val)
