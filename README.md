# Temas Selectos de Física Computacional II

## Métodos numéricos avanzados de ecuaciones diferenciales ordinarias

Semestre 2022-2, [grupo 8387](https://aulas-virtuales.cuaed.unam.mx/)

Luis Benet
[Instituto de Ciencias Físicas, UNAM](https://www.fis.unam.mx)

Julián Ramírez Castro
[Facultad de Ciencias, UNAM](http://www.fciencias.unam.mx)


*Lunes y miércoles: 9:00-10:30*


---

### Contenido del curso

El objetivo del curso es introducir una serie de métodos de matemáticas y física computacionales que permiten integrar ecuaciones diferenciales ordinarias (problemas de valor inicial) con alta precisión. En el curso estudiaremos e implementaremos en el lenguaje de programación [Julia](https://julialang.org) los conceptos básicos y técnicas relacionados con diferenciación automática de primer y alto orden, en una y varias variables, y el método de integración de Taylor. A través de ejemplos concretos cubriremos distintas aplicaciones a sistemas dinámicos, en particular en mecánica celeste. El curso está dirigido a estudiantes de Física, Matemáticas, Matemáticas Aplicadas y Ciencias de la Computación.

### Temario

- Herramientas computacionales: markdown, git y lenguaje Julia.
- Diferenciación automática de primer orden.
- Diferenciación automática de orden superior y series de Taylor.
- Método de Taylor de integración de EDOs.
- Transporte de jets y métodos semianalíticos.
- Proyecto semestral.

---

### Ligas de interés

- **git**
	- [Learn Git branching](https://learngitbranching.js.org/)

	- [Become a Git guru](https://www.atlassian.com/git/tutorials/)

	- [Github](https://docs.github.com/en/github/getting-started-with-github)

	- [Hello World en GitHub](https://guides.github.com/activities/hello-world/)

- **Markdown**
	- [Markdown guide](https://www.markdownguide.org/getting-started/)

- **Julia**
	- [http://julialang.org/](https://julialang.org)

	- [Julia programming for nervous beginners](https://www.youtube.com/watch?v=ub3tqCWZmo4&list=PLP8iPy9hna6Qpx0MgGyElJ5qFlaIXYf1R)

---

### Preparación (set-up) inicial

1. Instalar `git`:
    Seguir las instrucciones descritas en https://www.atlassian.com/git/tutorials/install-git, que dependen de la plataforma que usan:  [Linux](https://www.atlassian.com/git/tutorials/install-git#linux), [Mac](https://www.atlassian.com/git/tutorials/install-git#mac-os-x),  [Windows](https://www.atlassian.com/git/tutorials/install-git#windows)

2. Instalar Julia:
    Ir a https://julialang.org/downloads/, descargar [la última versión estable](https://julialang.org/downloads/#current_stable_release) (actualmente es la 1.7.2) y  que sea adecuada a su plataforma.

3. Verificar el funcionamiento de Julia; ver las notas específicas para [cada plataforma](https://julialang.org/downloads/platform/):
    Abran la aplicación que acaban de instalar y corran el comando: `1+1`.

4. Instalar el [Jupyter Lab](https://jupyter.org/) (o el Jupyter Notebook) siguiendo [las instrucciones oficiales](https://jupyter.org/install).

