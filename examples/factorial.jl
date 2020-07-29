#
# This is Agha's example 3.2.2, a recursive factorial
#
using YAActL

struct Factorial <: Message
    n::Integer
    u::Link
end

struct Response <: Message
    y::Integer
end

# implement the behaviors
function rec_factorial(f::Factorial)
    if f.n == 0
        send!(f.u, Response(1))
    else
        c = Actor(parallel(), rec_customer, f.n, f.u) # setup parallel actors
        send!(self(), Factorial(f.n-1, c))
    end
end

rec_customer(n::Integer, u::Link, k::Response) = send!(u, Response(n * k.y))

# setup factorial actor and response link
A = Actor(rec_factorial)
resp = newLink()

for i ∈ 0:20      # send and receive loop
    send!(A, Factorial(i, resp))
    println(take!(resp))
end

for i ∈ 0:20      # send all requests
    send!(A, Factorial(i, resp))
end
for i ∈ 0:20      # receive all results
    println(take!(resp))
end
