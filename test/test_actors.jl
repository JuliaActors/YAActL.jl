#
# This file is part of the YAActL.jl Julia package, MIT license
#
# Paul Bayer, 2020
#

using YAActL, Distributed

length(procs()) == 1 && addprocs(1)

@everywhere using YAActL

@everywhere mutate(a) = a[:] = a .+ 1
a = [1, 1, 1]
mutate(a)
@test a == [2,2,2]

mut = Actor(2, mutate)
@test call!(mut, a) == [3,3,3]
@test a == [2,2,2]
