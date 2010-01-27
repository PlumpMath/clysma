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
          ("on_symbols-combobox_changed"         ,#'gtk-refresh-symbols)
          ("on_symbols-treeview_row_activated"   ,#'gtk-describe-symbol)
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
    (let ((pkgs-ls (get-widget "packages-liststr"))
          (symb-ls (get-widget "symbols-combobox-liststr")))
      (gtk:list-store-clear pkgs-ls)
      (gtk:list-store-clear symb-ls)
      (gtk:list-store-insert-with-values symb-ls -1 "All Packages (slooow!)")
      (loop for pkg in (setf packages (trawl-packages))
            do (gtk:list-store-insert-with-values pkgs-ls -1 (getf pkg :name)
                                               (lst2str (getf pkg :nicknames)))
               (gtk:list-store-insert-with-values symb-ls -1
                                                  (getf pkg :name)))
      ;; In the future it would be nice to set this to the value it was
      ;; before the refresh.
      (setf (gtk:combo-box-active (get-widget "symbols-combobox")) 1))))


(let ((symbols nil))
  (defun gtk-describe-symbol (widget path column)
    (declare (ignore widget column))
    (let* ((list-store (get-widget "symbols-liststr"))
           (iter (gtk:tree-model-iter-by-path list-store path))
           (name (gtk:tree-model-value list-store iter 0)))
      (setf (gtk:text-buffer-text (get-widget "symbols-textbuffer"))
            (loop for symbol in symbols
                  when (string= name (getf symbol :name))
                  return (describe2str (getf symbol :symbol))))))

  (defun gtk-refresh-symbols (widget)
    (let ((symb-ls (get-widget "symbols-liststr"))
          (row (gtk:combo-box-active widget)))
      (unless (= row -1)
        (gtk:list-store-clear symb-ls)
        (loop with pkg = (if (equal (gtk:combo-box-active-text widget)
                                    "All Packages (slooow!)")
                             nil
                             (find-package (gtk:combo-box-active-text widget)))
              for symbol in (setf symbols (trawl-symbols pkg))
              do (gtk:list-store-insert-with-values symb-ls -1
                                                   (getf symbol :name)
                                                   (getf symbol :package)))))))


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


;;; Last to avoid compile / loading warnings.

;; The symbols list gets initialised due to setting the combobox in
;; #'gtk-refresh-packages.
(defun gtk-initialise-ui ()
  (gtk-refresh-classes)
  (gtk-refresh-packages)
  (gtk-refresh-threads))
