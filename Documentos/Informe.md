## Fase 2 — Integración de Quicklisp y cl-json

### Introducción

En esta fase se incorporó al sistema de semáforo una librería externa a través del gestor de paquetes Quicklisp, con el objetivo de eliminar los valores de
temporización fijos del código fuente y reemplazarlos por una configuración dinámica leída desde un archivo JSON externo.

La librería seleccionada fue cl-json, que provee funcionalidades de parseo y serialización del formato JSON dentro del entorno Common Lisp.

### Intérprete utilizado: SBCL

Para esta fase se utilizó Steel Bank Common Lisp (SBCL) como intérprete. La elección no es arbitraria: durante el desarrollo se intentó utilizar CLISP a
través del plugin SublimeREPL de Sublime Text 3, pero se descartó por las siguientes razones:

- Incompatibilidad con la instalación de Quicklisp: Quicklisp se instala de forma independiente para cada implementación de Common Lisp. La instalación realizada
fue sobre SBCL. Al intentar cargar `core.lisp` desde CLISP, el intérprete no encontraba el archivo `~/quicklisp/setup.lisp` ya que dicha instalación no le pertenece.

- Madurez y soporte: SBCL es la implementación de Common Lisp con mayor actividad de desarrollo activo, mejor soporte de ASDF/Quicklisp y mensajes de compilación más
detallados, lo que facilita la detección de errores en tiempo de carga.

Por lo tanto, todos los ejemplos y pruebas de esta fase se ejecutaron en SBCL desde Sublime Text 3, ingresando a el de la siguiente forma:

- En la barra superior ingresar a "Tools", seleccionar "SublimeREPL".
- En el plugin SublimeREPL, buscar CommonLisp y seleccionar.
- En CommonLisp seleccionar SBCL.

Esto abrira una pestaña en Sublime con el interprete correspondiente.

Este interprete tambien puede ser utilizado desde PowerShell con el comando:
```bash
sbcl --load core.lisp
```

### Instalación de Quicklisp

Quicklisp es un gestor de paquetes para Common Lisp que permite descargar e instalar librerías de forma automatizada desde su repositorio centralizado.

#### Pasos realizados

1. Se descargó el archivo instalador `quicklisp.lisp` desde el sitio oficial:

https://www.quicklisp.org/beta/

2. Se cargó el instalador en SBCL desde la terminal:
```bash
sbcl --load quicklisp.lisp
```

3. Dentro del REPL de SBCL, se ejecutaron los siguientes comandos:

```lisp
; Instala Quicklisp en la carpeta de usuario (~/.quicklisp/)
(quicklisp-quickstart:install)

; Agrega la carga automática al archivo de inicio de SBCL (~/.sbclrc)
; para que Quicklisp esté disponible en cada sesión sin cargarlo manualmente
(ql:add-to-init-file)
```

Con esto, Quicklisp quedó instalado en el directorio `~/quicklisp/` y se configuró para cargarse automáticamente cada vez que se inicia SBCL.

### Instalación de cl-json

Con Quicklisp disponible, la instalación de cl-json se realizó con un único comando desde el REPL:

```lisp
(ql:quickload "cl-json")
```

Quicklisp resolvió las dependencias, descargó la librería y la dejó disponible para ser utilizada en cualquier proyecto. Para verificar su correcto funcionamiento
se ejecutó:

```lisp
(json:decode-json-from-string "{\"rojo\": 90}")
; devolviendo → ((:ROJO . 90))
```

La librería convierte las claves del JSON en keywords de Common Lisp (símbolos precedidos por `:`), y los pares clave-valor en una lista de asociación
(association list o alist), una estructura nativa del lenguaje.

### Archivo de configuración externa

Se creó el archivo `config.json` en el mismo directorio que `core.lisp`, con los tiempos de temporización:

```json
{
  "rojo": 90,
  "amarillo": 6,
  "verde": 120
}
```

De esta forma, modificar los tiempos del semáforo ya no requiere editar el código fuente, sino únicamente este archivo externo.


### Cambios en el código

#### Versión preliminar (descartada): uso de variable global

La primera aproximación a la solución implicó crear una variable global `config` que almacenara la configuración leída del archivo JSON, y una función
`cargar-config` que la modificara mediante `setf`:

```lisp
; Variable global mutable — DESCARTADO
(defvar config nil)

; Función que modifica la variable global — DESCARTADO
(defun cargar-config (ruta)
  (with-open-file (stream ruta :direction :input)
    (setf config (json:decode-json stream))
  )
)

; Las funciones leían de la variable global implícitamente
(defun duracionCiclo ()
  (+ (obtener-tiempo config :rojo)
     (obtener-tiempo config :amarillo)
     (obtener-tiempo config :verde))
)
```

Esta implementación fue descartada porque viola una restricción explícita de la consigna: queda prohibido el uso de variables globales mutables 
(`defvar`, `defparameter`) para almacenar estados cambiantes, así como el uso de operadores destructivos (`setq`, `setf`). El estado del sistema debe fluir
únicamente a través de los argumentos de las funciones.

#### Versión final: el config fluye como argumento

La solución correcta elimina por completo la variable global. La función `cargar-config` simplemente retorna el resultado del parseo sin almacenarlo en ningún lugar.
Todas las funciones que necesitan los tiempos reciben la configuración como parámetro explícito.

