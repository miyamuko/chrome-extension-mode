; -*- mode: lisp; package: chrome-extension-mode -*-

;;; chrome-extension-mode/filer.l
;;
;; Copyright (c) 2010 MIYAMUKO Katsuyuki.
;;
;; Permission is hereby granted, free of charge, to any person obtaining
;; a copy of this software and associated documentation files (the
;; "Software"), to deal in the Software without restriction, including
;; without limitation the rights to use, copy, modify, merge, publish,
;; distribute, sublicense, and/or sell copies of the Software, and to
;; permit persons to whom the Software is furnished to do so, subject to
;; the following conditions:
;;
;; The above copyright notice and this permission notice shall be
;; included in all copies or substantial portions of the Software.
;;
;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
;; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
;; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
;; NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
;; LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
;; OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
;; WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

;;; Code:

(eval-when (:compile-toplevel :load-toplevel :execute)
  (mc-require "chrome-extension-mode/package")
  (mc-require "chrome-extension-mode/extension")
  )

(in-package :chrome-extension-mode)

(export '(chrome-extension-open-filer
          ))

(defun chrome-extension-open-filer (&optional pattern)
  (interactive "sExtension Name (Regexp): ")
  (let ((manifest (find-chrome-extension pattern :regexp t :case-fold t)))
    (unless manifest
      (message "~S not found." pattern)
      (return-from chrome-extension-open-filer nil))
    (message "Found ~A/~A (~A)"
             (chrome-extension-name manifest)
             (chrome-extension-version manifest)
             (chrome-extension-dir manifest))
    (open-chrome-extension1 manifest)))

(defun open-chrome-extension1 (manifest)
  (let ((*filer-primary-directory* (chrome-extension-dir manifest))
        (*filer-secondary-directory* (default-directory)))
    (multiple-value-bind (files result)
        (let ((omode (get-ime-mode)))
          (unwind-protect
              (filer nil t nil t (not *filer-modal*))
            (and *filer-modal* (toggle-ime omode))))
      (when result
        (ed::filer-readin-1 files)))))


(provide "chrome-extension-mode/filer")

;;; End
