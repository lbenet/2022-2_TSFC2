module SeriesTaylor

export Taylor

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
	function *(T1::Taylor, T2::Taylor)   ### Check formula in notebook
		m = min(length(T1.coefs), length(T2.coefs))
		T3 = zeros(m)
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
	function /(T1::Taylor, T2::Taylor)   ### Check formula in notebook
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
	/(T::Taylor, n::Number) = Taylor(T.coefs ./ n)   ### T/n = T[T₀/n, ..., Tₖ/n]
	function /(n::Number, T::Taylor)   ### n/T = T[1/T₀, 0/T₁, ..., 0/Tₖ]  
		@assert T.coefs[1] != 0
		l = length(T.coefs);   zs = zeros(l);   zs[1] = n
		return Taylor(zs)/T
	end

import Base: inv   ### Another method
	inv(T::Taylor) = 1/T

### Taylor's functions

nothing

end