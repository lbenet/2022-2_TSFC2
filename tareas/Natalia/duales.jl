
module DifAutom

import Base: ==, +, -, *, /, ^, inv, sqrt, exp, log, sin, cos, tan, asin, acos, atan, sinh, cosh, tanh, asinh, acosh, atanh
export Dual, dual, inv, fun, der, isdual

	"""
	Dual.

	Estructura paramétrica inmutable que define los duales, cuyos parámetros son subtipo de `Real`. 
	La parte que identifica a f_0 se llama `fun`, y la correspondiente a f'_0 será 	`der` y estas son del tipo `T`. 


	"""
	struct Dual{T <: Union{AbstractFloat,Rational}} 
		
    	fun :: T
    	der :: T
		
    	#function Dual(fun::T, der::T) where {T<:Union{AbstractFloat,Rational}}
			#return new{T}(fun, der)
		#end
	end

	function Dual(real::T) where {T<:Real}   
    		return Dual(real, 0)
    	end	
 		
    	function Dual(fun::T, der::R) where{T<:Real, R<:Real} 
	    	I,S,_= promote(fun, der, 1.0)
      		return Dual(I,S)
	end 
	function Dual(fun::T, der::T) where {T<:Real}   
		I, S, _ = promote(fun, der, 1.0)
		return Dual(I, S)
	end
	function dual(z::T) where {T<:Real}
		return Dual(z,1.0) 
	end

	# fun

	function fun(U::Dual)
		return U.fun 
	end 

	#der 

	function der(U::Dual) 
		return U.der
	end 

	# isdual
 
	function isdual(U::Dual)
		if U.der == 1 
			return true 
		else 
			return false 
		end 
	end 


	######## OPERACIONES ARITMÉTICAS ########
	
	# Igualdad doble 

	function ==(U::Dual, W::Dual)
		return U.fun == W.fun && U.der == W.der
	end

	function ==(U::Dual, x::Real)
		return U.fun == x 
	end

	function ==(x::Real,U::Dual)
		return U.fun == x 
	end

	# Suma
	
	function +(x::Real, B::Dual)
		D = Dual(x + B.fun, B.der)
		return D
	end 

	function +(A::Dual, x::Real)
		D = Dual(x + A.fun, A.der)
		return D 
	end

	function +(A::Dual, B::Dual) 
		D = Dual(A.fun + B.fun, A.der + B.der)					  
		return D
	end 
	
	+(U::Dual) = U

	# Resta 

	function -(x::Real, B::Dual)
		D = Dual(x - B.fun, -B.der)
		return D
	end 

	function -(A::Dual, x::Real)
		D = Dual(A.fun-x, A.der)
		return D
	end

	function -(A::Dual, B::Dual) 
		D = Dual(A.fun - B.fun, A.der - B.der)					  
		return D
	end
	
	-(U::Dual) = Dual(-U.fun, -U.der)

	# Multiplicación

	function *(U::Dual, W::Dual) 
		D = Dual(U.fun*W.fun, U.fun*W.der + W.fun*U.der)					  
		return D
	end

	function *(x::Real, W::Dual)
		D = Dual(x*W.fun, x*W.der)
		return D
	end

	function *(U::Dual, x::Real)
		D = Dual(U.fun*x, U.der*x)
		return D
	end

	# División

	function /(U::Dual, W::Dual) 
		D = Dual(U.fun/W.fun, (U.der - (U.fun/W.fun)*W.der)/W.fun)					  
		return D
	end
	function /(U::Dual, x::Real) 
		D = Dual(U.fun/x, U.der/x)					  
		return D
	end
	function /(x::Real, W::Dual)   
		return Dual(x/W.fun, -(x*W.der)/W.fun^2)
	end
    
	#Potencia

	function ^(U::Dual, n::Real)
		D = Dual(U.fun^n, n*U.fun^(n-1)*U.der)
		return D
	end

	#Inversa 

	function inv(U::Dual)
		D = 1/U
		return D
   	end 

	######## FUNCIONES  ######## 

	# Raíz 

	function sqrt(U::Dual)
		D = U^0.5
		return D
	end 

	# Exponencial

	function exp(U::Dual)
		E = Dual(exp(U.fun), exp(U.fun)*U.der)
		return E
	end

	# Logaritmo

	function log(U::Dual)
		L = Dual(log(U.fun), U.der/U.fun)
		return L 
	end
	
	# Seno

	function sin(U::Dual)
		S = Dual(sin(U.fun), cos(U.fun)*U.der)
		return S
	end 

	# Coseno 

	function cos(U::Dual)
		C = Dual(cos(U.fun), -sin(U.fun)*U.der)
		return C
	end 

	# Tangente 

	function tan(U::Dual)
		T = Dual(tan(U.fun), U.der*sec(U.fun)^2)
		return T
	end

	# Sinh 

	function sinh(U::Dual)
		SH = Dual(sinh(U.fun), cosh(U.fun)*U.der)
		return SH
	end

	# Cosh

	function cosh(U::Dual)
		CH = Dual(cosh(U.fun), sinh(U.fun)*U.der)
		return CH
	end

	# Tanh

	function tanh(U::Dual)
		TH = Dual(tanh(U.fun), U.der/cosh(U.fun)^2)
		return TH
	end

	# Asinh 

	function asinh(U::Dual)
		ASH = Dual(asinh(U.fun),U.der/sqrt(U.fun^2 + 1))
		return ASH
	end 

	# Acosh 
	
	function acosh(U::Dual)
		ACH = Dual(acosh(U.fun), U.der/sqrt(U.fun^2 - 1))
		return ACH
	end

	# Atanh
	
	function atanh(U::Dual)
		ATH = Dual(atanh(U.fun), U.der/sqrt(1-U.fun^2))
		return ATH
	end

	# Acos

	function acos(U::Dual)
		AC = Dual(acos(U.fun), -U.der/sqrt(1-U.fun^2))
		return AC
	end

	# Asin 

	function asin(U::Dual)
		AS = Dual(asin(U.fun), U.der/sqrt(1-U.fun^2))
		return AS
	end

	# Atan 

	function atan(U::Dual)
		AT = Dual(atan(U.fun), U.der/(U.fun^2 + 1))
		return AT
	end
end 
