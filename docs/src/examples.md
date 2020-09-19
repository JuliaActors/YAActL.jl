# Examples

## [A Stack](@id stack_example)

This is Agha's example 3.2.1. It implements a stack as a collection of actors with two operations/messages `Push` and `Pop`. A `StackNode` stores a content and a [`Link`](@ref) to the next [`Actor`](@ref) in the chain.

> The top of the stack is the only receptionist in the stack system and was the only actor of the stack system created externally. It is created with a NIL content which is assumed to be the bottom of the stack marker. Notice that no mail address of a stack node is ever communicated by any node to an external actor. Therefore no actor outside the configuration defined above can affect any of the actors inside the stack except by sending the receptionist a communication. When a *pop* operation is done, the actor on top of the stack simply becomes a *forwarder* to the next actor in the link. This means that all communications received by the top of the stack are now forwarded to the next element.

We define types for stack nodes and messages. We want our stack actor to dispatch its behavior on *push* and *pop*.

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
```

The code implementing the actor's behavior is very similar to Agha's example:

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

Then we create the top of the stack (the receptionist). All other actors of the system are created internally each time we send a `Push` message. We interact only with the top of the stack:

```julia
julia> mystack = Actor(stack_node, StackNode(nothing, Link()))
Channel{Message}(sz_max:32,sz_curr:0)

julia> response = newLink()           # create a response link
Channel{Message}(sz_max:32,sz_curr:0)

julia> send!(mystack, Push(1))        # push 1 on the stack

julia> send!(mystack, Pop(response))  # pop it

julia> take!(response)                # returns 1, 1st node now forwards messages
Response{Int64}(1)

julia> send!(mystack, Pop(response))  # pop again

julia> take!(response)                # now nothing is left
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

## [A Recursive Factorial](@id factorial_example)

This is Agha's example 3.2.2:

> Our implementation of the *factorial* relies on creating a *customer* which waits for the appropriate communication, in this case from the factorial actor itself. The factorial actor is free to concurrently process the next communication. We assume that a communication to a factorial includes a mail address to which the value of the factorial is to be sent.

For a requested factorial ``\,x! : x > 0\,`` the *factorial* actor creates a *customer* actor on a parallel thread answering the request and sends itself a request with ``\,x-1\,`` from the newly created customer. The created chain of customer actors finally answers the original request. We implement first the behaviors and then setup the factorial actor `F` and a response link:

```julia
using YAActL

function rec_factorial(f::Request)
    if f.x == 0
        send!(f.u, Response(1))
    else
        c = Actor(parallel(), rec_customer, f.x, f.u) # setup parallel actors
        send!(self(), Request(f.x - 1, c))
    end
end

function rec_customer(n::Integer, u::Link, k::Response) 
    send!(u, Response(n * k.y))
    stop()
end

F = Actor(rec_factorial)
resp = newLink()
```

Now we can send requests to the factorial actor and take the answers from the response link:

```julia
julia>  for i ∈ 0:5:50      # send and receive loop
            send!(F, Request(big(i), resp))
            println(take!(resp))
        end
Response{Int64}(1)
Response{BigInt}(120)
Response{BigInt}(3628800)
Response{BigInt}(1307674368000)
Response{BigInt}(2432902008176640000)
Response{BigInt}(15511210043330985984000000)
Response{BigInt}(265252859812191058636308480000000)
Response{BigInt}(10333147966386144929666651337523200000000)
Response{BigInt}(815915283247897734345611269596115894272000000000)
Response{BigInt}(119622220865480194561963161495657715064383733760000000000)
Response{BigInt}(30414093201713378043612608166064768844377641568960512000000000000)
```

If we send our requests successively without waiting and then read the response link, we still get the same sequence – which is a bit surprising. For sure this is not the most effective method to implement a factorial.
