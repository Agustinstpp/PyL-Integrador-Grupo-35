# Sistema de Semáforos Inteligentes

**Objetivos**

* **Modelar un problema del mundo real**: Traducir los requisitos funcionales de un sistema de tráfico urbano a código LISP utilizando paradigmas de programación funcional.  
* **Aplicar conceptos fundamentales**: Implementar funciones puras, inmutabilidad y composición funcional para resolver un problema de ingeniería de sistemas.  
* **Desarrollar pensamiento algorítmico**: Diseñar soluciones elegantes y eficientes que reflejen la naturaleza matemática de LISP.  
* Exposición a circunstancias nuevas y desconocidas.

---

## Contexto del Problema

Las ciudades modernas requieren sistemas de tráfico inteligentes para optimizar el flujo vehicular y garantizar la seguridad vial. Su equipo ha sido contratado para desarrollar el núcleo lógico de un sistema embebido que controlará semáforos en intersecciones críticas de la ciudad. El mismo fue implementado en Common Lisp.

---

# Especificaciones Técnicas

## Requerimiento 1: Estados de Transición

Implemente la función `transicion` que modele el cambio de estados del semáforo:

**Especificación:**

* **Entrada:** `color-actual` (símbolo: en-rojo, en-amarillo, en-verde) y `cambiar-a` (símbolo del color destino: rojo, amarillo, verde)  
* **Salida:** devuelve una lista con el estado y una acción a realizar, esta última como literal “cambiar-a-\<color\>”.  
* **Comportamiento:** Por defecto, retorna color actual y `'accion-por-defecto` si la transición no es válida

**Ejemplo esperado:**

(transicion 'en-rojo 'verde) → ('en-rojo "cambiar-a-verde")

## Requerimiento 2: Temporizador Automático

Para la implementación de un actuador que realizará el cambio de luces se necesita implementar un mecanismo automatizado de temporización. Se solicita implementar una función Timer, que recibirá el tiempo actual en formato tiempo Unix (o tiempo epoch).

Desarrolle la función `timer` para automatizar las transiciones basadas en tiempo Unix:

**Reglas de temporización:**

* **Rojo:** 90 segundos  
* **Amarillo:** 6 segundos   
* **Verde:** 120 segundos

**Especificación:**

* **Entrada:** Tiempo Unix actual (entero)  
* **Salida:** Color correspondiente al momento específico  
* **Comportamiento:** Calcular automáticamente qué color debe estar activo en el timestamp dado

## Requerimiento 3: Sistema de Auditoría

El equipo de analistas forenses necesita poder determinar qué color tenía una luz a determinada hora. Se necesita implementar un mecanismo de registro de los diferentes cambios de estado de las luces durante la ejecución del programa. Se ha solicitado que para la versión actual se implemente una función que imprima en la terminal de ejecución el cambio de estados del semáforo.

Implemente un mecanismo de logging para análisis forense de tráfico:

**Especificación:**

* Función que registre cada cambio de estado  
* **Formato de salida:** `"Tiempo <epoch>: la luz ha cambiado de <color-anterior> a <color-nuevo>"`  
* **Propósito:** Permitir reconstrucción histórica de estados del semáforo

## Requerimiento 4: Análisis de Ciclos Semafóricos

Para la coordinación y planificación de la vía se necesita calcular cuántos ciclos, transición entre rojo a rojo, se realizarán pasado un determinado tiempo. A la hora de determinar la duración de un ciclo semafórico se acostumbra a tener en cuenta la psicología del conductor, según la cual, ciclos menores de 35 segundos o mayores de 150 segundos se acomodan difícilmente a la mentalidad del usuario de la vía pública, por lo que tienden a evitarse. Por lo que se solicita implementar una función **duracion-ciclo** que calcule la duración que tendrá cada ciclo con las reglas de negocio actuales y una función de recomendacion sobre la duración del ciclo. 

Desarrolle funciones para análisis de eficiencia del sistema:

### 4a. Función `duracion-ciclo`

* **Entrada:** un número determinado de segundos  
* **Propósito: Calcular duración total** de un ciclo completo (rojo → amarillo → verde → **rojo)**  
* 

### 4b. Función `recomendacion-ciclo`

* **Entrada:** Duración calculada del ciclo  
* **Salida:** Recomendación de optimización basada en estándares de ingeniería de tráfico  
* **Consideración psicológica:** Evaluar si la duración está en el rango óptimo (35-150 segundos)

## Requerimiento 5: Planificación Temporal

Para la coordinación y planificación de la vía se necesita calcular cuántos ciclos se completan en determinada cantidad de minutos, por ejemplo en 15 minutos; se requiere una función ciclos-por-tiempo que calcule la cantidad de ciclos incluidos en ese tiempo.

Implemente `ciclos-por-tiempo`:

**Especificación:**

* **Entrada:** Duración en minutos  
* **Salida:** Número de ciclos completos en ese período  
* **Aplicación:** Planificación de mantenimiento y análisis de capacidad

## Requerimiento 6: Informe de Distribución Temporal

Por cuestiones de planificación logística, se necesita un informe que indique el porcentaje de cada color que se tendrá en 1 hora. Dadas ciertas reglas de negocios o según las actuales. 

Desarrolle una función que calcule la distribución porcentual de cada color en períodos de 1 hora:

**Especificación:**

* **Salida:** Porcentajes de tiempo para rojo, amarillo y verde  
* **Propósito:** Optimización de flujo vehicular y análisis de congestión

## Requerimiento 7: Aseguramiento de la calidad

El equipo de control de calidad ha solicitado que para cada uno de los requerimientos anteriores deberá proveer ejemplos de uso que demuestren el funcionamiento normal, ejemplos de caminos alternativos (si los hubiere) y ejemplos que generan errores. A sabiendas de que el equipo ejecutará lo indicado, copiando y pegando.

---

# Iteración 2

## Extensión 1: Intermitencia de Seguridad

Se solicita agregar tiempo de intermitencia de 3 segundos entre los cambios de luces, indicando el color intermitente (ejem. amarrillo-intermitente)

* Agregue 3 segundos de intermitencia entre transiciones  
* Modele estados intermedios, como por ejemplo `'amarillo-intermitente`  
* Actualice todas las funciones para manejar estos estados adicionales

## Extensión 2: Persistencia de Datos

Se solicita guardar en un archivo de texto plano el Log con los cambios de estado. Modificando la función informe.

Modifique el sistema de logging para guardar en archivo:

(defun informe (datos)

 (with-open-file (stream "informe-ejecucion-semaforo.txt" :direction :output)

   (format stream "Informe de Ejecución del Sistema Semafórico\~%")

   (format stream "=========================================\~%")

   ;; Implementar iteración sobre datos y formateo

   ;; Ejemplo de línea: "2024-06-04 14:30:15 \- Transición: ROJO → VERDE"

   (format stream "\~% \--- Fin del Informe \---")))

