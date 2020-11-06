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
sleep(1)
@test register(:act1, Actor(ident, 1))
@test call!(:act1, myid()) == ("local actor", 1, 1)
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
