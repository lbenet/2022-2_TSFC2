module SeriesTaylor

export Taylor, evaluar, integracion_taylor

struct Taylor{T<:Number} <: Number
	coefs::Vector{T}
end

### Taylor's methods

function Taylor(DT::Type, i::Int64)   ### Taylor([0, 1, 0, ..., 0])
	zs = zeros(DT, i+1)									# i times
	zs[2] = one(DT)						# with each entry of type: DT
	return Taylor(zs)
end
Taylor(i::Int64) = Taylor(Float64, i)   # default type: Float64

import Base: zero   ### Taylor([0, 0, ..., 0])
	zero(T::Taylor) = Taylor(zero(T.coefs))

import Base: one   ### Taylor([1, 0, 0, ..., 0])
	function one(T::Taylor)
		O = zeros(length(T.coefs))
		O[1] = 1
		return Taylor(O)
	end

import Base: ≈   ### T1ᵢ ≈ T2ᵢ for i={0, 1, ..., min(Order(T1), Order(T2))}
	≈(T1::Taylor, T2::Taylor) = T1.coefs ≈ T2.coefs

### Taylor's arithmetic (and with constants)

import Base: ==   ### T1 = T2  ⇒  T1ᵢ = T2ᵢ for i={0,1,..., min(Order(T1), Order(T2))}
	function ==(T1::Taylor, T2::Taylor)
		m = min(length(T1.coefs), length(T2.coefs))
		return T1.coefs[1:m] == T2.coefs[1:m]
	end
	function ==(T::Taylor, n::Number)   ### T == n  ⇒  T₀ = n  &  T₁, ..., Tₖ = 0
		l = length(T.coefs);   zs = zeros(l);   zs[1] = n
		return T.coefs == Taylor(zs).coefs
	end
	function ==(n::Number, T::Taylor)   ### n == T  ⇒  n = T₀  &  0 = T₁, ..., Tₖ
		l = length(T.coefs);   zs = zeros(l);   zs[1] = n
		return Taylor(zs).coefs == T.coefs
	end
	
import Base: +
	function +(T1::Taylor, T2::Taylor)   ### T1 + T2 = T[T1₀+T2₀, ..., T1ₘᵢₙ+T2ₘᵢₙ]
		m = min(length(T1.coefs), length(T2.coefs))
		return Taylor(T1.coefs[1:m]+T2.coefs[1:m])
	end
	function +(T::Taylor, n::Number)   ### with N = T[n, 0, 0, ..., 0ₖ]
		l = length(T.coefs);   zs = zeros(l);   zs[1] = n
		return T + Taylor(zs)
	end
	function +(n::Number, T::Taylor)
		l = length(T.coefs);   zs = zeros(l);   zs[1] = n
		return Taylor(zs) + T
	end

import Base: -
	function -(T1::Taylor, T2::Taylor)   ### T1 - T2 = T[T1₀-T2₀, ..., T1ₘᵢₙ-T2ₘᵢₙ]
		m = min(length(T1.coefs), length(T2.coefs))
		return Taylor(T1.coefs[1:m]-T2.coefs[1:m])
	end
	function -(T::Taylor, n::Number)   ### with N = T[n, 0, 0, ..., 0ₖ]
		l = length(T.coefs);   zs = zeros(l);   zs[1] = n
		return T - Taylor(zs)
	end
	function -(n::Number, T::Taylor)
		l = length(T.coefs);   zs = zeros(l);   zs[1] = n
		return Taylor(zs) - T
	end
	-(T::Taylor) = Taylor(-T.coefs)

import Base: *
	function *(T1::Taylor, T2::Taylor)   ### Check recurssion formulas in book
		m = min(length(T1.coefs), length(T2.coefs))
		T3 = zeros(promote(typeof(T1.coefs[1]), typeof(T2.coefs[1]))[1], m) # if Int
		for k in 1:m
			Σ = 0
			for i in 0:k-1
				Σ += T1.coefs[i+1]*T2.coefs[k-i]
			end
			T3[k] = Σ
		end
		return Taylor(T3)
	end
	*(T::Taylor, n::Number) = Taylor(T.coefs .* n)   ### T*n = T[T₀*n, ..., Tₖ*n]
	*(n::Number, T::Taylor) = Taylor(n .* T.coefs)   ### n*T = T[n*T₀, ..., n*Tₖ]

