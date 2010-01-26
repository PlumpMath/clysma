;;;; -*- Mode: LISP; Syntax: COMMON-LISP -*-
;;;;
;;;; clysma-gtk.asd
;;;;
;;;; author: Erik Winkels (aerique@xs4all.nl)
;;;;
;;;; See the LICENSE file in the root directory for more information.

(in-package :cl-user)


(asdf:defsystem :clysma-gtk
  :version "0.1"
  :depends-on (:clysma :cl-gtk2-gtk)
  :components ((:module src
                :serial t
                :components ((:file "gtk")))))
