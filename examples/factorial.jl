#
# This is Agha's example 3.2.2, a recursive factorial
#
using YAActL

# implement the behaviors
function rec_factorial(f::Request)
    if f.x == 0
        send!(f.u, Response(1))
    else
        c = Actor(parallel(), rec_customer, f.x, f.u) # setup parallel actors
        send!(self(), Request(f.x - 1, c))
    end
end

rec_customer(n::Integer, u::Link, k::Response) = send!(u, Response(n * k.y))

# setup factorial actor and response link
F = Actor(rec_factorial)
resp = newLink()

for i ∈ 0:20      # send and receive loop
    send!(F, Request(i, resp))
    println(take!(resp))
end

for i ∈ 0:20      # send all requests in one loop
    send!(F, Request(i, resp))
end
for i ∈ 0:20      # receive all results
    println(take!(resp))
end
