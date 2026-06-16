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
(defvar *config* (cargar-config "config.json"))

(format t "~%=============================================~%")
(format t "  EJEMPLOS DE USO - SISTEMA DE SEMAFOROS~%")
(format t "  Configuracion cargada: ~A~%" *config*)
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
;; REQUERIMIENTO 2: semaforo-en (timer)
;; Funcion: (semaforo-en timestamp config)
;; Ciclo con config por defecto: Rojo=90s, Verde=120s, Amarillo=6s
;; Total ciclo = 216s
;; Rango rojo:     0 a 89
;; Rango verde:   90 a 209
;; Rango amarillo: 210 a 215
;;==============================================================

(format t "~%--- REQUERIMIENTO 2: semaforo-en (timer) ---~%~%")

;; --- Funcionamiento normal ---
;; Timestamp 0 -> inicio del ciclo -> rojo
(format t "Ejemplo 2.1 - Normal: (semaforo-en 0 *config*)~%")
(format t "  Resultado: ~A~%" (semaforo-en 0 *config*))
;; Esperado: ROJO

;; Timestamp 45 -> mitad del rojo
(format t "Ejemplo 2.2 - Normal: (semaforo-en 45 *config*)~%")
(format t "  Resultado: ~A~%" (semaforo-en 45 *config*))
;; Esperado: ROJO

;; Timestamp 90 -> comienza verde
(format t "Ejemplo 2.3 - Normal: (semaforo-en 90 *config*)~%")
(format t "  Resultado: ~A~%" (semaforo-en 90 *config*))
;; Esperado: VERDE

;; Timestamp 150 -> mitad del verde
(format t "Ejemplo 2.4 - Normal: (semaforo-en 150 *config*)~%")
(format t "  Resultado: ~A~%" (semaforo-en 150 *config*))
;; Esperado: VERDE

;; Timestamp 210 -> comienza amarillo
(format t "Ejemplo 2.5 - Normal: (semaforo-en 210 *config*)~%")
(format t "  Resultado: ~A~%" (semaforo-en 210 *config*))
;; Esperado: AMARILLO

;; --- Caminos alternativos ---
;; Timestamp 216 -> nuevo ciclo, vuelve a rojo (216 mod 216 = 0)
(format t "Ejemplo 2.6 - Alternativo: (semaforo-en 216 *config*)~%")
(format t "  Resultado: ~A~%" (semaforo-en 216 *config*))
;; Esperado: ROJO (nuevo ciclo)

;; Timestamp grande (1000000) -> funciona con mod
(format t "Ejemplo 2.7 - Alternativo: (semaforo-en 1000000 *config*)~%")
(format t "  Resultado: ~A~%" (semaforo-en 1000000 *config*))
;; 1000000 mod 216 = 64 -> ROJO

;; Timestamp 89 -> ultimo segundo de rojo
(format t "Ejemplo 2.8 - Alternativo: (semaforo-en 89 *config*)~%")
(format t "  Resultado: ~A~%" (semaforo-en 89 *config*))
;; Esperado: ROJO (limite del rango)

;; Timestamp 209 -> ultimo segundo de verde
(format t "Ejemplo 2.9 - Alternativo: (semaforo-en 209 *config*)~%")
(format t "  Resultado: ~A~%" (semaforo-en 209 *config*))
;; Esperado: VERDE (limite del rango)

;; Timestamp 215 -> ultimo segundo de amarillo
(format t "Ejemplo 2.10 - Alternativo: (semaforo-en 215 *config*)~%")
(format t "  Resultado: ~A~%" (semaforo-en 215 *config*))
;; Esperado: AMARILLO (ultimo segundo antes de reiniciar)

;; --- Casos de error ---
;; Timestamp negativo: mod con negativos produce resultado dependiente de la implementacion
(format t "Ejemplo 2.11 - Error: (semaforo-en -1 *config*)~%")
(format t "  Resultado: ~A~%" (semaforo-en -1 *config*))
;; Resultado depende del comportamiento de MOD con negativos en SBCL

;; Sin config: genera error de tipo
(format t "Ejemplo 2.12 - Error: (semaforo-en 100 nil) -> config vacia~%")
(format t "  Al ejecutar (semaforo-en 100 nil) se genera:~%")
(format t "  ERROR: The value NIL is not of type NUMBER~%~%")


