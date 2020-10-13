using YAActL, .Threads
import .Threads: @spawn

function comp(i)
    sleep(2)
    return (id=i, thrd=threadid())
end

function p_basic(p)
    t = map(x->(@spawn comp(x)), 1:p)
    map(fetch, t)
end

function p_yaactl(p, func)
    lk = map(i->Actor(parallel(), func, i), 1:p)
    foreach(l->call!(l, USR), lk)
    map(i->receive!(USR).y, 1:p)
end
    

