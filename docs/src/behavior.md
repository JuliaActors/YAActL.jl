# Behaviors

```@meta
CurrentModule = YAActL
```

An actor's behavior is a ...

> ... function to express what an actor does when it processes a message. [^1]

[As an example](examples/stack.md) we define two behaviors `forward!` and `stack_node`, the latter with two methods, dispatched on the user implemented messages `Push` and `Pop`.

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

Like any Julia function a behavior function can be implemented with different methods. The methods are dispatched ...

> based on the number of arguments given, and on the types of all of the function's arguments [^2].

## [Behavior Dispatch](@id dispatch)

In the above example `stack_node` has two arguments: `sn` and `msg`. The first represents state, the second represents an event. An event happens when a message arrives. The actor already has the state argument and gets the event argument with the message.

1. With its creation as `Actor(stack_node, sn)` the actor gets the first argument `sn`.
2. With a message `msg` it gets the second argument and calls `stack_node(sn, msg)`.
3. Depending on whether the incoming message is a `Pop` or a `Push` one of the two implemented methods is dispatched.

`YAActL` allows to send arguments to actors:

- With [`cast!`](@ref) or [`call!`](@ref) you can send them any arguments.
- Or you can [`send!`](@ref) them a [`Request`](@ref) or a user implemented message.

Then an actor combines its first arguments with the received second arguments and executes the behavior function.

## [Argument Composition](@id composition)

You can [`set!`](@ref) `YAActL` actors into

- `full` dispatch or
- `state` dispatch.

The [`Dispatch`](@ref) mode determines how actors compose arguments and whether they use the returned value of the behavior function to update their internal state.

```@repl
using YAActL # hide
mult2 = Actor(*, 2);  # create a new actor to multiply with 2 in full dispatch
[call!(mult2, i) for i in 1:10]
set!(mult2, state);   # set it to state dispatch
update!(mult2, 2);    # set its state to 2
[call!(mult2, i) for i in 1:10]
query!(mult2)         # query its state
set!(mult2, full);    # back to full dispatch
call!(mult2, 10)      # again it multiplies with 2
```

The two dispatch modes cause quite different behaviors.

## Full Dispatch

With `Actor(stack_node, sn)` we used `full` dispatch. The actor got `sn` as the first argument and can use that to represent state. If it is mutable, the behavior function can change its content. When a message `msg` arrives, the actor takes it as the second argument and composes them to execute the behavior.

To install a behavior function `bhv` and its first arguments `args1...` we have

- [`act = Actor(bhv, args1...)`](@ref Actor) or
- [`become!(act, bhv, args1...)`](@ref become!).

The second arguments `args2...` get delivered with

- [`call!(act, args2...)`](@ref call!) or
- [`cast!(act, args2...)`](@ref cast!) or
- [`send!(act, msg)`](@ref send!).

The actor then calls

- `bhv((args1..., args2...)...)` or
- `bhv((args1..., msg)...)` respectively.

Empty arguments for `args1...` or `args2...` are allowed as long as their composition can be used to dispatch the behavior function `bhv`.

## State Dispatch

In `state` dispatch an actor uses its internal state [`sta`](@ref _ACT) as first argument to the behavior function. On a message `msg` it calls the behavior as `bhv(sta, msg)` and saves the returned value back to its internal state variable `sta`. Thus it operates as a [finite-state machine](https://en.wikipedia.org/wiki/Finite-state_machine).

A behavior `bhv` is installed without arguments[^3] as

- [`act = Actor(bhv)`](@ref Actor) or
- [`become!(act, bhv)`](@ref become!).

Actor state [`sta`](@ref _ACT) can be set 

- with [`update!(act, args1...)`](@ref update!) or
- by an [`init`](@ref _ACT) function installed with [`init!`](@ref).

The second arguments `args2...` get delivered with

- [`call!(act, args2...)`](@ref call!) or
- [`cast!(act, args2...)`](@ref cast!) or
- [`send!(act, msg)`](@ref send!).

and the actor calls

- `bhv((sta, args2...)...)` or
- `bhv((sta, msg)...)` respectively

and updates `sta` with the returned value `y`. At the next call the behavior `bhv` gets dispatched with the updated status and the new message.

!!! note "Status is updated if behavior returns something."

    The actor updates `sta` only if its behavior function returns something. If you want your behavior to not update `sta`, let it `return nothing`. 

## Keyword Arguments

In both modes an actor passes keyword arguments `kwargs...` to the behavior function. Those are not dispatched on but they too represent state and therefore can change the function result.

## Control of Actor Behavior

The described mechanisms allow a fine-grained control of an actor's behavior:

1. Set an actor's behavior function at startup or with `become!`.
2. Control the dynamic dispatch of implemented behavior methods with
    - the actor's dispatch mode,
    - the first arguments  
        - either of the behavior function in `full` dispatch,
        - or the actor state `sta` in `state` dispatch,
    - the second arguments from the incoming message.
3. Control the result of the dispatched function or method by setting the values of arguments and keyword arguments[^4].

This allows actors to use Julia's full expressiveness with functions and methods.

[^1]: see the [Actor Model](https://en.wikipedia.org/wiki/Actor_model#Behaviors) on Wikipedia.
[^2]: from [Methods](https://docs.julialang.org/en/v1/manual/methods/) in the Julia manual.
[^3]: arguments `arg1...` to the behavior function are simply ignored in `state` dispatch.
[^4]: you can also dispatch on values by using [`Val`](https://docs.julialang.org/en/v1/base/base/#Base.Val)
