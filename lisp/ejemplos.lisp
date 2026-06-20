;;==============================================================
;; ARCHIVO: ejemplos.lisp
;; Requerimiento 7: Aseguramiento de la Calidad
;;
;; Cada requerimiento cuenta con:
;;   - Ejemplos de funcionamiento normal
;;   - Ejemplos de caminos alternativos (si los hubiere)
;;   - Ejemplos que generan errores
;;
;; INSTRUCCIONES: Cargar primero core.lisp en SBCL
;;   (load "core.lisp")
;; Luego cargar la configuracion y ejecutar los ejemplos:
;;   (load "ejemplos.lisp")
;;==============================================================

;; ---- Carga de la configuracion desde el archivo JSON --------
(defvar config (cargar-config "config.json"))

(format t "~%=============================================~%")
(format t "  EJEMPLOS DE USO - SISTEMA DE SEMAFOROS~%")
(format t "  Configuracion cargada: ~A~%" config)
(format t "=============================================~%")


;;==============================================================
;; REQUERIMIENTO 1: transicion
;; Funcion: (transicion color-actual cambiar-a)
;;==============================================================

(format t "~%--- REQUERIMIENTO 1: transicion ---~%~%")

;; --- Funcionamiento normal ---
;; Transicion de rojo a verde
(format t "Ejemplo 1.1 - Normal: (transicion 'en-rojo 'verde)~%")
(format t "  Resultado: ~A~%" (transicion 'en-rojo 'verde))
;; Esperado: (EN-ROJO CAMBIAR_A_VERDE)

;; Transicion de verde a amarillo
(format t "Ejemplo 1.2 - Normal: (transicion 'en-verde 'amarillo)~%")
(format t "  Resultado: ~A~%" (transicion 'en-verde 'amarillo))
;; Esperado: (EN-VERDE CAMBIAR_A_AMARILLO)

;; Transicion de amarillo a rojo
(format t "Ejemplo 1.3 - Normal: (transicion 'en-amarillo 'rojo)~%")
(format t "  Resultado: ~A~%" (transicion 'en-amarillo 'rojo))
;; Esperado: (EN-AMARILLO CAMBIAR_A_ROJO)

;; --- Caminos alternativos ---
;; Transicion con color destino invalido -> accion-por-defecto
(format t "Ejemplo 1.4 - Alternativo: (transicion 'en-rojo 'azul)~%")
(format t "  Resultado: ~A~%" (transicion 'en-rojo 'azul))
;; Esperado: (EN-ROJO ACCION-POR-DEFECTO)

;; Transicion con otro color invalido
(format t "Ejemplo 1.5 - Alternativo: (transicion 'en-verde 'violeta)~%")
(format t "  Resultado: ~A~%" (transicion 'en-verde 'violeta))
;; Esperado: (EN-VERDE ACCION-POR-DEFECTO)

;; Estado actual no estandar pero destino valido
(format t "Ejemplo 1.6 - Alternativo: (transicion 'apagado 'rojo)~%")
(format t "  Resultado: ~A~%" (transicion 'apagado 'rojo))
;; Esperado: (APAGADO CAMBIAR_A_ROJO)

;; --- Casos de error ---
;; Sin argumentos: genera error por falta de parametros
(format t "Ejemplo 1.7 - Error: (transicion) -> sin argumentos~%")
(format t "  Al ejecutar (transicion) se genera:~%")
(format t "  ERROR: invalid number of arguments: 0~%~%")


;;==============================================================
;; REQUERIMIENTO 2: timer (timer)
;; Funcion: (timer timestamp config)
;; Ciclo con config por defecto: Rojo=93s, Verde=123s, Amarillo=9s
;; Total ciclo = 225s
;; Rango rojo:     0 a 92
;; Rango verde:   93 a 215
;; Rango amarillo: 216 a 224
;;==============================================================

(format t "~%--- REQUERIMIENTO 2: timer (timer) ---~%~%")

