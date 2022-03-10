# # Tarea 1
#
# Fecha **final** de aceptación del PR: 21 de marzo
#
# ---

# El objetivo de esta tarea es implementar un módulo, que se llamará
# `DifAutom`, que permita usar
# duales para poder llevar a cabo diferenciación automática
# en funciones de una variable. El módulo deberá incluirse en el
# archivo `duales.jl` dentro de su carpeta de trabajo, y usándolo
# deberán pasar todos los tests que se encuentran en la carpeta
# `tareas/tests/difautom.jl`. Todas las funciones que se definan
# deberán estar adecuadamente documentadas.

#-
# ## 1:
#
# - Implementen una estructura paramétrica inmutable (`struct`) que
# se llamará `Dual` y que definirá los duales. La estructura deberá
# ser paramétrica, y el parámetro deberá ser subtipo de `Real`. La
# parte que identifica a $f_0$ será llamada `fun`, y la correspondiente
# a $f'_0$ será `der`; ambas deberán ser del tipo `T`. Implementen
# las funciones `fun` y `der` que, aplicadas a un `Dual` devuelven
# la parte de la función $f_0$ o la de su derivada $f'_0$, respectivamente.
#
# - Definan métodos especiales que permitan la promoción si se utilizan
# tipos distintos, o para que `Dual(::Int, ::Int)` de como resultado un
# `Dual{Float64}`. Además, deben incluir métodos que
# den el resultado esperado al usarse en constantes (numéricas):
# para una constante numérica $c$, `Dual(c)` deberá
# devolver el `Dual` que corresponda a $(c,0)$.
#
# - Para definir la variable independiente de los duales, usaremos
# la función `dual` cuyo resultado corresponderá al $(x_0, 1)$.

#-

# ## 2:
#
# - Implementen la comparación (equivalencia) entre duales, es decir,
# sobrecarguen `==`.
#
# - Implementen las operaciones aritméticas `+`, `-`, `*`, `/` y `^`
# siguiendo las [notas de clase](../clases/04-DifAutom.jl).
# Estas operaciones deben incluir las operaciones aritméticas que
# involucran un número cualquiera (`a :: Real`) y un `Dual`` (`b::Dual`),
# o dos duales.

#-

# ## 3:
#
# - Extiendan el uso de `Dual` a las funciones elementales: `sqrt`,
# `exp`, `log`, `sin`, `cos`, `tan`, `asin`, `acos`, `atan`,
# `sinh`, `cosh`, `tanh`, `asinh`, `acosh`, `atanh`.
#
