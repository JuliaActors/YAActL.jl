#
# This file is part of the YAActL.jl Julia package, MIT license
#
# Paul Bayer, 2020
#

using YAActL, Distributed, Test

length(procs()) == 1 && addprocs(1)

@everywhere using YAActL
@everywhere function ident(id, from)
    id == from ?
        ("local actor",  id, from) :
        ("remote actor", id, from)
end

# 
# test registry with one local actor
#
@test register(:act1, Actor(ident, 1))
a1 = YAActL.diag!(:act1)
@test a1.name == :act1  # does it have its name ?
@test call!(:act1, myid()) == ("local actor", 1, 1)
act1 = whereis(:act1)
unregister(:act1)
sleep(0.1)
@test isnothing(a1.name) # did it delete the name ?
@test isempty(registered())
@test register(:act1, act1)
sleep(0.1)
@test length(registered()) == 1
exit!(:act1)
sleep(0.1)
@test act1.chn.state == :closed
@test isempty(registered()) # did it unregister at exit ?
# 
# test registry across workers
# 
@test register(:act1, Actor(ident, 1))
@test register(:act2, Actor(2, ident, 2))
@test call!(:act2, myid()) == ("remote actor", 2, 1)
@test fetch(@spawnat 2 call!(:act1, myid())) == ("remote actor", 1, 2)
@test fetch(@spawnat 2 call!(:act2, myid())) == ("local actor", 2, 2)
@test whereis(:act1).type == :local
@test whereis(:act2).type == :remote
@test fetch(@spawnat 2 whereis(:act1)).type == :remote
@test fetch(@spawnat 2 whereis(:act2)).type == :remote
let
    r = registered()
    l = [i[1] for i in r]
    @test length(r) == 2
    @test :act1 in l
    @test :act2 in l
    r = fetch(@spawnat 2 registered())
    @test all([i[2].type for i in r]) do x
        x == :remote
    end
end
unregister(:act1)
unregister(:act2)
@test isempty(registered())
# 
# test API functions with registered actors
# 
f(a, b) = a + b
@test register(:act1, Actor(f, 1))
a1 = YAActL.diag!(:act1)
send!(:act1, YAActL.Cast((1,)))
sleep(0.1)
@test a1.res == 2
@test request!(:act1, YAActL.Call, 2) == 3
become!(:act1, f, 0)
@test call!(:act1, 1) == 1
cast!(:act1, 2)
sleep(0.1)
@test a1.res == 2
@test exec!(:act1, Func(f, 5, 5)) == 10
@test query!(:act1, :res) == 2
set!(:act1, state)
@test query!(:act1, :dsp) == state
update!(:act1, 5)
@test call!(:act1, 5) == 10
unregister(:act1)
