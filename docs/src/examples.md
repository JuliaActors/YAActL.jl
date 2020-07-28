# Examples

## A Stack

```julia
using YAActL

mutable struct StackNode{T}
    content::T
    link::Link
end

struct Pop <: Message
    customer::Link
end

struct Push{T} <: Message
    content::T
end

struct Response{T} <: Message
    content::T
end

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
````

Now we can create the top of the stack (the receptionist). All other actors of the system are created internally if we send a `Push` message. We interact only with the top of the stack:

````julia
julia> mystack = Actor(lk, stack_node, StackNode(nothing, Link()))
Channel{Message}(sz_max:32,sz_curr:0)

julia> response = Link(10)            # create a response channel 
Channel{Message}(sz_max:10,sz_curr:0)

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
