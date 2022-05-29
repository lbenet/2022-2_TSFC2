
# # Tarea 2
#
# Fecha **final** de aceptación del PR: 21 de abril
#
# ---

# El objetivo de esta tarea es implementar un módulo, que se llamará
# `SeriesTaylor`, que permitirá obtener la serie de Taylor de funciones
# que son el resultado de la composición de varias funciones elementales.
# de una variable. El módulo deberá incluirse en el
# archivo `series_taylor.jl` dentro de su carpeta de trabajo, y usándolo
# deberán pasar todos los tests que se encuentran en la carpeta
# `tareas/tests/series_taylor.jl`. Todas las funciones que se definan
# deberán estar adecuadamente documentadas.

# ## 1:
#
# - Implementen la estructura paramétrica (`struct`) que define
#    el tipo `Taylor{T}`, donde el parámetro debe ser un subtipo de `Number`,
#    es decir, lo podremos también usar con complejos. Además, el tipo `Taylor`
#    deberá ser a su vez subtipo de `Number`. El campo básico de esta estructura
#    será un vector `coefs` del tipo `Vector{T}`.
# - Definan constructores externos necesarios. En particular definan uno que
#    a partir de un valor entero (`Int)` defina a la *variable independiente*.

module SeriesTaylor
export Taylor

struct Taylor{T <: Number} <: Number
    coefs::Vector{T}
end

function Taylor(a::Type, orden)
   coef = zeros(a, orden+1)
   coef[2] = one(a)
    return Taylor(coef)
end

Taylor(a::Int64) = Taylor(Float64,a)

##EXTRAS

import Base.zero, Base.one, Base.≈

zero(a::Taylor)= Taylor(zeros(typeof(a.coefs[1]),length(a.coefs)))
≈(a::Taylor, b::Taylor)= a.coefs ≈ b.coefs
one(a::Taylor)=  Taylor(pushfirst!(zeros(length(a.coefs)-1),1))

#################
import Base.==

function ==(a::Taylor, b::Taylor)
   i = min(length(a.coefs),length(b.coefs))
return a.coefs[1:i] == b.coefs[1:i]
end

==(a::Taylor, b::Number)= a.coefs == Taylor(pushfirst!(zeros(length(a.coefs)-1),b)).coefs
==(a::Number, b::Taylor)= b.coefs == Taylor(pushfirst!(zeros(length(b.coefs)-1),a)).coefs
==(a::Taylor{ComplexF64}, b::Taylor{Union{Int64,Float64}})= b.coefs == Taylor([real(a.coefs)]).coefs
==(a::Taylor{Union{Int64,Float64}}, b::Taylor{ComplexF64})= a.coefs == Taylor([real(b.coefs)]).coefs

#########################

import Base.+, Base.-

+(a::Taylor, b::Taylor)= Taylor([a.coefs[i] + b.coefs[i] for i in 1:min(length(a.coefs),length(b.coefs))])
+(a::Taylor, b::Number)= a + Taylor(pushfirst!(zeros(length(a.coefs)-1),b)) 
+(a::Number, b::Taylor)= b + Taylor(pushfirst!(zeros(length(b.coefs)-1),a)) 

-(a::Taylor, b::Taylor)= Taylor([a.coefs[i] - b.coefs[i] for i in 1:min(length(a.coefs),length(b.coefs))])
-(a::Taylor, b::Number)= a - Taylor(pushfirst!(zeros(length(a.coefs)-1),b)) 
-(a::Number, b::Taylor)= b - Taylor(pushfirst!(zeros(length(b.coefs)-1),a)) 
-(a::Taylor)= Taylor(-a.coefs)

############################

import Base .*, Base ./, Base.inv

function *(a::Taylor, b::Taylor)
    i=min(length(a.coefs),length(b.coefs))
    type= promote_type(typeof(a.coefs[1]), typeof(b.coefs[1]))
    coefs= zeros(type, i)

      for k in 1:i
        sum= zero(type)
            for j in 1:k
                sum += a.coefs[j] * b.coefs[k-j+1]
            end
     coefs[k]= sum
      end
    return Taylor(coefs)
