;;; gdb-shell.el --- minor mode to add gdb features to shell

;; Copyright (C) 2007, 2009, 2010, 2014 Tom Tromey <tom@tromey.com>

;; Author: Tom Tromey <tom@tromey.com>
;; Created: 17 Apr 2007
;; Version: 0.7
;; Keywords: tools

;; This file is not (yet) part of GNU Emacs.
;; However, it is distributed under the same license.

;; GNU Emacs is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;; This minor mode will recognize various commands in shell mode and
;; take one of two actions.  For "build" commands (currently make,
;; valgrind, and ant), it will enable compilation-shell-minor-mode.
;; For "gdb", it will invoke Emacs' built-in gdb rather than running
;; it in the shell buffer.  This is especially handy if you use
;; "gdb --args".

;;; Code:

(defconst gdb-shell-gdb-regexp "^\\(gdb\\)\\( .*\\)$")

;; no need for this, just run compilation-shell-minor-mode
;; yourself.  duh.
(defconst gdb-shell-make-regexp "^\\(make\\|valgrind\\|ant\\) ")

(defvar gdb-shell-gdb #'gud-gdb
  "The function to use to invoke `gdb'.

This is the function to use to invoke `gdb' from
`gdb-shell-egdb'.  The default is `gud-gdb'.")

(defun gdb-shell-input-sender (proc string)
  (save-match-data
    (cond
     ((string-match gdb-shell-gdb-regexp string)
      ;; We require gud here, so that our let-binding a local does
      ;; not shadow a defvar, causing problems later.
      (require 'gud)
      (let ((gud-chdir-before-run nil))
	(if (boundp 'gud-gdb-command-name)
	    ;; Emacs 22.
	    (setq string (concat gud-gdb-command-name
				 (match-string 2 string)))
	  ;; Emacs 21.
	  (setq string (concat (match-string 1 string)
			       ;; We could use -cd but there doesn't
			       ;; seem to be a reason to.
			       " -fullname"
			       (match-string 2 string))))
	;; We only need this for Emacs 21, but it is simpler to
	;; always do it.
	(flet ((gud-gdb-massage-args (file args) args))
	  (funcall gdb-shell-gdb string))
	(setq string "")))
     ((string-match gdb-shell-make-regexp string)
      (compilation-shell-minor-mode 1))))
  (comint-simple-send proc string))

;;;###autoload
(define-minor-mode gdb-shell-minor-mode
  "Minor mode to add gdb features to shell mode."
  nil
  ""
  nil
  (if gdb-shell-minor-mode
      (progn
	(make-local-variable 'comint-input-sender)
	(setq comint-input-sender 'gdb-shell-input-sender))
    (setq comint-input-sender 'comint-simple-send)))


;; The egdb script runs gdb in a new emacs terminal frame:
;;
;; #!/bin/sh
;; lisp="(gdb-shell-egdb \"`type -p gdb`\" \"`pwd`\" \"$@\")"
;; emacsclient -t -e $lisp

;;;###autoload
(defun gdb-shell-egdb (executable dir args)
  "Start gdb.
EXECUTABLE is the path to the gdb to use.
DIR is the directory in which to run.
ARGS are the remaining arguments to gdb.
This is handy when run from the shell via emacsclient."
  (let ((gud-chdir-before-run nil)
	(default-directory (file-name-as-directory dir)))
    (funcall gdb-shell-egdb (concat executable " --annotate=3 " args))))

(provide 'gdb-shell)

;;; gdb-shell.el ends here
