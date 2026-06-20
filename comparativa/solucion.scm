#lang racket

;; ========================================================
;; FUNCION: obtener-tiempo
;; NATURALEZA: Pura
;; ESTRATEGIA: Busqueda en lista de asociacion
;; IMPACTO: No destructiva
;; ========================================================

(define (obtener-tiempo config color)
  (cdr (assoc color config)))

;; ========================================================
;; FUNCION: transicion
;; NATURALEZA: Pura
;; ESTRATEGIA: Condicional
;; IMPACTO: No destructiva
;; ========================================================

(define (transicion color-actual cambiar)
  (cond
    ((eq? cambiar 'rojo)
     (list color-actual 'cambiar_a_rojo))
    ((eq? cambiar 'amarillo)
     (list color-actual 'cambiar_a_amarillo))
    ((eq? cambiar 'verde)
     (list color-actual 'cambiar_a_verde))
    (else
     (list color-actual 'accion-por-defecto))))

;; ========================================================
;; FUNCION: timer
;; NATURALEZA: Pura
;; ESTRATEGIA: Uso de modulo sobre duracion dinamica e intermitencia
;; IMPACTO: No destructiva
;; ========================================================

(define (timer timestamp config)
  (let* ((time-rojo (obtener-tiempo config 'rojo))
         (time-verde (obtener-tiempo config 'verde))
         (time-amarillo (obtener-tiempo config 'amarillo))
         (time-intermitente 3)
         (total (+ time-rojo time-intermitente
                   time-verde time-intermitente
                   time-amarillo time-intermitente))
         (ciclo (modulo timestamp total)))
    (cond
      ((< ciclo time-rojo) 'rojo)
      ((< ciclo (+ time-rojo time-intermitente)) 'rojo-intermitente)
      ((< ciclo (+ time-rojo time-intermitente time-verde)) 'verde)
      ((< ciclo (+ time-rojo time-intermitente time-verde time-intermitente)) 'verde-intermitente)
      ((< ciclo (+ time-rojo time-intermitente time-verde time-intermitente time-amarillo)) 'amarillo)
      (else 'amarillo-intermitente))))
;; ========================================================
;; FUNCIÓN: informe
;; NATURALEZA: Impura (Efectos secundarios de escritura en archivo)
;; ESTRATEGIA: Recursiva de Cola (Optimización TCO requerida por especificación)
;; IMPACTO: No destructiva
;; ========================================================
(define (informe datos)
  (call-with-output-file "informe-ejecucion-semaforo.txt"
    (lambda (port)
      (display "Informe de Ejecución del Sistema Semafórico\n" port)
      (display "=========================================\n" port)
      
      ;; Implementación recursiva de cola (iteración funcional)
      (let loop ((lista datos))
        (if (not (null? lista))
            (begin
              (display (car lista) port)
              (newline port)
              (loop (cdr lista)))))
              
      (display "\n --- Fin del Informe ---" port))))

;; ========================================================
;; PRUEBAS SUGERIDAS
;; ========================================================

;;(define config
;;  '((rojo . 90)
;;    (verde . 120)
;;    (amarillo . 6)))

;; (transicion 'en-rojo 'verde) ; '(en-rojo cambiar_a_verde)
;; (transicion 'en-rojo 'azul)  ; '(en-rojo accion-por-defecto)
;; (timer 0 config)    ; rojo
;; (timer 90 config)   ; rojo-intermitente
;; (timer 93 config)   ; verde
;; (timer 213 config)  ; verde-intermitente
;; (timer 216 config)  ; amarillo
;; (timer 222 config)  ; amarillo-intermitente
;; (timer 225 config)  ; rojo
