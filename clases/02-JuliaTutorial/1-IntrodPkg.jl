# # Manejo de Paquetes (Pkg) y `Literate.jl`

# > NOTA:
# > En lo siguiente supondremos que se encuentran en el directorio raíz del curso
# > esto es en `2022-2_TSFC2` y que hicieron la clonación usual a partir
# > del [repositorio del curso](https://github.com/lbenet/2022-2_TSFC2).
# >
# > Si fuera necesario cambiarse a ese directorio, una posibilidad es hacerlo explotando
# > las herramientas del sistema operativo; otra, desde Julia, es usar el comando `pwd()` que indica
# > el lugar (directorio de trabajo) en el que nos encontramos, y usar `cd("<directorio>")`
# > para cambiarnos al directorio `<directorio>`, relativo al que estamos, y donde se encuentra
# > la carpeta principal del curso; las comillas dobles `"` son importantes al usar `cd()`.

# Julia tiene un poderoso manejador de paquetes, [`Pkg`](https://docs.julialang.org/en/v1/stdlib/Pkg/),
# que está concebido para permitir
# la reproducibilidad del código, entre otras propiedades. Hay varias paqueterías que
# están incluidas en Julia, pero separadas del lenguaje que se carga por default, y éstas
# constituyen lo que se llama la librería estándard (*standard library*). Se trata entonces de
# paqueterías que *no* debemos instalar, pero sí se deben cargar si se necesitan.

# Empezaremos cargando `Pkg`, una de estas librerías estándard, para lo que usaremos
# la instrucción `using`.

using Pkg # Cargamos la paquetería `Pkg`

# Lo que haré a continuación es *definir* un proyecto, el del curso, que incluirá todas
# las paqueterías que (por ahora) nos serán necesarias para empezar, y que poco a poco
# iremos ampliando. Para hacer esto, "activaremos" el directorio local e "instanciaremos"
# (*instantiate* en inglés) el repositorio, lo que creará los archivos "Project.toml" y "Manifest.toml",
# que son la base de la reproducibilidad en Julia. Subiéndolos a GitHub, en principio tendremos
# todos los archivos necesarios, para hacer que todo funcione de igual manera para cada uno.

Pkg.activate(".")  # Activa el directorio "." respecto al lugar donde estamos

# En la instrucción anterior, estamos ejecutando la función `activate`, que pertenece al módulo `Pkg`
# y que no es exportada.

# Ahora, instanciaremos el repositorio; lo que esto hace es actualizar los archivos
# "Project.toml" y "Manifest.toml".

Pkg.instantiate() # Crea/actualiza los archivos "Project.toml" y "Manifest.toml"

# Ahora *instalaremos* una paquetería que usaremos para *generar* los notebooks del curso:
# [Literate.jl](https://github.com/fredrikekre/Literate.jl):

Pkg.add("Literate") # Instala la paquetería `Literate.jl`

# La instrucción anterior instala la paquetería `Literate.jl` en el proyecto del curso;
# esto actualiza el archivo `Project.toml` con la información de la paquetería que se instaló (como dependencia)
# y `Manifest.toml` con todas las dependencias que puede requerir `Literate`, y la información
# de las versiones específicas. Otras paqueterías se instalan de la misma manera usando `Pkg.add`.

# Otra paquetería muy útil para poder visualizar con JupyterLab los notebooks,
# es `IJulia`. La instalamos de la misma manera:

Pkg.add("IJulia")

# La siguiente instrucción es útil cada vez que se actualiza IJulia o el JupyterLab y por
# eso la incluímos aquí.

Pkg.build("IJulia")  # Esto lo deben volver a hacer si actualizan IJulia o JupyterLab

# Finalmente, instalaremos la paquetería [Pluto.jl](https://github.com/fonsp/Pluto.jl), que
# funciona más o menos de manera similar al JupyterLab, con la propiedad adicional de
# que es *reactivo*, es decir, *todas* las celdas se actualizan bajo cambios.

Pkg.add("Pluto")

# Para saber o visualizar qué paquetes tenemos instalados, usamos `Pkg.status()`.

Pkg.status()

# Cuando iniciemos cualquier actividad del curso, será importante activar nuevamente
# el projecto del curso. Esto lo podemos hacer de dos maneras: estando en el directorio raíz
# del curso, iniciamos el REPL (Read-Edit-Print Loop) con la instrucción
# ```
# julia --project
# ```
# De manera alternativa, podemos iniciar Julia como lo hacemos usualmente, y después de navegar
# al directorio raíz del curso, *activaremos* el proyecto local del curso, usado los comandos
# `using Pkg; Pkg.activate(".")`. (El `;` sirve para separar dos comandos que se escriben en una
# sóla línea.) Vale la pena decir que a veces es necesario volver a instanciar el proyecto, si
# por ejemplo hay nuevas paqueterías instaladas o actualizaciones, esto es, cambios en los archivos
# `Project.toml` y `Manifest.toml`.

