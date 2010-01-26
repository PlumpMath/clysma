;;;; -*- Mode: LISP; Syntax: COMMON-LISP -*-
;;;;
;;;; gtk.lisp
;;;;
;;;; author: Erik Winkels (aerique@xs4all.nl)

(in-package :clysma)


;;; Functions

(let ((builder nil))
  (defun get-widget (name)
    (gtk:builder-get-object builder name))

  (defun apply-gtk-enema ()
    (gtk:within-main-loop-and-wait
      (let ((builder-instance (make-instance 'gtk:builder)))
        (gtk:builder-add-from-file builder-instance "data/gtk/gtk-ui.glade")
        (setf builder builder-instance))
      (gtk:builder-connect-signals-simple builder
        `(;; we'll want to use this in the future instead of row_activated
          ;("on_packages-treeview_cursor_changed" ,#'echo-self)
          ;; requires a double-click :-(
          ("on_classes-treeview_row_activated"   ,#'gtk-describe-class)
          ("on_packages-treeview_row_activated"  ,#'gtk-describe-package)
          ("on_threads-treeview_row_activated"   ,#'gtk-describe-thread)))
      (gtk-initialise-ui)
      (gtk:widget-show (get-widget "top_level") :all t))))


(let ((classes nil))
  (defun gtk-describe-class (widget path column)
    (declare (ignore widget column))
    (let* ((list-store (get-widget "classes-liststr"))
           (iter (gtk:tree-model-iter-by-path list-store path))
           (name (gtk:tree-model-value list-store iter 0)))
      (setf (gtk:text-buffer-text (get-widget "classes-textbuffer"))
            (loop for class in classes
                  when (string= name (getf class :name))
                  return (describe2str (getf class :class))))))

  ;; XXX: this only lists the direct subclasses of T so far
  (defun gtk-refresh-classes ()
    (gtk:list-store-clear (get-widget "classes-liststr"))
    (loop for class in (setf classes (trawl-classes))
          do (gtk:list-store-insert-with-values  ; gtk-list-store-append?
              (get-widget "classes-liststr")
              -1
              (getf class :name)
              (getf class :package)))))


(let ((packages nil))
  (defun gtk-describe-package (widget path column)
    (declare (ignore widget column))
    (let* ((list-store (get-widget "packages-liststr"))
           (iter (gtk:tree-model-iter-by-path list-store path))
           (name (gtk:tree-model-value list-store iter 0)))
      (setf (gtk:text-buffer-text (get-widget "packages-textbuffer"))
            (loop for pkg in packages
                  when (string= name (getf pkg :name))
                  return (describe2str (getf pkg :package))))))

  (defun gtk-refresh-packages ()
    (gtk:list-store-clear (get-widget "packages-liststr"))
    (loop for pkg in (setf packages (trawl-packages))
          do (gtk:list-store-insert-with-values  ; gtk-list-store-append?
              (get-widget "packages-liststr")
              -1
              (getf pkg :name)
              (lst2str (getf pkg :nicknames))))))


(defun gtk-refresh-symbols ()
  (gtk:list-store-clear (get-widget "symbols-liststr"))
  (loop for symbol in (trawl-symbols)
        do (gtk:list-store-insert-with-values  ; gtk-list-store-append?
             (get-widget "symbols-liststr")
             -1
             (getf symbol :name)
             (getf symbol :package)
             "")))


(let ((threads nil))
  (defun gtk-describe-thread (widget path column)
    (declare (ignore widget column))
    (let* ((list-store (get-widget "threads-liststr"))
           (iter (gtk:tree-model-iter-by-path list-store path))
           (name (gtk:tree-model-value list-store iter 0)))
      (setf (gtk:text-buffer-text (get-widget "threads-textbuffer"))
            (loop for thread in threads
                  when (string= name (getf thread :name))
                  return (describe2str (getf thread :thread))))))

  (defun gtk-refresh-threads ()
    (gtk:list-store-clear (get-widget "threads-liststr"))
    (loop for thread in (setf threads (trawl-threads))
          do (gtk:list-store-insert-with-values  ; gtk-list-store-append?
              (get-widget "threads-liststr")
              -1
              (getf thread :name)
              (if (getf thread :alive?) "running" "dead")))))


;;; Last to avoid warnings compile / loading warnings.

(defun gtk-initialise-ui ()
  (gtk-refresh-classes)
  (gtk-refresh-packages)
  ;(gtk-refresh-symbols)  ; takes a long time
  (gtk-refresh-threads))