;; --- Funcionamiento normal ---
;; Timestamp 0 -> inicio del ciclo -> rojo
(format t "Ejemplo 2.1 - Normal: (timer 0 config)~%")
(format t "  Resultado: ~A~%" (timer 0 config))
;; Esperado: ROJO

;; Timestamp 46 -> mitad del rojo
(format t "Ejemplo 2.2 - Normal: (timer 46 config)~%")
(format t "  Resultado: ~A~%" (timer 46 config))
;; Esperado: ROJO

;; Timestamp 93 -> comienza verde
(format t "Ejemplo 2.3 - Normal: (timer 93 config)~%")
(format t "  Resultado: ~A~%" (timer 93 config))
;; Esperado: VERDE

;; Timestamp 150 -> mitad del verde
(format t "Ejemplo 2.4 - Normal: (timer 150 config)~%")
(format t "  Resultado: ~A~%" (timer 150 config))
;; Esperado: VERDE

;; Timestamp 216 -> comienza amarillo
(format t "Ejemplo 2.5 - Normal: (timer 216 config)~%")
(format t "  Resultado: ~A~%" (timer 216 config))
;; Esperado: AMARILLO

;; --- Caminos alternativos ---
;; Timestamp 225 -> nuevo ciclo, vuelve a rojo (225 mod 225 = 0)
(format t "Ejemplo 2.6 - Alternativo: (timer 225 config)~%")
(format t "  Resultado: ~A~%" (timer 225 config))
;; Esperado: ROJO (nuevo ciclo)

;; Timestamp grande (1000000) -> funciona con mod
(format t "Ejemplo 2.7 - Alternativo: (timer 1000000 config)~%")
(format t "  Resultado: ~A~%" (timer 1000000 config))
;; 1000000 mod 225 = 100 -> VERDE

;; Timestamp 92 -> ultimo segundo de rojo
(format t "Ejemplo 2.8 - Alternativo: (timer 92 config)~%")
(format t "  Resultado: ~A~%" (timer 92 config))
;; Esperado: ROJO (limite del rango)

;; Timestamp 215 -> ultimo segundo de verde
(format t "Ejemplo 2.9 - Alternativo: (timer 215 config)~%")
(format t "  Resultado: ~A~%" (timer 215 config))
;; Esperado: VERDE (limite del rango)

;; Timestamp 224 -> ultimo segundo de amarillo
(format t "Ejemplo 2.10 - Alternativo: (timer 224 config)~%")
(format t "  Resultado: ~A~%" (timer 224 config))
;; Esperado: AMARILLO (ultimo segundo antes de reiniciar)

;; --- Casos de error ---
;; Timestamp negativo: mod con negativos produce resultado dependiente de la implementacion
(format t "Ejemplo 2.11 - Error: (timer -1 config)~%")
(format t "  Resultado: ~A~%" (timer -1 config))
;; Resultado depende del comportamiento de MOD con negativos en SBCL

;; Sin config: genera error de tipo
(format t "Ejemplo 2.12 - Error: (timer 100 nil) -> config vacia~%")
(format t "  Al ejecutar (timer 100 nil) se genera:~%")
(format t "  ERROR: The value NIL is not of type NUMBER~%~%")


;;==============================================================
;; REQUERIMIENTO 3: mostrar-cambio (auditoria)
;; Funcion: (mostrar-cambio tiempo colorAnterior colorNuevo)
;;==============================================================

(format t "~%--- REQUERIMIENTO 3: mostrar-cambio (auditoria) ---~%~%")

;; --- Funcionamiento normal ---
(format t "Ejemplo 3.1 - Normal: (mostrar-cambio 1718574062 'rojo 'verde)~%")
(format t "  Resultado: ")
(mostrar-cambio 1718574062 'rojo 'verde)
;; Esperado: Tiempo 1718574062: la luz ha cambiado de ROJO a VERDE

(format t "Ejemplo 3.2 - Normal: (mostrar-cambio 1718574152 'verde 'amarillo)~%")
(format t "  Resultado: ")
(mostrar-cambio 1718574152 'verde 'amarillo)
;; Esperado: Tiempo 1718574152: la luz ha cambiado de VERDE a AMARILLO