end

*(a::Taylor, b::Number)= Taylor(b * a.coefs)
*(a::Number, b::Taylor)= Taylor(a * b.coefs)
###############################

function /(a::Taylor, b::Taylor)
     @assert b.coefs[1] != 0 
    
    i=min(length(a.coefs),length(b.coefs))
    type= promote_type(typeof(a.coefs[1]), typeof(b.coefs[1]))
    coefs= zeros(type, i)

      for k in 1:i
        sum=zero(type)
            for j in 1:k-1
                sum += coefs[j] * b.coefs[k-j+1]
            end
        coefs[k]= 1/b.coefs[1] * (a.coefs[k] - sum)
      end
    return Taylor(coefs)
end


function /(a::Taylor, b::Number)
 @assert b != 0  
 Taylor(a.coefs / b)
end

function /(a::Number, b::Taylor)
  @assert b.coefs[1] != 0
  Taylor(pushfirst!(zeros(length(b.coefs)-1),a)) /b
end

inv(a::Taylor)= 1/a

############################
function cuadrado(a::Taylor)
    i= length(a.coefs) 
    type= typeof(a.coefs[1]^2)
    coefs= zeros(type, i)
    coefs[1]= a.coefs[1]^2

    if a.coefs[1]==0
        coefs= a
    return Taylor(coefs*coefs)

    else
         for k in 2:i
            sum=zero(type)
            if iseven(k)
                for j in 0:(k-2)/2
                    sum += (a.coefs[Int(j+1)] * a.coefs[Int(k-j)])
                end
                coefs[Int(k)]= 2*sum 
    
            else 
                 for j in 0:(k-3)/2
                    sum += (a.coefs[Int(j+1)] * a.coefs[Int(k-j)])
                end
                coefs[Int(k)]= (a.coefs[Int((k+1)/2)])^2 + 2*sum
            end
        end
    return Taylor(coefs) 

    end

end

function potencia(a::Taylor,b::Union{Float64,Int64})
    i= length(a.coefs)
    type= typeof((a.coefs[1])^b)
    coefs= zeros(type, i) 
    coefs[1]= (a.coefs[1])^b

         for k in 2:i
         sum= zero(type)
             for j in 0:k-1
                 sum += (b*(k-j-1)-j)*a.coefs[Int(k-j)]*coefs[Int(j+1)]
             end
            coefs[Int(k)]= sum / ((k-1)*a.coefs[1]) 
        end
    return Taylor(coefs)
end
###########################

import Base.sqrt

function sqrt(a::Taylor)
    @assert a.coefs[1] != 0
        i= length(a.coefs)
        type= typeof(sqrt(a.coefs[1]))
        coefs= zeros(type, i) 
        coefs[1]= sqrt(a.coefs[1])
    
                for k in 2:i
                    sum=0
                    if iseven(k)
                             for j in 1:(k-1)/2
                             sum += coefs[Int(j+1)] * coefs[Int(k-j)]
                             end
                    coefs[Int(k)]= (1/(2*coefs[1])) * (a.coefs[Int(k)] - 2*sum)
          
                     else 
                              for j in 1:(k-2)/2
                              sum += coefs[Int(j+1)] * coefs[Int(k-j)]
                              end
                     coefs[Int(k)]= (1/(2 * coefs[1])) * (a.coefs[Int(k)] - (coefs[Int((k+1)/2)])^2 - 2*sum)
                    end
                 end
            return Taylor(coefs)
end

#####################

import Base .^

function ^(a::Taylor, b::T where {T<:AbstractFloat})
    if b== 0.0
        return one(a)

    elseif b== 2.0
            return cuadrado(a)

    elseif  b== 1.0
        return a

    elseif  b== 1/2 
        return sqrt(a)
            
    else
            coefs= a
               for j in 2:b
                   coefs= coefs*a
               end
           return Taylor(coefs)
    
    end  

    if b<1/2
        return potencia(a,b)
    end
end


function ^(a::Taylor, n::Int64)
    return a^Float64(n)
end

##########################

import Base.exp, Base.log