import Base: /
	function /(T1::Taylor, T2::Taylor)
		@assert T2.coefs[1] != 0
		m = min(length(T1.coefs), length(T2.coefs))
		T3 = zeros(m)
		for k in 1:m
			Σ = 0
			for i in 1:k-1
				Σ += T3[i]*T2.coefs[k+1-i]   ### The trick is in T2.coefs[k+1-i]
			end                                                           # ↑
			T3[k] = (T1.coefs[k] - Σ)/T2.coefs[1]
		end
		return Taylor(T3)
	end
	function /(n::Number, T::Taylor)   ### N/T with N = Taylor([n, 0, 0, ..., 0])
		@assert T.coefs[1] != 0
		l = length(T.coefs);   zs = zeros(l);   zs[1] = n
		return Taylor(zs)/T
	end
	/(T::Taylor, n::Number) = Taylor(T.coefs ./ n)   ### T/n = T[T₀/n, ..., Tₖ/n]
	

import Base: inv   ### Another method
	inv(T::Taylor) = 1/T

### Taylor's functions

import Base: ^
	function ^(T::Taylor, r::Union{Float64, Int64})
		l = length(T.coefs)
		P = zeros(typeof(T.coefs[1]), l)
		if r%1 == 0   ### Integer case (mathematically)
			if r == 2   ### T^2 case
				P[1] = T.coefs[1]^2
				for k in 2:l
					Σ = 0
					if k%2 == 0
						for j in 0:(k-2)/2
							Σ += T.coefs[Int(j)+1]*T.coefs[k-Int(j)]
						end
						P[k] = 2Σ
					else
						for j in 0:(k-3)/2
							Σ += T.coefs[Int(j)+1]*T.coefs[k-Int(j)]
						end
						P[k] = T.coefs[Int((k+1)/2)]^2 + 2Σ   ### index trick!
					end
				end
				return Taylor(P)
			else   ### T^n  n∈N  case
				P = T
				for p in 2:r
					P = P*T   ### Doing the product r times
				end
				return P
			end
		else   ### Rational case (mathematically)
			if r == 1/2
				@assert T.coefs[1] > 0
				P[1] = sqrt(T.coefs[1])
				for k in 2:l
					if k%2 == 0
						Σ = 0
						for j in 1:(k-1)/2
							Σ += P[Int(j)+1]*P[k-Int(j)]
						end
						P[k] = (T.coefs[k] - 2Σ)/(2P[1])
					else
						Σ = 0
						for j in 1:(k-2)/2
							Σ += P[Int(j)+1]*P[k-Int(j)]
						end
						P[k] = (T.coefs[k] - P[Int((k+1)/2)]^2 - 2Σ)/(2P[1])
					end
				end
				return Taylor(P)
			else
				@assert T.coefs[1] != 0
				P[1] = T.coefs[1]^r
				for k in 2:l
					Σ = 0
					for j in 0:k-1
						Σ += (r*(k-1-j)-j)*T.coefs[k-j]*P[j+1]
					end
					P[k] = Σ/((k-1)*T.coefs[1])
				end
				return Taylor(P)
			end
		end
	end

import Base: sqrt   ### Another method
	sqrt(T::Taylor) = T^(1/2)

import Base: exp
	function exp(T::Taylor)
		l = length(T.coefs)
		E2 = zeros(typeof(T.coefs[1]), l)   ### in case they are complex
		E = float.(E2)   ### in case they are Complex{Int64}
		E[1] = exp(T.coefs[1])
		for k in 2:l
			Σ = 0
			for j in 0:k-1
				Σ += (k-1-j)*T.coefs[k-j]*E[j+1]
			end
			E[k] = Σ/(k-1)
		end
		return Taylor(E)
	end

import Base: log
	function log(T::Taylor)
		@assert T.coefs[1] > 0
		l = length(T.coefs)
		L = zeros(l)
		L[1] = log(T.coefs[1])
		for k in 2:l
			Σ = 0
			for j in 0:k-2
				Σ += j*T.coefs[k-j]*L[j+1]
			end
			L[k] = (T.coefs[k] - Σ/(k-1))/T.coefs[1]
		end
		return Taylor(L)
	end

import Base: sin
import Base: cos
	function sin_cos(T::Taylor)
		l = length(T.coefs)
		S = zeros(l);   C = zeros(l)
		S[1] = sin(T.coefs[1]);   C[1] = cos(T.coefs[1])
		for k in 2:l
			Σs = 0;   Σc = 0
			for j in 0:k-2
				Σs += (k-1-j)*T.coefs[k-j]*C[j+1]
				Σc += (k-1-j)*T.coefs[k-j]*S[j+1]
			end
			S[k] = Σs/(k-1);   C[k] = -Σc/(k-1)
		end
		return S, C
	end
	function sin(T::Taylor)
		return Taylor(sin_cos(T)[1])
	end
	function cos(T::Taylor)
		return Taylor(sin_cos(T)[2])
	end

import Base: tan
	function tan(T::Taylor)
		l = length(T.coefs)
		Tg = zeros(l)
		Tg[1] = tan(T.coefs[1])
		for k in 2:l
			Σ = 0
			P = Taylor(Tg)^2
			for j in 0:k-1
				Σ += (k-1-j)*T.coefs[k-j]*P.coefs[j+1]
			end
			Tg[k] = T.coefs[k] + Σ/(k-1)
		end
		return Taylor(Tg)
	end

