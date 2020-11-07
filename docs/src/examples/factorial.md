# [A Recursive Factorial](@id factorial_example)

!!! note "This illustrates the actor model"

    It is **not** a proposal for an actual factorial implementation. It uses `YAActL`s message API to be as close as possible to Agha's orginal example.

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
            println(receive!(resp).y)
        end
1
120
3628800
1307674368000
2432902008176640000
15511210043330985984000000
265252859812191058636308480000000
10333147966386144929666651337523200000000
815915283247897734345611269596115894272000000000
119622220865480194561963161495657715064383733760000000000
30414093201713378043612608166064768844377641568960512000000000000
```

If we send our requests successively without waiting and then read the response link, we still get the same sequence – which is a bit surprising. 
