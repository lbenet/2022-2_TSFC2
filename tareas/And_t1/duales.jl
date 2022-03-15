module DifAutom

export Dual, dual, fun, der

struct Dual{T<:Real}

	fun::T   ### properties, field names or parameters
	der::T
	
	function Dual(fun::T, der::T) where {T<:Union{AbstractFloat,Rational}}
		return new{T}(fun, der)   ### Defining the Dual type
	end
end

	### Some methods

function Dual(fun::T1, der::T2) where {T1<:Real, T2<:Real}   ### Promoting to Float64
	fu, de = promote(fun, der)								   # or Rational
	return Dual(fu, de)										   # bigs included
end
function Dual(fun::T, der::T) where {T<:Integer}   ### both integers case
	fu, de, _ = promote(fun, der, 1.0)
	return Dual(fu, de)
end

function Dual{Float64}(fun::T1, der::T2) where {T1<:Real, T2<:Real}   ### Explicit
	return Dual(Float64(fun), der)										# types
end
function Dual{BigFloat}(fun::T1, der::T2) where {T1<:Real, T2<:Real}
	return Dual(BigFloat(fun), der)
end
function Dual{Rational{Int}}(fun::T1, der::T2) where {T1<:Real, T2<:Real}
	return Dual(Rational(fun), der)
end   ### Like this, it would be missed the Rational{BigInt} case

	### Some functions
	
function fun(D::Dual)   ### Getting the function (REDUNDANT, for me)
	D.fun
end
function der(D::Dual)   ### Getting the derivative (REDUNDANT, for me)
	D.der
end

function Dual(c::Real)   ### The constant function (zero)
	return Dual(c,0)	   # like evaluating the function in c: f(c)
end

function dual(x::Real)   ### The identity function (unity)
	return Dual(x,1)	   # obtaining the derivative of the function in x: f'(x)
end

	### Algebra of duals
	
import Base: ==
	function ==(D1::Dual, D2::Dual)   ### Dual(a,b) = Dual(c,d)  ⇒  a = c & b = d
		if D1.fun == D2.fun && D1.der == D2.der
			return true
		end
	end
	
	function ==(D::Dual, x::Real)   ### Dual(a,b) = x  ⇒  a = x
		if D.fun == x
			return true
		end
	end
	function ==(x::Real, D::Dual)   ### x = Dual(a,b) ⇒  x = a
		if x == D.fun
			return true
		end
	end

import Base: +
	function +(D::Dual)
		return Dual(+D.fun, +D.der)
	end
	
	function +(D1::Dual, D2::Dual)   ### Dual(a,b) + Dual(c,d)  ⇒  Dual(a+c,b+d)
		return Dual(D1.fun+D2.fun, D1.der+D2.der)
	end
	
	function +(D::Dual, x::Real)   ### Dual(a,b) + x  ⇒  Dual(a+x,b)
		return Dual(D.fun+x, D.der)
	end
	function +(x::Real, D::Dual)   ### x + Dual(a,b)  ⇒  Dual(x+a,b)
		return Dual(x+D.fun, D.der)
	end

import Base: -
	function -(D::Dual)
		return Dual(-D.fun, -D.der)
	end
	
	function -(D1::Dual, D2::Dual)   ### Dual(a,b) - Dual(c,d)  ⇒  Dual(a-c,b-d)
		return Dual(D1.fun-D2.fun, D1.der-D2.der)
	end
	
	function -(D::Dual, x::Real)   ### Dual(a,b) - x  ⇒  Dual(a-x,b)
		return Dual(D.fun-x, D.der)
	end
	function -(x::Real, D::Dual)   ### x - Dual(a,b)  ⇒  Dual(x-a,-b)
		return Dual(x-D.fun, -D.der)
	end

import Base: *
	function *(D1::Dual, D2::Dual)   ### Dual(a,b)*Dual(c,d)  ⇒  Dual(a*c,a*d+b*c)
		return Dual(D1.fun*D2.fun, D1.fun*D2.der+D1.der*D2.fun)
	end

	function *(D::Dual, x::Real)   ### Dual(a,b)*x  ⇒  Dual(a*x,b*x)
		return Dual(D.fun*x, D.der*x)
	end
	function *(x::Real, D::Dual)   ### x*Dual(a,b)  ⇒  Dual(x*a,x*b)
		return Dual(x*D.fun, x*D.der)
	end

import Base: /
	function /(D1::Dual, D2::Dual)   ### Dual(a,b)/Dual(c,d)  ⇒ Dual(a/c,(b-(a/c)d)/c)
		return Dual(D1.fun/D2.fun, (D1.der-D1.fun/D2.fun*D2.der)/D2.fun)
	end

	function /(D::Dual, x::Real)   ### Dual(a,b)/x  ⇒  Dual(a/x,b/x)
		return Dual(D.fun/x, D.der/x)
	end
	function /(x::Real, D::Dual)   ### x/Dual(a,b)  ⇒  Dual(x/a,-x*b/a^2)
		return Dual(x/D.fun, -(x*D.der)/D.fun^2)
	end

import Base: ^
	function ^(D::Dual, n::Real)   ### Dual(a,b)^n  ⇒  Dual(a^n,na^(n-1)b)
		return Dual(D.fun^n, n*D.fun^(n-1)*D.der)
	end
import Base: inv
	function inv(D::Dual)   ### inv(Dual(a,b))  ⇒  Dual(a,b)/1
		return 1/D
	end

	### Arithmetic functions for duals
	
import Base: sqrt
	function sqrt(D::Dual)
		return D^0.5
	end

end