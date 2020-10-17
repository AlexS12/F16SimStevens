using SafeTestsets

@safetestset "RK4" begin include("rk4.jl") end
@safetestset "SixDOF" begin include("sixdof.jl") end
