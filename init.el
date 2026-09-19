; -*- lexical-binding: t; -*-

;; Lexical-binding by default
(set-default-toplevel-value 'lexical-binding t)

;; Make sure we're not loading stale files
(setopt load-prefer-newer t)

(require 'package)

;; Make more intuitive knowing which packages are coming from an archive.
;; use-package is for archives and use-feature is for built-in ones.
;; Remember to use the library name, not the package name.
;; The locate-library function can be useful to know the name to use.
(defmacro use-feature (name &rest args)
  "Alias for use-package :ensure nil"
  (declare (indent defun))
  `(use-package ,name :ensure nil ,@args))

;; Highlight certain ubiquitous elisp functions as keywords to make
;; code nicer to read. Including some defined by me that are used globally.
;; (let ((keywords '("use-feature"
;; 		  "add-to-list"
;;                   "set-face-attribute"
;;                   "set-face-background"
;;                   "set-face-foreground"
;;                   "custom-set-variables"
;;                   "keymap-global-set"
;;                   "add-hook"
;;                   "car"
;;                   "cdr"
;;                   "concat"
;;                   "list")))
;;   (font-lock-add-keywords 'emacs-lisp-mode
;;                           `((,(concat "\\_<" (regexp-opt keywords t) "\\_>")
;;                              . font-lock-keyword-face))))

;; I guess this should do something similar to the above
(setopt elisp-fontify-semantically t)
(setopt elisp-variable-at-point t)

;; My custom code
(add-to-list 'load-path (expand-file-name "custom" user-emacs-directory))

(require 'variables) ;; Global Variables
(require 'colors) ;; Color palette
(require 'functions) ;; Custom functions

;; The keybindings.el file lists all the custom keybindings, but we set them
;; here. The reason is that it's confusing to get all the keybindings in this
;; large file, if I list all the keybindings in a separate file then I can get a
;; quick look at all of them at once.
(require 'keybindings)

;; Package repository
;; TODO: I should get all the packages locally and not depend on a package manager
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

;; Install packages in this list with M-x package-install-selected-packages
;; We only need to list the packages that are not bundled with Emacs
;; I do this manually instead of relying on the automatic method of Emacs because
;; I like to know what's being installed and make sure it's all intentional.
(setq package-selected-packages
      '(iedit
        vertico
        marginalia
        flycheck
        yasnippet
        expand-region
        multiple-cursors
        visual-fill-column
        paren-face
        treemacs
        magit
        git-gutter
        spell-fu
        aggressive-indent
        paredit
        orderless
        vundo
        forth-mode ; Forth
        geiser-chez ; Chez
        cider ; Clojure
        flycheck-clj-kondo ; Clojure linter
        emmet-mode
        ))

;; Prevent clicks in the terminal and GUI from moving the cursor
(use-feature xt-mouse
  :config
  (xterm-mouse-mode -1))

;; Remove the scroll bar
(setopt scroll-bar-mode nil)

;; Avoid automatically loading packages when starting Emacs so it starts faster
(setopt use-package-always-defer t)
;; Automatically fetch packages if they are not present.
;; Important: Because of this, an explicit `:ensure nil` is necessary sometimes
(setopt use-package-always-ensure t)

;; Keep parentheses
(use-package paredit
  :hook ((emacs-lisp-mode . paredit-mode)
         (lisp-mode . paredit-mode)
         (scheme-mode . paredit-mode)))

;; Make the cursor to stop blinking
;; Note: This depends on the terminal emulator about what "visible" means
(setopt visible-cursor nil)
(setopt blink-cursor-mode nil) ; GUI

;; Git indicators
;; Note: this needs a patched "nerd fonts" for the icons, I use Maple Mono
(use-package git-gutter
  :config
  ;; Only load Git indicators on code files, this way we avoid errors with other
  ;; modes that try to take control of the screen's left padding.
  ;; This wouldn't be needed on Emacs GUI but I use it on the terminal so there is
  ;; no other option.
  (add-hook 'prog-mode-hook 'git-gutter-mode)
  (setopt git-gutter:modified-sign "\uf440")
  (setopt git-gutter:added-sign "\uf067")
  (setopt git-gutter:deleted-sign "\uf068")
  (set-face-attribute 'git-gutter:modified nil :foreground custom/color-4 :weight 'normal)
  (set-face-attribute 'git-gutter:added nil :foreground custom/color-4 :weight 'normal)
  (set-face-attribute 'git-gutter:deleted nil :foreground custom/color-4 :weight 'normal))

;; Code folding
(use-feature hideshow
  :hook
  (prog-mode . hs-minor-mode)
  :config
  (keymap-global-set (getkey "hs-toggle-hiding") 'hs-toggle-hiding)
  (keymap-global-set (getkey "hs-hide-all") 'hs-hide-all))

;; File tree sidebar
(use-package treemacs
  :config
  (keymap-global-set (getkey "treemacs") 'treemacs)
  (set-face-attribute 'treemacs-git-modified-face nil
                      :foreground custom/color-black
                      :slant 'normal)
  (set-face-attribute 'treemacs-git-added-face nil
                      :foreground custom/color-black))

;; Add parentheses face everywhere
(use-package paren-face
  :hook (prog-mode . paren-face-mode)
  :config
  (global-paren-face-mode)
  (set-face-attribute 'parenthesis nil
                      :foreground custom/color-4
                      :weight 'normal)
  (setq paren-face-modes '(prog-mode))
  (setq paren-face-regexp "[][()}{]"))

;; Whitespace indicators
(use-feature whitespace
  :init
  (setopt whitespace-style '(face tabs spaces space-before-tab newline indentation empty
                                  space-after-tab space-mark tab-mark newline-mark missing-newline-at-eof))
  :custom-face
  (whitespace-space ((t (:background nil :foreground ,custom/color-white)))))


;; Wrap lines at fill-column
(setopt fill-column 80)
(use-package visual-fill-column)

;; For writing prose, also soft-breaks lines to make them readable
;; instead of them spanning the whole screen.
(use-feature markdown-ts-mode
  :mode ("\\.md\\'" . markdown-ts-mode)
  :hook
  (markdown-ts-mode . visual-fill-column-mode)
  (markdown-ts-mode . visual-line-mode))

(use-feature org
  :hook
  (org-mode . visual-fill-column-mode)
  (org-mode . visual-line-mode)
  :config
  (dolist (spec '((org-level-1 . 1.35)
                  (org-level-2 . 1.2)
                  (org-level-3 . 1.1)
                  (org-level-4 . 1.05)))
    (set-face-attribute (car spec) nil
                        :height (cdr spec)
                        :weight 'semibold)))

;; Select and edit multiple things at the same time
(use-package multiple-cursors
  :config
  (keymap-global-set (getkey "mc/mark-next-like-this") 'mc/mark-next-like-this)
  (keymap-global-set (getkey "mc/mark-previous-like-this") 'mc/mark-previous-like-this)
  (keymap-global-set (getkey "mc/mark-all-like-this") 'mc/mark-all-like-this))

;; Version Control
(use-package magit)

;; Increase selection in a semantic way
(use-package expand-region
  :config
  (keymap-global-set (getkey "er/expand-region") 'er/expand-region))

;; File manager
(use-feature dired
  :custom
  (dired-listing-switches "-alh")
  (dired-dwim-target t)
  :config
  (set-face-foreground 'dired-directory custom/color-blue))

;; Display the undo tree
(use-package vundo
  :defer nil
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
  :config
  (keymap-global-set (getkey "iedit-mode") 'iedit-mode)
  (set-face-background 'iedit-occurrence custom/color-white))

;; Show what functions are available on M-x
(use-package vertico
  :defer nil
  :init
  (vertico-mode))

;; Display descriptions of functions
(use-package marginalia
  :config
  (marginalia-mode))

;; Persist history over Emacs restarts.
;; - Vertico sorts by history position.
(use-feature savehist
  :init
  (savehist-mode))

;; Enable finding functions, variables, etc.
;; Without being precise in the spelling.
(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion))))
  (completion-pcm-leading-wildcard t))

;; Enable code checking
(use-package flycheck
  :defer nil
  :custom
  (flycheck-disabled-checkers '(emacs-lisp-checkdoc))
  (flycheck-emacs-lisp-load-path 'inherit)
  :init
  (global-flycheck-mode)
  :config
  (set-face-attribute 'flycheck-warning nil
                    :foreground custom/color-yellow :weight 'normal)
  (setq flycheck-mode-line
        '(:eval (pcase flycheck-last-status-change
                  (`finished
                   (let* ((counts (flycheck-count-errors flycheck-current-errors))
                          (errors (or (cdr (assq 'error counts)) 0))
                          (warnings (or (cdr (assq 'warning counts)) 0))
                          (infos (or (cdr (assq 'info counts)) 0)))
                     (concat
                      (propertize (format "● %d " errors)  'face `(:foreground ,custom/color-error))
                      (propertize (format "● %d " warnings) 'face `(:foreground ,custom/color-warning))
                      (propertize (format "● %d " infos) 'face `(:foreground ,custom/color-info)))))
                  (`running
                   (concat
                    (propertize "● 󰔟 " 'face `(:foreground ,custom/color-error))
                    (propertize "● 󰔟 " 'face `(:foreground ,custom/color-warning))
                    (propertize "● 󰔟 " 'face `(:foreground ,custom/color-info))))
                  (`no-checker nil)
                  (`not-checked nil)
                  (`errored " Flycheck:error")
                  (`interrupted " Flycheck:stopped")))))

;; Spell check for natural languages
;; Requires Aspell and the English dictionary ("en_US)
(declare-function spell-fu-dictionary-add "spell-fu")
(declare-function spell-fu-get-ispell-dictionary "spell-fu")
(declare-function spell-fu-get-personal-dictionary "spell-fu")
(use-package spell-fu
  :defer nil
  :init
  (spell-fu-global-mode)
  :config
  (add-hook 'spell-fu-mode-hook 'custom/spell-fu-add-personal-dict)
  ;; There are lots of technical words that we don't want to get flagged as
  ;; typos, so I'm using a local custom dictionary where I add all the words.
  (defun custom/spell-fu-add-personal-dict ()
    (spell-fu-dictionary-add
     (spell-fu-get-ispell-dictionary "en_US"))
    (spell-fu-dictionary-add
     (spell-fu-get-personal-dictionary
      "en-personal"
      (expand-file-name "personal-dictionary.pws" user-emacs-directory))))
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
  :defer nil
  :init
  (yas-global-mode 1)
  :custom
  (yas-snippet-dirs '("~/.emacs.d/snippets")))

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
(add-hook 'prog-mode-hook 'turn-on-auto-fill)

;; Customize the name of Elisp with explicit indication of lexical/dynamic binding
(add-hook 'emacs-lisp-mode-hook
          (lambda ()
            (setq mode-name
                  '("Elisp" (lexical-binding " \uf0ec Lexical" " \uf0ec Dynamic")))))

(defconst custom/vc-git-icon "\ue0a0"
  "Branch glyph (U+E0A0, Powerline/Nerd Font set).")

(defun custom/vc-git-mode-line (s)
  "Swap the \"Git\" backend name in S for a branch icon.
S is like \"Git-master\": index 3 is the state char, 4+ the branch.
Returns \"<icon> master\" clean, \"<icon> *master\" when modified;
the leading space is prepended later by `vc-mode-line'."
  (let ((face   (get-text-property 0 'face s))
        (branch (substring s 4)))
    (propertize (concat custom/vc-git-icon " " branch " ")
                'face face)))

(advice-add 'vc-git-mode-line-string :filter-return #'custom/vc-git-mode-line)

;; Next to the file name in the mode line we have an indicator that shows
;; the status of that file
(defun custom/file-status-indicator ()
  "Colored circle reflecting buffer save/modify/read-only state."
  (let ((color (cond
                (buffer-read-only custom/color-bright-black) ; read-only
                ((buffer-modified-p) custom/color-green) ; unsaved changes
                (t custom/color-white)))) ; saved
    (propertize " ●" 'face `(:foreground ,color))))

;; Custom mode line
(setq-default mode-line-format
              '("%1."
                (buffer-file-truename
                 ((:eval (custom/file-status-indicator)) "%2."))
                (:eval (propertize (or buffer-file-truename (buffer-name))
                                       'face '(:weight bold)))
                "%4.\uebd0%2."
                (:eval (format-mode-line "%l"))
                " of "
                (:eval (number-to-string (count-lines (point-min) (point-max))))
                "%4."
                mode-name
                (vc-mode ("%4." vc-mode))
                "%4."
                flycheck-mode-line))

;; How total number of matches when searching
(setq isearch-lazy-count t)

;; Never use tabs for indentation
(setq-default indent-tabs-mode nil)

;; Show recent files when invoking find-file
(recentf-mode 1)

;; Auto-scroll when something repeatedly shows in the compile mode
(with-eval-after-load 'compile
  (setopt compilation-scroll-output t))

;; Show what keybindings are available after a prefix like C-x or C-c.
(use-feature which-key
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
(tool-bar-mode -1)

;; Ask for Y or N instead of Yes or No
(defalias 'yes-or-no-p 'y-or-n-p)

;; Display line numbers
(global-display-line-numbers-mode 1)
(setopt display-line-numbers-type 'relative)

;; Display column numbers
(setq column-number-mode t)

;; Enable auto-completion for code and text
(use-feature completion-preview
  :config
  (setopt completion-preview-idle-delay 1)
  :init
  (global-completion-preview-mode))

;; Match delimiters
(setopt electric-pair-preserve-balance t)
(setopt electric-pair-delete-adjacent-pairs t)
(electric-pair-mode)

;; --------------------------------------------------
;; Visual customization

;; Global UI
(setopt fringe-styles 10)

(set-face-attribute 'fringe nil
                    :background custom/color-background)
(set-face-attribute 'button nil
                    :foreground custom/color-2)
(set-face-attribute 'mode-line nil
                    :background custom/color-5
                    :foreground custom/color-2
                    :box '(:style flat-button :line-width 4))
(set-face-attribute 'mode-line-inactive nil
                    :background custom/color-5
                    :foreground custom/color-4
                    :box '(:style flat-button :line-width 4))
(set-face-attribute 'default nil
                    :foreground custom/color-black
                    :background custom/color-background
                    :height 135
                    :family "JetBrainsMono Nerd Font")

(set-face-attribute 'show-paren-match nil
                    :foreground custom/color-1
                    :background custom/color-background
                    :weight 'bold)

(set-face-foreground 'line-number custom/color-4)
(set-face-attribute 'line-number-current-line nil
                    :foreground custom/color-2)

(set-face-background 'region custom/color-5)
(set-face-attribute 'isearch nil
                    :background custom/color-5
                    :foreground custom/color-black
                    :weight 'bold)
(set-face-attribute 'lazy-highlight nil
                    :background custom/color-5
                    :foreground custom/color-black)
(set-face-attribute 'minibuffer-prompt nil
                    :foreground custom/color-black
                    :weight 'normal)
(set-face-attribute 'highlight nil
                    :background custom/color-5)
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
                    :foreground custom/color-3)
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
                    :foreground custom/color-1)
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
(set-face-attribute 'error nil
                    :underline `(:style wave :color ,custom/color-red)
                    :foreground custom/color-red)
(set-face-attribute 'elisp-variable-at-point nil
                    :background custom/color-5)

;; --------------------------------------------------
;; Scheme (Chez Scheme)

(use-package geiser-chez
  :custom
  (geiser-chez-binary "chez"))

;; --------------------------------------------------
;; Forth (GForth)

(use-package forth-mode
  :mode ("\\.fs\\'" . forth-mode)
  :commands (forth-mode run-forth)
  :config
  (require 'forth-block-mode)
  (require 'forth-interaction-mode))

;; --------------------------------------------------
;; Clojure

(use-package flycheck-clj-kondo)
(use-package cider
  :config
  (require 'flycheck-clj-kondo))

;; --------------------------------------------------
;; Web

(setopt treesit-enabled-modes '(mhtml-ts-mode css-ts-mode js-ts-mode)
        treesit-auto-install-grammar 'ask)

(use-feature mhtml-ts-mode
  :ensure nil
  :custom ((mhtml-ts-mode-css-fontify-colors nil))
  :hook
  (mhtml-ts-mode . visual-fill-column-mode)
  (mhtml-ts-mode . visual-line-mode))

(use-package emmet-mode
  :hook (mhtml-ts-mode . emmet-mode))

;; --------------------------------------------------
;; New options

;; My god, finally there is a line-spacing option, the top and bottom spacing
;; needs to be different for a true center though.
(setopt line-spacing `(0.15 . 0.11))

;; Remove minor mode indicators in the mode line
(setopt mode-line-collapse-minor-modes t)
