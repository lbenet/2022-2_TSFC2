#=
using Test, Revise
includet("zYo/series_taylor.jl")
using .SeriesTaylor
include("tareas/tests/series_taylor.jl")

=#

using Test

# include("series_taylor.jl")

using .SeriesTaylor

@testset "Creación de Taylor" begin
    a = Taylor([1.0,2,3])
    @test typeof(a) == Taylor{Float64}
    @test a.coefs == [1.0, 2.0, 3.0]
    @test a isa Taylor
    @test a isa Number

    b = Taylor([big(1.0),2,3])
    @test typeof(b) == Taylor{BigFloat}
    @test b isa Number
    @test a.coefs == b.coefs

    c = Taylor(complex.(zeros(3), ones(3)))
    @test typeof(c) == Taylor{ComplexF64}
    @test c isa Taylor{ComplexF64}
    @test c isa Number

    orden = 2
    t = Taylor(orden)
    @test t.coefs == [0.0, 1.0, 0.0]
    @test length(t.coefs) == orden+1
    orden = 4
    t = Taylor(orden)
    @test t.coefs == [0.0, 1.0, 0.0, 0.0, 0.0]
    @test length(t.coefs) == orden+1
    orden = 3
    tb = Taylor(BigFloat, orden)
    @test tb.coefs == [0.0, big(1.0), 0.0, 0.0]
    @test length(tb.coefs) == orden+1
    ti = Taylor(Int, orden)
    @test ti isa Taylor{Int}
    @test ti.coefs == [0, 1, 0, 0]
end

@testset "Operaciones aritméticas" begin
    a = Taylor([1.0,2,3])
    b = Taylor([big(1.0),2,3, 4])
    c = Taylor(pushfirst!(zeros(2), 1))
    @test a == b
    @test a != Taylor(5)
    @test c == 1.0
    @test 1.0 != a

    # :+, :-
    @test +a == a
    @test -c == Taylor([-1.0, 0.0, 0.0])
    @test a + a == Taylor([2.0, 4.0, 6.0])
    @test a + b == b + b
    @test typeof(a+b) == Taylor{BigFloat}
    @test a - a == c - c
    @test c + (-1) == Taylor(zeros(3))
    @test c - 1 == Taylor(zeros(3))
    @test Taylor(zeros(3)) == c + (-1)
    @test Taylor(zeros(3)) == c - 1

    # :*
    @test a * a == Taylor([1.0, 4.0, 10.0])
    @test b * 2 == b + b
    @test big(2) * b == b * 2

    # :/
    d = inv(a)
    @test a / a == c
    @test a / 0.5 == a + a
    @test d == Taylor([1.0, -2.0, 1.0])
    @test a * inv(a) == c
    @test inv(c) == c
    @test_throws AssertionError a / Taylor(2)
    @test_throws AssertionError inv(Taylor(2))
end

@testset "Funciones con Taylor" begin
    t = Taylor(5)
    ti = Taylor(Int, 5)

    @test t^2 == ti^2
    @test 1-t^2 == (1-t)*(1+t)
    @test typeof(t^2) == Taylor{Float64}
    @test typeof(ti^2) == Taylor{Int}
    @test (ti^2).coefs == [0, 0, 1, 0, 0, 0]
    @test (1+ti)^5 == Taylor([1, 5, 10, 10, 5, 1])
    @test (1-t)^6 == Taylor([1, -6, 15, -20, 15, -6])
    @test t^6 == zero(t)
    @test sqrt(1+ti) == Taylor([1, 1/2, -1/8, 1/16, -5/128, 7/256])
    @test_throws AssertionError sqrt(ti)
    @test sqrt(sqrt(1+ti)) == (1+t)^0.25
    @test sqrt(sqrt(2-t)) ≈ (2-ti)^0.25
    #
    @test exp(t) == Taylor([1/1, 1/1, 1/2, 1/6, 1/24, 1/120])
    @test exp(2+t) ≈ exp(2)*exp(t)
    @test exp(t^2) == Taylor([1/1, 0, 1/1, 0, 1/2, 0])
    @test exp(t^6) == one(t)
    #
    @test_throws AssertionError log(t)
    @test_throws AssertionError log(-2+t)
    @test log(1+t) == Taylor([0.0, 1.0, -1/2, 1/3, -1/4, 1/5])
    @test log(1-t^2) == log(1-t)+log(1+t)
    @test log(exp(1-t)) == 1-t
    @test exp(log(1-t)) == 1-t
    @test exp(im*t) == cos(t)+im*sin(t)
    @test exp(im*ti^2) == cos(ti^2)+im*sin(ti^2)
    @test sin(t)^2+cos(t)^2 ≈ one(t)
    @test sin(t)/cos(t) ≈ tan(t)
    @test asin(sin(t)) ≈ t
    @test sin(asin(t)) ≈ t
    @test cos(acos(t)) ≈ t
    # @test acos(cos(pi/3+t)) ≈ pi/3+t
    @test tan(atan(t)) ≈ t
    @test atan(tan(t)) ≈ t
end