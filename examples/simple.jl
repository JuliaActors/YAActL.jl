using YAActL, Printf

struct Prt <: Message        # define a message
    txt::String
end

# define two behaviors accepting a msg::Message as their last argument
function pr(msg::Prt)
    print(@sprintf("%s\n", msg.txt))
    become(pr, "Next") # change behavior
end
pr(info, msg::Prt) = print(@sprintf("%s: %s\n", info, msg.txt))

# a behavior for doing arithmetic
function calc(op::F, v::U, msg::Request) where {F<:Function,U<:Number}
    send!(msg.from, Response(op(v,msg.x)))
end

# start an actor with the first behavior and save the returned link
myactor = Actor(pr)

send!(myactor, Prt("My first actor"))  # send a message to it

send!(myactor, Prt("Something else"))  # send again a message

become!(myactor, pr, "New behavior")   # change the behavior to another one

send!(myactor, Prt("bla bla bla"))     # and send again a message

become!(myactor, calc, +, 10);         # now become a adding machine

send!(myactor, Request(5, USR));       # send a request to add 5

take!(USR)                             # take the result
