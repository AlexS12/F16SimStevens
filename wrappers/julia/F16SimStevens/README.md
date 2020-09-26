# F16SimStevens Julia Wrapper

Fortran library will be compiled on F16SimStevens.jl build (see `./deps/build.jl`)

```julia
pkg> activate .
julia> using F16SimStevens
julia> F16SimStevens.damp(8.0)
9-element Array{Float64,1}:
   1.7840000000000003
   0.9603999999999999
   0.19880000000000003
 -31.279999999999998
   0.17
  -0.3978
  -5.7700000000000005
  -0.3764
  -0.0126
```
