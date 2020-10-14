using YAActL, .Threads, Distributed

function comp(i)  # a "heavy" computation
    sleep(2)
    return (id=i, thrd=threadid())
end

println("sequential execution:")
@time map(comp, 1:5)

println("with Julia's Threads:")
@time begin
    t = map(x->(Threads.@spawn comp(x)), 1:5)
    map(fetch, t)
end

println("with YAActL:")
A = map(i->Actor(parallel(), comp, i), 1:5); # start actors
@time begin
    foreach(a->call!(a, USR), A)
    map(x->receive!(USR).y, 1:5)
end

println("with Distributed:")
nworkers() < 5 && addprocs(4);  # add processes
@everywhere function comp(i)    # a "heavy" computation
    sleep(2)
    return (id=i, prc=myid())
end
@time begin
    f = map(i->(@spawnat i comp(i)), 1:5)
    map(fetch, f)
end

rmprocs(workers());
