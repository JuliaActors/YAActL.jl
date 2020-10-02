# Behaviors

An actor behavior is implemented by different methods of a behavior function. When a message arrives, the actor  composes the arguments to its behavior function based on its current state and on the incoming message. This causes a dispatch of one implemented behavior methods.

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

[Multiple dispatch](https://docs.julialang.org/en/v1/manual/methods/) is arguably one of Julia's strongest features [^1]. `YAActL` actors compose the arguments to the behavior function and thus dispatch one of its implemented methods.

An actor's dispatch mode determines how it

1. composes the arguments to the behavior function and
2. uses the function's returned value.

```@docs
Dispatch
```

The user must implement the needed methods for the behavior dispatch.

## [Argument Composition](@id composition)

When a message arrives, an actor calls its current behavior function. It composes the function arguments from two parts:

1. the first part is stored in the actor,
2. the second part is taken from the message.

Both parts are `Tuple`s and can have multiple arguments and then are composed to form the `args...` to the behavior function. Then the dispatch happens-

The actor eventually passes keyword arguments `kwargs...` to the behavior function. But those are not dispatched on.

As user or programmer of an actor system you influence this mechanism in three ways:

- First you implement the needed behavior methods with the full number of arguments.
- In setting the actor's dispatch mode with [`set!`](@ref) and by delivering arguments to the behavior function in [`Actor`](@ref) and [`become!`](@ref) you determine the  state-dependent arguments.
- In delivering messages with [`call!`](@ref), [`cast!`](@ref) and [`send!`](@ref) you determine the message-dependent arguments.

## Changing Behavior

An actor's behavior can be set with [`become!`](@ref) and respectively behavior functions can cause their actor to switch to another behavior.

[^1]: see also [JuliaCon 2019 | The Unreasonable Effectiveness of Multiple Dispatch | Stefan Karpinski](https://www.youtube.com/watch?v=kc9HwsxE1OY)
