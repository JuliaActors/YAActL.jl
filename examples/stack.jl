#
# This implements Agha's example 3.2.1
#
using YAActL, Printf

t = Ref{Task}()                # this is for debugging
lk = LinkParams(taskref=t)

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

struct Print <: Message end

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
# ----------------------------------------------------------------------

function stack_node(sn::StackNode, msg::Print)  # for debugging
    print(@sprintf("content: %s\n", sn.content))
    isnothing(sn.content) || send!(sn.link, msg)
end

mystack = Actor(lk, stack_node, StackNode(nothing, Link()))

response = newLink()

send!(mystack, Pop(response))  # new stack
take!(response)                # returns nothing
send!(mystack, Push(1))        # push 1 on the stack
send!(mystack, Pop(response))  # pop it
take!(response)                # returns 1, 1st node now forwards messages
send!(mystack, Pop(response))  # pop again
take!(response)                # now returns nothing

for i ∈ 1:5
    send!(mystack, Push(i))
end

(send!(mystack, Print()); sleep(1))

for i ∈ 1:5
    send!(mystack, Pop(response))
    println(take!(response))
end