- Carga de Quicklisp y cl-json al inicio del archivo:

```lisp
(load "~/quicklisp/setup.lisp")
(ql:quickload "cl-json" :silent t)
```

Esta forma de cargar quicklist, lanza advertencias en el REPL SBCL normales e inofensivos. Estos aparecen cada vez que se carga el codigo "core.lisp" porque se vuelve
a ejecutar el comando de carga, y quicklist redefine sus propias funciones internas.
No afectan al funcionamiento.

Las advertencias son las siguientes:
```text
WARNING: redefining QL-SETUP:QMERGE in DEFUN
WARNING: redefining QL-SETUP:QENOUGH in DEFUN
WARNING: redefining QL-SETUP::IMPLEMENTATION-SIGNATURE in DEFUN
WARNING: redefining QL-SETUP::DUMB-STRING-HASH in DEFUN
WARNING: redefining QL-SETUP::ASDF-FASL-PATHNAME in DEFUN
WARNING: redefining QL-SETUP::ENSURE-ASDF-LOADED in DEFUN
```

#### Nuevas funciones agregadas:

```lisp
;==============================================================
;; FUNCION: cargar-config
;; NATURALEZA: Impura
;; ESTRATEGIA: Lectura de archivo externo y parseo JSON
;; IMPACTO: No destructiva
;==============================================================

(defun cargar-config (ruta)
  (with-open-file (stream ruta :direction :input)
    (json:decode-json stream)
  )
)
```

cargar-config es impura porque realiza entrada/salida (lectura de un archivo del sistema), una operación con efecto observable fuera de la función. Sin embargo,
no modifica ningún estado externo: simplemente retorna el valor parseado.


```lisp
;==============================================================
;; FUNCION: obtener-tiempo
;; NATURALEZA: Pura
;; ESTRATEGIA: Busqueda en lista de asociacion (assoc)
;; IMPACTO: No destructiva
;==============================================================

(defun obtener-tiempo (config color)
  (cdr (assoc color config))
)
```

obtener-tiempo es pura: dado el mismo config y el mismo color, siempre devuelve el mismo resultado sin efectos secundarios. Utiliza assoc para buscar el par
clave-valor en la alist, y cdr para extraer únicamente el valor numérico.

#### Funciones modificadas para aceptar config como parámetro:

Las funciones duracionCiclo, semaforo-en, distribucionHora y ciclosPorTiempo pasaron de no recibir argumentos (o recibir solo los suyos) a recibir también `config`,
eliminando toda dependencia de estado global.

| Funcion original 			| Funcion actualizada 				|
|---------------------------------------|-----------------------------------------------|
| (defun duracionCiclo ()) 		| (defun duracionCiclo (config)) 		|
| (defun timer (timestamp)) 		| (defun semaforo-en (timestamp config)) 	|
| (defun distribucionHora ()) 		| (defun distribucionHora (config)) 		|
| (defun ciclosPorTiempo (minutos)) 	| (defun ciclosPorTiempo (minutos config)) 	|

Estas funciones pasaron de clasificarse como Puras a Impuras en su versión anterior (cuando dependían de config como variable global). En la versión final,
al recibir el config como parámetro explícito, recuperan su condición de Puras: son deterministas y sin efectos secundarios.

#### Renombrado de la función timer

Durante las pruebas en SBCL se presentó el siguiente error al intentar definir la función timer:

```text
debugger invoked on a SYMBOL-PACKAGE-LOCKED-ERROR:
  Lock on package SB-EXT violated when proclaiming TIMER as a function
```

El nombre TIMER está reservado por el paquete interno `SB-EXT` de SBCL, que lo utiliza para su propio sistema de temporizadores. Intentar definir una función con ese
nombre viola el lock del paquete.

La función fue renombrada a semaforo-en, nombre que describe con precisión su comportamiento: recibe un instante de tiempo y devuelve el color del semáforo activo en
ese momento. El nombre sigue la convención de Common Lisp de separar palabras con guión, y resulta autoexplicativo al leerlo:

```lisp
(semaforo-en 91 config)   ; → VERDE
```

Se lee naturalmente como: "el color del semaforo en el tiempo 91".

## Fase 3 — Estudio Comparativo: Scheme

### Introducción a Scheme e Impacto Industrial
[cite_start]Scheme es un dialecto de la familia de lenguajes Lisp, co-creado por Guy L. Steele y Gerald Jay Sussman en los años 70[cite: 49]. [cite_start]Se caracteriza por su enfoque en el minimalismo conceptual, una especificación sintáctica sumamente reducida y un diseño elegante[cite: 49]. 

A nivel industrial, Scheme se utiliza principalmente en:
* **Educación y Computación Académica:** Es el lenguaje insignia para la enseñanza de la estructura e interpretación de programas informáticos (como en el célebre libro SICP del MIT).
* **Sistemas de Extensión y Scripting:** Su variante *GNU Guile* es el lenguaje oficial de extensión del proyecto GNU, utilizado para configurar entornos del sistema y herramientas de desarrollo.
* **Empresas Destacadas:** Compañías como **Naughty Dog** han utilizado variantes basadas en Scheme para el scripting de mecánicas y comportamientos de IA en videojuegos aclamados (como la saga *Crash Bandicoot* y *Jak and Daxter*).
