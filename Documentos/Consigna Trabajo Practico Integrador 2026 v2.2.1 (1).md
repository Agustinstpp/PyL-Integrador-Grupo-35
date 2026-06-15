# **TRABAJO PRÁCTICO INTEGRADOR 2026**

## **Sistema de Semáforos Inteligentes y Análisis Comparativo de Paradigmas**

## **Objetivos del Trabajo Práctico**

* **Modelar un problema del mundo real**: Traducir los requisitos funcionales de un sistema de tráfico urbano a código LISP utilizando el paradigma funcional.  
* **Desarrollar autonomía y pensamiento algorítmico**: Resolver la integración de herramientas externas y el aprendizaje de una tecnología nueva con el mínimo de asistencia docente.  
* **Análisis Crítico y Metacognición**: Evaluar y tipificar las funciones creadas, comprendiendo sus implicancias en la memoria y el flujo de datos, y comparar cómo diferentes lenguajes abordan un mismo problema lógico.

## **Consignas de las Fases de Desarrollo**

El trabajo se compone de tres fases obligatorias que deben resolverse aplicando estrictamente los conceptos de funciones puras, inmutabilidad y composición.

### **Fase 1: El problema de los 3 focos**

Deberán implementar la lógica de control urbano para el "Sistema de Semáforos Inteligentes" detallado en el enunciado base (Requerimientos 1 al 6). 

Para garantizar que el desarrollo sea puramente funcional y evitar códigos genéricos de IA, se imponen las siguientes **Restricciones de Diseño e Implementación**:

1. **Inmutabilidad Absoluta:** Queda prohibido el uso de variables globales mutables (`defparameter`, `defvar`) para almacenar estados cambiantes, así como operadores destructivos (`setq`, `setf`). El estado del tráfico y del tiempo debe fluir únicamente a través de los argumentos de las funciones.  
2. **Cero Bucles Imperativos:** No se permite el uso de `loop`, `dolist`, `dotimes` o `while`. Toda iteración o cálculo acumulativo debe resolverse mediante **recursividad de cola (*tail recursion*)** o **funciones de orden superior** (`mapcar`, `reduce`, `remove-if`).  
3. **Autodocumentación y Clasificación Obligatoria:** Cada función que escriban (tanto en Lisp como en el lenguaje de la Fase 3\) **deberá iniciar obligatoriamente con un encabezado de comentarios** donde clasifican taxonómicamente la función bajo los conceptos del paradigma. Deberán especificar:  
   * **Naturaleza:** ¿Es una función *Pura* (sin efectos secundarios) o *Impura* (ej: funciones de logging que escriben en pantalla/archivo)?  
   * **Estrategia de Control:** ¿Es *Recursiva Simple*, *Recursiva de Cola (Tail Recursive)*, utiliza *Funciones de Orden Superior* o es una *Función Predicado*?  
   * **Impacto en Memoria:** ¿Es *Destructiva* (modifica estructuras existentes) o *No Destructiva*?  
4. *Ejemplo de formato requerido en el código Lisp:*  
   Lisp

| ;; \========================================================;; FUNCIÓN: timer;; NATURALEZA: Pura (Dado un timestamp, siempre retorna el mismo color);; ESTRATEGIA: Orden Superior (Implementada mediante mapcar y reduce);; IMPACTO: No destructiva;; \========================================================(defun timer (timestamp)    ;; ... código ...) |
| :---- |

5. **Bitácora de Depuración:** En el informe deberán documentar de forma cruda y explícita al menos **cuatro errores o bugs conceptuales** que hayan surgido durante el desarrollo en Lisp (ej. desbordes de pila por recursividad mal planteada, problemas con la evaluación de símbolos, etc.), explicando su causa y cómo lo solucionaron; incluyendo capturas de pantalla.

## Sistema de Semáforos Inteligentes

