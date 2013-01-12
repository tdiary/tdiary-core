;;; rd-mode.el --- Major mode for RD editing
;;; 
;;; NOTE: experimental.

;; Copyright (C) 1999 Koji Arai, Toshiro Kuwabara.

;; Author: Koji Arai, Toshiro Kuwabara
;; Created: Sat Nov 27 00:08:12 1999

;; This file is not part of GNU Emacs, but the same permissions apply.

;; GNU Emacs is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;; Settings:
;;
;; add below lines in your ~/.emacs
;;
;; (global-font-lock-mode 1 t)
;; (autoload 'rd-mode "rd-mode" "major mode for ruby document formatter RD" t)
;; (add-to-list 'auto-mode-alist '("\\.rd$" . rd-mode))

(require 'derived)

(defvar rd-use-prompt-when-insertion-p nil
  "Whether to use prompt when inserting inline.")

(defvar rd-selective-display-ellipses t
  "*Displays ellipses in RD-mode if non-nil")

(defvar rd-mode-hook nil
  "Hooks run when entering `rd-mode' major mode")

(define-derived-mode rd-mode text-mode "RD"
  "Major mode for RD editing.
\\{rd-mode-map}"
  (make-local-variable 'paragraph-separate)
  (setq paragraph-separate "=+\\|\\++\\|[ \t\n\^L]*$")
  (make-local-variable 'paragraph-start)
  (setq paragraph-start "=+\\|\\++\\|[ \t\n\^L]")
  (make-local-variable 'require-final-newline)  
  (setq require-final-newline t)
  (make-local-variable 'font-lock-defaults)
  (setq font-lock-defaults '((rd-font-lock-keywords) t nil))
  (make-local-variable 'font-lock-keywords)
  (setq font-lock-keywords rd-font-lock-keywords)
  (make-local-variable 'outline-regexp)
  (setq outline-regexp "^\\(=+\\)")
  (outline-minor-mode t)
  (add-hook (make-local-variable 'write-contents-hooks) 'rd-strip-cr-on-top)
  (add-hook (make-local-variable 'after-save-hook) 'rd-rehide-endline)
  (rd-hide-other-block-all)
  (rd-setup-keys)
  (setq indent-tabs-mode nil)
  (setq imenu-create-index-function 'rd-imenu-create-index)
  (run-hooks 'rd-mode-hook)
)

(defvar rd-heading1-face 'font-lock-keyword-face)
(defvar rd-heading2-face 'font-lock-type-face)
(defvar rd-heading3-face 'font-lock-variable-name-face)
(defvar rd-heading4-face 'font-lock-comment-face)
(defvar rd-emphasis-face 'font-lock-function-name-face)
(defvar rd-keyboard-face 'font-lock-function-name-face)
(defvar rd-variable-face 'font-lock-function-name-face)
(defvar rd-verbatim-face 'font-lock-function-name-face)
(defvar rd-term-face 'font-lock-function-name-face)
(defvar rd-footnote-face 'font-lock-function-name-face)
(defvar rd-link-face 'font-lock-function-name-face)
(defvar rd-code-face 'font-lock-function-name-face)
(defvar rd-description-face 'font-lock-constant-face)

(defvar rd-font-lock-keywords
  (list
   '("^= .*$"
     0 rd-heading1-face)
   '("^== .*$"
     0 rd-heading2-face)
   '("^=== .*$"
     0 rd-heading3-face)
   '("^=====* .*$"
     0 rd-heading4-face)
   '("((\\*[^*]*\\*+\\([^)*][^%]*\\*+\\)*))"    ; ((* ... *))
     0 rd-emphasis-face)
   '("((%[^%]*%+\\([^)%][^%]*%+\\)*))"      ; ((% ... %))
     0 rd-keyboard-face)
   '("((|[^|]*|+\\([^)|][^|]*|+\\)*))"      ; ((| ... |))
     0 rd-variable-face)
   '("(('[^']*'+\\([^)'][^']*'+\\)*))"      ; ((' ... '))
     0 rd-verbatim-face)
   '("((:[^:]*:+\\([^):][^:]*:+\\)*))"      ; ((: ... :))
     0 rd-term-face)
   '("((-[^-]*-+\\([^)-][^-]*-+\\)*))"      ; ((- ... -))
     0 rd-footnote-face)
   '("((<[^>]*>+\\([^)>][^>]*>+\\)*))"      ; ((< ... >))
     0 rd-link-face)
   '("(({[^}]*}+\\([^)}][^}]*}+\\)*))"      ; (({ ... }))
     0 rd-code-face)
   '("^:.*$"
     0 rd-description-face)
   ))

(defun rd-setup-keys ()
  (interactive)
  (define-key rd-mode-map "\t" 'rd-indent-line)
  (define-key rd-mode-map "\C-j" 'rd-newline-and-indent)
  (define-key rd-mode-map "\C-c\C-v" 'rd-cite-region)
  (define-key rd-mode-map "\C-c\C-ie" 'rd-insert-emphasis)
  (define-key rd-mode-map "\C-c\C-ic" 'rd-insert-code)
  (define-key rd-mode-map "\C-c\C-iv" 'rd-insert-var)
  (define-key rd-mode-map "\C-c\C-ik" 'rd-insert-keyboard)
  (define-key rd-mode-map "\C-c\C-ii" 'rd-insert-index)
  (define-key rd-mode-map "\C-c\C-ir" 'rd-insert-ref)
  (define-key rd-mode-map "\C-c\C-iu" 'rd-insert-reftourl)
  (define-key rd-mode-map "\C-c\C-if" 'rd-insert-footnote)
  (define-key rd-mode-map "\C-c\C-ib" 'rd-insert-verb)
  (define-key rd-mode-map "\C-c\C-y" 'rd-yank-as-url)
  (define-key rd-mode-map "\C-c\M-y" 'rd-yank-pop-as-url)
  (define-key rd-mode-map "\C-c\C-u" 'rd-insert-url)
  (define-key rd-mode-map "\M-\C-m" 'rd-intelligent-newline))

(defun rd-strip-cr-on-top ()
  (save-excursion
    (widen)
    (goto-char (point-min))
    (let ((mod (buffer-modified-p)))
      (while (re-search-forward "^\r=end\\>" nil t)
	(beginning-of-line)
	(delete-char 1)
	(forward-line))
      (set-buffer-modified-p mod)))
  nil)

(defun rd-rehide-endline ()
  (save-excursion
    (widen)
    (goto-char (point-min))
    (let ((mod (buffer-modified-p)))
      (while (re-search-forward "^=end\\>.*\r" nil t)
	(beginning-of-line)
	(insert "\r")
	(forward-line))
      (set-buffer-modified-p mod))))

(defun rd-hide-other-block ()
  "Hides following lines not in RD format."
  (interactive)
  (let (end (mod (buffer-modified-p)))
    (save-excursion
      (widen)
      (and (setq end (re-search-forward "^=begin\\>" nil t))
	   (re-search-backward "^=end\\>" nil t))
	(insert "\r")
	(while (search-forward "\n" end t)
	  (replace-match "\r" t t)))
    (set-buffer-modified-p mod))
  (setq selective-display t
	selective-display-ellipses rd-selective-display-ellipses))

(defun rd-hide-other-block-all ()
  "Hides all lines not in RD format."
  (interactive)
  (let (beg end (mod (buffer-modified-p)))
    (save-excursion
      (widen)
      (goto-char (point-min))
      (while (and (re-search-forward "^=end\\>" nil t)
		  (setq beg (progn (beginning-of-line) (point)))
		  (setq end (re-search-forward "^=begin\\>" nil t)))
	(goto-char beg)
	(insert "\r")
	(while (search-forward "\n" end t)
	  (replace-match "\r" t t))))
    (set-buffer-modified-p mod))
  (setq selective-display t
	selective-display-ellipses rd-selective-display-ellipses))
 
(defun rd-show-other-block ()
  "Shows lines not in RD format before current point."
  (interactive)
  (if selective-display
      (save-excursion
	(let (end (mod (buffer-modified-p)))
	  (widen)
	  (if (re-search-forward "^\r=end\\>" nil t)
	      (progn
		(end-of-line)
		(setq end (point))
		(beginning-of-line)
		(delete-char 1)
		(while (search-forward "\r" end t)
		  (replace-match "\n" t t))))
	  (set-buffer-modified-p mod)))))

(defun rd-show-other-block-all ()
  "Shows all lines not in RD format."
  (interactive)
  (if selective-display
      (save-excursion
	(let (end (mod (buffer-modified-p)))
	  (widen)
	  (goto-char (point-min))
	  (while (re-search-forward "^\r=end\\>" nil t)
	    (end-of-line)
	    (setq end (point))
	    (beginning-of-line)
	    (delete-char 1)
	    (while (search-forward "\r" end t)
	      (replace-match "\n" t t)))
	  (set-buffer-modified-p mod))))
  (setq selective-display nil selective-display-ellipses t))

(defun rd-show-label-list ()
  "Show RD Label list through temporary buffer."
  (interactive)
  (occur "^\\(=+\\s-\\|\\+\\|\\s-*:\\|\\s-*---\\)"))

(defun rd-insert-inline (beg end str)
  "Insert Inline Inline (general)."
  (if str
      (insert (concat beg str end))
  (progn
    (if rd-use-prompt-when-insertion-p
        (rd-insert-inline beg end (read-string (concat beg " elm " end ": ")))
      (insert beg end)
      (backward-char (length end))))))

(defun rd-insert-emphasis (&optional str)
  "Insert Inline Emphasis."
  (interactive "*") (rd-insert-inline "((*" "*))" str))

(defun rd-insert-code (&optional str)
  "Insert Inline Code."
  (interactive "*") (rd-insert-inline "(({" "}))" str))

(defun rd-insert-var (&optional str)
  "Insert Inline Var."
  (interactive "*") (rd-insert-inline "((|" "|))" str))

(defun rd-insert-keyboard (&optional str)
  "Insert Inline Keyboard."
  (interactive "*") (rd-insert-inline "((%" "%))" str))

(defun rd-insert-index (&optional str)
  "Insert Inline Index."
  (interactive "*") (rd-insert-inline "((:" ":))" str))

(defun rd-insert-ref (&optional str)
  "Insert Inline Reference."
  (interactive "*") (rd-insert-inline "((<" ">))" str))

(defun rd-insert-reftourl (&optional str)
  "Insert Inline RefToURL."
  (interactive "*") (rd-insert-inline "((<URL:" ">))" str))

(defun rd-insert-footnote (&optional str)
  "Insert Inline Footnote."
  (interactive "*") (rd-insert-inline "((-" "-))" str))

(defun rd-insert-verb (&optional str)
  "Insert Inline Verb."
  (interactive "*") (rd-insert-inline "(('" "'))" str))

(defun rd-yank-as-url (&optional arg)
  "Yank as Inline RefToURL."
  (interactive "*P")
  (yank arg)
  (setq this-command 'yank)
  (let ((yanked-str
	 (concat "((<URL:" (buffer-substring (point) (mark t)) ">))")))
    (delete-region (point) (mark t))
    (if (listp arg)
	(insert yanked-str)
      (insert-before-markers yanked-str))))

(defun rd-yank-pop-as-url (arg)
  "Yank pop as Inline RefToURL."
  (interactive "*p")
  (if (not (eq last-command 'yank))
      (progn
	(insert (symbol-name last-command))
      (error "Previous command is not yank-like.")))
  (setq this-command 'yank)
  (yank-pop arg)
  (let ((yanked-str
	 (concat "((<URL:" (buffer-substring (point) (mark t)) ">))")))
    (delete-region (point) (mark t))
    (insert yanked-str)))

(defun rd-newline-and-indent ()
  "Newline and indent as deep as prev line."
  (interactive "*")
  (newline)
  (rd-indent-line))

(defun rd-indent-line ()
  "Indent line as deep as prev line."
  (interactive "*")
  (let ((prev-indent (progn
		       (forward-line -1)
		       (rd-current-indentation))))
    (forward-line 1)
    (rd-indent-to prev-indent)
    (back-to-indentation)))

(defun rd-line-list-p ()
  "Whether the line is list or not."
  (save-excursion
    (beginning-of-line)
    (looking-at " *\\*\\|---")))

(defun rd-indent-to (num)
  (let (beg)
    (save-excursion
      (beginning-of-line)
      (setq beg (point))
      (back-to-indentation)
      (delete-region beg (point))
      (indent-to num))))

(defun rd-current-indentation ()
  ""
  (save-excursion
    (beginning-of-line)
    (looking-at "--- +\\| *\\(\\* +\\|([0-9]+) +\\)?")
    (length (buffer-substring (match-beginning 0)(match-end 0)))))
  
(defun rd-cite-region (beg end)
  "Make region into Verbatim."
  (interactive "r*")
  (let (listp prev-indent indent)
    (save-excursion
      (goto-char beg)
      (forward-line -1)
      (setq listp (rd-line-list-p)
            prev-indent (rd-current-indentation))
      (forward-line 1)
      (setq indent (rd-current-indentation))
      (if (and listp
               (not (= (- indent prev-indent) 2)))
          (rd-indent-region beg end (- (+ prev-indent 2) indent))
        (cond ((= prev-indent indent)
               (rd-indent-region beg end 2))
              ((> prev-indent indent)
               (rd-indent-region beg end prev-indent))
              (t
               (goto-char end)))))))
  
(defun rd-indent-region (beg end &optional indent)
  "Make the indent of region deeper by INDENT."
  (interactive "r*")
  (setq indent (or indent 2))
  (save-excursion
    (goto-char beg)
    (while (< (point) end)
      (setq end (+ end indent))
      (insert-char ?  indent)
      (forward-line 1))))

(defun rd-yank-as-verbatim (&optional arg)
  (interactive "P")
  (let ((beg (point))
        (end (progn
               (yank)
              (point)))
        )
    (rd-cite-region beg end)
    (if arg (goto-char beg))))

(defun rd-insert-buffer-as-verbatim (buf)
  (interactive "bInsert buffer (verb): ")
  (insert-buffer buf)
  (rd-cite-region (point)(mark)))


(defun rd-insert-url (url label)
  ""
  (interactive "sURL: \nsLabel: ")
  (if (string= label "")
      (rd-insert-reftourl url)
    (rd-insert-ref (concat label "|URL:" url))))

(defun rd-search-last-listitem ()
  (beginning-of-line)
  (if (looking-at "[ \t]*\\(\\*\\|([0-9])\\|:\\|---\\)[ \t]*")
      (match-string 0)
    (and (and (eq
               (rd-current-indentation)
               (progn (forward-line -1) (rd-current-indentation))
               )
              (not (eq (point) (point-min)) )
              )
         (rd-search-last-listitem)
         )
    )
  )

(defun rd-intelligent-newline ()
  (interactive)
  (let (item)
    (setq item
          (save-excursion (rd-search-last-listitem) )
          )
    (end-of-line)
    (newline)
    (if item (insert-string item) )
    )
  )

(defun rd-imenu-create-index ()
  (let ((root '(nil . nil))
        cur-alist
        (cur-level 0)
        (pattern "^\\(=+\\)[ \t\v\f]*\\(.*?\\)[ \t\v\f]*$")
        (empty-heading "-")
        (self-heading ".")
        pos level heading alist)
    (save-excursion
      (goto-char (point-min))
      (while (re-search-forward pattern (point-max) t)
        (setq heading (match-string-no-properties 2)
              level (min 6 (length (match-string-no-properties 1)))
              pos (match-beginning 1))
        (if (= (length heading) 0)
            (setq heading empty-heading))
        (setq alist (list (cons heading pos)))
        (cond
         ((= cur-level level)		; new sibling
          (setcdr cur-alist alist)
          (setq cur-alist alist))
         ((< cur-level level)		; first child
          (dotimes (i (- level cur-level 1))
            (setq alist (list (cons empty-heading alist))))
          (if cur-alist
              (let* ((parent (car cur-alist))
                     (self-pos (cdr parent)))
                (setcdr parent (cons (cons self-heading self-pos) alist)))
            (setcdr root alist))	; primogenitor
          (setq cur-alist alist
                cur-level level))
         (t				; new sibling of an ancestor
          (let ((sibling-alist (last (cdr root))))
            (dotimes (i (1- level))
              (setq sibling-alist (last (cdar sibling-alist))))
            (setcdr sibling-alist alist)
            (setq cur-alist alist
                  cur-level level))))))
    (cdr root)))

(provide 'rd-mode)
;;; rd-mode.el ends here

