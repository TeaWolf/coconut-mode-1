;;; coconut-mode.el --- sample major mode for editing Coconut.

;; Copyright © 2016, by Victor Santos

;; Author: Victor Santos ( victor_santos@fisica.ufc.br )
;; Version: 2.0.13
;; Created: 02 Nov 2016
;; Keywords: languages
;; Homepage: http://gitlab.com/padawanphysicist/coconut-mode

;; This file is not part of GNU Emacs.

;;; License:

;; You can redistribute this program and/or modify it under the terms of the GNU General Public License version 2.

;;; Commentary:

;; Major mode for Coconut Lang

;;; Code:
(add-to-list 'auto-mode-alist '("\\.coco$" . coconut-mode))

;; Python keywords + Coconut keywords
(defvar coconut-keywords
  '("False" "None" "True" "and"
    "as" "assert" "break" "case"
    "class" "continue" "data" "def"
    "del" "elif" "else" "except"
    "finally" "for" "from" "global"
    "if" "import" "in" "is"
    "lambda" "match" "nonlocal" "not"
    "or" "pass" "raise" "return"
    "try" "while" "with" "yield"))

;; Some builtin functions
(defvar coconut-builtin-functions
  '("abs" "all" "any" "ascii"
    "bin" "bool" "bytearray" "bytes"
    "callable" "chr" "classmethod" "compile" 
    "complex" "consume" "delattr" "dict" "dir"
    "divmod" "enumerate" "eval" "exec"
    "filter" "float" "format" "frozenset"
    "getattr" "globals" "hasattr" "hash"
    "help" "hex" "id" "input"
    "int" "isinstance" "issubclass" "iter"
    "len" "list" "locals" "map"
    "max" "memoryview" "min" "next"
    "object" "oct" "open" "ord"
    "pow" "print" "property" "range"
    "reduce" "repr" "reversed" "round" "set"
    "setattr" "slice" "sorted" "staticmethod"
    "str" "sum" "super" "tuple"
    "type" "vars" "zip" "__import__"
    ))

  ;; Two small edits.
  ;; First is to put an extra set of parens () around the list
  ;; which is the format that font-lock-defaults wants
  ;; Second, you used ' (quote) at the outermost level where you wanted ` (backquote)
  ;; you were very close
  (defvar coconut-font-lock-defaults
    `((
       ;; stuff between double quotes
       ("\"\\.\\*\\?" . font-lock-string-face)
       ;; Functions
       ("\\<def[ \t]+\\([a-zA-Z]+[a-zA-Z0-9_]*\\)" 1 font-lock-function-name-face)
       ;; |> |*> <| <*| -> are treated as special 
       ("\|>\\|<\|\\|<\\*\|\\|\|\\*>\\|->\\|\\$" . font-lock-variable-name-face)
       ( ,(regexp-opt coconut-keywords 'words) . font-lock-keyword-face)
       ( ,(regexp-opt coconut-builtin-functions 'words) . font-lock-builtin-face)
       )))

  (define-derived-mode coconut-mode python-mode "Coconut script"
    "Coconut mode is a major mode for editing coconut files"

    (setq font-lock-defaults coconut-font-lock-defaults)
    ;; Note that there's no need to manually call `coconut-mode-hook'; `define-derived-mode'
    ;; will define `coconut-mode' to call it properly right before it exits

    ;; Support for shell integration through some python mode hacks
    (setq python-shell-interpreter "coconut")
    (setq python-shell-interpreter-args "-i")

    (setq python-shell-prompt-output-regexp "")

    (add-to-list 'python-shell-setup-codes "import coconut.convenience;coconut.convenience.setup(line_numbers=True, keep_lines=True, target='sys')")


    (defun python-shell-send-file (file-name &optional process temp-file-name
                                             delete msg)
      "Send FILE-NAME to inferior Python PROCESS.
If TEMP-FILE-NAME is passed then that file is used for processing
instead, while internally the shell will continue to use
FILE-NAME.  If TEMP-FILE-NAME and DELETE are non-nil, then
TEMP-FILE-NAME is deleted after evaluation is performed.  When
optional argument MSG is non-nil, forces display of a
user-friendly message if there's no process running; defaults to
t when called interactively."
      (interactive
       (list
        (read-file-name "File to send: ")   ; file-name
        nil                                 ; process
        nil                                 ; temp-file-name
        nil                                 ; delete
        t))                                 ; msg
      (let* ((process (or process (python-shell-get-process-or-error msg)))
             (encoding (with-temp-buffer
                         (insert-file-contents
                          (or temp-file-name file-name))
                         (python-info-encoding)))
             (file-name (expand-file-name (file-local-name file-name)))
             (temp-file-name (when temp-file-name
                               (expand-file-name
                                (file-local-name temp-file-name)))))
        (python-shell-send-string
         (format
          (concat
           "import codecs, os;"
           "__pyfile = codecs.open('''%s''', encoding='''%s''');"
           "__code = __pyfile.read();"
           "__pyfile.close();"
           (when (and delete temp-file-name)
             (format "os.remove('''%s''');" temp-file-name))
           "exec(coconut.convenience.parse(__code, 'block'));")
          (or temp-file-name file-name) encoding file-name)
         process))))
  (provide 'coconut-mode)

;; Local Variables:
;; coding: utf-8
;; End:

;;; coconut-mode.el ends here
