;;==============================================================
;; Integracion de Quicklisp + cl-json
;; Se carga Quicklisp y la libreria cl-json para permitir
;; la lectura dinamica de tiempos desde un archivo .json externo
;;==============================================================

(load (merge-pathnames "quicklisp/setup.lisp" (user-homedir-pathname)))

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
;; ESTRATEGIA: Uso de operador MOD sobre duracion dinamica
;; IMPACTO: No destructiva
;==============================================================

(defun timer (timestamp config)
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
;; FUNCION: mostrar-cambio
;; NATURALEZA: Impura
;; ESTRATEGIA: Salida por pantalla
;; IMPACTO: No destructiva
;==============================================================

(defun mostrar-cambio (tiempo colorAnt colorNue)
  (format t
          "Tiempo ~A: la luz ha cambiado de ~A a ~A~%"
          tiempo
          colorAnt
          colorNue)
)

;==============================================================
;; FUNCION: duracion-ciclo
;; NATURALEZA: Pura
;; ESTRATEGIA: Suma de tiempos obtenidos dinamicamente del config
;; IMPACTO: No destructiva
;==============================================================

(defun duracion-ciclo (config)
  (+ (obtener-tiempo config :rojo)
     (obtener-tiempo config :amarillo)
     (obtener-tiempo config :verde))
)

;==============================================================
;; FUNCION: recomendacion-ciclo
;; NATURALEZA: Pura
;; ESTRATEGIA: Condicional
;; IMPACTO: No destructiva
;==============================================================

(defun recomendacion-ciclo (duracion)
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
;; FUNCION: ciclos-por-tiempo 
;; NATURALEZA: Pura
;; ESTRATEGIA: Aritmetica simple sobre duracion dinamica
;; IMPACTO: No destructiva
;==============================================================

(defun ciclos-por-tiempo (minutos config)
  (floor (/ (* minutos 60)
            (duracion-ciclo config)))
)

;==============================================================
;; FUNCION: distribucion-hora
;; NATURALEZA: Pura
;; ESTRATEGIA: Calculo porcentual sobre tiempos dinamicos
;; IMPACTO: No destructiva
;==============================================================

(defun distribucion-hora (config)
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
;; ========================================================
;; FUNCIÓN: informe
;; NATURALEZA: Impura (Realiza operaciones de E/S al escribir en un archivo físico)
;; ESTRATEGIA: Recursiva de Cola (Tail Recursive) para procesar la lista de logs
;; IMPACTO: No destructiva
;; ========================================================
(defun informe (datos)
  "Extrae el historial de log de los semáforos a un archivo de texto plano."
  (with-open-file (stream "informe-ejecucion-semaforo.txt"
                         :direction :output
                         :if-exists :supersede
                         :if-does-not-exist :create)
    (format stream "Informe de Ejecución del Sistema Semafórico~%")
    (format stream "=========================================~%")
    
    ;; labels: permite definir funciones locales con nombre dentro de otra funcion.
    (labels (
             ;; obtener-fecha: lee la fecha y hora actual del sistema operativo.
             ;; get-decoded-time es una funcion nativa de Common Lisp que devuelve
             ;; 9 valores: segundo, minuto, hora, dia, mes, anio, dia-semana, horario-verano y zona-horaria.
             ;; multiple-value-bind captura los primeros 6 valores en variables locales.
             ;; format nil retorna un string (sin imprimirlo) con el formato AAAA-MM-DD HH:MM:SS
             ;; Directiva ~N,'0D: imprime un entero Decimal con N digitos minimos, rellenando con '0' a la izquierda. Ej: (format nil "~2,'0D" 6) -> "06"
             (obtener-fecha ()
               (multiple-value-bind (seg min hora dia mes anio)
                   (get-decoded-time)
                 (format nil "~4,'0D-~2,'0D-~2,'0D ~2,'0D:~2,'0D:~2,'0D"
                         anio mes dia hora min seg)))

             ;; escribir-lineas: recorre la lista de logs recursivamente.
             ;; En cada llamada, escribe la fecha/hora seguida del primer elemento (car),
             ;; y luego se llama a si misma con el resto de la lista (cdr).
             (escribir-lineas (lista)
               (when lista
                 (format stream "~A - ~A~%" (obtener-fecha) (car lista))
                 (escribir-lineas (cdr lista)))))
      (escribir-lineas datos))
      
    (format stream "~% --- Fin del Informe ---"))
  (format t "Informe generado exitosamente en 'informe-ejecucion-semaforo.txt'.~%"))
