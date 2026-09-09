;;; -*- lexical-binding: t; -*-

;; Duplicate line
;; Copied from https://github.com/rexim/dotfiles/blob/a590e0962f9c466977d12276e28c5832c05570c1/.emacs.rc/misc-rc.el#L113C1-L123C28
(defun custom/duplicate-line ()
  "Duplicate current line"
  (interactive)
  (let ((column (- (point) (line-beginning-position)))
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

;; Clipboard integration
(defconst custom/clipboard-paste-command
  (cond ((eq system-type 'darwin) "pbpaste")
        ((getenv "WAYLAND_DISPLAY") "wl-paste --no-newline")
        ((getenv "DISPLAY") "xclip -selection clipboard -o")
        (t nil))
  "Shell command writing the system clipboard to stdout, or nil if unavailable.")

(defun custom/osc52-copy (text)
  "Send TEXT to the terminal's clipboard via OSC 52.
Wraps the sequence for tmux/screen passthrough when running inside either."
  (let* ((payload (base64-encode-string
                   (encode-coding-string text 'utf-8) t))
         (seq (format "\e]52;c;%s\a" payload)))
    (send-string-to-terminal
     (cond ((getenv "TMUX")
            (format "\ePtmux;\e%s\e\\" seq))
           ((string-prefix-p "screen" (or (getenv "TERM") ""))
            (format "\eP%s\e\\" seq))
           (t seq)))))

(defun custom/copy-to-clipboard ()
  "Copy the active region to the system clipboard."
  (interactive)
  (cond ((display-graphic-p)
         (call-interactively #'clipboard-kill-ring-save)
         (message "Yanked region to clipboard"))
        ((region-active-p)
         (custom/osc52-copy (buffer-substring-no-properties
                             (region-beginning) (region-end)))
         (deactivate-mark)
         (message "Yanked region to clipboard"))
        (t (message "No region active; can't yank to clipboard"))))

(defun custom/paste-from-clipboard ()
  "Insert the system clipboard at point."
  (interactive)
  (cond ((display-graphic-p) (clipboard-yank))
        (custom/clipboard-paste-command
         (insert (shell-command-to-string custom/clipboard-paste-command)))
        (t (message "No clipboard reader available; use the terminal's paste"))))

;; Stefan Monnier <foo at acm.org>.
;; It is the opposite of fill-paragraph
(defun unfill-paragraph (&optional region)
  "Takes a multi-line paragraph and makes it into a single line of text."
  (interactive (progn (barf-if-buffer-read-only) '(t)))
  (let ((fill-column (point-max))
        ;; This would override `fill-column' if it's an integer.
        (emacs-lisp-docstring-fill-column t))
    (fill-paragraph nil region)))

(provide 'functions)
