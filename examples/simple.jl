using YAActL, Printf

# define two functions for printing a message
function pr(msg)
    print(@sprintf("%s\n", msg))
    become(pr, "Next") # change behavior
end
pr(info, msg) = print(@sprintf("%s: %s\n", info, msg))

# a function for doing arithmetic
calc(op::F, x, y) where F<:Function = op(x, y)

# start an actor with the first behavior
myactor = Actor(pr)

cast!(myactor, "My first actor")     # send a message to it

cast!(myactor, "Something else")     # send again a message

become!(myactor, pr, "New behavior") # change the behavior to another one

cast!(myactor, "bla bla bla")        # and send again a message

become!(myactor, calc, +, 10);       # become a machine for adding to 10

call!(myactor, 5)                    # send a request to add 5

become!(myactor, ^);                 # become a exponentiation machine

call!(myactor, 123, 456)             # try it
