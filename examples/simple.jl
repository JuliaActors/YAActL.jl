using YAActL, Printf

# t = Ref{Task}()                # this is for debugging
# lk = LinkParams(taskref=t)

struct Print <: Message        # define a message
    txt::String
end

# define two behaviors accepting a msg::Message as their last argument
function pr(msg::Print)
    print(@sprintf("%s\n", msg.txt))
    become(pr, "Next") # change behavior
end
pr(info, msg::Print) = print(@sprintf("%s: %s\n", info, msg.txt))

# a behavior for doing arithmetic
function calc(op::F, v::U, msg::Request) where {F<:Function,U<:Number}
    send!(msg.lk, Response(op(v,msg.x)))
end

# start an actor with the first behavior and save the returned link
myactor = Actor(pr)

send!(myactor, Print("My first actor"))  # send a message to it

send!(myactor, Print("Something else"))  # send again a message

become!(myactor, pr, "New behavior")     # change the behavior to another one

send!(myactor, Print("bla bla bla"))     # and send again a message

become!(myactor, calc, +, 10)

send!(myactor, Request(5, USR))

take!(USR)