# Muchos de los comandos anteriores se simplifican al trabajar desde el REPL (sesión de
# Julia en la terminal) usando `]` al principio de la línea de comando, lo que nos da entrada
# al modo de trabajo con los paquetes. En este caso, al entrar a este modo, haremos:
# ```julia
# (@v1.7) pkg> activate .
#   Activating new project at `~/Documents/4-Clases/46-TemasSelectos/2022-2/2022-2_TSFC2`
#
# (2022-2_TSFC2) pkg> instantiate
#     Updating registry at `~/.julia/registries/General`
#   No Changes to `~/Documents/4-Clases/46-TemasSelectos/2022-2/2022-2_TSFC2/Project.toml`
#   No Changes to `~/Documents/4-Clases/46-TemasSelectos/2022-2/2022-2_TSFC2/Manifest.toml`
#
# (2022-2_TSFC2) pkg> add Literate
#    ...
# ```

# Para agregar `IJulia` usaremos `add IJulia` seguido de `build IJulia` estando
# dentro del manejador de paquetes en el REPL, y similarmente
# para `Pluto.jl`.

# # Generando notebooks (`ipynb`) con `Literate.jl`

# Aquí ilustraré cómo generar los Jupyter notebooks con el contenido
# de las clases y tareas, usando [Literate.jl](https://github.com/fredrikekre/Literate.jl).
# Como ejemplo generaremos el Jupyter notebook correspondiente a este archivo, y
# supondremos que estamos en el directorio raiz del curso, `2022-2_TSFC2/`,
# y que ahí iniciamos una sesión del REPL de Julia. Primero, activaremos el
# repositorio del
# curso (usando la tecla `]`, y para salirnos del manejador de paquetes usaremos la
# tecla <delete>) y después cambiaremos de directorio al directorio `clases/02-JuliaTutorial`:
#
# ```julia
# (@v1.7) pkg> activate .
#   Activating project at `~/Documents/4-Clases/46-TemasSelectos/2022-2/2022-2_TSFC2`
#
# julia> cd("clases/02-JuliaTutorial")   # Cambiamos al directorio ./clases/02-JuliaTutorial
# ```

# Ahora *cargaremos* la paquetería `Literate`:
#
# ```julia
# julia> using Literate
# ```

# Finalmente, generaremos a partir del archivo fuente ---en este caso "1-IntrodPkg.jl"---
# el Jupyter notebook correspondiente (con extensión `.ipynb`).

# ```julia
# julia> Literate.notebook("1-IntrodPkg.jl", execute=false)
# [ Info: generating notebook from `~/Documents/4-Clases/46-TemasSelectos/2022-2/2022-2_TSFC2/1-IntrodPkg.jl`
# [ Info: writing result to `~/Documents/4-Clases/46-TemasSelectos/2022-2/2022-2_TSFC2/1-IntrodPkg.ipynb`
# "/Users/benet/Documents/4-Clases/46-TemasSelectos/2022-2/2022-2_TSFC2/1-IntrodPkg.ipynb"
# ```

# La instrucción anterior ejecuta la función `notebook`, que está definida dentro de la paquetería `Literate`
# y genera el archivo "1-IntrodPkg.ipynb" que es el notebook que correspondiente.
# En este caso hemos usado el argumento (opción) `execute=false` para
# que **no** se ejecute el código que puede haber dentro del archivo. Esto es útil, en el contexto
# del curso, ya que a veces, por cuestiones pedagógicas, hay *errores* en el código, y éstos impediden
# que se genere el notebook.
#
# Vale la pena notar que el archivo `.jl` permite generar celdas que pueden ser de código,
# o en Markdown, y pueden también incluir ecuaciones, imágenes, etc. Por esto,
# es **muy** recomendable leer la [documentación](https://fredrikekre.github.io/Literate.jl/v2/)
# de `Literate`, lo que puede ser útil para formatear los archivos `.jl` que
# enviarán con las tareas resueltas.

# La paquetería `IJulia` es útil para abrir (desde Julia) el notebook, en este caso, `1-IntrodPkg.ipynb`,
# y de hecho poderlo explotar. Entre otras cosas, instala el *kernel* de Julia.

# # `Pluto.jl`

# La paquetería `Pluto.jl` puede ser muy útil para hacer las tareas que se les pide
# en el curso, e incluso para generar notebooks de pluto con el contenido de las clases.
# Esencialmente, los *notebooks* en `Pluto` son archivos escritos en Julia,
# con terminación `.jl`, donde las celdas `markdown` se marcan de una manera ligeramente
# distinta. Los notebooks en `Pluto` incluyen varias instrucciones *escondidas* del
# notebook, pero presentes en el archivo `.jl`, que permiten la funcionalidad del notebook,
# y que de hecho definen la visualización y el orden en que las instrucciones se ejecutan,
#  independientemente de donde aparecen en el notebook. Todo esto es ciertamente útil para el desarrollo y
# y trabajo para las tareas.

# Sin embargo, trabajar con `Pluto` también impone ciertas cuestiones que no son necesarias
# en general. Por ejemplo, hay cuestiones con la reutilización de la misma variable con distinto
# valor o al ejecutar *varias* instrucciones en una celda, lo que requiere
# que éstas estén en un bloque `begin ... end`.

# Si les acomoda trabajar con `Pluto`, adelante. Sin embargo, en general las tareas **no**
# requerirán que suban los archivos que `Pluto` genera, sino archivos `.jl` que usan `Literate`
# u otros que pueden usarse para definir módulos específicos. Tengan esto en cuenta esto.
