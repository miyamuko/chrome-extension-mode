; -*- mode: lisp; package: chrome-extension-mode -*-

;;; chrome-extension-mode/chrome-extension.l
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
  )

(in-package :chrome-extension-mode)

(defun find-chrome-extension (pattern &key regexp case-fold)
  (let ((predicate (cond (regexp
                          (if (or (not case-fold)
                                  (and (eq case-fold :smart)
                                       (not (string-match "[A-Z]" pattern))))
                              #'string-match
                            #'string-matchp))
                         (t
                          (if case-fold
                              #'string-equal
                            #'string=)))))
    (find-if #'(lambda (name)
                 (funcall predicate pattern name))
             (list-chrome-extensions)
             :key 'chrome-extension-name)))


(defun chrome-extension-name (manifest)
  (cdr (assoc "name" manifest :test #'string=)))

(defun chrome-extension-version (manifest)
  (cdr (assoc "version" manifest :test #'string=)))

(defun chrome-extension-dir (manifest)
  (cdr (assoc "__dir__" manifest :test #'string=)))


(defun list-chrome-extensions ()
  (mapcar #'(lambda (manifest-file)
              (let ((manifest (json:json-decode-file manifest-file)))
                (acons "__dir__" (directory-namestring manifest-file) manifest)))
          (directory (get-chrome-extension-directory) :wild "manifest.json" :absolute t :recursive t)))

(defun list-chrome-extension-names ()
  (mapcar #'chrome-extension-name (list-chrome-extensions)))


(defun get-local-app-data-directory ()
  (or (si:getenv "LOCALAPPDATA")                                                      ; Vista/7
      (merge-pathnames "Local Settings/Application Data" (si:getenv "USERPROFILE")))) ; XP

(defun get-chrome-base-directory ()
  (merge-pathnames "Google/Chrome" (get-local-app-data-directory)))

(defun get-chrome-application-directory ()
  (merge-pathnames "Application" (get-chrome-base-directory)))

(defun get-chrome-user-data-directory ()
  (merge-pathnames "User Data" (get-chrome-base-directory)))

(defun get-chrome-extension-directory ()
  (merge-pathnames "Default/Extensions" (get-chrome-user-data-directory)))


(provide "chrome-extension-mode/chrome-extension")


;;; End
