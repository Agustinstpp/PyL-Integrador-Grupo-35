;;==============================================================
;; Integracion de Quicklisp + cl-json
;; Se carga Quicklisp y la libreria cl-json para permitir
;; la lectura dinamica de tiempos desde un archivo .json externo
;;==============================================================

;;; Carga de Quicklisp y cl-json
;;; Si Quicklisp no esta instalado, se instala automaticamente
;;; usando el archivo quicklisp.lisp incluido en el proyecto.
;;; Si ya esta instalado, simplemente lo carga.
(let ((quicklisp-init (merge-pathnames "quicklisp/setup.lisp"
                                       (user-homedir-pathname))))
  ;;; Si Quicklisp ya esta instalado, cargarlo directamente
  (if (probe-file quicklisp-init)
      (load quicklisp-init)
      ;;; Si no esta instalado, ejecutar el instalador
      ;;; que se encuentra en el directorio del proyecto
      (progn
        (load "quicklisp.lisp")
        (funcall (intern "INSTALL" :quicklisp-quickstart)))))
;;; Una vez cargado Quicklisp, instalar/cargar cl-json
(when (find-package :ql)
  (funcall (intern "QUICKLOAD" :ql) "cl-json" :silent t))

;;; Evita conflicto con el simbolo timer de paquetes externos
;;; creando un simbolo local en el paquete actual.
(shadow 'timer)

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
  (rest (assoc color config))
)

;==============================================================
;; FUNCION: transicion
;; NATURALEZA: Pura
;; ESTRATEGIA: Condicional
;; IMPACTO: No destructiva
;==============================================================

(defun transicion (color-actual cambiar)
  (cond
    ((and (eq color-actual 'rojo) (eq cambiar 'rojo-intermitente))
     (list color-actual "cambiar-a-rojo-intermitente"))
    ((and (eq color-actual 'rojo-intermitente) (eq cambiar 'verde))
     (list color-actual "cambiar-a-verde"))
    ((and (eq color-actual 'verde) (eq cambiar 'verde-intermitente))
     (list color-actual "cambiar-a-verde-intermitente"))
    ((and (eq color-actual 'verde-intermitente) (eq cambiar 'amarillo))
     (list color-actual "cambiar-a-amarillo"))
    ((and (eq color-actual 'amarillo) (eq cambiar 'amarillo-intermitente))
     (list color-actual "cambiar-a-amarillo-intermitente"))
    ((and (eq color-actual 'amarillo-intermitente) (eq cambiar 'rojo))
     (list color-actual "cambiar-a-rojo"))
    (t
     (list color-actual 'accion-por-defecto))
  )
)

;==============================================================
;; FUNCION: timer
;; NATURALEZA: Pura
;; ESTRATEGIA: Uso de operador MOD sobre duracion dinamica
;;    Recursion de cola con acumulador, recorriendo
;;    las fases obtenidas dinamicamente del config via MAPCAR.
;;    A diferencia de la version principal (basada en COND),
;;    esta variante no requiere modificacion al agregar nuevas
;;    fases al archivo de configuracion.
;; IMPACTO: No destructiva
;==============================================================

(defun timer (timestamp config)
  (let ((ciclo (mod timestamp (duracion-ciclo config)))
        (fases (mapcar #'first config)))
    (labels ((buscar-fase (restantes acum)
                (let ((nuevo (+ acum (obtener-tiempo config (first restantes)))))
                  (if (< ciclo nuevo)
                      (first restantes)
                      (buscar-fase (rest restantes) nuevo)
                  )
                )
              )
            )
      (buscar-fase fases 0)
    )
  )
)

;==============================================================
;; FUNCION: mostrar-cambio
;; NATURALEZA: Impura
;; ESTRATEGIA: Salida por pantalla
;; IMPACTO: No destructiva
;==============================================================

(defun mostrar-cambio (tiempo color-anterior color-nuevo)
  (format t
          "Tiempo ~A: la luz ha cambiado de ~A a ~A~%"
          tiempo
          color-anterior
          color-nuevo)
)

;==============================================================
;; FUNCION: duracion-ciclo
;; NATURALEZA: Pura
;; ESTRATEGIA: Suma de tiempos obtenidos dinamicamente del config
;; utilizando mapcar para extraer los tiempos, y apply para sumarlos
;; IMPACTO: No destructiva
;==============================================================

(defun duracion-ciclo (config)
  (apply #'+ (mapcar (lambda (fase)
                       (obtener-tiempo config (first fase))
                      )
              config)
  )
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
  (let ((total (duracion-ciclo config)) (lista-colores (mapcar #'first config)))
    (mapcar (lambda (color)
              (list color (float (* (/ (obtener-tiempo config color) total) 100)))
            )
            lista-colores
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
             ;; 9 valores: segundo, minuto, hora, dia, mes, anio, dia-semana,
             ;; horario-verano y zona-horaria.
             ;; multiple-value-bind captura los primeros 6 valores en variables locales.
             ;; format nil retorna un string (sin imprimirlo) con el formato
             ;; AAAA-MM-DD HH:MM:SS
             ;; Directiva ~N,'0D: imprime un entero Decimal con N digitos minimos
             ;; rellenando con '0' a la izquierda. Ej: (format nil "~2,'0D" 6) -> "06"
             (obtener-fecha ()
               (multiple-value-bind (seg min hora dia mes anio)
                   (get-decoded-time)
                 (format nil "~4,'0D-~2,'0D-~2,'0D ~2,'0D:~2,'0D:~2,'0D"
                         anio mes dia hora min seg)))

             ;; escribir-lineas: recorre la lista de logs recursivamente.
             ;; En cada llamada, escribe la fecha/hora seguida del primer elemento (first),
             ;; y luego se llama a si misma con el resto de la lista (rest).
             (escribir-lineas (lista)
               (when lista
                 (format stream "~A - ~A~%" (obtener-fecha) (first lista))
                 (escribir-lineas (rest lista)))))
      (escribir-lineas datos))
      
    (format stream "~% --- Fin del Informe ---"))
  (format t "Informe generado exitosamente en 'informe-ejecucion-semaforo.txt'.~%"))
