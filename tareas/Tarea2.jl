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

#-
# ## 2:
#
# Extiendan los métodos para que las operaciones aritméticas básicas.
#    (`+`, `-`, `*`, `/`) y la igualdad (`==`) puedan ser usadas tanto con valores
#    numéricos como con objetos del tipo `Taylor`.

#-

# ## 3:
#
# Para  las funciones elementales que están [en la tabla vista en clase](../clases/05-SeriesTaylor.jl),
# implementen los métodos adecuados para esas funciones puedan usarse
# con objetos del tipo `Taylor`.
#

#-