Enunciado base disponible en el siguiente enlace [Ejercicio Semaforos v2.1](https://docs.google.com/document/d/1vggtZeTajvG9gsEl66-yPj7nNE1EtgFvBgXGupGfC5A/edit?usp=sharing)

[https://docs.google.com/document/d/1vggtZeTajvG9gsEl66-yPj7nNE1EtgFvBgXGupGfC5A/edit?usp=sharing](https://docs.google.com/document/d/1vggtZeTajvG9gsEl66-yPj7nNE1EtgFvBgXGupGfC5A/edit?usp=sharing) 

### **Fase 2: Autonomía y Ecosistema**

Deberán investigar el uso del gestor de paquetes **Quicklisp** (quicklisp.org) e integrar al núcleo de su aplicación **una (1)** de las siguientes librerías:

* **`local-time`:** Modificar el *Sistema de Auditoría (Requerimiento 3\)* para que, en lugar de imprimir el tiempo en formato Unix (Epoch), muestre la fecha y hora en un formato legible para humanos (Ej: `[2026-05-16 14:30:00]`).  
    
* **`cl-json`:** Modificar el sistema para que los tiempos de temporización por color (90s, 6s, 120s) no estén fijos en el código, sino que se carguen dinámicamente desde un archivo `.json` de configuración externa.

### **Fase 3: Estudio Comparativo**

A cada grupo se le asignará de forma aleatoria **uno** de los siguientes 7 lenguajes de programación: **Haskell, Scala, Clojure, OCaml, Scheme, Erlang o Elixir**. Deberán investigar su sintaxis y **reimplementar únicamente las funciones de `transición` y `timer`** en el lenguaje asignado, aplicando también la obligatoriedad de los comentarios de clasificación de funciones del punto 3\.

Deberán incluir un presentación breve del lenguaje e indicar en qué industrias o áreas se utiliza y dar ejemplos de empresas conocidas que lo estén utilizando.

Incluir una conclusión del grupo sobre la experiencia de estudio y utilización del lenguaje.

Además, según el lenguaje que les toque, deberán contestar las siguientes preguntas:

* **Si les tocó HASKELL:**   
  * 1\. Common Lisp tiene un tipado dinámico. Haskell tiene un tipado estático estricto. ¿Cómo modelaron los colores del semáforo? Expliquen qué es un *Algebraic Data Type* (ADT) y cómo el compilador de Haskell impide pasar un estado inválido antes de que el programa se ejecute.   
  * 2\. Expliquen cómo afecta la *Evaluación Perezosa (Lazy Evaluation)* de Haskell al procesamiento de los tiempos del temporizador si tuvieran un flujo infinito de eventos de tráfico.  
* **Si les tocó SCALA:**   
  * 1\. Scala combina la Programación Orientada a Objetos (POO) con la Funcional. ¿Cómo estructuraron el semáforo? ¿Usaron una clase tradicional, un `object` (Singleton), o `case classes`? Justifiquen desde el diseño funcional.   
  * 2\. Comparen la manipulación de listas en Scala (métodos como `.map` o `.filter`) contra las funciones de orden superior de Common Lisp. ¿Cuál resulta más legible y por qué?  
* **Si les tocó CLOJURE:**   
  * 1\. Ambos lenguajes son Lisps, pero Clojure elimina los símbolos cotizados (`'rojo`) en favor de los *Keywords* (`:rojo`). ¿Cuál es la ventaja técnica y de rendimiento de un Keyword en Clojure para mapear estados?   
  * 2\. Clojure prohíbe la mutabilidad por defecto usando estructuras de datos persistentes. ¿Cómo maneja Clojure el paso del tiempo en el simulador semafórico sin modificar variables?  
* **Si les tocó OCAML:**   
  * 1\. Al igual que Haskell, OCaml usa tipos estáticos pero cuenta con *Inferencia de Tipos*. ¿Tuvieron que declarar explícitamente de qué tipo eran las funciones o el compilador lo dedujo solo? Muestren cómo lo interpreta el entorno.   
  * 2\. OCaml es un lenguaje "orientado a expresiones". ¿Cómo cambia esto la estructura de control de flujos (como el uso de `match...with`) comparado con los condicionales de Lisp?  
* **Si les tocó SCHEME:**   
  * 1\. Common Lisp es un "Lisp-2" (funciones y variables viven en espacios de nombres distintos) y Scheme es un "Lisp-1". Expliquen por qué en Scheme **no** hace falta usar `funcall` ni el operador `#'` para pasar funciones como argumentos.   
  * 2\. Scheme exige por especificación la Optimización de Llamada de Cola (*Tail Call Optimization* \- TCO). ¿Cómo estructuraron la recursividad en su función para asegurar que el compilador no agote la pila de memoria?  
* **Si les tocó ERLANG:**   
  * 1\. Erlang utiliza una sintaxis derivada de Prolog. Muestren cómo se delimitan las funciones y las expresiones (puntos, comas y puntos y comas) y cómo afectó esto a la lectura del código comparado con los paréntesis de Lisp.   
  * 2\. En Erlang las variables son de *asignación única*. ¿Cómo simulan un ciclo continuo de cambios en el semáforo si no pueden reasignar valores a las variables?  
* **Si les tocó ELIXIR:**   
  * 1\. En Common Lisp, para la función `transicion` se suele usar un `cond` o `case`. En Elixir se utiliza *Pattern Matching* directo en los argumentos de la función (múltiples cláusulas). Muestren su código y expliquen por qué este enfoque es más declarativo.   
  * 2\. Elixir utiliza el Modelo de Actores. Expliquen conceptualmente cómo se diseñaría un sistema donde cada semáforo de una esquina real sea un proceso independiente que se comunica enviando mensajes a los otros.

La punta del hilo… 

* Haskell  
  * [https://www.haskell.org/](https://www.haskell.org/)  
  * [https://www.tryhaskell.org/](https://www.tryhaskell.org/)      
* Scala   
  * Scala   
  * [https://www.scala-lang.org/](https://www.scala-lang.org/)   
  * [https://scastie.scala-lang.org/](https://scastie.scala-lang.org/)   
* Clojure  
  * [https://clojure.org](https://clojure.org)  
  * [https://tryclojure.org/](https://tryclojure.org/)   
* OCaml  
  * [https://ocaml.org/](https://ocaml.org/)   
  * [https://ocaml.org/play](https://ocaml.org/play)   
* Scheme  
  * [https://www.scheme.org/](https://www.scheme.org/)   
  * [https://try.scheme.org/](https://try.scheme.org/)   
* Erlang   
  * [https://www.erlang.org/](https://www.erlang.org/)   
  * [https://www.tryerlang.org/](https://www.tryerlang.org/)   
* Elixir  
  * [https://elixir-lang.org/](https://elixir-lang.org/)   
  * [https://playground.functional-rewire.com/](https://playground.functional-rewire.com/) 

# FORMA DE ENTREGA

---

La resolución de este Trabajo Práctico Integrador trasciende la mera escritura de líneas de código aisladas. Para formalizar y dar por válida la entrega del proyecto, cada equipo deberá consolidar obligatoriamente un ecosistema evaluable compuesto por tres componentes integrales:

* **1\. Informe Técnico Analítico:** Un documento estructurado formal (en formato PDF o Markdown) que exponga con rigurosidad los fundamentos del diseño funcional adoptado, la justificación de las librerías seleccionadas en la Fase 2, la bitácora pormenorizada de bugs de depuración y las respuestas teóricas a los ejes comparativos de la Fase 3\. Incluir integrantes del grupo, tema investigado, bibliografía.  
* **2\. Video de Defensa “Demo Tecnica”:** Un video sintético de 5 a 10 minutos de duración máxima, disponible públicamente en YouTube, donde se verifique la correcta ejecución de los entornos de software y se compendien oralmente las conclusiones críticas del grupo.  
* **3\. Defensa Pública (Demo en Escenario):** Durante las sesiones estipuladas de cierre, la cátedra seleccionará grupos de forma aleatoria para subir al escenario y realizar una demostración técnica práctica en vivo de un máximo de 10 minutos ante todo el auditorio.

**Formalmente**: La entrega se realizará en el aula virtual compartiendo un enlace a un repositorio público de Github y el enlace al video publicado en YouTube, ambos deberán estar accesible para cuando el profesor revise su trabajo. Se creará una tarea en el aula virtual con fecha límite de entrega, donde el coordinador del equipo deberá hacer la entrega. Fecha límite: Martes 16 de Junio.

La entrega, el control y el seguimiento continuo de todos estos entregables se centralizará y gestionará de manera transparente a través de la plataforma GitHub bajo las condiciones operativas que se detallan a continuación.

## **Estructura del Repositorio en GitHub**

El repositorio público de GitHub debe llamarse estrictamente `TPI-Funcional-2026-Grupo[Numero]` y seguir esta **arquitectura exacta de carpetas**. El incumplimiento de esta estructura restará puntos de forma directa.

| PlaintextTPI-Funcional-2026-Grupo\[Numero\]/├── lisp/│   ├── core.lisp             \<-- Código de los requerimientos 1 al 6 en Common Lisp (con comentarios de tipo)│   └── config.json           \<-- Archivo de configuración (si eligieron cl-json en Fase 2\)├── comparativa/│   └── solucion.\[ext\]        \<-- Código en el lenguaje asignado (con comentarios de tipo según su sintaxis)├── docs/│   ├── INFORME.pdf           \<-- Informe conceptual con las respuestas analíticas│   └── HONOR.md              \<-- Declaración obligatoria de Código de Honor└── README.md                 \<-- Portada del repositorio y enlaces a los videos |
| :---- |

### **Reglas de Oro de GitHub**

* **Trazabilidad de Commits:** Se evaluará el proceso. Repositorios con un único *commit* masivo del estilo "Proyecto terminado" o "Subiendo todo" **serán reprobados automáticamente** por sospecha de plagio o automatización externa. Los commits deben ser incrementales y descriptivos.  
* **Contribución Equitativa:** Cada integrante del grupo debe realizar aportes de código o documentación desde su propia cuenta de GitHub. Miembro del grupo que registre 0 commits en el historial de contribuciones tendrá una nota final de 0 (cero) en el trabajo práctico.

---

## **📜 Código de Honor y Declaración de Autoría**

*(Deberá completarse individualmente por cada integrante dentro del archivo `docs/HONOR.md`)*

Como parte de nuestra formación profesional y ética académica, cada estudiante debe declarar de forma transparente el alcance y uso de herramientas de Inteligencia Artificial (ChatGPT, Claude, Copilot, etc.) en este proyecto. **El uso de la IA para asistencia en sintaxis o detección de errores no está penalizado, pero la falta de transparencia o el plagio de lógica total sí.**

Marque con una **X** la opción que mejor describa su situación para cada componente del trabajo:

### **👤 Integrante 1: \[Nombre y Apellido\] \- Usuario GitHub: \[Usuario\]**

#### **1\. Código en Common Lisp (Fase 1 y 2\)**

* \[ \] **Desarrollo 100% Humano:** El código fue diseñado, escrito y depurado puramente por mí/el grupo sin intervención de IA.  
* \[ \] **Asistencia de IA (Co-piloto):** Utilicé IA como un tutor o documentación dinámica (búsqueda de errores sintácticos, explicación de funciones primitivas), pero la lógica y clasificación del semáforo fue estructurada por el grupo.  
* \[ \] **Generación Completa por IA:** Un modelo de IA generó bloques enteros o la totalidad de las funciones principales a partir del enunciado base.

#### **2\. Código del Lenguaje Asignado (Fase 3\)**

* \[ \] **Desarrollo 100% Humano:** Aprendí la sintaxis básica, clasifiqué sus componentes y escribí la solución de forma autónoma.  
* \[ \] **Asistencia de IA:** Utilicé la IA para traducir la sintaxis de Lisp al nuevo lenguaje o entender los errores del compilador ajeno.  
* \[ \] **Generación Completa por IA:** La IA realizó la traducción automática de las funciones `transicion` y `timer`.

#### **3\. Redacción del Informe y Respuestas Teóricas**

* \[ \] **Autoría Propia:** Las explicaciones de los conceptos de los lenguajes y el análisis comparativo reflejan nuestras propias conclusiones conceptuales.  
* \[ \] **Redacción Asistida / Generada:** La IA redactó o fundamentó las respuestas teóricas basadas en prompts conceptuales proporcionados por el grupo.  
* \[ \] Generación completa por IA

**Declaración Jurada:** Al subir este archivo al repositorio, declaro bajo compromiso de honor que las marcas anteriores reflejan fielmente mi participación y la naturaleza del desarrollo de este trabajo práctico. Entiendo que la cátedra cruzará esta declaración con la correcta clasificación en comentarios del código y con mi desempeño en la defensa oral/video.

---

## **⏱️ Cronograma y Evaluación**

### **Cronograma de Entregas**

1. **Semana 1 (Post 1° Parcial):** Asignación aleatoria del segundo lenguaje y creación del repositorio de GitHub.  
2. **Semana 2 y 3:** Desarrollo en clase del núcleo en Lisp e investigación autónoma del ecosistema con sus respectivas documentaciones en código.  
3. **Semana 4):** Entrega del repositorio completo (Código clasificado, Informe, Código de Honor) y exposición en el Auditorio / Envío del enlace de YouTube.  
   1. MARTES 16 de Junio  
   2. Defensa: Lunes 22 o Miércoles 24\.

### **Criterios de Evaluación**

* **Rigurosidad Conceptual y Metacognición (40%):** Utilización y clasificación correcta de los términos técnicos específicos del paradigma funcional en los encabezados de comentarios y respuestas analíticas.  
* **Trazabilidad e Integridad (30%):** Consistencia en el historial de commits de GitHub, aportes equitativos y honestidad en el Código de Honor.  
* **Capacidad de síntesis y Relación (30%):** Claridad en las respuestas del informe escrito y solidez en la defensa del flujo de datos en el video/exposición en vivo.

