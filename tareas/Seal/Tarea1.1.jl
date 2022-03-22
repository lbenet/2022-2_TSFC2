struct Dual{T <: Real} <: Real   ##Para derivadas multiples,eso creo
    fun::T
    der::T
end

function Dual(funcion,derivada) 
         fun,der = promote(funcion,derivada)
         return Dual(fun,der)
end

function Dual(funcion::T,derivada::T) where {T<:Integer} 
    fun, der = promote(funcion,derivada,1.0)
 return Dual(fun,der)
end

function Dual(x::Real)
	return Dual(x,0)
end


function dual(x::Real)
    return Dual(x,1)
end

function fun(a::Dual)
    return a.fun
end

function der(a::Dual)
    return a.der
end
    


import Base.==
==(a::Dual, b::Dual) = a.fun == b.fun && a.der == b.der
==(a::Dual, b::Real) = a.fun == b && a.der == 0
==(a::Real, b::Dual) = a == b.fun && b.der == 0


# definimos cómo operar con los el número dual: +,-,*,/,^, inv, Base.sqrt,
import Base.+, Base.-, Base.*, Base./, Base.^, Base.inv, Base.sqrt

+(a::Dual, b::Dual) = Dual(a.fun + b.fun, a.der + b.der)
+(a::Dual, b::Real) = Dual(a.fun + b, a.der)
+(b::Real, a::Dual) = Dual(a.fun + b, a.der)
+(a::Dual) = a

-(a::Dual, b::Dual) = Dual(a.fun - b.fun, a.der - b.der)
-(a::Dual, b::Real) = Dual(a.fun - b, a.der)
-(b::Real, a::Dual) = Dual(-a.fun - b, -a.der)
-(a::Dual) = Dual(-a.fun,-a.der)

*(a::Dual, b::Dual) = Dual(a.fun*b.fun, a.der*b.fun + b.der*a.fun)
*(a::Dual, b::Real) = Dual(b*a.fun, b*a.der)
*(b::Real, a::Dual) = Dual(b*a.fun, b*a.der)

/(a::Dual, b::Dual) = Dual(a.fun/b.fun, (a.der*b.fun - a.fun*b.der)/b.fun^2)
/(a::Dual, b::Real) = Dual(a.fun/b, a.der/b)
/(b::Real, a::Dual) = Dual(b/a.fun, -b*a.der/a.fun^2)

^(a::Dual, b::Real) = Dual(a.fun^b, b*a.fun^(b-1)*a.der)
^(a::Dual, b::Int) =  Dual(a.fun^b, b*a.fun^(b-1)*a.der)

inv(a::Dual) = 1/a

sqrt(a::Dual) = Dual(sqrt(a.fun), a.der/(2*sqrt(a.fun)))


# definimos cómo operar con los el número dual: exp,ln,sin,cos,...
import   Base.exp, Base.log, Base.sin, Base.cos, Base.tan, Base.asin, Base.acos, Base.atan, Base.sinh, Base.cosh, Base.tanh, Base.asinh, Base.acosh, Base.atanh
    
exp(a::Dual) = Dual(exp(a.fun), (a.der)*exp(a.fun))
log(a::Dual) = Dual(log(a.fun), (a.der)/a.fun)

sin(a::Dual) = Dual(sin(a.fun), cos(a.fun)*a.der)
cos(a::Dual) = Dual(cos(a.fun), (-1)*sin(a.fun)*a.der)
tan(a::Dual) = Dual(tan(a.fun), a.der*(sec(a.fun)^2))

asin(a::Dual) = Dual(asin(a.fun), a.der/(sqrt(1-(a.fun)^2)))
acos(a::Dual) = Dual(acos(a.fun), (-1)*a.der/(sqrt(1-(a.fun)^2)))
atan(a::Dual) = Dual(atan(a.fun), a.der/(1+(a.fun)^2))

sinh(a::Dual) = Dual(sinh(a.fun), a.der*cosh(a.fun))
cosh(a::Dual) = Dual(cosh(a.fun), a.der*sinh(a.fun))
tanh(a::Dual) = Dual(tanh(a.fun), a.der*sech(a.fun)^2)

asinh(a::Dual) = Dual(asinh(a.fun), a.der/sqrt((a.fun)^2 +1))
acosh(a::Dual) = Dual(acosh(a.fun), a.der/sqrt((a.fun)^2 -1))
atanh(a::Dual) = Dual(atanh(a.fun), a.der/(1-(a.fun)^2))