;;==============================================================
;; REQUERIMIENTO 3: mostrarCambio (auditoria)
;; Funcion: (mostrarCambio tiempo colorAnterior colorNuevo)
;;==============================================================

(format t "~%--- REQUERIMIENTO 3: mostrarCambio (auditoria) ---~%~%")

;; --- Funcionamiento normal ---
(format t "Ejemplo 3.1 - Normal: (mostrarCambio 1718574062 'rojo 'verde)~%")
(format t "  Resultado: ")
(mostrarCambio 1718574062 'rojo 'verde)
;; Esperado: Tiempo 1718574062: la luz ha cambiado de ROJO a VERDE

(format t "Ejemplo 3.2 - Normal: (mostrarCambio 1718574152 'verde 'amarillo)~%")
(format t "  Resultado: ")
(mostrarCambio 1718574152 'verde 'amarillo)
;; Esperado: Tiempo 1718574152: la luz ha cambiado de VERDE a AMARILLO

(format t "Ejemplo 3.3 - Normal: (mostrarCambio 1718574158 'amarillo 'rojo)~%")
(format t "  Resultado: ")
(mostrarCambio 1718574158 'amarillo 'rojo)
;; Esperado: Tiempo 1718574158: la luz ha cambiado de AMARILLO a ROJO

;; --- Caminos alternativos ---
;; Uso combinado con semaforo-en para registrar un cambio real
(format t "Ejemplo 3.4 - Alternativo: Combinar con semaforo-en~%")
(let ((color-en-89 (semaforo-en 89 *config*))
      (color-en-90 (semaforo-en 90 *config*)))
  (format t "  Color en t=89: ~A | Color en t=90: ~A~%" color-en-89 color-en-90)
  (format t "  Registro: ")
  (mostrarCambio 90 color-en-89 color-en-90))
;; Muestra el cambio detectado en el limite rojo->verde

;; --- Casos de error ---
;; Sin argumentos: genera error por falta de parametros
(format t "Ejemplo 3.5 - Error: (mostrarCambio) -> sin argumentos~%")
(format t "  Al ejecutar (mostrarCambio) se genera:~%")
(format t "  ERROR: invalid number of arguments: 0~%~%")


;;==============================================================
;; REQUERIMIENTO 4a: duracionCiclo
;; Funcion: (duracionCiclo config)
;;==============================================================

(format t "~%--- REQUERIMIENTO 4a: duracionCiclo ---~%~%")

;; --- Funcionamiento normal ---
;; Con la config por defecto: 90 + 6 + 120 = 216
(format t "Ejemplo 4a.1 - Normal: (duracionCiclo *config*)~%")
(format t "  Resultado: ~A segundos~%" (duracionCiclo *config*))
;; Esperado: 216

