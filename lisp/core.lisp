;;==============================================================
;; Integracion de Quicklisp + cl-json
;; Se carga Quicklisp y la libreria cl-json para permitir
;; la lectura dinamica de tiempos desde un archivo .json externo
;;==============================================================

(load "~/quicklisp/setup.lisp")
(ql:quickload "cl-json" :silent t)

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

;==============================================================
;; FUNCION: obtener-tiempo
;; NATURALEZA: Pura
;; ESTRATEGIA: Busqueda en lista de asociacion (assoc)
;; IMPACTO: No destructiva
;==============================================================

(defun obtener-tiempo (config color)
  (cdr (assoc color config))
)

;==============================================================
;; FUNCION: transicion
;; NATURALEZA: Pura
;; ESTRATEGIA: Condicional
;; IMPACTO: No destructiva
;==============================================================

(defun transicion (color-actual cambiar)
  (cond
    ((eq cambiar 'rojo)
     (list color-actual 'cambiar_a_rojo))
    ((eq cambiar 'amarillo)
     (list color-actual 'cambiar_a_amarillo))
    ((eq cambiar 'verde)
     (list color-actual 'cambiar_a_verde))
    (t
     (list color-actual 'accion-por-defecto))
  )
)

;==============================================================
;; FUNCION: semaforo-en
;; NATURALEZA: Pura
;; ESTRATEGIA: Uso de operador MOD sobre duracion dinamica
;; IMPACTO: No destructiva
;==============================================================

(defun semaforo-en (timestamp config)
  (let* ((time-rojo     (obtener-tiempo config :rojo))
         (time-verde    (obtener-tiempo config :verde))
         (time-amarillo (obtener-tiempo config :amarillo))
         (total      (+ time-rojo time-verde time-amarillo))
         (ciclo      (mod timestamp total)))
    (cond
      ((< ciclo time-rojo) 'rojo)
      ((< ciclo (+ time-rojo time-verde)) 'verde)
      (t 'amarillo)
    )
  )
)

;==============================================================
;; FUNCION: mostrarCambio
;; NATURALEZA: Impura
;; ESTRATEGIA: Salida por pantalla
;; IMPACTO: No destructiva
;==============================================================

(defun mostrarCambio (tiempo colorAnt colorNue)
  (format t
          "Tiempo ~A: la luz ha cambiado de ~A a ~A~%"
          tiempo
          colorAnt
          colorNue)
)

;==============================================================
;; FUNCION: duracionCiclo
;; NATURALEZA: Pura
;; ESTRATEGIA: Suma de tiempos obtenidos dinamicamente del config
;; IMPACTO: No destructiva
;==============================================================

(defun duracionCiclo (config)
  (+ (obtener-tiempo config :rojo)
     (obtener-tiempo config :amarillo)
     (obtener-tiempo config :verde))
)

;==============================================================
;; FUNCION: recomendacionCiclo
;; NATURALEZA: Pura
;; ESTRATEGIA: Condicional
;; IMPACTO: No destructiva
;==============================================================

(defun recomendacionCiclo (duracion)
  (cond
    ((< duracion 35)
      "Ciclo demasiado corto")
    ((> duracion 150)
      "Ciclo demasiado largo")
    (t
      "Ciclo dentro del rango recomendado")
  )
)

;==============================================================
;; FUNCION: ciclosPorTiempo
;; NATURALEZA: Pura
;; ESTRATEGIA: Aritmetica simple sobre duracion dinamica
;; IMPACTO: No destructiva
;==============================================================

(defun ciclosPorTiempo (minutos config)
  (floor (/ (* minutos 60)
            (duracionCiclo config)))
)

;==============================================================
;; FUNCION: distribucionHora
;; NATURALEZA: Pura
;; ESTRATEGIA: Calculo porcentual sobre tiempos dinamicos
;; IMPACTO: No destructiva
;==============================================================

(defun distribucionHora (config)
  (let* ((time-rojo     (obtener-tiempo config :rojo))
         (time-amarillo (obtener-tiempo config :amarillo))
         (time-verde    (obtener-tiempo config :verde))
         (total      (float (+ time-rojo time-amarillo time-verde))))
    (list
      (list 'rojo     (* (/ time-rojo     total) 100))
      (list 'amarillo (* (/ time-amarillo total) 100))
      (list 'verde    (* (/ time-verde    total) 100))
    )
  )
)