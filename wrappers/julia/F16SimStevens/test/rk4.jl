using Test
using Libdl
using F16SimStevens

# Stevens, B. L., Lewis, F. L., & Johnson, E. N. (2015). Aircraft control
# and simulation: dynamics, controls design, and autonomous systems. John Wiley
# & Sons.
# Example 3.6-5: Simulation of a Coordinated Turn (page 197)


xcg = 0.35

# ---------- PROPAGATE COORDINATED TURN ----------
# Check that this is a trimmed condition
# Stevens, B. L., Lewis, F. L., & Johnson, E. N. (2015). Aircraft control
# and simulation: dynamics, controls design, and autonomous systems. John Wiley
# & Sons.
# Example 3.6-2 (page 191)
t = 0.0
xcg = 0.35
# Trimmed conditions: page 192
# C     X(1)  -> vt (ft/s)
# C     X(2)  -> alpha (rad)
# C     X(3)  -> beta (rad)
# C     X(4)  -> phi (rad)
# C     X(5)  -> theta (rad)
# C     X(6)  -> psi (rad)
# C     X(7)  -> P (rad/s)
# C     X(8)  -> Q (rad/s)
# C     X(9)  -> R (rad/s)
# C     X(10) -> North (ft)
# C     X(11) -> East (ft)
# C     X(12) -> Altitude (ft)
# C     X(13) -> Pow
x_stev = [
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
# THTL = controls[1]
# EL = controls[2]
# AIL = controls[3]
# RDR = controls[4]
controls_stev = [0.8349601, -1.481766, 0.09553108, -0.4118124]
x_dot, outputs = F16SimStevens.f(t, x_stev, xcg, controls_stev)

# Linear acceleration
@test isapprox(x_dot[1:3], zeros(3), atol = 5e-4)
# Angular acceleration
@test isapprox(x_dot[7:9], zeros(3), atol = 1e-5)
# Cost function
cost =
    x_dot[1]^2 +
    100 * (x_dot[2]^2 + x_dot[3]^2) +
    10 * (x_dot[7]^2 + x_dot[8]^2 + x_dot[9]^2)
@test isapprox(cost, 0.0, atol = 1e-5)

# Desired turn rate
@test isapprox(x_dot[6], 0.3, atol = 1e-6)
# No vertical changes
@test isapprox(x_dot[12], 0.0, atol = 1e-4)

# RETRIM to refine flying condition
x_trim = [502.0, 0.23938453954823216, 0.0005058915539990123, 1.3662947046110303, 0.0500325181561006, 0.2340769, -0.015003494028336268, 0.2933811079422718, 0.06084751983036574, 0.0, 0.0, 0.0, 64.19077790184821]
controls_trim = [0.8352690123371433, -1.4796502802087073, 0.09556417123953126, -0.4119443314334451]
x_dot_trim = [-7.429106379762155e-20, 0.0, -2.925333564730057e-19, 1.734723475976807e-18, 6.938893903907228e-18, 0.30000000000000004, 1.6297627688309652e-17, -8.885921624691832e-17, 3.113576632990501e-18, 501.9999964228281, -0.059928962851330425, 0.0, 0.0]
outputs_trim = [4.65048938250396, -1.150004800292683e-16, 723.2793086655872, 299.506754, 0.44953076478661363, 0.2933811079422718, 13.71572391335681]
cost = [-7.429106379762155e-20, 0.0, -2.925333564730057e-19, 1.6297627688309652e-17, -8.885921624691832e-17, 3.113576632990501e-18]

dt = 0.01  # s
t = 0.0  # s

x = x_trim
controls = controls_trim

results = []

dll = dlopen(F16SimStevens.DLL)

while t < 180.0 + dt / 2.0
    global t, x
    local x_dot, outputs, cost

    push!(results, vcat([t], x))
    x = F16SimStevens.rk4(dlsym(dll, :f_), dt, x, t, xcg, controls)

    t += dt

end

results = hcat(results...)'

# Check X, Y against Stevens
# Stevens, B. L., Lewis, F. L., & Johnson, E. N. (2015). Aircraft control
# and simulation: dynamics, controls design, and autonomous systems. John Wiley
# & Sons.
# Example 3.6-6 (page 198)
xy_trajectory_data = [
    # time (s)  X (ft)  Y(ft)
    0.00e0      0.00e0    0.00e0
    1.00e1      2.36e2    3.33e3
    2.00e1     -4.68e2    6.65e1
    3.00e1      6.90e2    3.20e3
    4.00e1     -8.97e2    2.61e2
    5.00e1      1.09e3    2.94e3
    6.00e1     -1.26e3    5.68e2
    7.00e1      1.40e3    2.59e3
    8.00e1     -1.51e3    9.62e2
    9.00e1      1.60e3    2.16e3
    1.00e2     -1.66e3    1.41e3
    1.10e2      1.67e3    1.70e3
    1.20e2     -1.66e3    1.89e3
    1.30e2      1.61e3    1.22e3
    1.40e2     -1.53e3    2.35e3
    1.50e2      1.42e3    7.87e2
    1.60e2     -1.28e3    2.76e3
    1.70e2      1.11e3    4.22e2
    1.80e2     -9.21e2    3.07e3
 ]

 for case in eachrow(xy_trajectory_data)
    idx = findall(x->abs(x-case[1])<1e-10, results[:, 1])[1]
    @test isapprox(case[2], results[idx, 11], atol=20)
    @test isapprox(case[3], results[idx, 12], atol=20)
 end

# Check that TAS, α, β, θ, ϕ, p, q, r, alt, pow remain constant
@test isapprox(x[1], x_trim[1])  # TAS
@test isapprox(x[2], x_trim[2])  # α
@test isapprox(x[3], x_trim[3])  # β
@test isapprox(x[4], x_trim[4])  # θ
@test isapprox(x[5], x_trim[5])  # ϕ
@test isapprox(x[7], x_trim[7])  # p
@test isapprox(x[8], x_trim[8])  # q
@test isapprox(x[9], x_trim[9])  # r
@test isapprox(x[12], x_trim[12])  # alt
@test isapprox(x[13], x_trim[13])  # pow
