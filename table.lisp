(dolist (x '(:hunchentoot :cl-who :parenscript :cl-fad))
  (asdf:oos 'asdf:load-op x))

(defpackage :testserv
  (:use :cl :hunchentoot :cl-who :parenscript :cl-fad)
  (:export :start-server))

(in-package :testserv)

(setf *dispatch-table*
      (list #'dispatch-easy-handlers))

(setf *show-lisp-errors-p* t
      *show-lisp-backtraces-p* t)

(push (create-static-file-dispatcher-and-handler "/cell.png" "img/Cell.png") *dispatch-table*)

(defun start-server (&key (port 4242))
  (start (make-instance 'easy-acceptor :port port)))

(defmacro page-template ((&key title) &body body)
  `(with-html-output-to-string 
    (*standard-output* nil :prologue t :indent t)
    (:html :xmlns "http://www.w3.org/1999/xhtml" :xml\:lang "en" :lang "en"
           (:head (:meta :http-equiv "Content-Type" :content "text/html;charset=utf-8")
                  (:title ,(format nil "~@[~A - ~]Test Site" title)))
           (:body ,@body))))

(defmacro define-url-fn ((name) &body body)
  `(progn
     (defun ,name ()
       ,@body)
     (push (create-prefix-dispatcher ,(format nil "/~(~a~).htm" name) ',name) *dispatch-table*)))

(define-easy-handler (test-page :uri "/") ()
  (page-template (:title "Splash Page") (:p "Testing testing")))

   
(define-url-fn (table)
	       (page-template (:title "Table test") 
			      (:table :border 0 :cellpadding 4
				       (loop for i below 25 by 5
						 do (htm
						     (:tr :align "right"
						      (loop for j from i below (+ i 5)
							    do (htm
								(:td :bgcolor (if (oddp j)
										"white"
										"black")
								     (:img :src "/cell.png" ))))))))))

