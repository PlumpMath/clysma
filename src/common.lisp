;;;; -*- Mode: LISP; Syntax: COMMON-LISP -*-
;;;;
;;;; common.lisp
;;;;
;;;; author: Erik Winkels (aerique@xs4all.nl)
;;;;
;;;; See the LICENSE file in the root directory for more information.

(in-package :clysma)


;;; Functions

(defun append1 (lst obj)
  (append lst (list obj)))


(defun asdf (system)
  (asdf:oos 'asdf:load-op system))


(defun class-package-name (class)
  (package-name (symbol-package (class-name class))))


(defun current-date-time-string ()
  (multiple-value-bind (sec min hou day mon yea)
      (decode-universal-time (get-universal-time))
    (format nil "~D-~2,'0D-~2,'0D ~2,'0D:~2,'0D:~2,'0D"
            yea mon day hou min sec)))


(defun defalias (function alias)
  "Defines an alias for FUNCTION, meaning it can be called with ALIAS too."
  (setf (symbol-function alias) function))


(defun describe2str (object)
  (with-output-to-string (stream)
    (describe object stream)))


(defun echo-self (&rest args)
  (format t "~&~S~%" args))


(defun error-message (msg)
  (format *error-output* "~&E: ~A~%" msg))


(defun last1 (lst)
  (car (last lst)))


(defun lst2str (lst &optional (seperator ", "))
  (loop with str = ""
        with length = (length lst)
        for item in lst
        for i from 1
        do (setf str (mkstr str item (if (>= i length) "" seperator)))
        finally (return str)))


(defun mkstr (&rest args)
  (with-output-to-string (s)
    (dolist (a args) (princ a s))))


(defun print-hash (hash)
  (maphash (lambda (key value)
             (format t "~S: ~S~%" key value))
           hash))


(defun quit ()
  (cl-user::quit))


(defun system-relative-path (system &optional (relative-path ""))
  (namestring (asdf:system-relative-pathname system relative-path)))


(defun verbose (msg)
  (format *standard-output* "~&D: ~A~%" msg))


(defun write-to-file (name object)
  (with-open-file (f name :direction :output)
    (format f "~S~%" object)))