(format t "Ejemplo 3.3 - Normal: (mostrar-cambio 1718574158 'amarillo 'rojo)~%")
(format t "  Resultado: ")
(mostrar-cambio 1718574158 'amarillo 'rojo)
;; Esperado: Tiempo 1718574158: la luz ha cambiado de AMARILLO a ROJO

;; --- Caminos alternativos ---
;; Uso combinado con timer para registrar un cambio real
(format t "Ejemplo 3.4 - Alternativo: Combinar con timer~%")
(let ((color-en-92 (timer 92 config))
      (color-en-93 (timer 93 config)))
  (format t "  Color en t=92: ~A | Color en t=93: ~A~%" color-en-92 color-en-93)
  (format t "  Registro: ")
  (mostrar-cambio 93 color-en-92 color-en-93))
;; Muestra el cambio detectado en el limite rojo->verde

;; --- Casos de error ---
;; Sin argumentos: genera error por falta de parametros
(format t "Ejemplo 3.5 - Error: (mostrar-cambio) -> sin argumentos~%")
(format t "  Al ejecutar (mostrar-cambio) se genera:~%")
(format t "  ERROR: invalid number of arguments: 0~%~%")


;;==============================================================
;; REQUERIMIENTO 4a: duracion-ciclo
;; Funcion: (duracion-ciclo config)
;;==============================================================

(format t "~%--- REQUERIMIENTO 4a: duracion-ciclo ---~%~%")

;; --- Funcionamiento normal ---
;; Con la config por defecto: 93 + 9 + 123 = 225
(format t "Ejemplo 4a.1 - Normal: (duracion-ciclo config)~%")
(format t "  Resultado: ~A segundos~%" (duracion-ciclo config))
;; Esperado: 225

