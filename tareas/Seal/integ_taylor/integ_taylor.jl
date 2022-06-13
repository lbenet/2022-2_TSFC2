include("series_taylor.jl")

function evaluar(fT::Taylor,h)
    i= length(fT.coefs)
    x_p = fT.coefs[i]
    x_q= fT.coefs[i-1]
    sum_p= x_q + h*x_p                                                                    
    sum= sum_p
    for k in i-2:-1:1
        sum= fT.coefs[k] + h*sum
    end
   return sum
end

#function evaluar2(fT::Taylor,h)
#    i= length(fT.coefs)
#    sumandos=[]
#        for k in 0:i-1
#            s= fT.coefs[k+1] * h^(k)
#            sumandos= push!(sumandos,s)
#        end
#    return sum(sumandos)
#end

function coefs_taylor(f, t::Taylor, u::Taylor, p)
    i= length(u.coefs)
    T= t.coefs
    U= u.coefs
    x_k= [U[1]]

    for k in 1:i-1
        Us= Taylor(x_k[k])
        Ts= Taylor(T[k])
            f_k= f(Us, p, Ts) / k
                x_k= push!(x_k,f_k)
    end
    return Taylor(x_k)
end

function paso_integracion(u::Taylor, ϵ)
    i= length(u.coefs)
    x_k= u.coefs

    h_t= (ϵ/(abs(x_k[i])))^(1/i)
    h_s= (ϵ/(abs(x_k[i-1])))^(1/(i-1))
    
    return min(h_t, h_s)
end

function paso_taylor(f, t::Taylor, u::Taylor, p, ϵ)
     x_k= coefs_taylor(f,t,u,p)
     h_k= paso_integracion(u,ϵ)

     return x_k, h_k
end

function integracion_taylor(f, x0, t_i, t_f, n, ϵ, p)
    x_k= [x0]
    h_k= [t_i]

while h_k[end] < t_f
    u= Taylor(n) + x_k[end]
    t= Taylor(n) + h_k[end]

    u, Δt = paso_taylor(f, t, u, p, ϵ) 
    t_k= h_k[end] + Δt

        if t_f < t_k
           h= tf-h_k[end]
           x_ks= evaluar(u,h)
           push!(x_k, x_ks)
           push!(h_k,t_k)  
        
        elseif  Δt >= 1.0e-15
            h= Δt
            x_ks= evaluar(u,h)
             push!(x_k, x_ks)
             push!(h_k,t_k) 
 
        end
    end

    return x_k, h_k

end


 
