using Test

# include("series_taylor.jl")

using .SeriesTaylor

@testset "Tests para `evaluar`" begin
    t = Taylor(16)
    s = sin(t)
    @test evaluar(s, 0.1) == sin(0.1)
    @test abs(evaluar(s, 0.2) - sin(0.2)) < 1.e-15
    @test abs(evaluar(s, -0.2) - sin(-0.2)) < 1.e-15
    @test abs(evaluar(s, 0.3) - sin(0.3)) < 1.e-13
    @test abs(evaluar(s, -0.3) - sin(-0.3)) < 1.e-13

    f(x) = sqrt(1-sin(x)^2)
    t = Taylor(16)
    ft = f(pi/6+t)
    @test evaluar(ft, 0.0) ≈ cos(pi/6)
    @test abs(evaluar(ft, 0.2) - cos(pi/6+0.2)) < 1.e-15
    @test abs(evaluar(ft, -0.2) - cos(pi/6-0.2)) < 1.e-15
    @test abs(evaluar(ft, 0.3) - cos(pi/6+0.3)) < 1.e-13
    @test abs(evaluar(ft, -0.3) - cos(pi/6-0.3)) < 1.e-13
end

@testset "Integracion EDO escalar" begin
    flin(x, p, t) = p*x
    exact_sol_flin(t, t0, x0, p) = x0 * exp(p*(t-t0))
    pp = 1.0

    # Integración "hacia adelante"
    x0 = 2.0
    vt, vx = integracion_taylor(flin, x0, 0.0, 0.6, 20, 1.e-20, pp)
    @test maximum(exact_sol_flin.(vt, 0.0, x0, pp) .- vx) < 1.e-14
    @test vt[end] == 0.6
    # Integración "hacia atrás"
    x0 = vx[end]
    vtb, vxb = integracion_taylor(flin, x0, vt[end], vt[1], 20, 1.e-20, pp)
    @test maximum(exact_sol_flin.(vtb, vt[end], x0, pp) .- vxb) < 1.e-14
    @test vtb[end] == vt[1]
    @test vxb[end] ≈ vx[1]

    pp = -2.0
    # Integración "hacia adelante"
    x0 = 2.0
    vt, vx = integracion_taylor(flin, x0, 0.0, 0.25, 20, 1.e-20, pp)
    @test maximum(exact_sol_flin.(vt, 0.0, x0, pp) .- vx) < 1.e-14
    @test vt[end] == 0.25
    # Integración "hacia atrás"
    x0 = vx[end]
    vtb, vxb = integracion_taylor(flin, x0, vt[end], vt[1], 20, 1.e-20, pp)
    @test maximum(exact_sol_flin.(vtb, vt[end], x0, pp) .- vxb) < 1.e-14
    @test vtb[end] == vt[1]
    @test vxb[end] ≈ vx[1]

    # Integración "hacia adelante"
    f(x, p, t) = x^2
    exact_sol_f(t, t0, x0) = x0/(1-x0*(t-t0))
    vt, vx = integracion_taylor(f, 1.0, 0.0, 0.6, 20, 1.e-20, nothing)
    @test maximum(exact_sol_f.(vt, 0.0, 1.0) .- vx) < 1.e-14
    @test vt[end] == 0.6
    # Integración hacia atrás
    vtb, vxb = integracion_taylor(f, vx[end], vt[end], vt[1], 20, 1.e-20, nothing)
    @test maximum(exact_sol_f.(vt, vt[end], 1.0) .- vx) < 1.e-14
    @test vtb[end] == vt[1]
    @test vxb[end] ≈ vx[1]

    # Integración "hacia adelante"
    vt, vx = integracion_taylor(f, 3.0, 0.0, 0.25, 20, 1.e-20, nothing)
    @test maximum(exact_sol_f.(vt, 0.0, 3.0) .- vx) < 1.e-14
    @test vt[end] == 0.25
    # Integración "hacia atrás"
    vtb, vxb = integracion_taylor(f, vx[end], vt[end], vt[1], 20, 1.e-20, nothing)
    @test maximum(exact_sol_f.(vt, vt[end], 3.0) .- vx) < 1.e-14
    @test vtb[end] == vt[1]
    @test vxb[end] ≈ vx[1]

    # Integración dependiente de t
    g(x, p, t) = cos(t)
    exact_sol_g(t, t0) = sin(t) - sin(t0)
    vt, vx = integracion_taylor(g, 0.0, 0.0, pi/2, 20, 1.e-20, nothing)
    @test maximum(exact_sol_g.(vt, 0.0) .- vx) < 1.e-14
    @test vt[end] ≈ pi/2
