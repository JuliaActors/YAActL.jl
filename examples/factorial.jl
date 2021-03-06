#
# This is Agha's example 3.2.2, a recursive factorial
#
# message type version
#
using YAActL

# implement the behaviors
function rec_factorial(f::Request)
    if f.x == 0
        send!(f.from, Response(1))
    else
        c = Actor(parallel(), rec_customer, f.x, f.from) # setup parallel actors
        send!(self(), Request(f.x - 1, c))
    end
end

function rec_customer(n::Integer, u::Link, k::Response) 
    send!(u, Response(n * k.y))
    stop()
end

# setup factorial actor and response link
F = Actor(rec_factorial)
resp = Link()

for i ∈ 0:5:50      # send and receive loop
    send!(F, Request(big(i), resp))
    println(receive!(resp).y)
end

for i ∈ 0:5:50      # send all requests in one loop
    send!(F, Request(big(i), resp))
end
for i ∈ 0:10      # receive all results
    println(receive!(resp).y)
end
