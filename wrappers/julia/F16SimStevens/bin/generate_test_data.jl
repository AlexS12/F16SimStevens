using DataFrames
using CSV
using Libdl

using F16SimStevens


# ------------------------------ADC------------------------------
df = DataFrame(vt = Number[], alt = Number[], mach = Number[], qbar = Number[])

for vt = 0.0:50.0:1000.0, alt = 0.0:1000.0:50000.0
    mach, qbar = F16SimStevens.adc(vt, alt)
    push!(df, (vt, alt, mach, qbar))
end

CSV.write("../data/adc.csv", df)

# ------------------------------AERO------------------------------
α_test = LinRange(-10, 45, 20)
β_test = LinRange(-30, 30, 20)

de_test = LinRange(-25, 25, 20)
da_test = LinRange(-21.5, 21.5, 20)
dr_test = LinRange(-30, 30, 20)

df = DataFrame(
    alpha = Number[],
    d1 = Number[],
    d2 = Number[],
    d3 = Number[],
    d4 = Number[],
    d5 = Number[],
    d6 = Number[],
    d7 = Number[],
    d8 = Number[],
    d9 = Number[],
)
for α in α_test
    rv = F16SimStevens.damp(α)
    push!(df, (α, rv...))
end
CSV.write("../data/damp.csv", df)


df = DataFrame(alpha = Number[], de = Number[], cx = Number[])
for α in α_test, de in de_test
    rv = F16SimStevens.CX(α, de)
    push!(df, (α, de, rv))
end
CSV.write("../data/cx.csv", df)


df = DataFrame(beta = Number[], da = Number[], dr = Number[], cy = Number[])
for β in β_test, da in da_test, dr in dr_test
    rv = F16SimStevens.CY(β, da, dr)
    push!(df, (β, da, dr, rv))
end
CSV.write("../data/cy.csv", df)


df = DataFrame(alpha = Number[], beta = Number[], de = Number[], cz = Number[])
for α in α_test, β in β_test, de in de_test
    rv = F16SimStevens.CZ(α, β, de)
    push!(df, (α, β, de, rv))
end
CSV.write("../data/cz.csv", df)


df = DataFrame(alpha = Number[], de = Number[], cm = Number[])
for α in α_test, de in de_test
    rv = F16SimStevens.CM(α, de)
    push!(df, (α, de, rv))
end
CSV.write("../data/cm.csv", df)


df = DataFrame(
    alpha = Number[],
    beta = Number[],
    cl = Number[],
    cn = Number[],
    dlda = Number[],
    dldr = Number[],
    dnda = Number[],
    dndr = Number[],
)
for α in α_test, β in de_test
    cl = F16SimStevens.CL(α, β)
    cn = F16SimStevens.CN(α, β)
    dlda = F16SimStevens.DLDA(α, β)
    dldr = F16SimStevens.DLDR(α, β)
    dnda = F16SimStevens.DNDA(α, β)
    dndr = F16SimStevens.DNDR(α, β)
    push!(df, (α, β, cl, cn, dlda, dldr, dnda, dndr))
end
CSV.write("../data/aero_coeffs.csv", df)


# ------------------------------ENGINE------------------------------
df = DataFrame(thtl = Number[], tgear = Number[])
for thtl in LinRange(0, 1, 20)
    rv = F16SimStevens.tgear(thtl)
    push!(df, (thtl, rv))
end
CSV.write("../data/tgear.csv", df)


df = DataFrame(p3 = Number[], p1 = Number[], pdot = Number[])
for p3 in LinRange(0, 100, 50), p1 in LinRange(0, 100, 50)
    rv = F16SimStevens.pdot(p3, p1)
    push!(df, (p3, p1, rv))
end
CSV.write("../data/pdot.csv", df)


df = DataFrame(dp = Number[], rtau = Number[])
for dp in LinRange(0, 100, 50)
    rv = F16SimStevens.rtau(dp)
    push!(df, (dp, rv))
end
CSV.write("../data/rtau.csv", df)


df = DataFrame(pow = Number[], alt = Number[], rmach = Number[], thrust = Number[])
for pow in LinRange(0, 100, 50), alt in LinRange(0, 50000, 500), rmach in LinRange(0, 1, 25)
    rv = F16SimStevens.thrust(pow, alt, rmach)
    push!(df, (pow, alt, rmach, rv))
end
CSV.write("../data/thrust.csv", df)


# ------------------------------RK4------------------------------
x = [
    502.0,
    0.2392628,
    0.0005061803,
    1.366289,
    0.05000808,
    0.2340769,
    -0.01499617,
    0.2933811,
    0.06084932,
    0.0,
    0.0,
    0.0,
    64.12363,
]

