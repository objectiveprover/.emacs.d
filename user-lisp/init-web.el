;;; -*- lexical-binding: t; -*-

(setopt treesit-enabled-modes '(mhtml-ts-mode css-ts-mode js-ts-mode)
        treesit-auto-install-grammar 'ask)

(use-package mhtml-ts-mode
  :ensure nil
  :custom ((mhtml-ts-mode-css-fontify-colors nil)))