function exp(a::Taylor)
    i= length(a.coefs)
    type= typeof(exp(a.coefs[1]))
    coefs= zeros(type, i) 
    coefs[1]= exp(a.coefs[1])

        for k in 2:i
            sum= zero(type)
                for j in 1:k-1
                sum += (k-j)*a.coefs[k-j+1]*coefs[j]
                end
            coefs[k]= 1/(k-1) * sum
        end
    return Taylor(coefs)
end

function log(a::Taylor)
    if a.coefs[1] < 0
    i= length(a.coefs)
    type= typeof(log(Complex(a.coefs[1])))
    coefs= zeros(type, i) 
    coefs[1]= log(Complex(a.coefs[1]))

         for k in 2:i
             sum= zero(type)
                 for j in 1:k-1
                 sum += (j-1)*a.coefs[k-j+1]*coefs[j]
                 end
            coefs[k]= (a.coefs[k] - 1/(k-1)*sum)/a.coefs[1]
         end
     return Taylor(coefs)

        else
            i= length(a.coefs)
            type= typeof(log(a.coefs[1]))
            coefs= zeros(type, i) 
            coefs[1]= log(a.coefs[1])
             @assert a.coefs[1] != 0
        
                 for k in 2:i
                     sum= zero(type)
                         for j in 1:k-1
                         sum += (j-1)*a.coefs[k-j+1]*coefs[j]
                         end
                    coefs[k]= (a.coefs[k] - 1/(k-1)*sum)/a.coefs[1]
                 end
             return Taylor(coefs)
    end
end




import Base.sin, Base.cos, Base.tan

function sin_and_cos(a::Taylor)

    i= length(a.coefs)
    type1= typeof(sin(a.coefs[1]))
    type2= typeof(cos(a.coefs[1]))

    S= zeros(type1,i)
    S[1]= sin(a.coefs[1])

    C= zeros(type2,i)
    C[1]= cos(a.coefs[1])

        for k in 2:i
            sum_seno= 0; sum_coseno=0
                for j in 0:k-1
                sum_seno += (k-j-1)*a.coefs[k-j] * C[j+1]
                sum_coseno += (k-j-1)*a.coefs[k-j] * S[j+1]
                end
            S[k]= 1/(k-1) * sum_seno;
            C[k]= -1/(k-1) * sum_coseno
        end
    return S,C
end


function sin(a::Taylor)
   return Taylor(sin_and_cos(a)[1])
end

function cos(a::Taylor)
    return Taylor(sin_and_cos(a)[2])
 end

function tan(a::Taylor)
    i= length(a.coefs)
    type= typeof(tan(a.coefs[1]))
    coefs= zeros(type,i)
    coefs[1]= tan(a.coefs[1])
  
        for k in 2:i
            P= Taylor(coefs)^2
            sum= zero(type)
                for j in 0:k-1
                sum += (k-j-1)*a.coefs[k-j]*(P.coefs[j+1])
                end
            coefs[k]= a.coefs[k] + sum/(k-1)
        end
    return Taylor(coefs)
end




import Base.asin, Base.acos, Base.atan

function asin(a::Taylor)
    i= length(a.coefs)
    type= typeof(asin(a.coefs[1]))
    coefs= zeros(type,i)
    coefs[1]= asin(a.coefs[1])
        for k in 2:i
        R= sqrt(1-a^2)
        sum= zero(type)
            for j in 1:k-1
            sum += j*R.coefs[k-j]*coefs[j+1]
            end
        coefs[k]= (a.coefs[k]- sum/(k-1))/sqrt(1-(a.coefs[1])^2)
        end
    return Taylor(coefs)
end

function atan(a::Taylor)
    i= length(a.coefs)
    type= typeof(atan(a.coefs[1]))
    coefs= zeros(type,i)
    coefs[1]= atan(a.coefs[1])
        for k in 2:i
        R= (1+a^2)
        sum= zero(type)
            for j in 1:k-1
            sum += j*R.coefs[k-j]*coefs[j+1]
            end
        coefs[k]= (a.coefs[k]- sum/(k-1))/(1+(a.coefs[1])^2)
        end
    return Taylor(coefs)
end

end


#-