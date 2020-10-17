using Test
using F16SimStevens


#  Stevens, B. L., Lewis, F. L., & Johnson, E. N. (2015). Aircraft control
#  and simulation: dynamics, controls design, and autonomous systems. John Wiley
#  & Sons. (page 185 table 3.5-2)

# xcg = 0.4 * CMA

# INPUTS
# U(1) = THTL =   0.9  [-]
# U(2) = ELEV =  20    [DEG]
# U(3) = DAIL = -15    [DEG]
# U(4) = RDR  = -20    [DEG]

# STATE
# IDX     name      X        UNITS        XDOT           XDOT MORELLI
# 1       VT       500       [ft/s]      -75.23724       -77.57521
# 2       ALPHA      0.5     [RAD]       -0.8813491      -0.88123
# 3       BETA      -0.2     [RAD]       -0.4759990      -0.45276
# 4       PHI       -1       [RAD]        2.505734        0.70000
# 5       THETA      1       [RAD]        0.3250820       0.32508
# 6       PSI       -1       [RAD]        2.145926        2.14593
# 7       P          0.7     [RAD/S]     12.62679        12.91108
# 8       Q         -0.8     [RAD/S]      0.9649671      0.97006
# 9       R          0.9     [RAD/S]      0.5809759      -0.55450
# 10      X       1000       [FT]       342.4439         342.44390
# 11      Y        900       [FT]      -266.7707         -266.77068
# 12      ALT    10000       [FT]       248.1241          248.12412
# 13      POW       90       [%]        -58.6899         -58.6900

t = 0.0  # s

x = [500.0, 0.5, -0.2, -1.0, 1.0, -1.0, 0.7, -0.8, 0.9, 1000.0, 900.0, 10000.0, 90.0]
xcg = 0.40
controls = [0.9, 20.0, -15.0, -20.0]

xd_exp = [
    -75.23724,
    -0.8813491,
    -0.4759990,
    2.505734,
    0.3250820,
    2.145926,
    12.62679,
    0.9649671,
    0.5809759,
    342.4439,
    -266.7707,
    248.1241,
    -58.6899,
]

xd_1, outputs_1 = F16SimStevens.f(t, x, xcg, controls)

# Check against Stevens
@test isapprox(xd_1, xd_exp, atol=0.05)
