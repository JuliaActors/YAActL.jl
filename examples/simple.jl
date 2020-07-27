using YAActL, Printf

t = Ref{Task}()                # this is for debugging
lk = LinkParams(taskref=t)

struct Print <: Message        # define a message
    txt::String
end

# define two behaviors accepting a msg::Message as their last argument
function pr(msg::Print)
    print(@sprintf("%s\n", msg.txt))
    become(pr, "Next") # change behavior
end
pr(info, msg::Print) = print(@sprintf("%s: %s\n", info, msg.txt))

# start an actor with the first behavior and save the returned link
myactor = Actor(lk, pr)

send!(myactor, Print("My first actor"))  # send a message to it

send!(myactor, Print("Something else"))  # send again a message

become!(myactor, pr, "New behavior")     # change the behavior to another one

send!(myactor, Print("bla bla bla"))     # and send again a message