end

@testset "Integracion EDO vectorial" begin
    function flin!(dx, x, p, t)
        dx .= p .* x
        return nothing
    end
    exact_sol_flin(t, t0, x0, p) = x0 .* exp.(p .* (t .- t0))
    pp = [1.0, -2.0]
    # Integración "hacia adelante"
    x0 = [2.0, 2.0]
    vt, vx = integracion_taylor(flin!, x0, 0.0, 0.6, 20, 1.e-20, pp)
    @test all(maximum.(exact_sol_flin.(vt, 0.0, (x0,), (pp,)) .- vx) .< 1.e-14)
    @test vt[end] == 0.6
    @test isa(vx, Vector{Vector{Float64}})
    # Integración "hacia atrás"
    x0 = vx[end][:]
    vtb, vxb = integracion_taylor(flin!, x0, vt[end], vt[1], 20, 1.e-20, pp)
    @test all(maximum.(exact_sol_flin.(vtb, vt[end], (x0,), (pp,)) .- vxb) .< 1.e-14)
    @test vtb[end] == vt[1]
    @test vxb[end] ≈ vx[1]

    function f!(dx, x, p, t)
        dx .= x .^ 2
        return nothing
    end
    exact_sol_f(t, t0, x0) = x0 ./ (1 .- x0 .* (t-t0))
    # Integración "hacia adelante"
    x0 = [1.0, 3.0]
    vt, vx = integracion_taylor(f!, x0, 0.0, 0.5, 20, 1.e-20, nothing)
    @test vt[end] < 1/3
    @test all(maximum.(exact_sol_f.(vt, 0.0, (x0,)) .- vx) .< 1.e-14)
    vt, vx = integracion_taylor(f!, x0, 0.0, 0.2, 20, 1.e-20, nothing)
    # Integración "hacia atrás"
    x0 = vx[end][:]
    vtb, vxb = integracion_taylor(f!, x0, vt[end], vt[1], 20, 1.e-20, nothing)
    @test all(maximum.(exact_sol_f.(vtb, vt[end], (x0,)) .- vxb) .< 1.e-14)
    @test vtb[end] == vt[1]
    @test vxb[end] ≈ vx[1]

    function osc_arm!(dx, x, p, t)
        dx[1] = x[2]
        dx[2] = -x[1]
        return nothing
    end
    exact_sol_osc_arm(t, t0, x0) =
        [x0[1]*cos(t-t0) + x0[2]*sin(t-t0), -x0[1]*sin(t-t0) + x0[2]*cos(t-t0)]
    energia_osc_arm(x) = x[2]^2/2 + x[1]^2/2
    # Integración "hacia adelante"
    x0 = [1.0, 0.0]
    vt, vx = integracion_taylor(osc_arm!, x0, 0.0, 4*pi, 20, 1.e-20, nothing)
    @test all(maximum.(exact_sol_osc_arm.(vt, 0.0, (x0,)) .- vx) .< 1.e-14)
    # Conservación de la energía
    @test all(maximum.(energia_osc_arm.(vx) .- energia_osc_arm(vx[1,])) .< 1.e-14)
    # Integración "hacia atrás"
    x0 = vx[end][:]
    vtb, vxb = integracion_taylor(osc_arm!, x0, vt[end], vt[1], 20, 1.e-20, nothing)
    @test all(maximum.(exact_sol_osc_arm.(vtb, vt[end], (x0,)) .- vxb) .< 1.e-14)
    @test vtb[end] == vt[1]
    @test vxb[end] ≈ vx[1]
end
