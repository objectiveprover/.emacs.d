;;; -*- lexical-binding: t -*-
(require 'package)

;; Highlight certain ubiquitous elisp functions as keywords to make code look
;; nicer to read.
(let ((keywords '("add-to-list"
                  "set-face-attribute"
                  "set-face-background"
                  "custom-set-variables"
                  "keymap-global-set"
                  "add-hook"
                  "car"
                  "cdr"
                  "concat")))
  (font-lock-add-keywords 'emacs-lisp-mode
    `((,(concat "\\_<" (regexp-opt keywords t) "\\_>")
       . font-lock-keyword-face))))

(add-to-list 'load-path (expand-file-name "packages" user-emacs-directory)) ; Third party code
(add-to-list 'load-path (expand-file-name "custom" user-emacs-directory)) ; My code

(require 'variables) ;; Global Variables
(require 'colors) ;; Color palette
(require 'functions) ;; Custom functions
(require 'keybindings) ;; Keybindings reference (No keybindings set in there)

(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

;; Install packages in this list with M-x package-install-selected-packages
;; We only need to list the packages that are not bundled with Emacs
;; I do this manually instead of relying on the automatic method of Emacs because
;; I like to know what's being installed and make sure it's all intentional.
(setq package-selected-packages
      '(olivetti
        iedit
        vertico
        marginalia
        flycheck
        geiser-chez
        yasnippet
        expand-region
        multiple-cursors
        visual-fill-column
        paren-face
        treemacs
        delight
        helpful
        breadcrumb
        magit
        git-gutter
        spell-fu))

(use-package git-gutter
  :ensure t
  :delight
  :init
  (global-git-gutter-mode +1)
  :config
  (set-face-attribute 'git-gutter:modified nil :foreground ansi-color-bright-white :weight 'normal)
  (set-face-attribute 'git-gutter:added nil :foreground ansi-color-bright-white :weight 'normal)
  (set-face-attribute 'git-gutter:deleted nil :foreground ansi-color-bright-white :weight 'normal)
  (custom-set-variables
   '(git-gutter:modified-sign "∓")
   '(git-gutter:added-sign "+")
   '(git-gutter:deleted-sign "-")))

(use-package breadcrumb
  :ensure t)

(use-package helpful
  :ensure t
  :config
  (keymap-global-set (getkey "helpful-callable") 'helpful-callable)
  (keymap-global-set (getkey "helpful-variable") 'helpful-variable)
  (keymap-global-set (getkey "helpful-key") 'helpful-key)
  (keymap-global-set (getkey "helpful-command") 'helpful-command)
  (keymap-global-set (getkey "helpful-at-point") 'helpful-at-point))

(use-package delight
  :ensure t)

(use-package eldoc
  :delight)

(use-package hideshow
  :ensure t
  :delight (hs-minor-mode)
  :hook
  (prog-mode . hs-minor-mode)
  :config
  (keymap-global-set (getkey "hs-toggle-hiding") 'hs-toggle-hiding)
  (keymap-global-set (getkey "hs-hide-all") 'hs-hide-all))

(use-package treemacs
  :ensure t
  :config
  (keymap-global-set (getkey "treemacs") 'treemacs)
  (set-face-attribute 'treemacs-git-modified-face nil :foreground ansi-color-black :slant 'normal)
  (set-face-attribute 'treemacs-git-added-face nil :foreground ansi-color-black))

;; Add parentheses face everywhere
(use-package paren-face
  :ensure t
  :hook (prog-mode . paren-face-mode)
  :init
  (global-paren-face-mode)
  :config
  (set-face-attribute 'parenthesis nil :foreground ansi-color-white :weight 'normal)
  (setq paren-face-modes '(prog-mode))
  (setq paren-face-regexp "[][()}{]"))

;; Remove whitespace modeline indicator
(use-package whitespace
  :delight whitespace-mode)

;; Center text
(use-package visual-fill-column
  :ensure t
  :hook (visual-line-mode . visual-fill-column-for-vline)
  :custom
  (visual-fill-column-center-text t))

(use-package simple
  :delight visual-line-mode)

(use-package markdown-mode
  :defer t
  :custom
  (fill-column 80)
  :init
  (add-hook 'visual-line-mode-hook #'visual-fill-column-for-vline)
  :config
  (add-hook 'markdown-mode-hook
            (lambda ()
              (auto-fill-mode -1)
              (visual-line-mode)
              (whitespace-mode)
              (set-face-attribute 'whitespace-space nil :background nil :foreground ansi-color-black :weight 'bold)
              ;; We don't want highlighting long lines on Markdown documents
              ;; because every paragraph is a line.
              (set-face-attribute 'whitespace-line nil :background nil :foreground nil)
              ;; I use as little syntax highlighting as possible, but sometimes
              ;; we ned to be able to visually parse text fast.
              (face-remap-add-relative 'font-lock-keyword-face :foreground ansi-color-black)
              (font-lock-update))))

;; Select and edit multiple things at the same time
(use-package multiple-cursors
  :ensure t
  :config
  (keymap-global-set (getkey "mc/mark-next-like-this") 'mc/mark-next-like-this)
  (keymap-global-set (getkey "mc/mark-previous-like-this") 'mc/mark-previous-like-this)
  (keymap-global-set (getkey "mc/mark-all-like-this") 'mc/mark-all-like-this))




;; Version Control
(use-package magit
  :ensure t
  :config
  ;; (set-face-attribute
  ;;  'magit-diff-added nil :background color-background :foreground color-black)
  ;; (set-face-attribute
  ;;  'magit-diff-removed nil :background color-background :foreground color-black)
  ;; (set-face-attribute
  ;;  'magit-diff-added-highlight nil :background color-background :foreground color-black)
  ;; (set-face-attribute
  ;;  'magit-diff-removed-highlight nil
  ;;  :background color-background :foreground color-black)
  ;; (set-face-attribute
  ;;  'magit-diff-context-highlight nil
  ;;  :background color-background :foreground color-black)
  ;; (set-face-attribute
  ;;  'magit-diff-hunk-heading-highlight nil
  ;;  :background color-white :foreground color-black :weight 'bold)
  ;; (set-face-attribute
  ;;  'magit-diff-hunk-heading nil
  ;;  :background color-white :foreground color-black :weight 'normal)
  ;; (set-face-attribute
  ;;  'magit-section-heading nil :background nil :foreground color-black)
  )

;; Increase selection in a semantic way
(use-package expand-region
  :ensure t
  :config
  (keymap-global-set (getkey "er/expand-region") 'er/expand-region))

(use-package dired
  :custom
  (dired-listing-switches "-alh")
  (dired-dwim-target t)
  :config
  (set-face-foreground 'dired-directory flexoki-blue-700)
  (add-hook 'dired-hook #'dired-hide-details-mode))

;; A better experience for writing text
(use-package olivetti
  :ensure t
  :defer t
  :hook org-mode)

;; Display the undo tree
(use-package vundo
  :ensure t
  :config
  (keymap-global-set (getkey "vundo") 'vundo)
  :custom
  (vundo-glyph-alist vundo-unicode-symbols))

;; Simultaneous editing of occurrences
;; To avoid editing all instances, it's a good idea to combine with:
;; C-x n n -> narrow-to-region
;; C-x n w -> widen (restore full buffer view)
(put 'narrow-to-region 'disabled nil) ; Enable narrow-to-region
(use-package iedit
  :ensure t
  :defer t
  :config
  (keymap-global-set (getkey "iedit-mode") 'iedit-mode)
  (set-face-background 'iedit-occurrence color-white))

;; Show what functions are available on M-x
(use-package vertico
  :ensure t
  :defer t
  :init
  (vertico-mode))

;; Display descriptions of functions
(use-package marginalia
  :ensure t
  :defer t
  :init
  (marginalia-mode))

;; Make all whitespace characters visible
(use-package whitespace
  :config
  ;; (set-face-attribute 'whitespace-line nil
  ;;                     :background color-white
  ;;                     :foreground color-black)
  )

;; Persist history over Emacs restarts.
;; - Vertico sorts by history position.
(use-package savehist
  :ensure t
  :init
  (savehist-mode))

;; Enable finding functions, variables, etc.
;; Without being precise in the spelling.
(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion))))
  (completion-pcm-leading-wildcard t))

;; .editorconfig file support
(use-package editorconfig
  :ensure t
  :defer t
  :delight
  :config
  (editorconfig-mode +1))

;; Enable code checking
(use-package flycheck
  :ensure t
  :custom
  ;;(flycheck-disabled-checkers '(emacs-lisp emacs-lisp-checkdoc))
  (flycheck-disabled-checkers '(emacs-lisp-checkdoc))
  (flycheck-mode-line-prefix " FC")
  (flycheck-emacs-lisp-load-path 'inherit)
  :init
  (global-flycheck-mode)
  :config
  (setq flycheck-mode-line
        '(:eval (pcase flycheck-last-status-change
                  (`finished
                   (let* ((counts (flycheck-count-errors flycheck-current-errors))
                          (errors (or (cdr (assq 'error counts)) 0))
                          (warnings (or (cdr (assq 'warning counts)) 0))
                          (infos (or (cdr (assq 'info counts)) 0)))
                     (format " E:%d W:%d I:%d " errors warnings infos)))
                  (`running " FC:running")
                  (`no-checker " FC:off")
                  (`not-checked " FC:?")
                  (`errored " FC:err")
                  (`interrupted " FC:stopped")))))

;; Spell check for natural language
;; Requires Aspell
(use-package spell-fu
  :ensure t
  :config
  (spell-fu-global-mode)

  (defun custom/spell-fu-add-personal-dict ()
    (spell-fu-dictionary-add
     (spell-fu-get-ispell-dictionary "en_US"))
    (spell-fu-dictionary-add
     (spell-fu-get-personal-dictionary
      "en-personal"
      (expand-file-name "personal-dictionary.pws" user-emacs-directory))))

  (add-hook 'spell-fu-mode-hook #'custom/spell-fu-add-personal-dict)
  :custom-face
  (spell-fu-incorrect-face
   ((t (:underline nil :style wave :color ,ansi-color-red))))
  :custom
  (spell-fu-faces-exclude
   '(font-lock-keyword-face
     font-lock-function-name-face
     font-lock-variable-name-face
     font-lock-builtin-face
     font-lock-constant-face
     font-lock-type-face)))

;; Quickly insert bits of code
(use-package yasnippet
  :ensure t
  :delight (yas-minor-mode)
  :custom
  (yas-snippet-dirs '("~/.emacs.d/snippets"))
  :init
  (yas-global-mode 1))

(require 'languages)

;; --------------------------------------------------
;; General settings

;; Automatically wrap comments
(setq comment-auto-fill-only-comments t)
(add-hook 'prog-mode-hook 'turn-on-auto-fill)

;; Dictionary
(setq dictionary-server "dict.org")

;; How total number of matches when searching
(setq isearch-lazy-count t)

;; Delay inline suggestions by 1 second
(setq completion-preview-idle-delay 1)

;; Never use tabs for indentation
(setq-default indent-tabs-mode nil)

;; Show recent files when invoking find-file
(recentf-mode 1)

;; Enable ANSI colors when using compile mode
(add-hook 'compilation-filter-hook #'ansi-color-compilation-filter)

;; Auto-scroll when something repeatedly shows in the compile mode
(with-eval-after-load 'compile
  (setq compilation-scroll-output t))

;; Show what keybindings are available after a prefix like C-x or C-c.
(use-package which-key
  :ensure t
  :delight
  :config
  (setq which-key-separator " → "
        which-key-max-display-columns 1
        which-key-popup-type 'side-window
        which-key-side-window-location 'bottom
        which-key-side-window-max-width 0.75
        which-key-max-description-length 0.9
        which-key-show-docstrings t)
  :init
  (which-key-mode t))

;; Keep buffers in sync with file changes
(global-auto-revert-mode t)

;; Keep buffers in sync with directory changes
(setq global-auto-revert-non-file-buffers t)

;; Don't show a startup screen
(setq inhibit-startup-screen t)

;; Avoid having backup and autosave files everywhere
(setq backup-directory-alist '(("." . "~/.emacs.d/backups")))
(setq auto-save-file-name-transforms '((".*" "~/.emacs.d/autosaves/" t)))

;; Make sure there is always a new line at the end of the file
(setq require-final-newline t)

;; Remove trailing whitespace when saving a file
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; Remove the dash separator in the mode line
(setq-default mode-line-end-spaces "")

;; Hide menu bar
(menu-bar-mode -1)

;; Ask for Y or N instead of Yes or No
(defalias 'yes-or-no-p 'y-or-n-p)

;; Display line numbers
(global-display-line-numbers-mode 1)
(setq display-line-numbers-type 'relative)

;; Display column numbers
(setq column-number-mode t)

;; Enable auto-completion for code and text
(use-package completion-preview
  :delight
  :init
  (global-completion-preview-mode))

;; Match delimiters
(setq electric-pair-preserve-balance t)
(setq electric-pair-delete-adjacent-pairs t)
(electric-pair-mode)

;; --------------------------------------------------
;; Color customization

;; Global UI
(set-face-attribute 'mode-line nil
                    :background color-dark-background
                    :foreground ansi-color-black
                    :box '(:style flat-button :line-width 4))

(set-face-attribute 'mode-line-inactive nil
                    :background ansi-color-bright-white
                    :foreground ansi-color-bright-black
                    :box '(:style flat-button :line-width 4))

(set-face-attribute 'default nil
                    :foreground ansi-color-black
                    :background color-background)

(set-face-background 'show-paren-match nil)
(set-face-foreground 'show-paren-match ansi-color-red)
(set-face-foreground 'line-number ansi-color-white)
(set-face-foreground 'line-number-current-line ansi-color-red)
(set-face-background 'region color-region)
(set-face-attribute 'isearch nil :background color-dark-background :foreground ansi-color-red)
(set-face-attribute 'lazy-highlight nil
                    :background color-dark-background :foreground ansi-color-red)
(set-face-attribute 'minibuffer-prompt nil
                    :foreground ansi-color-black :weight 'normal)
(set-face-attribute 'highlight nil :background color-dark-background)

;; Syntax highlighting
(set-face-attribute 'font-lock-function-name-face nil :foreground ansi-color-black)
(set-face-attribute 'font-lock-function-call-face nil :foreground ansi-color-black)
(set-face-attribute 'font-lock-variable-name-face nil :foreground ansi-color-black :slant 'italic)
(set-face-attribute 'font-lock-variable-use-face nil :foreground ansi-color-black)
(set-face-attribute 'font-lock-keyword-face nil :foreground ansi-color-black :weight 'bold)
(set-face-attribute 'font-lock-comment-face nil
                    :slant 'italic
                    :foreground ansi-color-cyan)
(set-face-attribute 'font-lock-type-face nil :foreground ansi-color-black)
(set-face-attribute 'font-lock-constant-face nil :foreground ansi-color-black)
(set-face-attribute 'font-lock-builtin-face nil :foreground ansi-color-black :weight 'bold :slant 'italic)
(set-face-attribute 'font-lock-string-face nil
                    :slant 'italic
                    :foreground ansi-color-bright-black)
(set-face-attribute 'font-lock-number-face nil :foreground ansi-color-black)
(set-face-attribute 'font-lock-operator-face nil :foreground ansi-color-black)
(set-face-attribute 'font-lock-punctuation-face nil :foreground ansi-color-black)
(set-face-attribute 'font-lock-bracket-face nil :foreground ansi-color-black)
(set-face-attribute 'font-lock-delimiter-face nil :foreground ansi-color-black)
(set-face-attribute 'font-lock-escape-face nil :foreground ansi-color-black)
(set-face-attribute 'error nil :underline `(:style wave :color ,ansi-color-red) :weight 'normal)
(set-face-attribute 'flycheck-warning nil :foreground ansi-color-yellow :weight 'normal)
(set-face-attribute 'error nil :underline `(:style wave :color ,ansi-color-red) :foreground ansi-color-red)
