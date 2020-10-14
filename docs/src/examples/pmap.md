# Parallel Map

Here we compare five executions of `comp`, a "heavy" computation taking 2 seconds:

```julia
using YAActL, .Threads, Distributed

function comp(i)  # a "heavy" computation
    sleep(2)
    return (id=i, thrd=threadid())
end
```

We can check how long it takes sequentially:

```julia
julia> @time map(comp, 1:5)  # sequential
 10.024817 seconds (36 allocations: 1.234 KiB)
5-element Array{NamedTuple{(:id, :thrd),Tuple{Int64,Int64}},1}:
 (id = 1, thrd = 1)
 (id = 2, thrd = 1)
 (id = 3, thrd = 1)
 (id = 4, thrd = 1)
 (id = 5, thrd = 1)
```

now with Julia's `Threads`:

```julia
julia> @time begin
            t = map(x->(Threads.@spawn comp(x)), 1:5)
            map(fetch, t)
       end
  2.074831 seconds (150.55 k allocations: 8.045 MiB)
5-element Array{NamedTuple{(:id, :thrd),Tuple{Int64,Int64}},1}:
 (id = 1, thrd = 2)
 (id = 2, thrd = 3)
 (id = 3, thrd = 5)
 (id = 4, thrd = 4)
 (id = 5, thrd = 6)
```

now with `YAActL` (we get the results in the `USR` channel):

```julia
julia> A = map(i->Actor(parallel(), comp, i), 1:5); # start actors

julia> @time begin
           foreach(a->call!(a, USR), A)
           map(x->receive!(USR).y, 1:5)
       end
  2.042264 seconds (83.46 k allocations: 4.448 MiB, 0.53% gc time)
5-element Array{NamedTuple{(:id, :thrd),Tuple{Int64,Int64}},1}:
 (id = 2, thrd = 3)
 (id = 5, thrd = 6)
 (id = 4, thrd = 4)
 (id = 3, thrd = 2)
 (id = 1, thrd = 5)
```

now with `Distributed`:

```julia
julia> addprocs(4);   # add processes

julia> @everywhere function comp(i)  # a "heavy" computation
           sleep(2)
           return (id=i, prc=myid())
       end

julia> @time begin
            f = map(i->(@spawnat i comp(i)), 1:5)
            map(fetch, f)
       end
  2.252625 seconds (185.30 k allocations: 9.740 MiB, 0.38% gc time)
5-element Array{NamedTuple{(:id, :prc),Tuple{Int64,Int64}},1}:
 (id = 1, prc = 1)
 (id = 2, prc = 2)
 (id = 3, prc = 3)
 (id = 4, prc = 4)
 (id = 5, prc = 5)
```

`YAActL` actors and `Distributed` processes are persistent objects. Therefore we must allocate them before we do computations with them. If we work with remote actors on other processes or nodes, we have to ensure as in `Distributed` that the code is available on each node.
