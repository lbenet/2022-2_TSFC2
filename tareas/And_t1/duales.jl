module DifAutom

export Dual, dual, fun, der

struct Dual{T<:Real}

	fun::T;   der::T   ### properties, field names or parameters
	
end   ### julia automatically creates a 'new' constructor

	### Some methods

function Dual(fun, der)   ### Promoting to Float64
	fu, de = promote(fun, der)   # or Rational
	return Dual(fu, de)   # bigs included
end
function Dual(fun::T, der::T) where {T<:Integer}   ### both integers case
	fu, de, _ = promote(fun, der, 1.0)
	return Dual(fu, de)
end

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
		return D1.fun == D2.fun && D1.der == D2.der
	end
	
	function ==(D::Dual, x::Real)   ### Dual(a,b) = x  ⇒  b = 0 & a = x
		return D.fun == x && D.der == 0.0
	end
	function ==(x::Real, D::Dual)   ### x = Dual(a,b) ⇒  x = a & 0 = b
		return x == D.fun && 0.0 == D.der
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
		return Dual(D1.fun/D2.fun, (D1.der-(D1.fun/D2.fun)*D2.der)/D2.fun)
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
	function inv(D::Dual)   ### inv(Dual(a,b))  ⇒  1/Dual(a,b)
		return 1/D
	end

	### Arithmetic functions for duals
	
import Base: sqrt
	function sqrt(D::Dual)
		return Dual(sqrt(D.fun), 1/(2*sqrt(D.fun))*D.der)
	end

import Base: exp
	function exp(D::Dual)
		return Dual(exp(D.fun), D.der*exp(D.fun))
	end

import Base: log
	function log(D::Dual)
		return Dual(log(D.fun), D.der/D.fun)
	end

import Base: sin
	function sin(D::Dual)
		return Dual(sin(D.fun), cos(D.fun)*D.der)
	end

import Base: cos
	function cos(D::Dual)
		return Dual(cos(D.fun), -sin(D.fun)*D.der)
	end

import Base: tan
	function tan(D::Dual)
		return Dual(tan(D.fun), sec(D.fun)^2*D.der)
	end

import Base: asin
	function asin(D::Dual)
		return Dual(asin(D.fun), 1/sqrt(1-D.fun^2)*D.der)
	end

import Base: acos
	function acos(D::Dual)
		return Dual(acos(D.fun), -1/sqrt(1-D.fun^2)*D.der)
	end

import Base: atan
	function atan(D::Dual)
		return Dual(atan(D.fun), 1/(1+D.fun^2)*D.der)
	end

import Base: sinh
	function sinh(D::Dual)
		return Dual(sinh(D.fun), cosh(D.fun)*D.der)
	end

import Base: cosh
	function cosh(D::Dual)
		return Dual(cosh(D.fun), sinh(D.fun)*D.der)
	end

import Base: tanh
	function tanh(D::Dual)
		return Dual(tanh(D.fun), sech(D.fun)^2*D.der)
	end

import Base: asinh
	function asinh(D::Dual)
		return Dual(asinh(D.fun), 1/sqrt(D.fun^2+1)*D.der)
	end

import Base: acosh
	function acosh(D::Dual)
		return Dual(acosh(D.fun), 1/(sqrt(D.fun+1)*sqrt(D.fun-1))*D.der)
	end

import Base: atanh
	function atanh(D::Dual)
		return Dual(atanh(D.fun), 1/(1-D.fun^2)*D.der)
	end

end