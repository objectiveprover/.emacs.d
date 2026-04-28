;;; -*- lexical-binding: t; -*-

;; Duplicate line
;; Copied from https://github.com/rexim/dotfiles/blob/a590e0962f9c466977d12276e28c5832c05570c1/.emacs.rc/misc-rc.el#L113C1-L123C28
(defun custom/duplicate-line ()
  "Duplicate current line"
  (interactive)
  (let ((column (- (point) (point-at-bol)))
        (line (let ((s (thing-at-point 'line t)))
                (if s (string-remove-suffix "\n" s) ""))))
    (move-end-of-line 1)
    (newline)
    (insert line)
    (move-beginning-of-line 1)
    (forward-char column)))

(defun custom/beginning-of-line ()
 "Toggle between the first non-whitespace character and the beginning of the line."
 (interactive)
 (let ((orig-point (point)))
   (back-to-indentation)
   (when (= orig-point (point))
     (move-beginning-of-line 1))))

(defun custom/copy-to-clipboard ()
  "Copies selection to x-clipboard."
  (interactive)
  (if (display-graphic-p)
      (progn
	(message "Yanked region to x-clipboard!")
	(call-interactively 'clipboard-kill-ring-save))
    (if (region-active-p)
	(progn
	  (shell-command-on-region (region-beginning) (region-end) "pbcopy")
	  (message "Yanked region to clipboard!")
	  (deactivate-mark))
      (message "No region active; can't yank to clipboard!"))))

(defun custom/paste-from-clipboard ()
  "Pastes from x-clipboard."
  (interactive)
  (if (display-graphic-p)
      (progn
	(clipboard-yank)
	(message "graphics active"))
    (insert (shell-command-to-string "pbpaste"))))

;; Stefan Monnier <foo at acm.org>.
;; It is the opposite of fill-paragraph
(defun unfill-paragraph (&optional region)
  "Takes a multi-line paragraph and makes it into a single line of text."
  (interactive (progn (barf-if-buffer-read-only) '(t)))
  (let ((fill-column (point-max))
        ;; This would override `fill-column' if it's an integer.
        (emacs-lisp-docstring-fill-column t))
    (fill-paragraph nil region)))

;; When navigating by words, consider spaces as words otherwise it's confusing
;; to know where the pointer is going to go
;; (defun custom/forward-word-with-space ()
;;   "Move forward to the next space or word boundary."
;;   (interactive)
;;   (if (looking-at "[\\s-\\s.]+")
;;       (skip-syntax-forward " ")
;;     (forward-word)))

;; ;; Same as (forward-space) but backwards
;; (defun custom/backward-word-with-space ()
;;   "Move backward to the previous space or word boundary."
;;   (interactive)
;;   (if (looking-back "[\\s-\\s.]+" nil)
;;       (skip-syntax-backward " ")
;;     (backward-word)))

(provide 'functions)
