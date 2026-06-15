#Informe Técnico — Trabajo Práctico Integrador 2026
**Grupo 35**

#FASE 2- Integración de Quicklisp y cl-json

##Introducción
En esta fase se incorporó al sistema de semáforo una librería externa a través del gestor de paquetes Quicklisp, con el objetivo de eliminar los valores de temporización fijos del código fuente y reemplazarlos por una configuración dinámica leída desde un archivo JSON externo.

La librería seleccionada fue `cl-json`, que provee funcionalidades de parseo y serialización del formato JSON dentro del entorno Common Lisp.

### Intérprete utilizado: SBCL
Para esta fase se utilizó Steel Bank Common Lisp (SBCL) como intérprete. La elección no es arbitraria: durante el desarrollo se intentó utilizar CLISP a través del plugin SublimeREPL de Sublime Text 3, pero se descartó por las siguientes razones:

* **Incompatibilidad con la instalación de Quicklisp:** Quicklisp se instala de forma independiente para cada implementación de Common Lisp. La instalación realizada fue sobre SBCL. Al intentar cargar `core.lisp` desde CLISP, el intérprete no encontraba el archivo `~/quicklisp/setup.lisp` ya que dicha instalación no le pertenece.
* **Madurez y soporte:** SBCL es la implementación de Common Lisp con mayor actividad de desarrollo activo, mejor soporte de ASDF/Quicklisp y mensajes de compilación más detallados, lo que facilita la detección de errores en tiempo de carga.

Por lo tanto, todos los ejemplos y pruebas de esta fase se ejecutaron en SBCL desde Sublime Text 3, ingresando a él de la siguiente forma:

1. En la barra superior ingresar a **Tools**, seleccionar **SublimeREPL**.
2. En el plugin SublimeREPL, buscar **CommonLisp** y seleccionar.
3. En CommonLisp seleccionar **SBCL**.

Esto abrirá una pestaña en Sublime con el intérprete correspondiente. Este intérprete también puede ser utilizado desde PowerShell con el comando:
bash
sbcl --load core.lisp

##Instalación de Quicklisp
Quicklisp es un gestor de paquetes para Common Lisp que permite descargar e instalar librerías de forma automatizada desde su repositorio centralizado.
Pasos realizados:
Se descargó el archivo instalador quicklisp.lisp desde el sitio oficial: https://www.quicklisp.org/beta/
Se cargó el instalador en SBCL desde la terminal:
Bash
sbcl --load quicklisp.lisp
Dentro del REPL de SBCL, se ejecutaron los siguientes comandos:
Lisp
;; Instala Quicklisp en la carpeta de usuario (~/.quicklisp/)
(quicklisp-quickstart:install)
;; Agrega la carga automática al archivo de inicio de SBCL (~/.sbclrc)
;; para que Quicklisp esté disponible en cada sesión sin cargarlo manualmente (ql:add-to-init-file)
Con esto, Quicklisp quedó instalado en el directorio ~/quicklisp/ y se configuró para cargarse automáticamente cada vez que se inicia SBCL.
Instalación de cl-json
Con Quicklisp disponible, la instalación de cl-json se realizó con un único comando desde el REPL:
Lisp
(ql:quickload "cl-json")

Para verificar su correcto funcionamiento se ejecutó:
Lisp
(json:decode-json-from-string "{\"rojo\": 90}")
;; Devolviendo → ((:ROJO . 90))

La librería convierte las claves del JSON en keywords de Common Lisp (símbolos precedidos por :), y los pares clave-valor en una lista de asociación (association list o alist), una estructura nativa del lenguaje.
Archivo de configuración externa
Se creó el archivo config.json en el mismo directorio que core.lisp, con los tiempos de temporización:
JSON
{
  "rojo": 90,
  "amarillo": 6,
  "verde": 120
}

De esta forma, modificar los tiempos del semáforo ya no requiere editar el código fuente, sino únicamente este archivo externo.
Cambios en el código
Versión preliminar (descartada): uso de variable global
La primera aproximación a la solución implicó crear una variable global config que almacenara la configuración leída del archivo JSON, y una función cargar-config que la modificara mediante setf:
Lisp
;; Variable global mutable — DESCARTADO
(defvar config nil)

;; Función que modifica la variable global — DESCARTADO
(defun cargar-config (ruta)
  (with-open-file (stream ruta :direction :input)
    (setf config (json:decode-json stream))
  )
)

;; Las funciones leían de la variable global implícitamente
(defun duracionCiclo ()
  (+ (obtener-tiempo config :rojo)
     (obtener-tiempo config :amarillo)
     (obtener-tiempo config :verde))
)

Esta implementación fue descartada porque viola una restricción explícita de la consigna: queda prohibido el uso de variables globales mutables (defvar, defparameter) para almacenar estados cambiantes, así como el uso de operadores destructivos (setq, setf). El estado del sistema debe fluir únicamente a través de los argumentos de las funciones.
Versión final: el config fluye como argumento
La solución correcta elimina por completo la variable global. La función cargar-config simplemente retorna el resultado del parseo sin almacenarlo en ningún lugar. Todas las funciones que necesitan los tiempos reciben la configuración como parámetro explícito.
Carga de Quicklisp y cl-json al inicio del archivo:
Lisp
(load "~/quicklisp/setup.lisp")
(ql:quickload "cl-json" :silent t)}

Esta forma de cargar Quicklisp lanza advertencias normales e inofensivas en el REPL que redefinen funciones internas de la librería y no afectan al funcionamiento del sistema:
Plaintext
WARNING: redefining QL-SETUP:QMERGE in DEFUN
WARNING: redefining QL-SETUP:QENOUGH in DEFUN
WARNING: redefining QL-SETUP::IMPLEMENTATION-SIGNATURE in DEFUN

