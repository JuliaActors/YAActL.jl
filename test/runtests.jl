#
# This file is part of the YAActL.jl Julia package, MIT license
#
# Paul Bayer, 2020
#

using Test, SafeTestsets, Distributed

function redirect_devnull(f)
    open(@static(Sys.iswindows() ? "nul" : "/dev/null"), "w") do io
        redirect_stdout(io) do
            f()
        end
    end
end

length(procs()) == 1 && addprocs(1)

@safetestset "Basics"        begin include("test_basics.jl") end
@testset "Actors"            begin include("test_actors.jl") end
@safetestset "Communication" begin include("test_com.jl") end
@safetestset "API"           begin include("test_api.jl") end

println("running examples, output suppressed!")
redirect_devnull() do
    @safetestset "Factorial"     begin include("../examples/factorial.jl") end
    @safetestset "Simple"        begin include("../examples/simple.jl") end
    @safetestset "Simple msg."   begin include("../examples/simple_msg.jl") end
    @testset     "Simple distr." begin include("../examples/simple_distr.jl") end
    @safetestset "Stack"         begin include("../examples/stack.jl") end
end
