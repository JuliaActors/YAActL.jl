using YAActL

function fib(D::Dict{Int,BigInt}, n::Int)
    get!(D, n) do
        n == 0 && return big(0)
        n == 1 && return big(1)
        return fib(D, n-1) + fib(D, n-2)
    end
end

myfib = Actor(fib, Dict{Int,BigInt}())

call!(myfib, 1000)

