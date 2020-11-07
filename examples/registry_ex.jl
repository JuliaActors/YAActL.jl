using YAActL, Distributed
length(procs()) == 1 && addprocs(1)

@everywhere using YAActL
@everywhere function ident(id, from)
    id == from ?
        ("local actor",  id, from) :
        ("remote actor", id, from)
end

register(:act1, Actor(ident, 1))       # a registered local actor
call!(:act1, myid())                   # call! it
register(:act2, Actor(2, ident, 2))    # a registered remote actor on pid 2
call!(:act2, myid())                   # call! it
fetch(@spawnat 2 call!(:act1, myid())) # call! :act1 on pid 2
fetch(@spawnat 2 call!(:act2, myid())) # call! :act2 on pid 2
whereis(:act1)                         # get a link to :act1
whereis(:act2)                         # get a link to :act2
fetch(@spawnat 2 whereis(:act1))       # get a link to :act1 on pid 2
registered()                           # get a list of registered actors
fetch(@spawnat 2 registered())         # get it on pid 2
unregister(:act1)
unregister(:act2)
