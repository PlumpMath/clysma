;;;; -*- Mode: LISP; Syntax: COMMON-LISP -*-
;;;;
;;;; clysma.lisp
;;;;
;;;; author: Erik Winkels (aerique@xs4all.nl)
;;;;
;;;; See the LICENSE file in the root directory for more information.

;;; Packages

(in-package :clysma)


;;; Functions

(defun trawl-classes ()
  (loop with classes = '()
        for class in (closer-mop:class-direct-subclasses (find-class t))
        do (push (list :class class
                       :name (mkstr (class-name class))
                       :package (class-package-name class))
                 classes)
        finally (return (sort classes #'string-lessp
                              :key (lambda (class) (getf class :name))))))


(defun trawl-packages ()
  (loop with packages = '()
        for pkg in (list-all-packages)
        do (push (list :package pkg
                       ;; XXX: copy-seq necessary?
                       :name (package-name pkg)
                       :nicknames (sort (copy-seq (package-nicknames pkg))
                                        #'string-lessp))
                 packages)
        finally (return (sort packages #'string-lessp
                              :key (lambda (package) (getf package :name))))))


(defun trawl-symbols ()
  (let ((symbols nil))
    (do-all-symbols (symbol)
      (push (list :symbol symbol
                  :name (symbol-name symbol)
                  :package (package-name (symbol-package symbol)))
            symbols))
    (sort symbols #'string-lessp :key (lambda (symbol) (getf symbol :name)))))


(defun trawl-threads ()
  (loop with threads = '()
        for thread in (bt:all-threads)
        do (push (list :thread thread
                       :name (bt:thread-name thread)
                       :alive? (bt:thread-alive-p thread))
                 threads)
        finally (return (sort threads #'string-lessp
                              :key (lambda (thread) (getf thread :name))))))
