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
                  (:title ,(format nil "~@[~A - ~] Epidemia Test Site" title))
		  (:link :type "text/css"
			 :rel "stylesheet"
			 :href "css/epidemia.css"))
           (:body ,@body))))

(defmacro define-url-fn ((name) &body body)
  `(progn
     (defun ,name ()
       ,@body)
     (push (create-prefix-dispatcher ,(format nil "/~(~a~).html" name) ',name) *dispatch-table*)))

(define-easy-handler (test-page :uri "/") ()
  (page-template (:title "Splash Page") 
		 (:p "Go to new-game.html")))

(define-url-fn (new-game)
  (page-template (:title "New Game")
		 (:p "Create new square game board")
		 (:form :action "/game.html" :method "post"
			(:p "Game board size"
			(:input :type "number" 
				:name "board_size" 
				:value "15" 
				:min "9" 
				:max "21"))
			(:p (:input :type "submit"
				:value "Create"
				:class "btn" )))))
   
(define-url-fn (game)
	       (let ((size (parse-integer (parameter "board_size"))))
		       (page-template (:title "Table test") 
				      (:table :border 0 :cellpadding 0
					       (loop for i below (* size size) by size
							 do (htm
							     (:tr :align "right"
							      (loop for j from i below (+ i size)
								    do (htm
									(:td :bgcolor (if (oddp j)
											"white"
											"black")
									     (:img :src "/cell.png" :onclick (ps-inline (alert "Hello, parenscript")))))))))))))

