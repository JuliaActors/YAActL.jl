#
# This file is part of the YAActL.jl Julia package, MIT license
#
# Paul Bayer, 2020
#

function __init__()
    if myid() == 1
        global USR = Link(
            RemoteChannel(()->Channel{Message}(32)),
            myid(), :remote)
        global _REG = Link(
            RemoteChannel(()->Actor(_reg, Dict{Symbol, Link}()).chn), 
            1, :remote)
    else
        tmp = Actor(1, ()->YAActL.USR)
        global USR = call!(tmp)
        become!(tmp, ()->YAActL._REG)
        global _REG = call!(tmp)
        exit!(tmp)
    end
end
