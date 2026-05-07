;;; -*- lexical-binding: t -*-

;; --------------------------------------------------
;; Scheme (Chez Scheme)

(use-package geiser-chez
  :ensure t
  :defer t
  :custom
  (geiser-chez-binary "chez"))

;; --------------------------------------------------
;; Forth (GForth)

(use-package forth-mode
  :ensure t
  :mode ("\\.fs\\'" . forth-mode)
  :commands (forth-mode run-forth)
  :config
  (require 'forth-block-mode)
  (require 'forth-interaction-mode))

;; --------------------------------------------------

(provide 'languages)
