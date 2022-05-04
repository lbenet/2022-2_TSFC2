
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

struct Taylor{T <: Number} <: Number
    coefs::Vector{T}
end
#
function Taylor(a::Type, orden)
    coef = zeros(a,orden)
    coefs = insert!(coef, 2, 1)
     return Taylor(coefs)
 end
 
 Taylor(a=Int64) = Taylor(Float64,a)
#-
# ## 2:
#
# Extiendan los métodos para que las operaciones aritméticas básicas.
#    (`+`, `-`, `*`, `/`) y la igualdad (`==`) puedan ser usadas tanto con valores
#    numéricos como con objetos del tipo `Taylor`.

#-
import Base.==

function ==(a::Taylor, b::Taylor)
    if length(a.coefs)==length(b.coefs)
        return a.coefs == b.coefs
    else
        return a.coefs == (a.coefs ∩ b.coefs) || b.coefs == (a.coefs ∩ b.coefs)
    end
end

==(a::Taylor, b::Number)= a.coefs == Taylor(pushfirst!(zeros(length(a.coefs)-1),b)).coefs
==(a::Number, b::Taylor)= b.coefs == Taylor(pushfirst!(zeros(length(b.coefs)-1),a)).coefs
#
#
import Base.+, Base.-

+(a::Taylor, b::Taylor)= Taylor([a.coefs[i] + b.coefs[i] for i in 1:min(length(a.coefs),length(b.coefs))])
+(a::Taylor, b::Number)= a + Taylor(pushfirst!(zeros(length(a.coefs)-1),b)) 
+(a::Number, b::Taylor)= b + Taylor(pushfirst!(zeros(length(b.coefs)-1),a)) 

-(a::Taylor, b::Taylor)= Taylor([a.coefs[i] - b.coefs[i] for i in 1:min(length(a.coefs),length(b.coefs))])
-(a::Taylor, b::Number)= a - Taylor(pushfirst!(zeros(length(a.coefs)-1),b)) 
-(a::Number, b::Taylor)= b - Taylor(pushfirst!(zeros(length(b.coefs)-1),a)) 
-(a::Taylor)= Taylor(-a.coefs)
#
#
import Base .*, Base ./, Base.inv

function *(a::Taylor, b::Taylor)
    i=min(length(a.coefs),length(b.coefs))
    type= promote(typeof(a.coefs[1]), typeof(b.coefs[1]))[1]
    coefs=type[]
      for k in 1:i
        sum=0
            for j in 1:k
                sum += a.coefs[j] * b.coefs[k-j+1]
            end
     coefs=push!(coefs,sum)
      end
    return Taylor(coefs)
end

*(a::Taylor, b::Number)= Taylor(b * a.coefs)
*(a::Number, b::Taylor)= Taylor(a * b.coefs)

function /(a::Taylor, b::Taylor)
     @assert b.coefs[1] != 0 
    
    i=min(length(a.coefs),length(b.coefs))
    type= promote(typeof(a.coefs[1]), typeof(b.coefs[1]))[1]
    coefs=type[]
      for k in 1:i
        sum=0
            for j in 1:k-1
                sum += coefs[j] * b.coefs[k-j+1]
            end
        ks= 1/b.coefs[1] * (a.coefs[k] - sum)
     coefs=push!(coefs,ks)
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
#
#
import Base .^

