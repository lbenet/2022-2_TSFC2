# # Metaprogramming

# ## Expresiones

#-
# Julia, igual que Lisp, representa al código (por ejemplo, en el REPL)
# como una estructura de datos en el *propio lenguaje*. Entonces, es posible
# escribir y modificar código de manera programática. La posibilidad de escribir
# código que genere y modifique código es lo que se entiende por "Metaprogramming".
#
# Aquí ilustraremos algunos conceptos, siguiendo el
# [manual](https://docs.julialang.org/en/v1/manual/metaprogramming), dejando varios temas
# sin cubrir.

#-
# Cualquier línea de código inicialmente es una cadena:
prog = "1 + 1"

# El siguiente paso es convertir la cadena en una expresión:
ex1 = Meta.parse(prog)

#-
typeof(ex1)

#-
propertynames(ex1)

#-
# Claramente, un objeto tipo Expr tiene dos campos:
# - `head`: usando un `Symbol`, define el tipo de expresión. En este caso se trata de un `:call`
ex1.head

#-
# - `args`: usando un `Vector{Any}`, contiene los argumentos de la expresión
ex1.args

# Las expresiones también pueden ser escritas directamente a partir del constructor de
# un objeto tipo `Expr`:
ex2 = Expr(:call, :+, 1, 1)

#-
ex1 == ex2

# El punto importante es que el código en Julia está representado internamente por
# expresiones escritas en Julia y que son accesibles desde Julia.

#-
# La función `dump()`` da información anotada de la expresión:
dump(ex1)

# Expresiones más complejas se construyen de forma similar:
ex3 = Meta.parse("(4 + sin(1.0)) / 2")

# Otra manera de visualizar a la expresión es con `Meta.show_sexpr`
Meta.show_sexpr(ex3)

# Uno de los usos de `:` es crear símbolos, o también se puede usar `Symbol()`
:foo == Symbol("foo")

# `Symbol` permite concatenar distintas partes, que esencialmente se toman como
# cadenas
Symbol(:var,'_',"sym",3)

# Otro uso de `:` es crear expresiones sin usar el constructor `Expr`, en lo que
# se llama *citar* (en inglés, *quoting*)
ex4 = :(a+b*c+1)

#-
dump(ex4)

#-
# No sólo es el hecho de que podamos escribir programáticamente las expresiones, sino que
# también podemos modificarlas. Como ejemplo, tomaremos `ex4`, y la transformaremos
# de ser `:(a + b * c + 1)` a ser `:(a + b * c + 2.1)`. Esto, simplemente lo
# conseguimos cambiando el cuarto elemento del vector `ex4.args`:
ex4.args[4] = 2.1

#-
ex4

# Otra manera de construir expresiones más complejas es usando el bloque `quote ... end`
ex = quote
    x = 1
    y = 2
    x + y
end

# Para evaluar una expresión, es decir, considerar a la cadena de texto y *correrla*, se
# utiliza la función `eval`. En la expresión anterior, las variables `x` y `y` no han
# sido evaluadas, y por eso se obtienen `UndefVarError`.
x

#-
eval(ex)

#-
x, y

# Las expresiones pueden involucrar variables cuyo valor ha sido asignado; evaluar dichas
# expresiones utiliza el valor de estas variables:
z = 4
eval( :(2*x + z) )

# Incluso, uno puede *sustituir* el valor de esas variables, usando `$`, de la misma
# manera que uno *interpola* valores en cadenas
dump( :(2*x + $z) )

# ## Generación de código

#-
# Un ejemplo un poco más interesante, es el implementar la evaluación de los polinomios
# de Wilkinson:
# ```math
# W_n(x) = \Prod_{i=1}^{n} (x-i) = (x-1)(x-2)\dots(x-n).
# ```

nombre(n::Int) = Symbol( string("W_", n) )

#-
nombre(3)

#-
# La siguiente función regresa la expresión que corresponde al polinomio de Wilkinson
# $W_n(x)$.
function wilkinson(n::Int)
    # Imponemos que que `n` sea ≥ 1
    @assert n ≥ 1 "`n` tiene que ser mayor o igual a 1"

    ex = :(x-1)
    for i = 2:n
        ex = :( ($ex) * ( x-$i) )
    end
    ex_ret = :( $(nombre(n))(x) = $ex )
    return ex_ret
end

#-
wilkinson(0) # Da un AssertionError !

#-
w3 = wilkinson(3)
eval(w3)
#-
W_3(2.1)

# Uno puede *automatizar la generación de código. Tomando el ejemplo de los
# polinomios de Wilkinson podemos, dentro de un ciclo `for`, generar varios
# de éstos.

for i = 1:10
    ex = wilkinson(i) # genera el polinomio de orden `i`
    println(ex)
    @eval $ex
end

#-
W_8(1.0)

# Esta forma de generar código permite tener código más conciso y sencillo de
# mantener, aunque debe ser utilizado con cuidado.

# ## Macros

# En ocasiones hemos usado instrucciones que incluyen `@` antes de la *expresión*,
# un ejemplo es `@assert`. Éstos son macros: Los macros son funciones cuyas
# entradas son expresiones, que son manipuladas y al final se evalúan.

macro simple_example(expr)
    @show expr   # this is another macro !
    return 0     # for simplicity
end

#-
@simple_example(x+y)

#-
# Cambiemos un poco el macro `@simple_example`
macro simple_example(expr)
    @show expr   # this is another macro !
    return expr     # for simplicity
end

#-
x, y

#-
@simple_example x + y

#-
@simple_example x1 + y1

#-
# El macro `@macroexpand` permite ver lo que hace el macro:

@macroexpand @simple_example x1 + y1

#-
# Una sutileza importante de los macros es que, a diferencia de las funciones,
# los macros permiten introducir y modificar código *antes* de que sea
# ejecutado, dado que los macros son ejecutados cuando el código se traduce
# en expresiones (*parse time*).
#
# El siguiente ejemplo, tomado del manual, ilustra esto:

macro twostep(arg)
    println("I execute at parse time. The argument is: ", arg)

    return :(println("I execute at runtime. The argument is: ", $arg))
end

#-
exx = macroexpand(Main, :(@twostep :(1, 2, 3)) );

# El primer uso de `println` ocurre cuando `macroexpand` es utilizado; la expresión resultante
# incluye el segundo `println` únicamente.
exx

#-
eval(exx)

# Más información sobre los macros puede ser encontrada
# [aquí](https://docs.julialang.org/en/v1/manual/metaprogramming), e incluye ejemplos
# de [generación de código](https://docs.julialang.org/en/v1/manual/metaprogramming/#Code-Generation) que
# son útiles, [cadenas literales no estándar](https://docs.julialang.org/en/v1/manual/metaprogramming/#meta-non-standard-string-literals)
# o [funciones generadoras](https://docs.julialang.org/en/v1/manual/metaprogramming/#Generated-functions).
# La lectura de este capítulo del manual es altamente recomendada.
