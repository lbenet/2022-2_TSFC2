
module SeriesTaylor

import Base: ==, ≈, +, -, *, /, ^, one, zero, inv, sqrt, exp, log, sin, cos, tan, asin, acos, atan
export Taylor, evaluar, coefs_taylor, paso_integracion

	"""
	Taylor.
	
	Estructura paramétrica (`struct`) que define el tipo `Taylor{T}`, 
    donde el parámetro es un subtipo de `Number`. Además, el tipo `Taylor`
    es a su vez subtipo de `Number`. El campo básico de esta estructura
    es un vector `coefs` del tipo `Vector{T}`.

	"""
	struct Taylor{T <: Number} <: Number
		coefs:: Vector{T}
	end	
	function Taylor(T::Type, orden::Int)   
		A = [zero(T), one(T)]
		B = zeros(T, orden-1)
		C = vcat(A,B)
		return Taylor(C)
	end 		
	function Taylor(orden::Int) 
		return Taylor(Float64, orden)	
	end 
	function one(T::Taylor)
		A = [1]
		B = zeros(typeof(T.coefs[1]),length(T.coefs)-1)
		C = vcat(A,B)
		return Taylor(C)
	end
	zero(T::Taylor) = Taylor(zero(T.coefs))

	function ≈(T1::Taylor, T2::Taylor) 
		return T1.coefs ≈ T2.coefs
	end

	#IGUALDAD ==

	function ==(f::Taylor, g::Taylor) 
		minimo = min(length(f.coefs), length(g.coefs))
		return f.coefs[1:minimo] == g.coefs[1:minimo]
	end 
	function ==(f::Taylor, a::Number)   
		A = [a]
		B = zeros(typeof(f.coefs[1]),length(f.coefs)-1)
		C = vcat(A,B)
		D = Taylor(C)
		return f.coefs == D.coefs
	end
	function ==(a::Number, f::Taylor)   
		A = [a]
		B = zeros(typeof(f.coefs[1]),length(f.coefs)-1)
		C = vcat(A,B)
		D = Taylor(C)
		return f.coefs == D.coefs
	end

	#SUMA 

	function +(a::Number, f::Taylor)
		L = length(f.coefs)
		B = Taylor(zeros(L))
	    B.coefs[1]=a
		C = B+f
		return C
	end
	function +(f::Taylor, g::Taylor)   
		A = length(f.coefs)
		B = length(g.coefs)  
		minimo = min(A,B)
		return Taylor(f.coefs[1:minimo]+g.coefs[1:minimo])
	end
	+(f::Taylor) = f
	+(f::Taylor, a::Number) = +(a::Number, f::Taylor)

	#RESTA 

	function -(f::Taylor, g::Taylor)   
		minimo = min(length(f.coefs), length(g.coefs))
		return Taylor(f.coefs[1:minimo]-g.coefs[1:minimo])
	end 
	function -(f::Taylor, a::Number) 
		L = length(f.coefs)
		A = [f.coefs[1] - a]
		B = zeros(L-1)
		C = vcat(A,B)
		return Taylor(C)
	end
	function -(a::Number, f::Taylor) 
		L = length(f.coefs)
		B = Taylor(zeros(L))
	    B.coefs[1]=a
		C = B-f
		return C
	end 
	function -(f::Taylor) 
		C = -f.coefs
		T2 = Taylor(C)
		return T2
	end 

	#MULTIPLICACIÓN 

	function *(f::Taylor, g::Taylor) 
		f₀ = f.coefs[1]
		l1 =  length(f.coefs)
		l2 =  length(g.coefs)
		minimo = min(l1,l2)
		P = zeros(typeof(f₀), minimo) 
		for k in 1:minimo
			suma = 0
			for i in 0:k-1
				suma = suma + f.coefs[i+1]*g.coefs[k-i]
			end
		 P[k] = suma 
		end
		return Taylor(P)
	end
	*(f::Taylor, a::Number) = Taylor(f.coefs .* a)  
	*(a::Number, f::Taylor) = Taylor(a .* f.coefs)  

	#DIVISIÓN 

	function /(f::Taylor, g::Taylor)
		g₀ = g.coefs[1]
		@assert g₀ ≠ 0
        f₀ = f.coefs[1]
		l1 =  length(f.coefs)
		l2 =  length(g.coefs)
		minimo = min(l1,l2)
		P = zeros(typeof(f₀), minimo)

		for k in 1:minimo 
			suma = 0
			for i in 1:k-1

				suma = suma + P[i]*g.coefs[k-i + 1]

			end                                                       
			P[k] = (f.coefs[k] - suma)*inv(g₀)
		end
		return Taylor(P)
	end
	function /(a::Number, g::Taylor)
		g₀ = g.coefs[1]
		@assert g₀ ≠ 0

		A = [a]
		B = zeros(typeof(g.coefs[1]),length(g.coefs)-1)
		C = vcat(A,B) 

		return Taylor(C)/g
	end
	function /(f::Taylor, a::Number)
		P = f.coefs ./ a
		return Taylor(P)
	end

	#INVERSA 

	function inv(f::Taylor)
		return 1/f 
	end

	# EXPONENCIAL 
				
	function exp(f::Taylor)
		L = length(f.coefs) 
		E₀ = exp(f.coefs[1])
		Eₖ = zeros(typeof(f.coefs[1]), L-1)
		E = vcat(E₀,Eₖ)
		for k in 2:L
			suma = zero(E₀)
			for j in 0:k-2
				suma = suma + (k-j-1)*f.coefs[k-j]*E[j+1] 
			end
			E[k] = suma*inv(k-1) 
		end
		return Taylor(E)
	end

	#LOGARITMO 

	function log(f::Taylor{<:Real})

		f₀ = f.coefs[1] 

		@assert f₀ > 0

		L = length(f.coefs) 
		l₀ = log(f₀)
		lₖ = zeros(typeof(f₀), L-1)
		l = vcat(l₀,lₖ)
		for k in 2:L
			suma = zero(l₀)
			for j in 0:k-2
				suma = suma + j*f.coefs[k-j]*l[j+1] 
			end
			l[k] = (f.coefs[k]-suma*inv(k-1))*inv(f₀) 
		end
		return Taylor(l)
	end

	function log(f::Taylor{<:ComplexF64})

		f₀ = f.coefs[1] 
		L = length(f.coefs) 
		l₀ = log(f₀)
		lₖ = zeros(typeof(f₀), L-1)
		l = vcat(l₀,lₖ)
		for k in 2:L
			suma = 0
			for j in 0:k-2
				suma = suma + j*f.coefs[k-j]*l[j+1] 
			end
			l[k] = (f.coefs[k]-suma*inv(k-1))*inv(f₀) 
		end
		return Taylor(l)
	end

	
	#COSENO 

	"""
	Coseno.
	Es aplicada a un objeto tipo `Taylor` tomando la parte real de la identidad: 
	eⁱˣ = cos(z) + isin(z)
	"""
	function cos(f::Taylor)
		E = exp(im*f)
		C = real.(E.coefs)		
		return Taylor(C)
	end 

	#SENO 
	
	"""
	Seno. 
	Es aplicada a un objeto tipo `Taylor` tomando la parte imaginaria de la identidad: 
	eⁱˣ = cos(z) + isin(z)
	"""
	function sin(f::Taylor)
		E = exp(im*f)
		S = imag.(E.coefs)		
		return Taylor(S)
	end 

	"""
	Tangente. 
	Es aplicada a un objeto tipo `Taylor` usando la formula: 
	tan(z) = sin(z)/cos(z)
	"""
	function tan(f::Taylor)
		T = sin(f)/cos(f)
		return T
	end

	"""
	Arcsin.
	Es aplicada a un objeto tipo `Taylor` usando la formula: 
	sin⁻¹(z) = -iln(iz-sqrt(1-z^2))
	"""
	function asin(f::Taylor)
		AS = -im*log(im*f+sqrt(1-f^2))
		return AS
	end
	"""
	Arccos.
	Es aplicada a un objeto tipo `Taylor` usando la formula:
	cos⁻¹(z) = 0.5*(π-2sin⁻¹(z))
	"""
	#function acos(f::Taylor)
		#AC = -im*log(f + sqrt((-1+0im)+f^2))
		#return AC
	#end
	function acos(f::Taylor)
		AC = 0.5*(pi-2*asin(f))
		return AC
	end
	"""
	Arctan.
	Es aplicada a un objeto tipo `Taylor` usando la formula: 
    tan⁻¹(z) = 0.5iln((1-iz)/(1+iz))
	"""
	function atan(f::Taylor)
		N = 1-im*f
		D = 1+im*f
		AT = 0.5*im*log(N/D)
		return AT
	end

	#POTENCIA 

	function ^(f::Taylor, α::Float64)
		L = length(f.coefs)
		f₀ = f.coefs[1] 
		if α == 2
			P₀ = f₀^2 
			Pₖ = zeros(typeof(f₀),L-1)
			P = vcat(P₀,Pₖ)
			for k in 2:L
				suma = zero(P₀)
				if isodd(k)
					for j in 0:(k-3)/2
						suma = suma + 2*f.coefs[j+1]*f.coefs[k-j]
					end 
					P[k] = suma + f.coefs[(k+1)/2]^2
				else 
					for j in 0:(k-2)/2
						suma = suma + 2*f.coefs[j+1]*f.coefs[k-j]
					end 
					P[k] = suma 
				end 
			end 
		elseif α == 1/2
			@assert f₀ > 0
			P₀ = f₀^(1/2)
			Pₖ = zeros(typeof(f₀),L-1)
			P = vcat(P₀,Pₖ)
			for k in 2:L
				suma = zero(P₀)
				if isodd(k)
					for j in 1:(k-2)/2
						suma = suma + 2*P[Int(j)+1]*P[k-Int(j)]
					end 
					P[k] = (f.coefs[k] - P[Int((k+1)/2)]^2 - suma)*inv(P[1])*0.5
				else 
					for j in 1:(k-1)/2
						suma = suma + 2*P[Int(j)+1]*P[k-Int(j)]
					end
					P[k] = (f.coefs[k] - suma)*inv(P[1])*inv(2)
				end 
			end 
		else 
			P₀ = f₀^α 
			Pₖ = zeros(typeof(f₀),L-1)
			P = vcat(P₀,Pₖ)
			for k in 2:L
				suma = zero(P₀)
				for j in 0:k-1
					suma = suma + (α*(k-j-1)-j)*f.coefs[k-j]*P[j+1]
				end 
				P[k] = inv(k-1)*inv(f₀)*suma
			end 
		end 
		return Taylor(P)
	end
	#RAIZ
	function sqrt(f::Taylor) 
		return f^(1/2)
	end 
	#-----------------------------------------------------#

	# TAREA 3

	"""
	evaluar. 

	Evalua objetos del tipo `Taylor` en un valor específico, usando el método de Horner.
	EL parámetro `fT::Taylor` es el desarrollo de Taylor de una función f(x)
	alrededor del punto x₀. Como resultado no da evaluación numérica de f(x₀+h).

	x(t₁)= x₀ + h(x₁ + h(... + h(xₚ₋₁ + hxₚ))...)

	"""
	function evaluar(fT::Taylor, h)
		P = length(fT.coefs)  
		xₚ₋₁ = fT.coefs[P-1]
		xₚ = fT.coefs[P]
		S₀ = xₚ₋₁ + h*xₚ
		S = S₀ 
		for k in P-2:-1:1 
			S = fT.coefs[k] + h*S
    	end
    	return S
	end
	function coefs_taylor(f, t::Taylor, u::Taylor, p)
		P = length(u.coefs)
		u₀ = u.coefs[1]
		t = t.coefs
		U = [u₀]
		for k in 1:P-1
			append!(U,f(Taylor(U), p, Taylor(t)).coefs[k]*inv(k))
		end 
		return Taylor(U)
	end 
	function paso_integracion(u::Taylor, ϵ)
		P  = length(u)
		uₚ = u.coefs[P]
		δt = (ϵ*abs(inv(uₚ)))^(inv(P-1))*inv(2)
		uₚ₋₁ = u.coefs[P-1]
		δt2 = (ϵ*abs(inv(uₚ₋₁))^(inv(P-1)))*inv(2)
		return min(δt,δt2)
	end 
end 