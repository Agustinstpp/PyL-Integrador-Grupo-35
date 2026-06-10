;==============================================================
;; FUNCION: transicion
;; NATURALEZA: Pura
;; ESTRATEGIA: Condicional
;; IMPACTO: No destructiva
;==============================================================

(defun transicion (color-actual cambiar)
  (cond
    ((eq cambiar 'rojo)
     (list color-actual "cambiar-a-rojo"))
    ((eq cambiar 'amarillo)
     (list color-actual "cambiar-a-amarillo"))
    ((eq cambiar 'verde)
     (list color-actual "cambiar-a-verde"))
    (t
     (list color-actual 'accion-por-defecto))
  )
)

;==============================================================
;; FUNCION: timer
;; NATURALEZA: Pura
;; ESTRATEGIA: Uso de operador MOD
;; IMPACTO: No destructiva
;==============================================================


(defun timer (timestamp)
  (let ((ciclo (mod timestamp 216)))
    (cond
      ((< ciclo 90) 'rojo)
      ((< ciclo 96) 'amarillo)
      (t 'verde)
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
;; ESTRATEGIA: Aritmetica simple
;; IMPACTO: No destructiva
;==============================================================

(defun duracionCiclo()
  (+ 90 6 120)
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
;; ESTRATEGIA: Aritmetica simple
;; IMPACTO: No destructiva
;==============================================================

(defun ciclosPorTiempo (minutos)
  (floor (/ (* minutos 60)
            (duracionCiclo)))
)

;==============================================================
;; FUNCION: distribucionHora
;; NATURALEZA: Pura
;; ESTRATEGIA: Calculo porcentual
;; IMPACTO: No destructiva
;==============================================================

(defun distribucionHora ()
  (list
    (list 'rojo
          (* (/ 90 216) 100))
    (list 'amarillo
          (* (/ 6 216) 100))
    (list 'verde
          (* (/ 120 216) 100))
  )
)