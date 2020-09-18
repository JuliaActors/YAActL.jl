using Distributed
addprocs(2)

@everywhere using Pkg
@everywhere Pkg.activate(".")
@everywhere using YAActL, Printf

@everywhere begin
    struct PM <: Message        # define a message
        txt::String
    end

    # define two behaviors accepting a msg::Message as their last argument
    function pr(msg::PM)
        print(@sprintf("%s\n", msg.txt))
        become(pr, "Next") # change behavior
    end
    pr(info, msg::PM) = print(@sprintf("%s: %s\n", info, msg.txt))

    # a behavior for doing arithmetic
    function calc(op::F, v::U, msg::Request) where {F<:Function,U<:Number}
        send!(msg.lk, Response(op(v,msg.x)))
    end
end

t = Ref{Task}()                # this is for debugging
lk = LinkParams(2, taskref=t)

# start an actor with the first behavior and save the returned link
myactor = Actor(2, pr)

send!(myactor, PM("My first actor"))  # send a message to it

send!(myactor, PM("Something else"))  # send again a message

become!(myactor, pr, "New behavior")     # change the behavior to another one

send!(myactor, PM("bla bla bla"))     # and send again a message

become!(myactor, calc, +, 10)

send!(myactor, Request(5, USR))

take!(USR)