;; --- Caminos alternativos ---
;; Con una configuracion personalizada (tiempos cortos)
(format t "Ejemplo 4a.2 - Alternativo: Config personalizada (10, 3, 15)~%")
(let ((config-corta '((:rojo . 10) (:amarillo . 3) (:verde . 15))))
  (format t "  (duracionCiclo config-corta) = ~A segundos~%"
          (duracionCiclo config-corta)))
;; Esperado: 28

;; Con una configuracion de tiempos largos
(format t "Ejemplo 4a.3 - Alternativo: Config personalizada (60, 5, 80)~%")
(let ((config-larga '((:rojo . 60) (:amarillo . 5) (:verde . 80))))
  (format t "  (duracionCiclo config-larga) = ~A segundos~%"
          (duracionCiclo config-larga)))
;; Esperado: 145

;; --- Casos de error ---
;; Config vacia: genera error de tipo al intentar sumar nil
(format t "Ejemplo 4a.4 - Error: (duracionCiclo nil) -> config vacia~%")
(format t "  Al ejecutar (duracionCiclo nil) se genera:~%")
(format t "  ERROR: The value NIL is not of type NUMBER~%~%")


;;==============================================================
;; REQUERIMIENTO 4b: recomendacionCiclo
;; Funcion: (recomendacionCiclo duracion)
;; Rango optimo: 35 a 150 segundos
;;==============================================================

(format t "~%--- REQUERIMIENTO 4b: recomendacionCiclo ---~%~%")

;; --- Funcionamiento normal ---
;; Duracion dentro del rango (config por defecto = 216 -> fuera de rango)
(format t "Ejemplo 4b.1 - Normal: (recomendacionCiclo (duracionCiclo *config*))~%")
(format t "  Duracion actual: ~A~%" (duracionCiclo *config*))
(format t "  Resultado: ~A~%" (recomendacionCiclo (duracionCiclo *config*)))
;; Esperado: "Ciclo demasiado largo" (216 > 150)

;; Duracion dentro del rango optimo
(format t "Ejemplo 4b.2 - Normal: (recomendacionCiclo 100)~%")
(format t "  Resultado: ~A~%" (recomendacionCiclo 100))
;; Esperado: "Ciclo dentro del rango recomendado"

;; --- Caminos alternativos ---
;; Justo en el limite inferior (35)
(format t "Ejemplo 4b.3 - Alternativo: (recomendacionCiclo 35)~%")
(format t "  Resultado: ~A~%" (recomendacionCiclo 35))
;; Esperado: "Ciclo dentro del rango recomendado"

;; Justo en el limite superior (150)
(format t "Ejemplo 4b.4 - Alternativo: (recomendacionCiclo 150)~%")
(format t "  Resultado: ~A~%" (recomendacionCiclo 150))
;; Esperado: "Ciclo dentro del rango recomendado"

;; Debajo del limite (demasiado corto)
(format t "Ejemplo 4b.5 - Alternativo: (recomendacionCiclo 20)~%")
(format t "  Resultado: ~A~%" (recomendacionCiclo 20))
;; Esperado: "Ciclo demasiado corto"

;; Encima del limite (demasiado largo)
(format t "Ejemplo 4b.6 - Alternativo: (recomendacionCiclo 200)~%")
(format t "  Resultado: ~A~%" (recomendacionCiclo 200))
;; Esperado: "Ciclo demasiado largo"

;; --- Casos de error ---
;; Con un string en vez de numero
(format t "Ejemplo 4b.7 - Error: (recomendacionCiclo \"abc\") -> tipo invalido~%")
(format t "  Al ejecutar (recomendacionCiclo \"abc\") se genera:~%")
(format t "  ERROR: The value \"abc\" is not of type REAL~%~%")


;;==============================================================
;; REQUERIMIENTO 5: ciclosPorTiempo
;; Funcion: (ciclosPorTiempo minutos config)
;; Con config por defecto: ciclo = 216s
;;==============================================================

(format t "~%--- REQUERIMIENTO 5: ciclosPorTiempo ---~%~%")

;; --- Funcionamiento normal ---
;; 15 minutos = 900 segundos / 216 = 4 ciclos completos
(format t "Ejemplo 5.1 - Normal: (ciclosPorTiempo 15 *config*)~%")
(format t "  Resultado: ~A ciclos~%" (ciclosPorTiempo 15 *config*))
;; Esperado: 4

;; 60 minutos (1 hora) = 3600 / 216 = 16 ciclos completos
(format t "Ejemplo 5.2 - Normal: (ciclosPorTiempo 60 *config*)~%")
(format t "  Resultado: ~A ciclos~%" (ciclosPorTiempo 60 *config*))
;; Esperado: 16

;; --- Caminos alternativos ---
;; 1 minuto = 60 / 216 = 0 ciclos completos
(format t "Ejemplo 5.3 - Alternativo: (ciclosPorTiempo 1 *config*)~%")
(format t "  Resultado: ~A ciclos~%" (ciclosPorTiempo 1 *config*))
;; Esperado: 0 (no alcanza para completar un ciclo)

;; 0 minutos
(format t "Ejemplo 5.4 - Alternativo: (ciclosPorTiempo 0 *config*)~%")
(format t "  Resultado: ~A ciclos~%" (ciclosPorTiempo 0 *config*))
;; Esperado: 0

;; 480 minutos (8 horas, jornada laboral)
(format t "Ejemplo 5.5 - Alternativo: (ciclosPorTiempo 480 *config*)~%")
(format t "  Resultado: ~A ciclos~%" (ciclosPorTiempo 480 *config*))
;; Esperado: 133

;; Con config personalizada de ciclo corto (28s)
(format t "Ejemplo 5.6 - Alternativo: Config corta, 15 minutos~%")
(let ((config-corta '((:rojo . 10) (:amarillo . 3) (:verde . 15))))
  (format t "  (ciclosPorTiempo 15 config-corta) = ~A ciclos~%"
          (ciclosPorTiempo 15 config-corta)))
;; Esperado: 32 (900 / 28)

;; --- Casos de error ---
;; Config vacia
(format t "Ejemplo 5.7 - Error: (ciclosPorTiempo 15 nil) -> config vacia~%")
(format t "  Al ejecutar (ciclosPorTiempo 15 nil) se genera:~%")
(format t "  ERROR: The value NIL is not of type NUMBER~%~%")


;;==============================================================
;; REQUERIMIENTO 6: distribucionHora
;; Funcion: (distribucionHora config)
;;==============================================================

(format t "~%--- REQUERIMIENTO 6: distribucionHora ---~%~%")

;; --- Funcionamiento normal ---
;; Con config por defecto: rojo=90, amarillo=6, verde=120, total=216
;; Rojo:     90/216 * 100 = 41.67%
;; Amarillo:  6/216 * 100 =  2.78%
;; Verde:   120/216 * 100 = 55.56%
(format t "Ejemplo 6.1 - Normal: (distribucionHora *config*)~%")
(format t "  Resultado: ~A~%" (distribucionHora *config*))
;; Esperado: ((ROJO 41.666668) (AMARILLO 2.7777779) (VERDE 55.555557))

;; --- Caminos alternativos ---
;; Config con tiempos iguales (distribucion uniforme)
(format t "Ejemplo 6.2 - Alternativo: Config tiempos iguales (60, 60, 60)~%")
(let ((config-igual '((:rojo . 60) (:amarillo . 60) (:verde . 60))))
  (format t "  (distribucionHora config-igual) = ~A~%"
          (distribucionHora config-igual)))
;; Esperado: 33.33% para cada color

;; Config con un color dominante
(format t "Ejemplo 6.3 - Alternativo: Config verde dominante (30, 5, 180)~%")
(let ((config-verde '((:rojo . 30) (:amarillo . 5) (:verde . 180))))
  (format t "  (distribucionHora config-verde) = ~A~%"
          (distribucionHora config-verde)))
;; Esperado: Rojo ~13.95%, Amarillo ~2.33%, Verde ~83.72%

;; --- Casos de error ---
;; Config vacia
(format t "Ejemplo 6.4 - Error: (distribucionHora nil) -> config vacia~%")
(format t "  Al ejecutar (distribucionHora nil) se genera:~%")
(format t "  ERROR: The value NIL is not of type NUMBER~%~%")


;;==============================================================
;; EJEMPLO INTEGRADOR: Simulacion de un ciclo completo
;; Combina transicion, semaforo-en y mostrarCambio
;;==============================================================

(format t "~%--- EJEMPLO INTEGRADOR ---~%~%")

(format t "Simulacion de cambios en un ciclo completo (216 segundos):~%~%")

;; Uso de mapcar (funcion de orden superior) en lugar de dolist
(mapcar (lambda (t-actual)
          (format t "  t=~3D -> ~A~%" t-actual (semaforo-en t-actual *config*)))
        '(0 89 90 209 210 215 216))

(format t "~%Registro de transiciones detectadas:~%~%")
;; Transiciones explicitas sin bucles ni variables mutables
(mostrarCambio 0 'inicio (semaforo-en 0 *config*))
(mostrarCambio 90 (semaforo-en 89 *config*) (semaforo-en 90 *config*))
(mostrarCambio 210 (semaforo-en 209 *config*) (semaforo-en 210 *config*))
(mostrarCambio 216 (semaforo-en 215 *config*) (semaforo-en 216 *config*))

(format t "~%Resumen del sistema:~%")
(format t "  Duracion del ciclo: ~A segundos~%" (duracionCiclo *config*))
(format t "  Recomendacion: ~A~%" (recomendacionCiclo (duracionCiclo *config*)))
(format t "  Ciclos en 15 min: ~A~%" (ciclosPorTiempo 15 *config*))
(format t "  Ciclos en 1 hora: ~A~%" (ciclosPorTiempo 60 *config*))
(format t "  Distribucion: ~A~%" (distribucionHora *config*))

(format t "~%=============================================~%")
(format t "  FIN DE LOS EJEMPLOS~%")
(format t "=============================================~%")
