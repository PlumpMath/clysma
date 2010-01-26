;;;; -*- Mode: LISP; Syntax: COMMON-LISP -*-
;;;;
;;;; clysma.asd
;;;;
;;;; author: Erik Winkels (aerique@xs4all.nl)
;;;;
;;;; See the LICENSE file in the root directory for more information.

(in-package :cl-user)


(asdf:defsystem :clysma
  :version "0.1"
  :depends-on (:bordeaux-threads :closer-mop)
  :components ((:module src
                :serial t
                :components ((:file "package")
                             (:file "config")
                             (:file "common")
                             (:file "clysma")))))