Nuevas funciones agregadas
Lisp
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

cargar-config es impura porque realiza entrada/salida (lectura de un archivo del sistema). Sin embargo, no modifica ningún estado externo: simplemente retorna el valor parseado.
Lisp
;==============================================================
;; FUNCION: obtener-tiempo
;; NATURALEZA: Pura
;; ESTRATEGIA: Busqueda en lista de asociacion (assoc)
;; IMPACTO: No destructiva
;==============================================================
(defun obtener-tiempo (config color)
  (cdr (assoc color config))
)

obtener-tiempo es pura: dado el mismo config y el mismo color, siempre devuelve el mismo resultado de la alist mediante assoc y cdr sin efectos secundarios.
Funciones modificadas para aceptar config como parámetro
Las funciones pasaron de no recibir argumentos de estado a recibir también config, recuperando su condición de Puras al ser completamente deterministas:
Función original
Función actualizada
(defun duracionCiclo ())
(defun duracionCiclo (config))
(defun timer (timestamp))
(defun semaforo-en (timestamp config))
(defun distribucionHora ())
(defun distribucionHora (config))
(defun ciclosPorTiempo (minutos))
(defun ciclosPorTiempo (minutos config))

Renombrado de la función timer
Durante las pruebas en SBCL se presentó el siguiente error:
debugger invoked on a SYMBOL-PACKAGE-LOCKED-ERROR:
  Lock on package SB-EXT violated when proclaiming TIMER as a function

El nombre TIMER está reservado por el paquete interno SB-EXT de SBCL. Para evitar violar el lock del paquete, la función fue renombrada a semaforo-en, resultando autoexplicativa: (semaforo-en 91 config) $\rightarrow$ VERDE.
Bitácora de Depuración (Bugs Detectados)
Bug de Bloqueo de Paquete: Tratamiento del símbolo reservado TIMER en SBCL solucionado mediante el renombrado a semaforo-en.
Bug de Mutación de Estado: Descarte del prototipo inicial con variables globales (defvar y setf) para pasar a un flujo puramente parametrizado por argumentos.
FASE 3 — Estudio Comparativo: Scheme
Introducción a Scheme e Impacto Industrial
Scheme es un dialecto de la familia de lenguajes Lisp, co-creado por Guy L. Steele y Gerald Jay Sussman en los años 70. Se caracteriza por su enfoque en el minimalismo conceptual, una especificación sintáctica sumamente reducida y un diseño elegante.
A nivel industrial, Scheme se utiliza principalmente en:
Educación y Computación Académica: Es el lenguaje insignia para la enseñanza de la estructura e interpretación de programas informáticos (como en el célebre libro SICP del MIT).
Sistemas de Extensión y Scripting: Su variante GNU Guile es el lenguaje oficial de extensión del proyecto GNU, utilizado para configurar entornos del sistema.
Empresas Destacadas: Compañías como Naughty Dog han utilizado variantes basadas en Scheme para el scripting de mecánicas y comportamientos de IA en videojuegos (como la saga Crash Bandicoot).
Ejes Comparativos Analíticos
1. Espacio de Nombres: Lisp-2 vs. Lisp-1 y la omisión de funcall
Common Lisp es clasificado como un Lisp-2, lo que significa que las funciones y las variables residen en espacios de nombres (namespaces) separados. Por ende, para pasar una función como argumento en Common Lisp se debe usar el operador #'' para obtener el objeto función y, posteriormente, invocarlo mediante la primitiva funcall.
Por el contrario, Scheme es un Lisp-1: las funciones y las variables comparten el mismo espacio de nombres idéntico. En Scheme, el identificador de una función es tratado exactamente igual que cualquier otra variable que contiene un valor. Por esta razón técnica, no hace falta utilizar funcall ni el operador #''. Para ejecutar una función recibida como argumento, basta con colocar el símbolo en la primera posición de una lista evaluable: (fun_argumento datos).
2. Optimización de Llamada de Cola (Tail Call Optimization - TCO)
Por especificación oficial del estándar de Scheme, todos los compiladores e intérpretes están obligados a implementar TCO. Esto significa que si una función realiza una llamada recursiva como su última acción absoluta (el resultado de la llamada no requiere cálculos adicionales pendientes en el marco de la pila), el entorno de Scheme no añade un nuevo marco a la pila de ejecución, sino que reutiliza el marco actual.
En nuestra función semaforo-en de solucion.scm, estructuramos el flujo de datos utilizando la macro de enlace secuencial let*. Al evaluar las ligaduras internas de los tiempos dinámicos extraídos de la lista de asociación, la expresión condicional cond resuelve el color de forma atómica y directa en sus cláusulas de salida. Si hubiésemos necesitado un ciclo continuo de simulación a través del tiempo, la estructura recursiva se habría diseñado de la siguiente manera para garantizar que el compilador no agote la pila de memoria (Stack Overflow):
Scheme
(define (bucle-simulacion-semaforo timestamp config)
  ;; La llamada recursiva ocurre al final sin operaciones pendientes fuera de ella
  (bucle-simulacion-semaforo (+ timestamp 1) config))

Bitácora de Depuración en la Migración
Bug del Predicado de Igualdad de Símbolos: Error de concordancia resuelto al cambiar el operador primitivo eq de Common Lisp por el predicado nativo eq? requerido por el estándar Scheme.
Bug de Keywords JSON en la Alist: Conflicto de tipos resuelto al reemplazar la sintaxis de claves con dos puntos (:rojo) por símbolos puros ('rojo, 'verde) para asegurar el correcto funcionamiento de assoc en la suite de Scheme.