;; --- Caminos alternativos ---
;; Con una configuracion personalizada (tiempos cortos)
(format t "Ejemplo 4a.2 - Alternativo: Config personalizada (10, 3, 15)~%")
(let ((config-corta '((:rojo . 10) (:amarillo . 3) (:verde . 15))))
  (format t "  (duracion-ciclo config-corta) = ~A segundos~%"
          (duracion-ciclo config-corta)))
;; Esperado: 28

;; Con una configuracion de tiempos largos
(format t "Ejemplo 4a.3 - Alternativo: Config personalizada (60, 5, 80)~%")
(let ((config-larga '((:rojo . 60) (:amarillo . 5) (:verde . 80))))
  (format t "  (duracion-ciclo config-larga) = ~A segundos~%"
          (duracion-ciclo config-larga)))
;; Esperado: 145

;; --- Casos de error ---
;; Config vacia: genera error de tipo al intentar sumar nil
(format t "Ejemplo 4a.4 - Error: (duracion-ciclo nil) -> config vacia~%")
(format t "  Al ejecutar (duracion-ciclo nil) se genera:~%")
(format t "  ERROR: The value NIL is not of type NUMBER~%~%")


;;==============================================================
;; REQUERIMIENTO 4b: recomendacion-ciclo
;; Funcion: (recomendacion-ciclo duracion)
;; Rango optimo: 35 a 150 segundos
;;==============================================================

(format t "~%--- REQUERIMIENTO 4b: recomendacion-ciclo ---~%~%")

;; --- Funcionamiento normal ---
;; Duracion dentro del rango (config por defecto = 225 -> fuera de rango)
(format t "Ejemplo 4b.1 - Normal: (recomendacion-ciclo (duracion-ciclo config))~%")
(format t "  Duracion actual: ~A~%" (duracion-ciclo config))
(format t "  Resultado: ~A~%" (recomendacion-ciclo (duracion-ciclo config)))
;; Esperado: "Ciclo demasiado largo" (225 > 150)

;; Duracion dentro del rango optimo
(format t "Ejemplo 4b.2 - Normal: (recomendacion-ciclo 100)~%")
(format t "  Resultado: ~A~%" (recomendacion-ciclo 100))
;; Esperado: "Ciclo dentro del rango recomendado"

;; --- Caminos alternativos ---
;; Justo en el limite inferior (35)
(format t "Ejemplo 4b.3 - Alternativo: (recomendacion-ciclo 35)~%")
(format t "  Resultado: ~A~%" (recomendacion-ciclo 35))
;; Esperado: "Ciclo dentro del rango recomendado"

;; Justo en el limite superior (150)
(format t "Ejemplo 4b.4 - Alternativo: (recomendacion-ciclo 150)~%")
(format t "  Resultado: ~A~%" (recomendacion-ciclo 150))
;; Esperado: "Ciclo dentro del rango recomendado"

;; Debajo del limite (demasiado corto)
(format t "Ejemplo 4b.5 - Alternativo: (recomendacion-ciclo 20)~%")
(format t "  Resultado: ~A~%" (recomendacion-ciclo 20))
;; Esperado: "Ciclo demasiado corto"

;; Encima del limite (demasiado largo)
(format t "Ejemplo 4b.6 - Alternativo: (recomendacion-ciclo 200)~%")
(format t "  Resultado: ~A~%" (recomendacion-ciclo 200))
;; Esperado: "Ciclo demasiado largo"

;; --- Casos de error ---
;; Con un string en vez de numero
(format t "Ejemplo 4b.7 - Error: (recomendacion-ciclo \"abc\") -> tipo invalido~%")
(format t "  Al ejecutar (recomendacion-ciclo \"abc\") se genera:~%")
(format t "  ERROR: The value \"abc\" is not of type REAL~%~%")


;;==============================================================
;; REQUERIMIENTO 5: ciclos-por-tiempo
;; Funcion: (ciclos-por-tiempo minutos config)
;; Con config por defecto: ciclo = 225s
;;==============================================================

(format t "~%--- REQUERIMIENTO 5: ciclos-por-tiempo ---~%~%")

;; --- Funcionamiento normal ---
;; 15 minutos = 900 segundos / 225 = 4 ciclos completos
(format t "Ejemplo 5.1 - Normal: (ciclos-por-tiempo 15 config)~%")
(format t "  Resultado: ~A ciclos~%" (ciclos-por-tiempo 15 config))
;; Esperado: 4

;; 60 minutos (1 hora) = 3600 / 225 = 16 ciclos completos
(format t "Ejemplo 5.2 - Normal: (ciclos-por-tiempo 60 config)~%")
(format t "  Resultado: ~A ciclos~%" (ciclos-por-tiempo 60 config))
;; Esperado: 16

;; --- Caminos alternativos ---
;; 1 minuto = 60 / 225 = 0 ciclos completos
(format t "Ejemplo 5.3 - Alternativo: (ciclos-por-tiempo 1 config)~%")
(format t "  Resultado: ~A ciclos~%" (ciclos-por-tiempo 1 config))
;; Esperado: 0 (no alcanza para completar un ciclo)

;; 0 minutos
(format t "Ejemplo 5.4 - Alternativo: (ciclos-por-tiempo 0 config)~%")
(format t "  Resultado: ~A ciclos~%" (ciclos-por-tiempo 0 config))
;; Esperado: 0

;; 480 minutos (8 horas, jornada laboral)
(format t "Ejemplo 5.5 - Alternativo: (ciclos-por-tiempo 480 config)~%")
(format t "  Resultado: ~A ciclos~%" (ciclos-por-tiempo 480 config))
;; Esperado: 128

;; Con config personalizada de ciclo corto (28s)
(format t "Ejemplo 5.6 - Alternativo: Config corta, 15 minutos~%")
(let ((config-corta '((:rojo . 10) (:amarillo . 3) (:verde . 15))))
  (format t "  (ciclos-por-tiempo 15 config-corta) = ~A ciclos~%"
          (ciclos-por-tiempo 15 config-corta)))
;; Esperado: 32 (900 / 28)

;; --- Casos de error ---
;; Config vacia
(format t "Ejemplo 5.7 - Error: (ciclos-por-tiempo 15 nil) -> config vacia~%")
(format t "  Al ejecutar (ciclos-por-tiempo 15 nil) se genera:~%")
(format t "  ERROR: The value NIL is not of type NUMBER~%~%")


;;==============================================================
;; REQUERIMIENTO 6: distribucion-hora
;; Funcion: (distribucion-hora config)
;;==============================================================

(format t "~%--- REQUERIMIENTO 6: distribucion-hora ---~%~%")

;; --- Funcionamiento normal ---
;; Con config por defecto: rojo=93, amarillo=9, verde=123, total=225
;; Rojo:     93/225 * 100 = 41.33%
;; Amarillo:  9/225 * 100 =  4.00%
;; Verde:   123/225 * 100 = 54.67%
(format t "Ejemplo 6.1 - Normal: (distribucion-hora config)~%")
(format t "  Resultado: ~A~%" (distribucion-hora config))
;; Esperado: ((ROJO 41.333332) (AMARILLO 4.0) (VERDE 54.666668))

;; --- Caminos alternativos ---
;; Config con tiempos iguales (distribucion uniforme)
(format t "Ejemplo 6.2 - Alternativo: Config tiempos iguales (60, 60, 60)~%")
(let ((config-igual '((:rojo . 60) (:amarillo . 60) (:verde . 60))))
  (format t "  (distribucion-hora config-igual) = ~A~%"
          (distribucion-hora config-igual)))
;; Esperado: 33.33% para cada color

;; Config con un color dominante
(format t "Ejemplo 6.3 - Alternativo: Config verde dominante (30, 5, 180)~%")
(let ((config-verde '((:rojo . 30) (:amarillo . 5) (:verde . 180))))
  (format t "  (distribucion-hora config-verde) = ~A~%"
          (distribucion-hora config-verde)))
;; Esperado: Rojo ~13.95%, Amarillo ~2.33%, Verde ~83.72%

;; --- Casos de error ---
;; Config vacia
(format t "Ejemplo 6.4 - Error: (distribucion-hora nil) -> config vacia~%")
(format t "  Al ejecutar (distribucion-hora nil) se genera:~%")
(format t "  ERROR: The value NIL is not of type NUMBER~%~%")


;;==============================================================
;; EJEMPLO INTEGRADOR: Simulacion de un ciclo completo
;; Combina transicion, timer y mostrar-cambio
;;==============================================================

(format t "~%--- EJEMPLO INTEGRADOR ---~%~%")

(format t "Simulacion de cambios en un ciclo completo (225 segundos):~%~%")

;; Uso de mapcar (funcion de orden superior) en lugar de dolist
(mapcar (lambda (t-actual)
          (format t "  t=~3D -> ~A~%" t-actual (timer t-actual config)))
        '(0 92 93 215 216 224 225))

(format t "~%Registro de transiciones detectadas:~%~%")
;; Transiciones explicitas sin bucles ni variables mutables
(mostrar-cambio 0 'inicio (timer 0 config))
(mostrar-cambio 93 (timer 92 config) (timer 93 config))
(mostrar-cambio 216 (timer 215 config) (timer 216 config))
(mostrar-cambio 225 (timer 224 config) (timer 225 config))

(format t "~%Resumen del sistema:~%")
(format t "  Duracion del ciclo: ~A segundos~%" (duracion-ciclo config))
(format t "  Recomendacion: ~A~%" (recomendacion-ciclo (duracion-ciclo config)))
(format t "  Ciclos en 15 min: ~A~%" (ciclos-por-tiempo 15 config))
(format t "  Ciclos en 1 hora: ~A~%" (ciclos-por-tiempo 60 config))
(format t "  Distribucion: ~A~%" (distribucion-hora config))

(format t "~%=============================================~%")
(format t "  FIN DE LOS EJEMPLOS~%")
(format t "=============================================~%")
