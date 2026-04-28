;;; -*- lexical-binding: t; -*-

;; I need a way to know all the keybindings I'm defining so I don't make the
;; mistake of repeating them. Also as a reference to know all the keybindings
;; that I have defined. Also, some of these keybindings have "chained" letters
;; and are they are meant to be used inside (use-package) for simplicity. Those
;; that are not "chained" are usuallt for global keybindings.

;; Sample usage:
;;   (getkey "fold-block")

;; (use-package
;;   ...
;;   :bind ((getkey "filesystem-tree") . treemacs)
;;   ...)


;; Dedicated keybindings for modes
(setq custom/mode-keybindings '(("hs-toggle-hiding" . "C-c f f")
                                ("hs-hide-all" . "C-c f a")
                                ("treemacs" . "C-c t")
                                ("mc/mark-next-like-this" . "C-c m f")
                                ("mc/mark-previous-like-this" . "C-c m b")
                                ("mc/mark-all-like-this" . "C-c m a")
                                ("er/expand-region" . "C-c SPC")
                                ("iedit-mode" . "C-c i")
                                ("vundo" . "C-x u")
                                ("helpful-callable" . "C-h f")
                                ("helpful-variable" . "C-h v")
                                ("helpful-key" . "C-h k")
                                ("helpful-command" . "C-h x")
                                ("helpful-at-point" . "C-c C-h")))

;; Standalone global keybindings
(setq custom/global-keybindings '(("recentf-open" . "C-x C-r")
                                  ("comment-line" . "C-c ;")
                                  ("dictionary-lockup-definition" . "C-c d")
                                  ("enlarge-window" . "C-c ^")
                                  ("enlarge-window-horizontally" . "C-c >")
                                  ("custom/copy-to-clipboard" . "C-c c")
                                  ("custom/paste-from-clipboard" . "C-c v")
                                  ("custom/duplicate-line" . "C-c d")
                                  ("custom/beginning-of-line" . "C-a")
                                  ("custom/backward-word-with-space" . "M-b")
                                  ("custom/forward-word-with-space" . "M-f")))

;; I didn't prefix the function like (custom/getkey) because I want it to be as
;; short as possible for readability.
;; When getting the keys we don't care if they are global or local, they are in
;; different variables just to make things clear for myself as a reference.
(defun getkey (function-name)
  "Get the custom keybinding for the function name"
  (or (assoc-default function-name custom/mode-keybindings)
      (assoc-default function-name custom/global-keybindings)))

;; Global keybindings
(keymap-global-set (getkey "recentf-open") 'recentf-open)
(keymap-global-set (getkey "comment-line") 'comment-line)
(keymap-global-set (getkey "dictionary-lockup-definition") 'dictionary-lockup-definition)
(keymap-global-set (getkey "enlarge-window") 'enlarge-window)
(keymap-global-set (getkey "enlarge-window-horizontally") 'enlarge-window-horizontally)
(keymap-global-set (getkey "custom/copy-to-clipboard") 'custom/copy-to-clipboard)
(keymap-global-set (getkey "custom/paste-from-clipboard") 'custom/paste-from-clipboard)
(keymap-global-set (getkey "custom/duplicate-line") 'custom/duplicate-line)
(keymap-global-set (getkey "custom/beginning-of-line") 'custom/beginning-of-line)
;(keymap-global-set (getkey "custom/backward-word-with-space") 'custom/backward-word-with-space)
;(keymap-global-set (getkey "custom/forward-word-with-space") 'custom/forward-word-with-space)

;; Avoid the the mistake of calling "C-x C-b" instead of "C-x b"
(global-unset-key (kbd "C-x C-b"))

(provide 'keybindings)
