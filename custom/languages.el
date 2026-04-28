;;; -*- lexical-binding: t -*-

(add-hook 'prog-mode-hook (lambda ()
  (setq indent-tabs-mode nil)
  (setq tab-width 2)))

(setq js-indent-level 2)

(add-hook 'css-ts-mode-hook '(lambda ()
                               (setq css-indent-offset 2)
                               (setq css-ts-mode-indent-offset 2)
                               (setq indent-tabs-mode nil)
                               (setq tab-width 2)
                               (setq css-fontify-colors nil)))

;; --------------------------------------------------
;; Tree-sitter Parsers
;; Run treesit-install-language-grammar
;;
;; Because apparently tree-sitter parsers are a lot faster
;; than the classic ones written in Elisp.

(setq treesit-language-source-alist
      '((html "https://github.com/tree-sitter/tree-sitter-html")
        (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src")
        (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
        (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
        (css "https://github.com/tree-sitter/tree-sitter-css")
        (json "https://github.com/tree-sitter/tree-sitter-json")))

;; Evaluate to install grammars
;; (mapc #'treesit-install-language-grammar (mapcar #'car treesit-language-source-alist))

;; (use-package haskell-ts-mode
;;   :custom
;;   (haskell-ts-use-indent t)
;;   :vc (:url "git@github.com:Jaiheravi/haskell-ts-mode.git"
;;             :rev :newest))

(add-hook 'js-mode-hook #'js-ts-mode)
;;(add-hook 'html-mode-hook #'html-ts-mode)
(add-hook 'json-mode-hook #'json-ts-mode)

(add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-ts-mode))
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . tsx-ts-mode))
(add-to-list 'auto-mode-alist '("\\.css\\'" . css-ts-mode))
(add-to-list 'auto-mode-alist '("\\.html\\'" . html-ts-mode))

;; --------------------------------------------------
;; Scheme (Chez Scheme)
(use-package geiser-chez
  :ensure t
  :defer t
  :config
  (setq geiser-chez-binary "chez"))

(provide 'languages)
