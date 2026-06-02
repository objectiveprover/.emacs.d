;; -*- lexical-binding: t; -*-

(require 'package)

;; Highlight certain ubiquitous elisp functions as keywords to make code look
;; nicer to read.
(let ((keywords '("add-to-list"
                  "set-face-attribute"
                  "set-face-background"
                  "set-face-foreground"
                  "custom-set-variables"
                  "keymap-global-set"
                  "add-hook"
                  "car"
                  "cdr"
                  "concat"
                  "list")))
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
        spell-fu
        forth-mode))

;; Avoid loading stuff when starting Emacs so it starts faster
(setopt use-package-always-defer t)

(use-package git-gutter
  :ensure t
  :delight
  :init
  (global-git-gutter-mode +1)
  :config
  (set-face-attribute 'git-gutter:modified nil :foreground custom/color-bright-blue :weight 'normal)
  (set-face-attribute 'git-gutter:added nil :foreground custom/color-bright-green :weight 'normal)
  (set-face-attribute 'git-gutter:deleted nil :foreground custom/color-bright-red :weight 'normal)
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

;; Code folding
(use-package hideshow
  :ensure t
  :delight (hs-minor-mode)
  :hook
  (prog-mode . hs-minor-mode)
  :config
  (keymap-global-set (getkey "hs-toggle-hiding") 'hs-toggle-hiding)
  (keymap-global-set (getkey "hs-hide-all") 'hs-hide-all))

;; File tree sidebar
(use-package treemacs
  :ensure t
  :config
  (keymap-global-set (getkey "treemacs") 'treemacs)
  (set-face-attribute 'treemacs-git-modified-face nil
                      :foreground custom/color-black
                      :slant 'normal)
  (set-face-attribute 'treemacs-git-added-face nil
                      :foreground custom/color-black))

;; Add parentheses face everywhere
(use-package paren-face
  :ensure t
  :hook (prog-mode . paren-face-mode)
  :init
  (global-paren-face-mode)
  :config
  (set-face-attribute 'parenthesis nil
                      :foreground custom/color-white
                      :weight 'normal)
  (setq paren-face-modes '(prog-mode))
  (setq paren-face-regexp "[][()}{]"))

;; Remove whitespace mode-line indicator
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
              (set-face-attribute 'whitespace-space nil
                                  :background nil
                                  :foreground custom/color-black
                                  :weight 'bold)
              ;; We don't want highlighting long lines on Markdown documents
              ;; because every paragraph is a line.
              (set-face-attribute 'whitespace-line nil
                                  :background nil
                                  :foreground nil)
              ;; I use as little syntax highlighting as possible, but sometimes
              ;; we ned to be able to visually parse text fast.
              (face-remap-add-relative 'font-lock-keyword-face
                                       :foreground custom/color-black)
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
  :ensure t)

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
  (set-face-foreground 'dired-directory custom/color-blue))

;; A better experience for writing text
(use-package olivetti
  :ensure t
  :hook org-mode)

;; Display the undo tree
(use-package vundo
  :defer nil
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
  :config
  (keymap-global-set (getkey "iedit-mode") 'iedit-mode)
  (set-face-background 'iedit-occurrence custom/color-white))

;; Show what functions are available on M-x
(use-package vertico
  :ensure t
  :init
  (vertico-mode))

;; Display descriptions of functions
(use-package marginalia
  :ensure t
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
  :delight
  :config
  (editorconfig-mode +1))

;; Enable code checking
(use-package flycheck
  :ensure t
  :custom
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
                     (concat
                      (propertize (format "● %d " errors)  'face `(:foreground ,custom/color-red))
                      (propertize (format "● %d " warnings) 'face `(:foreground ,custom/color-yellow))
                      (propertize (format "● %d " infos) 'face `(:foreground ,custom/color-blue)))))
                  ;;(format " ●:%d ▲:%d ⊙:%d " errors warnings infos)))
                  (`running " Flyckeck:running")
                  (`no-checker " Flycheck:off")
                  (`not-checked " Flycheck:?")
                  (`errored " Flycheck:err")
                  (`interrupted " Flycheck:stopped")))))

;; Spell check for natural language
;; Requires Aspell
(declare-function spell-fu-dictionary-add "spell-fu")
(declare-function spell-fu-get-ispell-dictionary "spell-fu")
(declare-function spell-fu-get-personal-dictionary "spell-fu")
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

  (add-hook 'spell-fu-mode-hook 'custom/spell-fu-add-personal-dict)

  :custom
  (spell-fu-ignore-modes '(dired-mode))
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

;; Remove Charset indicators
(setq-default mode-line-mule-info "")

;; Remove TTY indicator
(setq-default mode-line-front-space "")

;; Remove the remote file indicator until needed
(setq-default mode-line-remote
  '(:eval (when (file-remote-p default-directory) "Remote file")))

;; Remove the frame number since I don't need it
(setq-default mode-line-frame-identification " ")

;; Automatically wrap comments
(setq comment-auto-fill-only-comments t)
(delight 'auto-fill-function nil t)
(add-hook 'prog-mode-hook 'turn-on-auto-fill)

(add-hook 'emacs-lisp-mode-hook
          (lambda ()
            (setq mode-name
                  '("Elisp" (lexical-binding "[Lexical]" "[Dynamic]")))))

(defun my/ml-render (left right)
  "Return a mode-line construct with LEFT and RIGHT pushed to the edges."
  (let ((width (string-width (format-mode-line right))))
    (list left
          (propertize " " 'display `(space :align-to (- right ,width)))
          right)))

(defun my/ml-status-circle ()
  "Colored circle reflecting buffer save/modify/read-only state."
  (let ((color (cond
                ((not buffer-file-name)  custom/color-white) ; not a file
                (buffer-read-only        custom/color-bright-black) ; read-only
                ((buffer-modified-p)     custom/color-green) ; unsaved changes
                (t                       custom/color-white)))) ; saved
    (propertize "●" 'face `(:foreground ,color))))

(setq-default mode-line-position '(:eval (format-mode-line "%l:%c")))

(setq-default mode-line-format
  '(:eval
    (my/ml-render
     ;; left segments
     '(;"%e"
       ;mode-line-front-space
       (:eval (my/ml-status-circle))
       " "
       mode-line-buffer-identification
       mode-line-position
       "   "
       mode-name)
     ;; right segments
     '(""
       flycheck-mode-line vc-mode))))

;; How total number of matches when searching
(setq isearch-lazy-count t)

;; Never use tabs for indentation
(setq-default indent-tabs-mode nil)

;; Show recent files when invoking find-file
(recentf-mode 1)

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
(setopt display-line-numbers-type 'relative)

;; Display column numbers
(setq column-number-mode t)

;; Enable auto-completion for code and text
(use-package completion-preview
  :delight
  :config
  (setopt completion-preview-idle-delay 1)
  :init
  (global-completion-preview-mode))

;; Match delimiters
(setopt electric-pair-preserve-balance t)
(setopt electric-pair-delete-adjacent-pairs t)
(electric-pair-mode)

;; --------------------------------------------------
;; Color customization

;; Global UI
(set-face-attribute 'mode-line nil
                    :background custom/color-region
                    :foreground custom/color-black
                    :box '(:style flat-button :line-width 4))
(set-face-attribute 'mode-line-inactive nil
                    :background custom/color-background
                    :foreground custom/color-yellow
                    :box '(:style flat-button :line-width 4))
(set-face-attribute 'default nil
                    :foreground custom/color-black
                    :background custom/color-background)
(set-face-background 'show-paren-match nil)
(set-face-foreground 'show-paren-match custom/color-red)
(set-face-foreground 'line-number custom/color-white)
(set-face-foreground 'line-number-current-line custom/color-red)
(set-face-background 'region custom/color-region)
(set-face-attribute 'isearch nil
                    :background custom/color-dark-background
                    :foreground custom/color-red)
(set-face-attribute 'lazy-highlight nil
                    :background custom/color-dark-background
                    :foreground custom/color-red)
(set-face-attribute 'minibuffer-prompt nil
                    :foreground custom/color-black
                    :weight 'normal)
(set-face-attribute 'highlight nil
                    :background custom/color-dark-background)
(set-face-attribute 'cursor nil
                    :foreground custom/color-white)

;; Syntax highlighting
(set-face-attribute 'font-lock-function-name-face nil
                    :foreground custom/color-black)
(set-face-attribute 'font-lock-function-call-face nil
                    :foreground custom/color-black)
(set-face-attribute 'font-lock-variable-name-face nil
                    :foreground custom/color-black
                    :slant 'italic)
(set-face-attribute 'font-lock-variable-use-face nil
                    :foreground custom/color-black)
(set-face-attribute 'font-lock-keyword-face nil
                    :foreground custom/color-black
                    :weight 'bold)
(set-face-attribute 'font-lock-comment-face nil
                    :slant 'italic
                    :foreground custom/color-cyan)
(set-face-attribute 'font-lock-type-face nil
                    :foreground custom/color-black)
(set-face-attribute 'font-lock-constant-face nil
                    :foreground custom/color-black)
(set-face-attribute 'font-lock-builtin-face nil
                    :foreground custom/color-black
                    :weight 'bold
                    :slant 'italic)
(set-face-attribute 'font-lock-string-face nil
                    :slant 'italic
                    :foreground custom/color-bright-black)
(set-face-attribute 'font-lock-number-face nil
                    :foreground custom/color-black)
(set-face-attribute 'font-lock-operator-face nil
                    :foreground custom/color-black)
(set-face-attribute 'font-lock-punctuation-face nil
                    :foreground custom/color-black)
(set-face-attribute 'font-lock-bracket-face nil
                    :foreground custom/color-black)
(set-face-attribute 'font-lock-delimiter-face nil
                    :foreground custom/color-black)
(set-face-attribute 'font-lock-escape-face nil
                    :foreground custom/color-black)
(set-face-attribute 'error nil
                    :underline `(:style wave :color ,custom/color-red) :weight 'normal)
(set-face-attribute 'flycheck-warning nil
                    :foreground custom/color-yellow :weight 'normal)
(set-face-attribute 'error nil
                    :underline `(:style wave :color ,custom/color-red)
                    :foreground custom/color-red)
