#
# This file is part of the YAActL.jl Julia package, MIT license
#
# Paul Bayer, 2020
#

using YAActL, Distributed

length(procs()) == 1 && addprocs(1)

@everywhere using Pkg
@everywhere Pkg.activate(".")
@everywhere using YAActL, Printf