import Base: asin
	function asin(T::Taylor)
		l = length(T.coefs)
		As = zeros(l)
		As[1] = asin(T.coefs[1])
		As[2] = T.coefs[2]/sqrt(1-T.coefs[1]^2)
		r = sqrt(1-T^2)   ### auxiliar poly
		for k in 3:l
			Σ = 0
			for j in 1:k-1
				Σ += j*r.coefs[k-j]*As[j+1]
			end
			As[k] = (T.coefs[k] - Σ/(k-1))/sqrt(1-T.coefs[1]^2)
		end
		return Taylor(As)
	end

import Base: acos
	acos(T::Taylor) = -asin(T::Taylor).+π/2

import Base: atan
	function atan(T::Taylor)
		l = length(T.coefs)
		At = zeros(l)
		At[1] = atan(T.coefs[1])
		At[2] = T.coefs[2]/(1+T.coefs[1]^2)
		r = 1 + T^2   ### auxiliar poly
		for k in 3:l
			Σ = 0
			for j in 1:k-1
				Σ += j*r.coefs[k-j]*At[j+1]
			end
			At[k] = (T.coefs[k] - Σ/(k-1))/(1+T.coefs[1]^2)
		end
		return Taylor(At)
	end

### Taylor applications

function evaluar(T::Taylor, h::Real)   ### f(x) ≡ Taylor ⇒ f(x₀) ≡ f(h) Export!
	coefs = T.coefs
	b₀ = coefs[end-1] + coefs[end]*h   ### Horner's algorithm
	for c in 2:length(coefs)-1
		b₀ = coefs[end-c] + b₀*h
	end
	return b₀
end

### Scalar case

function coefs_taylor(f, t::Taylor{T}, u::Taylor{T}, p) where {T}
	l = length(t.coefs)   ### order
	C = zeros(T, l)   ### T to assure same type
	ts = t.coefs
	C[1] = u.coefs[1]   ### x₀
	for c in 2:l   ### till c-1 'cause we don't need evaluate higher orders
		C[c] = f(Taylor(C[1:c-1]), p, Taylor(ts[1:c-1])).coefs[c-1]/(c-1)
	end
	return Taylor(C)
end

function paso_integracion(U, ϵ)
	u = U.coefs
	orden = length(u)-1
	δₜ = (ϵ/abs(u[end]))^(1/orden)
	δₜ₋₁ = (ϵ/abs(u[end-1]))^(1/(orden-1))
	return min(δₜ, δₜ₋₁)*0.5
end

function paso_taylor(f, t::Taylor, u::Taylor, p, ϵ)
	xₖ = coefs_taylor(f, t, u, p)
	δ = paso_integracion(xₖ, ϵ)
	return δ, xₖ
end

function integracion_taylor_f(f, x₀::T, t₀::T, tₖ::T, order, ϵ, p) where {T<:Real}
	ts = [t₀];   xs = [x₀]
	while ts[end] < tₖ
		t = Taylor(T, order)+ts[end]
		u = Taylor(T, order);   u.coefs[1] = xs[end]
		δ, u = paso_taylor(f, t, u, p, ϵ);   mb = 1.e-10   ### mb: minimum bound t
		nt = ts[end]+δ   ### nt: new t
		if tₖ < nt
			push!(xs, evaluar(u, tₖ-ts[end]))
			push!(ts, tₖ)
		elseif δ ≥ mb
			push!(ts, nt)
			push!(xs, evaluar(u, δ))
		else
			break
		end
	end
	return ts, xs
end

function integracion_taylor_b(f, x₀::T, t₀::T, tₖ::T, order, ϵ, p) where {T<:Real}
	ts = [t₀];   xs = [x₀]
	while tₖ < ts[end]
		t = Taylor(T, order)+ts[end]
		u = Taylor(T, order);   u.coefs[1] = xs[end]
		δ, u = paso_taylor(f, t, u, p, ϵ);   mb = 1.e-10   ### mb: minimum bound t
		nt = ts[end]-δ   ### nt: new t
		if nt < tₖ
			push!(xs, evaluar(u, tₖ-ts[end]))
			push!(ts, tₖ)
		elseif δ ≥ mb
			push!(ts, nt)
			push!(xs, evaluar(u, -δ))
		else
			break
		end
	end
	return ts, xs
end
	
function integracion_taylor(f, x₀, t₀, tₖ, order, ϵ, p)
	if t₀ < tₖ
		return integracion_taylor_f(f, x₀, t₀, tₖ, order, ϵ, p)
	else
		return integracion_taylor_b(f, x₀, t₀, tₖ, order, ϵ, p)
	end
end

### Vectorial case

end
