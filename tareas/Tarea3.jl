# # Tarea 3
#
# Fecha **final** de aceptación del PR: 23 de mayo
#
# ---

# El objetivo de esta tarea es implementar la integración de EDOs usando el
# método de Taylor, basándonos en el módulo `SeriesTaylor` que hicieron en la
# Tarea 2. Todas las funciones y cambios deben estar, o ser llamados, desde
# el archivo `series_taylor.jl` en el que está el código para `SeriesTaylor`,
# es decir, deben ser parte de ese módulo.
# Su implementación deberá pasar los tests `tests/integ_taylor.jl`.

# El integrador debe hacer las operaciones necesarias para obtener automáticamente
# los coeficientes $x_{[k]}$, *en cada paso de integración*, a partir de la condición
# inicial "local", o sea, al tiempo de interés.

#-
# ## 1:
#
# Implementen la función `evaluar` que servirá para evaluar polinomios de Taylor,
# es decir, objetos del tipo `Taylor` en un valor específico, usando el método de Horner.
# Entonces, si representamos el desarrollo de Taylor de una función ``f(x)``
# alrededor del punto ``x_0`` como `fT::Taylor`, entonces,
# `evaluar(fT, h)` corresponde a la evaluación numérica de ``f(x_0+h)``. Esta función
# debe ser exportada por el módulo.

#-
# ## 2:
# En este ejercicio implementarán funciones que calculen los coeficientes de Taylor de
# la o las variables dependientes en términos de la variable independiente.
# - Caso escalar: Implementen la función `coefs_taylor(f, t, u, p)` que calculará los
# coeficientes ``x_{[k]}`` de la expansión de Taylor para la variable dependiente
# en términos de la independiente, regresando el desarrollo de Taylor, es decir,
# un objeto tipo `Taylor`. Los argumentos de esta función son la función `f` que define
# a la ecuación diferencial (con la convención de que los argumentos de `f` en el
# *caso escalar* son `f(x, p, t)`), la variable independiente `t::Taylor`, la variable
# dependiente `u::Taylor` y donde `p` representa cualquier parámetros necesarios que
# se necesite en la función `f`.
# - Caso vectorial: Implementen la función `coefs_taylor!(f, t, u, du, p)`, que usaremos
# cuando tenemos un *sistema* de ecuaciones diferenciales. Los argumentos son la función
# `f` que define las ecuaciones diferenciales, la variable independiente `t::Taylor`,
# el vector (de objetos `Taylor`) con las variables dependientes `u`, el vector (de objetos `Taylor`)
# con el lado izquierdo de las ecuaciones diferenciales `du`, y
# finalmente los parámetros necesarios representados por `p`.
# La función `f`, en el caso vectorial, usará para su definición la convención `f(du,u,p,t)`,
# y debe estar definida de tal manera que `du` (a la salida) tenga el lado izquierdo de
# las ecuaciones diferenciales, es decir, la `du` de entrada será modificada de manera apropiada
# a la salida. La función `coefs_taylor!` debe estar implementada de tal
# manera que `u` y `du` *cambien* (se actualizen) de manera adecuada, es decir, esta función
# cambiará a sus argumentos.

#-
# ## 3:
# Implementen la función `paso_integracion` con *dos métodos* (dependiendo si
# estamos con una ecuación diferencial escalar o vectorial), donde se obtenga el paso
# de integración $h$ a partir de los *dos últimos coeficientes* $x_{[k]}$ del desarrollo de
# Taylor para las variables independientes, multiplicado por 0.5.
# (Para el caso vectorial, el paso de integración
# será el menor de los pasos de integración asociados a cada variable dependiente.)
# Esta función dependerá de la serie de Taylor para la variable variable dependiente `u`
# (o del vector correspondiente), y de la tolerancia absoluta `epsilon`.

#-
# ## 4:
# Combinen las funciones anteriores en dos funciones, `paso_taylor` para el caso escalar y
# `paso_integracion!` para el vectorial, que combine las funciones implementadas en los
# ejercicios 2 y 3 adecuadamente. Estas funciones dependerán de `f`, `t`, `u`,
# `du` para el caso vectorial, la tolerancia absoluta ϵ, y los parámetros `p`. La función
# devolverá `u` y el paso de integración `h` en el caso escalar, y en el caso vectorial
# únicamente `h`, ya que el código debe ser escrito de tal manera que `u` y `du` deben
# ser *apropiadamente* actualizados (dado que son vectores, y los vectores son mutables).

#-
# ## 5:
# Escriban una función `integracion_taylor` (con dos métodos al menos) donde,
# a partir de las condiciones iniciales `x0` se implementen todos los pasos necesarios
# para integrar desde `t_ini` hasta `t_fin` las ecuaciones diferenciales definidas por `f`.
# Los argumentos de esta función serán la función `f`, la condición inicial `x0` (escalar o
# vectorial), `t_ini`, `t_fin`, el orden para los desarrollos de Taylor, la tolerancia
# absoluta ϵ, y los parámetros `p` necesarios para definir las ecuaciones diferenciales.
# La función deberá devolver un vector con los tiempos calculados a cada paso de integración,
# y un vector con la variable dependiente obtenida de la integración; noten que si estamos en
# el caso vectorial, la salida que corresponde a los valores obtenidos de la variable dependiente
# será un vector de vectores. Esta función debe ser exportada por el módulo.
#
# Un punto importante a notar es que el integrador debe evitar situaciones donde se tenga ciclos
# infinitos, en particular, en el número de pasos de integración. Esto puede ocurrir
# dado que el paso de integración es demasiado pequeño (y el tiempo final no se alcanza).
# La manera de evitar esto puede ser imponiendo un número máximo de iteraciones (que el
# usuario puede cambiar), o poniendo una cota ínfima para el paso de integración. La implementación
# concreta se las deja a su criterio, pero los valores de default deben permitir que
# el integrador pase los tests.

#-
