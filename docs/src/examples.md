# Examples

## A Stack

This is Agha's example 3.2.1. It implements a stack as a collection of actors with two operations/messages `Push` and `Pop`. A `StackNode` stores a content and a [`Link`](@ref) to the next [`Actor`](@ref) in the chain.

> The top of the stack is the only receptionist in the stack system and was the only actor of the stack system created externally. It is created with a NIL content which is assumed to be the bottom of the stack marker. Notice that no mail address of a stack node is ever communicated by any node to an external actor. Therefore no actor outside the configuration defined above can affect any of the actors inside the stack except by sending the receptionist a communication. When a *pop* operation is done, the actor on top of the stack simply becomes a *forwarder* to the next actor in the link. This means that all communications received by the top of the stack are now forwarded to the next element.

Now the core lines in our implementation are essentially the same as in Agha's example:

```julia
using YAActL

mutable struct StackNode{T}
    content::T
    link::Link
end

# define the messages
struct Pop <: Message
    customer::Link
end

struct Push{T} <: Message
    content::T
end

struct Response{T} <: Message
    content::T
end

# define the forwarder behavior
forward!(lk::L, msg::M) where {L<:Link, M<:Message} = send!(lk, msg)

# ----- this is essentially Agha's code example written in Julia/YAActL
function stack_node(sn::StackNode, msg::Pop)
    isnothing(sn.content) || become(forward!, sn.link)
    send!(msg.customer, Response(sn.content))
end

function stack_node(sn::StackNode, msg::Push)
    P = Actor(stack_node, sn)
    become(stack_node, StackNode(msg.content, P))
end
```

Now we can create the top of the stack (the receptionist). All other actors of the system are created internally if we send a `Push` message. We interact only with the top of the stack:

```julia
julia> mystack = Actor(lk, stack_node, StackNode(nothing, Link()))
Channel{Message}(sz_max:32,sz_curr:0)

julia> response = newLink()           # create a response link
Channel{Message}(sz_max:32,sz_curr:0)

julia> send!(mystack, Pop(response))  # new stack

julia> take!(response)                # returns nothing
Response{Nothing}(nothing)

julia> send!(mystack, Push(1))        # push 1 on the stack

julia> send!(mystack, Pop(response))  # pop it

julia> take!(response)                # returns 1, 1st node now forwards messages
Response{Int64}(1)

julia> send!(mystack, Pop(response))  # pop again

julia> take!(response)                # now returns nothing
Response{Nothing}(nothing)

julia> for i ∈ 1:5
           send!(mystack, Push(i))
       end

julia> for i ∈ 1:5
           send!(mystack, Pop(response))
           println(take!(response))
       end
Response{Int64}(5)
Response{Int64}(4)
Response{Int64}(3)
Response{Int64}(2)
Response{Int64}(1)
```