function ^(a::Taylor, b::Float64)

     if b==2
    i= length(a.coefs)
    #type= typeof(a.coefs[1])
    coefs= Float64[a.coefs[1]^2]   ## coefs[1]= a.coefs^2

            for k in 2:i
               sum=0
               if mod(k,2)==0
                    for j in 0:(k-2)/2
                    sum += (a.coefs[j+1] * a.coefs[k-j])
                    end
                ks= (a.coefs[k/2])^2 + 2*sum
                coefs=push!(coefs,ks)

                else 
                    for j in 0:(k-3)/2
                    sum += 2*(a.coefs[j+1] * a.coefs[k-j])
                    end
                coefs=push!(coefs,sum)
              end
           end
        return Taylor(coefs)

    elseif b==1/2
    #@assert a.coefs[1] > 0
    i= length(a.coefs)
    #type= typeof(a.coefs[1])
    coefs= Float64[sqrt(a.coefs[1])]   ## coefs[1]= a.coefs^2
            for k in 2:i
                sum=0
                if mod(k,2)==0
                         for j in 0:(k-2)/2
                         sum += coefs[Int(j+1)] * coefs[Int(k-j-1)]
                         end
                     ks= 1/(2 * coefs[1])*(a.coefs[Int(k)] - (coefs[Int(k/2)])^2 - 2*sum)
                     coefs=push!(coefs,ks)
      
                 else 
                          for j in 0:(k-1)/2
                          sum += coefs[Int(j+1)] * coefs[Int(k-j-1)]
                          end
                      ks= 1/(2*coefs[1]) * (a.coefs[Int(k)] - 2*sum)
                      coefs=push!(coefs,ks)
                end
             end
        return Taylor(coefs)

    else
    i= length(a.coefs)
    #type= typeof(a.coefs[1])
    coefs= Float64[a.coefs[1]^b]   ## coefs[1]= a.coefs^b    

        for k in 2:i
            sum= 0
                for j in 1:k-1
                    sum += (b*(k-j-1)-(j-1))*a.coefs[k-j]*coefs[j]
                end
            ks= 1/((k-1) * a.coefs[1]) * sum
            coefs= push!(coefs,ks)
        end
    return Taylor(coefs)

    end
end
#
#
import Base.sqrt
function sqrt(a::Taylor)
    return a^(1/2)
end
# ## 3:
#
# Para  las funciones elementales que están [en la tabla vista en clase](../clases/05-SeriesTaylor.jl),
# implementen los métodos adecuados para esas funciones puedan usarse
# con objetos del tipo `Taylor`.
#
import Base.exp, Base.log, Base .≈, Base.one

function exp(a::Taylor)
    i= length(a.coefs)
   #type= typeof(a.coefs[2])
    coefs= Float64[exp(a.coefs[1])]
        for k in 2:i
            sum=0
                for j in 1:k-1
                sum += (k-j)*a.coefs[k-j+1]*coefs[j]
                end
             ks= 1/(k-1) * sum
            coefs=push!(coefs,ks)
        end
    return Taylor(coefs)
end

function log(a::Taylor{<:ComplexF64})
    i= length(a.coefs)
    #type= typeof(a.coefs[2])
     coefs= Float64[log(a.coefs[1])]
     @assert a.coefs[1] > 0
         for k in 2:i
             sum=0
                 for j in 1:k-1
                 sum += (j-1)*a.coefs[k-j+1]*coefs[j]
                 end
              ks= (a.coefs[k] - 1/(k-1)*sum)/a.coefs[1]
             coefs=push!(coefs,ks)
         end
     return Taylor(coefs)
    end
    
    ≈(a::Taylor, b::Taylor)= a.coefs ≈ b.coefs
    one(a::Taylor)=  Taylor(pushfirst!(zeros(length(a.coefs)-1),1))

#
#
import Base.sin, Base.cos, Base.tan

function sin(a::Taylor)
    i= length(a.coefs)
    coefs= Float64[sin(a.coefs[1])]
        for k in 2:i
            sum=0
                for j in 1:k-1
                sum += (k-j)*a.coefs[k-j]*coefs[j]
                end
             ks= 1/(k-1) * sum
            coefs=push!(coefs,ks)
        end
    return Taylor(coefs)
end


function cos(a::Taylor)
    i= length(a.coefs)
    coefs= Float64[cos(a.coefs[1])]
    for k in 2:i
        sum=0
            for j in 1:k-1
            sum += (k-j)*a.coefs[k-j]*coefs[j]
            end
         ks= -1/(k-1) * sum
        coefs=push!(coefs,ks)
    end
return Taylor(coefs)
end

function tan(a::Taylor)
    i= length(a.coefs)
    coefs= Float64[tan(a.coefs[1])]
        for k in 2:i
            sum=0
                for j in 1:k-1
                sum += (k-j-1)*a.coefs[k-j+1]*coefs[j]
                end
             ks= a.coefs[k-1] + 1/(k-1) * sum
            coefs=push!(coefs,ks)
        end
    return Taylor(coefs)
end


#-