controls = [0.8349601, -1.481766, 0.09553108, -0.4118124]

xcg = 0.35

df = DataFrame(
    dt = Number[],
    x1 = Number[],
    x2 = Number[],
    x3 = Number[],
    x4 = Number[],
    x5 = Number[],
    x6 = Number[],
    x7 = Number[],
    x8 = Number[],
    x9 = Number[],
    x10 = Number[],
    x11 = Number[],
    x12 = Number[],
    x13 = Number[],
    time = Number[],
    xcg = Number[],
    c1= Number[],
    c2= Number[],
    c3= Number[],
    c4= Number[],
    x1_new = Number[],
    x2_new = Number[],
    x3_new = Number[],
    x4_new = Number[],
    x5_new = Number[],
    x6_new = Number[],
    x7_new = Number[],
    x8_new = Number[],
    x9_new = Number[],
    x10_new = Number[],
    x11_new = Number[],
    x12_new = Number[],
    x13_new = Number[],
)

dll = dlopen(F16SimStevens.DLL)

for time in [0.0, 0.1, 1000.0]
    for dt in [0.0001, 0.001, 0.01, 0.1, 1]
        x_new = F16SimStevens.rk4(dlsym(dll, :f_), dt, x, time, xcg, controls)
        push!(df, [dt, x..., time, xcg, controls..., x_new...])
    end
end
CSV.write("../data/RK4.csv", df)


# ------------------------------SIXDOF------------------------------
t = 0.0;

vt_test = [50.0, 75.0]  # ft/s
α_test = deg2rad.([1.0, 5.0])
β_test = deg2rad.([-5.0, 5.0])
ϕ_test = deg2rad.([-30.0, 25.0])
θ_test = deg2rad.([-15.0, 25.0])
ψ_test = deg2rad.([45.0, 175.0])
p_test = deg2rad.([-15.0, 30.0])
q_test = deg2rad.([-5.0, 10.0])
r_test = deg2rad.([-20.0, 30.0])
norh_ft = 0.0  # ft
east_ft = 0.0  # ft
alt_test = [5000.0, 45000.0]  # ft
pow_test = [10., 80.]  # %

de_test = [-25.0, 20.0]  # deg
da_test = [-15.0, 10.0]  # deg
dr_test = [-25.0, 20.0]  # deg
thtl_test = [0.2, 0.6]

xcg_test = [0.35, 0.25]

df = DataFrame(
    time = Number[],
    x1 = Number[],
    x2 = Number[],
    x3 = Number[],
    x4 = Number[],
    x5 = Number[],
    x6 = Number[],
    x7 = Number[],
    x8 = Number[],
    x9 = Number[],
    x10 = Number[],
    x11 = Number[],
    x12 = Number[],
    x13 = Number[],
    xcg = Number[],
    c1= Number[],
    c2= Number[],
    c3= Number[],
    c4= Number[],
    x1_dot = Number[],
    x2_dot = Number[],
    x3_dot = Number[],
    x4_dot = Number[],
    x5_dot = Number[],
    x6_dot = Number[],
    x7_dot = Number[],
    x8_dot = Number[],
    x9_dot = Number[],
    x10_dot = Number[],
    x11_dot = Number[],
    x12_dot = Number[],
    x13_dot = Number[],
    o1 = Number[],
    o2 = Number[],
    o3 = Number[],
    o4 = Number[],
    o5 = Number[],
    o6 = Number[],
    o7 = Number[],
)

for vt_fts in vt_test,
    α_rad in α_test,
    β_rad in β_test,
    ϕ_rad in ϕ_test,
    θ_rad in ϕ_test,
    ψ_rad in ψ_test,
    p_rads in p_test,
    q_rads in q_test,
    r_rads in r_test,
    alt_ft in alt_test,
    pow in pow_test,
    thtl in thtl_test,
    el in de_test,
    ail in da_test,
    rdr in dr_test,
    pow in thtl_test,
    xcg in xcg_test

        local x
        local controls

        x = [
            vt_fts,
            α_rad,
            β_rad,
            ϕ_rad,
            θ_rad,
            ψ_rad,
            p_rads,
            q_rads,
            r_rads,
            norh_ft,
            east_ft,
            alt_ft,
            pow,
        ]

        controls =
            [thtl, el, ail, rdr]

        xd1, outputs1 =
        F16SimStevens.f(
                t,
                x,
                xcg,
                controls,
            )

        push!(df, [t, x..., xcg, controls..., xd1..., outputs1...])
end
CSV.write("../data/sixdof.csv", df)
