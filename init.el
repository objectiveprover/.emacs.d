;;; init.el --- The Minimalist Emacs  -*- lexical-binding: t; -*-

;;; Commentary:
;; Personal configuration, all in this file.
;; Keybindings are set with `bind-key' and use-package's :bind, so
;; M-x describe-personal-keybindings lists all of them in one place.

;;; Code:

;; Lexical binding by default, also for code evaluated outside files
(set-default-toplevel-value 'lexical-binding t)

;; --------------------------------------------------------------------------------
;; Packages

(require 'package)
;; TODO: I should get all the packages locally and not depend on a package manager
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

;; Don't load packages at startup so Emacs starts faster.  A package only loads
;; through :demand, :init, :hook, :bind, :mode, :autoload or similar.
(setopt use-package-always-defer t)
;; Fetch missing packages automatically.  Built-in and local libraries need an
;; explicit `:ensure nil', which is what `use-feature' below is for.
(setopt use-package-always-ensure t)

;; Install packages in this list with M-x package-install-selected-packages
;; Only packages not bundled with Emacs.  Kept by hand instead of letting Emacs
;; manage it, so I know what's being installed and every install is intentional.
(setq package-selected-packages
      '(
        aggressive-indent
        astro-ts-mode
        cider
        dirvish
        eat
        emmet-mode
        exec-path-from-shell
        expand-region
        flycheck
        flycheck-clj-kondo
        flycheck-eglot
        forth-mode
        geiser-chez
        git-gutter
        iedit
        magit
        marginalia
        multiple-cursors
        orderless
        paredit
        paren-face
        plz
        rainbow-mode
        spell-fu
        vertico
        visual-fill-column
        vundo
        yasnippet
        ))

;; Make it obvious which packages come from an archive: `use-package' is for
;; archives and `use-feature' for built-in and local libraries.
;; Both take the library name, not the package name (see `locate-library').
(defmacro use-feature (name &rest args)
  "Alias for `use-package NAME :ensure nil ... ARGS'."
  (declare (indent defun))
  `(use-package ,name :ensure nil ,@args))

;; macOS GUI apps don't inherit the shell environment
(use-package exec-path-from-shell
  :if (memq window-system '(mac ns))
  :demand t
  :custom
  (exec-path-from-shell-variables '("PATH" "MANPATH" "GOPATH" "GOROOT"))
  :config
  (exec-path-from-shell-initialize))

;; --------------------------------------------------------------------------------
;; Colors
;;
;; Two layers, as in a design system:
;; - Palette: literal colors, named by what they look like.  Only tokens use them.
;; - Tokens: what a color is for.  The rest of the config uses only tokens, so
;;   restyling means remapping a token instead of hunting for hex values.
;; Constants rather than a lookup table so the byte compiler (and Flycheck)
;; flags a misspelled name.
;;
;; Based on Flexoki

;; Palette: neutrals, warm grays from darkest to lightest
(defconst custom/black    "#100F0F")
(defconst custom/base-950 "#1C1B1A")
(defconst custom/base-900 "#282726")
(defconst custom/base-850 "#343331")
(defconst custom/base-800 "#403E3C")
(defconst custom/base-700 "#575653")
(defconst custom/base-600 "#6F6E69")
(defconst custom/base-500 "#878580")
(defconst custom/base-300 "#B7B5AC")
(defconst custom/base-200 "#CECDC3")
(defconst custom/base-150 "#DAD8CE")
(defconst custom/base-100 "#E6E4D9")
(defconst custom/base-50  "#F2F0E5")
(defconst custom/paper    "#FFFCF0")

;; Palette: accents.  Flexoki uses the 600s on light backgrounds and the 400s
;; on dark ones, so the tokens below use 600s and the 400s are for a dark
;; variant.
(defconst custom/red-400     "#D14D41")
(defconst custom/orange-400  "#DA702C")
(defconst custom/yellow-400  "#D0A215")
(defconst custom/green-400   "#879A39")
(defconst custom/cyan-400    "#3AA99F")
(defconst custom/blue-400    "#4385BE")
(defconst custom/purple-400  "#8B7EC8")
(defconst custom/magenta-400 "#CE5D97")

(defconst custom/red-600     "#AF3029")
(defconst custom/orange-600  "#BC5215")
(defconst custom/yellow-600  "#AD8301")
(defconst custom/green-600   "#66800B")
(defconst custom/cyan-600    "#24837B")
(defconst custom/blue-600    "#205EA6")
(defconst custom/purple-600  "#5E409D")
(defconst custom/magenta-600 "#A02F6F")

;; Tokens: text
(defconst custom/fg           custom/base-950    "Body text, code and the cursor.")
(defconst custom/fg-string    custom/base-900    "String literals.")
(defconst custom/fg-comment   custom/magenta-600 "Comments.")
(defconst custom/fg-secondary custom/base-800    "Secondary UI text: mode line, buttons.")
(defconst custom/fg-subtle    custom/base-600    "Header line.")
(defconst custom/fg-faint     custom/base-300    "Gutter text: line numbers, fringe, Git signs.")
(defconst custom/fg-ghost     custom/base-150    "Barely visible syntax: parentheses.")

;; Tokens: surfaces
(defconst custom/bg           custom/paper    "Buffer background.")
(defconst custom/bg-surface   custom/base-50  "Raised surfaces: the mode line.")
(defconst custom/bg-selection custom/base-150 "Region, search matches and highlights.")

;; Tokens: markers and states
(defconst custom/marker       custom/base-300  "Non-text marks: whitespace, iedit, saved dot.")
(defconst custom/modified     custom/green-600 "Unsaved-changes dot.")
(defconst custom/read-only    custom/black     "Read-only dot.")
(defconst custom/accent       custom/blue-600  "Directories.")
(defconst custom/paren-match  custom/red-600   "Matching parenthesis.")

;; Tokens: diagnostics
(defconst custom/error        custom/red-600    "Errors.")
(defconst custom/warning      custom/yellow-600 "Warning marks in the fringe.")
(defconst custom/warning-text custom/orange-600 "Text flagged with a warning.")
(defconst custom/info         custom/blue-600   "Info diagnostics.")

;; --------------------------------------------------------------------------------
;; General behavior

(setopt inhibit-startup-screen t
        confirm-kill-emacs #'y-or-n-p ; Avoid accidentally closing Emacs
        use-short-answers t ; y/n instead of yes/no
        delete-by-moving-to-trash t ; Don't irreversibly delete files
        require-final-newline t
        isearch-lazy-count t) ; Show the total number of matches when searching

;; Never use tabs for indentation
(setq-default indent-tabs-mode nil)

;; Avoid having backup and autosave files everywhere
(setopt backup-directory-alist
        `(("." . ,(expand-file-name "backups" user-emacs-directory)))
        auto-save-file-name-transforms
        `((".*" ,(expand-file-name "autosaves/" user-emacs-directory) t)))

;; Remove trailing whitespace when saving a file
(add-hook 'before-save-hook #'delete-trailing-whitespace)

;; Keep buffers in sync with changes on disk, directories included
(setopt global-auto-revert-non-file-buffers t)
(global-auto-revert-mode 1)

;; Track recently opened files (C-x C-r)
(recentf-mode 1)

;; Persist minibuffer history over restarts; Vertico sorts by it
(use-feature savehist
  :init
  (savehist-mode))

;; Enable narrowing: C-x n n narrows to the region, C-x n w widens back
(put 'narrow-to-region 'disabled nil)

;; Navigate visible windows
(defvar-keymap custom/windmove-map
  :doc "Move between windows by direction."
  :repeat t
  "w" #'windmove-up
  "a" #'windmove-left
  "s" #'windmove-down
  "d" #'windmove-right)

(keymap-set global-map "C-c b" custom/windmove-map)
(repeat-mode 1)

;; Global keybindings
(require 'bind-key)
(bind-keys
 ("C-a"     . custom/beginning-of-line)
 ("C-x C-r" . recentf-open)
 ("C-c ;"   . comment-line)
 ("C-c ^"   . enlarge-window)
 ("C-c >"   . enlarge-window-horizontally)
 ("C-c c"   . custom/copy-to-clipboard)
 ("C-c v"   . custom/paste-from-clipboard)
 ("C-c l"   . dictionary-lookup-definition)
 ("C-c r"   . compile))

;; Avoid pressing C-x C-b (list-buffers) when meaning C-x b
(keymap-global-unset "C-x C-b")

;; --------------------------------------------------------------------------------
;; Editing

(defun custom/beginning-of-line ()
  "Toggle between the first non-whitespace character and the beginning of the line."
  (interactive)
  (let ((orig-point (point)))
    (back-to-indentation)
    (when (= orig-point (point))
      (move-beginning-of-line 1))))

;; M-x duplicate-line (built in): move point to the copy
(setopt duplicate-line-final-position 1)

;; The opposite of `fill-paragraph'.  By Stefan Monnier.
(defun unfill-paragraph (&optional region)
  "Join a multi-line paragraph into a single line.
With REGION non-nil, unfill the paragraphs in the active region."
  (interactive (progn (barf-if-buffer-read-only) '(t)))
  (let ((fill-column (point-max))
        ;; This would override `fill-column' if it's an integer.
        (emacs-lisp-docstring-fill-column t))
    (fill-paragraph nil region)))

;; Clipboard.  In the GUI this uses Emacs's own clipboard support.  In a
;; terminal, copying goes through OSC 52 and pasting through an external
;; command.

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

(defun custom/copy-to-clipboard (beg end)
  "Copy the active region between BEG and END to the system clipboard."
  (interactive (if (region-active-p)
                   (list (region-beginning) (region-end))
                 (user-error "No active region to copy")))
  (if (display-graphic-p)
      (clipboard-kill-ring-save beg end)
    (custom/osc52-copy (buffer-substring-no-properties beg end)))
  (deactivate-mark)
  (message "Copied region to clipboard"))

(defun custom/paste-from-clipboard ()
  "Insert the system clipboard at point."
  (interactive)
  (cond ((display-graphic-p) (clipboard-yank))
        (custom/clipboard-paste-command
         (let ((text (with-temp-buffer
                       ;; Discard stderr so error messages never get inserted
                       (when (zerop (call-process-shell-command
                                     custom/clipboard-paste-command nil '(t nil)))
                         (buffer-string)))))
           (if text
               (insert text)
             (message "Couldn't read the clipboard"))))
        (t (message "No clipboard reader available; use the terminal's paste"))))

;; Match delimiters
(setopt electric-pair-preserve-balance t
        electric-pair-delete-adjacent-pairs t)
(electric-pair-mode)

;; Hard-wrap comments, and only comments, in code
(setopt comment-auto-fill-only-comments t)
(add-hook 'prog-mode-hook #'auto-fill-mode)

;; Select and edit multiple things at the same time
(use-package multiple-cursors
  :bind (("C-c m f" . mc/mark-next-like-this)
         ("C-c m b" . mc/mark-previous-like-this)
         ("C-c m a" . mc/mark-all-like-this)))

;; Increase selection in a semantic way
(use-package expand-region
  :bind ("C-c SPC" . er/expand-region))

;; Simultaneous editing of occurrences.
;; To limit which occurrences are edited, narrow first (C-x n n).
(use-package iedit
  :bind ("C-c i" . iedit-mode)
  :config
  (set-face-background 'iedit-occurrence custom/marker))

;; Display the undo tree, in place of the default `undo' key
(use-package vundo
  :bind ("C-x u" . vundo)
  :config
  (setopt vundo-glyph-alist vundo-unicode-symbols))

;; Code folding
(use-feature hideshow
  :hook (prog-mode . hs-minor-mode)
  :bind (("C-c f f" . hs-toggle-hiding)
         ("C-c f a" . hs-hide-all)))

;; Quickly insert bits of code
(use-package yasnippet
  :custom
  (yas-snippet-dirs (list (expand-file-name "snippets" user-emacs-directory)))
  :init
  (yas-global-mode 1))

;; --------------------------------------------------------------------------------
;; Completion

;; Vertical minibuffer completion (M-x, find-file...)
(use-package vertico
  :init
  (vertico-mode))

;; Descriptions next to the candidates
(use-package marginalia
  :init
  (marginalia-mode))

;; Find functions, variables, etc. without being precise in the spelling
(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion))))
  (completion-pcm-leading-wildcard t))

;; Auto-completion for code and text
(use-feature completion-preview
  :custom
  (completion-preview-idle-delay 1)
  :init
  (global-completion-preview-mode))

;; Show what keybindings are available after a prefix like C-x or C-c
(use-feature which-key
  :custom
  (which-key-separator " → ")
  (which-key-max-display-columns 1)
  (which-key-popup-type 'side-window)
  (which-key-side-window-location 'bottom)
  (which-key-side-window-max-width 0.75)
  (which-key-max-description-length 0.9)
  (which-key-show-docstrings t)
  :init
  (which-key-mode))

;; --------------------------------------------------------------------------------
;; Checking

;; Spell check for natural languages
;; Requires Aspell and the English dictionary ("en_US")
(declare-function spell-fu-dictionary-add "spell-fu")
(declare-function spell-fu-get-ispell-dictionary "spell-fu")
(declare-function spell-fu-get-personal-dictionary "spell-fu")
(use-package spell-fu
  :demand t
  :config
  (setq-default spell-fu-ignore-modes '(dired-mode json-ts-mode))
  (setq-default spell-fu-faces-exclude
                '(font-lock-keyword-face
                  font-lock-function-name-face
                  font-lock-variable-name-face
                  font-lock-variable-use-face
                  font-lock-builtin-face
                  font-lock-constant-face
                  font-lock-type-face
                  ;; Eglot semantic tokens: types (comment and string stay checked)
                  eglot-semantic-namespace eglot-semantic-type eglot-semantic-class
                  eglot-semantic-enum eglot-semantic-interface eglot-semantic-struct
                  eglot-semantic-typeParameter eglot-semantic-parameter
                  eglot-semantic-variable eglot-semantic-property
                  eglot-semantic-enumMember eglot-semantic-event
                  eglot-semantic-function eglot-semantic-method eglot-semantic-macro
                  eglot-semantic-keyword eglot-semantic-modifier eglot-semantic-number
                  eglot-semantic-regexp eglot-semantic-operator eglot-semantic-decorator
                  ;; Eglot semantic tokens: modifiers (documentation stays checked)
                  eglot-semantic-declaration eglot-semantic-definition
                  eglot-semantic-readonly eglot-semantic-static
                  eglot-semantic-deprecated eglot-semantic-abstract
                  eglot-semantic-async eglot-semantic-modification
                  eglot-semantic-defaultLibrary))
  ;; There are lots of technical words that we don't want flagged as typos,
  ;; so they go in a local custom dictionary.
  (defun custom/spell-fu-add-personal-dict ()
    "Add the en_US and personal dictionaries to the current buffer."
    (spell-fu-dictionary-add
     (spell-fu-get-ispell-dictionary "en_US"))
    (spell-fu-dictionary-add
     (spell-fu-get-personal-dictionary
      "en-personal"
      (expand-file-name "personal-dictionary.pws" user-emacs-directory))))
  (add-hook 'spell-fu-mode-hook #'custom/spell-fu-add-personal-dict)
  ;; Enable last, so buffers that exist already also get the hook
  (spell-fu-global-mode))

;; Code checking
(use-package flycheck
  :demand t
  :custom
  (flycheck-emacs-lisp-load-path 'inherit)
  (flycheck-global-modes '(not lisp-interaction-mode markdown-ts-mode))
  (flycheck-indication-mode 'left-fringe)
  :config
  ;; (normal . hi-res) bitmaps, defined in the fringe section
  (dolist (level '(error warning info))
    (put level 'flycheck-fringe-bitmaps '(custom/square . custom/square)))
  (set-face-attribute 'flycheck-fringe-error nil
                      :foreground custom/error
                      :background 'unspecified)
  (set-face-attribute 'flycheck-fringe-warning nil
                      :foreground custom/warning
                      :background 'unspecified)
  (set-face-attribute 'flycheck-fringe-info nil
                      :foreground custom/info
                      :background 'unspecified)
  (set-face-attribute 'flycheck-warning nil
                      :foreground custom/warning-text :weight 'normal)
  (setq flycheck-mode-line
        '(:eval (pcase flycheck-last-status-change
                  (`finished
                   (let* ((counts (flycheck-count-errors flycheck-current-errors))
                          (errors (or (cdr (assq 'error counts)) 0))
                          (warnings (or (cdr (assq 'warning counts)) 0))
                          (infos (or (cdr (assq 'info counts)) 0)))
                     (concat
                      (propertize (format " %d:E " errors)  'face `(:foreground ,custom/fg-secondary))
                      (propertize (format " %d:W " warnings) 'face `(:foreground ,custom/fg-secondary))
                      (propertize (format " %d:I " infos) 'face `(:foreground ,custom/fg-secondary)))))
                  (`running
                   (concat
                    (propertize " 󰔟:E " 'face `(:foreground ,custom/fg-secondary))
                    (propertize " 󰔟:W " 'face `(:foreground ,custom/fg-secondary))
                    (propertize " 󰔟:I " 'face `(:foreground ,custom/fg-secondary))))
                  (`no-checker nil)
                  (`not-checked nil)
                  (`errored " Flycheck:error")
                  (`interrupted " Flycheck:stopped"))))
  (global-flycheck-mode))

;; --------------------------------------------------------------------------------
;; Files and version control

;; File manager
(use-package dirvish
  :init
  (dirvish-override-dired-mode)
  :bind (("C-c d" . dirvish)
         ("C-c t" . dirvish-side)))

(use-feature dired
  :custom
  (dired-listing-switches "-alh")
  (dired-dwim-target t)
  :config
  (set-face-foreground 'dired-directory custom/accent))

(use-feature project
  :custom
  ;; `touch .project` marks a root
  (project-vc-extra-root-markers '(".project")))

(use-package magit)

;; Git indicators, only in code buffers: git-gutter and visual-fill-column
;; both use the left margin and would fight over it in text buffers.
;; The signs need a Nerd Font.
(use-package git-gutter
  :hook (prog-mode . git-gutter-mode)
  :custom
  (git-gutter:modified-sign "\uf440")
  (git-gutter:added-sign "\uf067")
  (git-gutter:deleted-sign "\uf068")
  :config
  (dolist (face '(git-gutter:modified git-gutter:added git-gutter:deleted))
    (set-face-attribute face nil :foreground custom/fg-faint :weight 'normal)))

;; --------------------------------------------------------------------------------
;; Tools

;; HTTP client.  `fetch-api' is autoloaded, so it works before plz is loaded.
(use-package plz
  :autoload fetch-api
  :functions plz custom/plz-show
  :config
  (defun custom/plz-show (response &optional buffer-name)
    "Display plz RESPONSE pretty-printed in BUFFER-NAME (default *HTTP Response*)."
    (let ((buf (get-buffer-create (or buffer-name "*HTTP Response*"))))
      (with-current-buffer buf
        (let ((inhibit-read-only t))
          (erase-buffer)
          (insert (or (plz-response-body response) ""))
          (ignore-errors (json-pretty-print-buffer)) ; leave non-JSON (e.g. HTML errors) as-is
          (goto-char (point-min)))
        (if (treesit-language-available-p 'json) (json-ts-mode) (js-json-mode))
        (hs-minor-mode 1)
        ;; set after the major mode, which resets buffer-local variables
        (setq header-line-format (format " HTTP %d" (plz-response-status response))))
      (display-buffer buf)))

  (defun fetch-api (method url &optional data)
    "Send DATA as JSON with METHOD to URL; show the response in *HTTP Response*."
    (plz method url
         :headers '(("Content-Type" . "application/json")
                    ("Accept" . "application/json"))
         :body (when data (json-encode data))
         :as 'response
         :then #'custom/plz-show
         :else (lambda (err)
                 (if-let* ((resp (plz-error-response err)))
                     (custom/plz-show resp)  ; 4xx/5xx: show the error body too
                   (message "Request failed: %S" (plz-error-curl-error err)))))))

;; Terminal emulator that supports TUIs
(use-package eat)

(use-feature compile
  ;; Interpret color escape sequences
  :hook (compilation-filter . ansi-color-compilation-filter)
  :custom
  ;; Follow the output as it comes in
  (compilation-scroll-output t))

;; --------------------------------------------------------------------------------
;; Interface

(menu-bar-mode -1)
(tool-bar-mode -1)
(setopt scroll-bar-mode nil)

;; Stop the cursor from blinking.
;; In a terminal, what "visible" means depends on the emulator.
(setopt visible-cursor nil
        blink-cursor-mode nil)

;; Don't let mouse clicks in a terminal move the cursor (TTY only)
(xterm-mouse-mode -1)

(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'text-mode-hook #'display-line-numbers-mode)

;; Line spacing as (TOP . BOTTOM).  Top and bottom need different values for
;; the text to look truly centered.
(setopt line-spacing '(0.22 . 0.12))

;; Fringe

(defun custom/fringe-bitmap (name &rest rows)
  "Define fringe bitmap NAME from ROWS of `X' (on) and `.' (off)."
  (define-fringe-bitmap
    name
    (vconcat (mapcar (lambda (row)
                       (seq-reduce (lambda (acc ch) (+ (* acc 2) (if (eq ch ?X) 1 0)))
                                   row 0))
                     rows))
    nil (length (car rows)) 'center))

(use-feature fringe
  :config
  (fringe-mode '(20 . 0))

  (custom/fringe-bitmap 'custom/square
                        "XXXXXXXXXX"
                        "XXXXXXXXXX"
                        "XXXXXXXXXX"
                        "XXXXXXXXXX"
                        "XXXXXXXXXX"
                        "XXXXXXXXXX"
                        "XXXXXXXXXX"
                        "XXXXXXXXXX"
                        "XXXXXXXXXX"
                        "XXXXXXXXXX")

  (custom/fringe-bitmap 'custom/wrap
                        "X..........."
                        "X..........."
                        "X..........."
                        "X..........."
                        "X..........."
                        "X..........."
                        "X..........."
                        "X..........."
                        "XXXXXXXXXXXX")

  ;; Mark wrapped lines with the custom bitmap
  (setq-default fringe-indicator-alist
                (cons '(continuation custom/wrap nil)
                      (assq-delete-all 'continuation
                                       (copy-sequence
                                        (default-value 'fringe-indicator-alist))))))

;; Mode line
;; The format below is fully custom, so the default mode-line-* pieces
;; (mule info, remote indicator, frame id, position, minor modes) never show.

(defconst custom/vc-git-icon "\ue0a0"
  "Branch glyph (U+E0A0, Powerline/Nerd Font set).")

(defun custom/vc-git-mode-line (s)
  "Swap the \"Git\" backend name in S for a branch icon.
S is like \"Git-master\": index 3 is the state char, 4+ the branch.
Returns \"<icon> master \"; the state shows only through the face
copied from S.  The leading space is prepended later by `vc-mode-line'."
  (let ((face   (get-text-property 0 'face s))
        (branch (substring s 4)))
    (propertize (concat custom/vc-git-icon " " branch " ")
                'face face)))

(advice-add 'vc-git-mode-line-string :filter-return #'custom/vc-git-mode-line)

(defun custom/file-status-indicator ()
  "Colored circle reflecting buffer save/modify/read-only state."
  (let ((color (cond
                (buffer-read-only custom/read-only) ; read-only
                ((buffer-modified-p) custom/modified) ; unsaved changes
                (t custom/marker)))) ; saved
    (propertize " ●" 'face `(:foreground ,color))))

(defvar-local custom/display-path-cache nil
  "Cons of (TRUENAME . DISPLAY-STRING) for the mode line.")

(defun custom/buffer-display-path ()
  "Project name and project-relative path or the full path or the buffer name."
  (if-let* ((file buffer-file-truename))
      (if (equal (car custom/display-path-cache) file)
          (cdr custom/display-path-cache)
        (let* ((proj (project-current))
               (str (if proj
                        (concat (project-name proj) "/"
                                (file-relative-name file (project-root proj)))
                      file)))
          (setq custom/display-path-cache (cons file str))
          str))
    (buffer-name)))

(defvar-local custom/line-count-cache nil
  "Cons of (KEY . LINE-COUNT-STRING) for the mode line.
KEY is (CHARS-MODIFIED-TICK POINT-MIN POINT-MAX), so the count is
redone only after an edit or a change of narrowing.")

(defun custom/buffer-line-count ()
  "Number of lines in the accessible part of the buffer, as a string.
`count-lines' scans the whole buffer, so the result is cached instead
of recomputed on every mode-line redisplay."
  (let ((key (list (buffer-chars-modified-tick) (point-min) (point-max))))
    (if (equal (car custom/line-count-cache) key)
        (cdr custom/line-count-cache)
      (let ((str (number-to-string (count-lines (point-min) (point-max)))))
        (setq custom/line-count-cache (cons key str))
        str))))

(setq-default mode-line-format
              '("%1."
                (buffer-file-truename
                 ((:eval (custom/file-status-indicator)) "%2."))
                (:eval (propertize (custom/buffer-display-path)
                                   'face '(:weight bold)))
                "%4.\uebd0%2."
                "%l of "
                (:eval (custom/buffer-line-count))
                "%4."
                mode-name
                (vc-mode ("%4." vc-mode))
                "%4."
                flycheck-mode-line))

;; Faces

(set-face-attribute 'default nil
                    :foreground custom/fg
                    :background custom/bg
                    :height 140
                    :family "JetBrainsMono Nerd Font")
(set-face-attribute 'header-line nil
                    :background custom/bg
                    :foreground custom/fg-subtle)
(set-face-attribute 'fringe nil
                    :background custom/bg
                    :foreground custom/fg-faint)
(set-face-attribute 'mode-line nil
                    :background custom/bg-surface
                    :foreground custom/fg-secondary
                    :box '(:style flat-button :line-width 4))
(set-face-attribute 'mode-line-inactive nil
                    :background custom/bg-surface
                    :foreground custom/fg-faint
                    :box '(:style flat-button :line-width 4))
(set-face-attribute 'button nil
                    :foreground custom/fg-secondary)
(set-face-attribute 'show-paren-match nil
                    :foreground custom/paren-match
                    :background custom/bg
                    :weight 'bold)
(set-face-foreground 'line-number custom/fg-faint)
(set-face-attribute 'line-number-current-line nil
                    :foreground custom/fg-secondary)
(set-face-background 'region custom/bg-selection)
(set-face-attribute 'highlight nil
                    :background custom/bg-selection)
(set-face-attribute 'isearch nil
                    :background custom/bg-selection
                    :foreground custom/fg
                    :weight 'bold)
(set-face-attribute 'lazy-highlight nil
                    :background custom/bg-selection
                    :foreground custom/fg)
(set-face-attribute 'minibuffer-prompt nil
                    :foreground custom/fg
                    :weight 'normal)
;; Only :background sets the cursor color (GUI only; terminals draw their own)
(set-face-attribute 'cursor nil
                    :background custom/fg)
(set-face-attribute 'error nil
                    :foreground custom/error
                    :underline `(:style wave :color ,custom/error)
                    :weight 'normal)

;; Syntax highlighting: grayscale, structure shown through weight and slant
(set-face-attribute 'font-lock-function-name-face nil
                    :foreground custom/fg
                    :weight 'bold)
(set-face-attribute 'font-lock-keyword-face nil
                    :foreground custom/fg
                    :weight 'bold)
(set-face-attribute 'font-lock-builtin-face nil
                    :foreground custom/fg
                    :weight 'bold
                    :slant 'italic)
(set-face-attribute 'font-lock-variable-name-face nil
                    :foreground custom/fg
                    :slant 'italic)
(set-face-attribute 'font-lock-comment-face nil
                    :foreground custom/fg-comment
                    :slant 'italic)
(set-face-attribute 'font-lock-string-face nil
                    :foreground custom/fg-string
                    :slant 'italic)
(dolist (face '(font-lock-function-call-face
                font-lock-variable-use-face
                font-lock-type-face
                font-lock-constant-face
                font-lock-number-face
                font-lock-operator-face
                font-lock-punctuation-face
                font-lock-bracket-face
                font-lock-delimiter-face
                font-lock-escape-face))
  (set-face-attribute face nil :foreground custom/fg))

;; Dim parentheses in code
(use-package paren-face
  :hook (prog-mode . paren-face-mode)
  :custom
  (paren-face-regexp "[][()}{]")
  :config
  (set-face-attribute 'parenthesis nil
                      :foreground custom/fg-ghost
                      :weight 'normal))

;; Whitespace indicators (M-x whitespace-mode)
(use-feature whitespace
  :custom
  (whitespace-style '(face tabs spaces space-before-tab newline indentation empty
                           space-after-tab space-mark tab-mark newline-mark
                           missing-newline-at-eof))
  :custom-face
  (whitespace-space ((t (:background nil :foreground ,custom/marker)))))

;; --------------------------------------------------------------------------------
;; Text and markup

;; Width for wrapped comments and prose
(setopt fill-column 100)
(use-package visual-fill-column)

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

(use-feature markdown-ts-mode
  :mode ("\\.md\\'" "\\.markdown\\'")
  :hook
  (markdown-ts-mode . visual-fill-column-mode))

(use-feature json-ts-mode
  :mode ("\\.json\\'"))

;; --------------------------------------------------------------------------------
;; General programming

;; M-x treesit-install-language-grammar
(use-feature treesit
  :custom
  (treesit-enabled-modes '(mhtml-ts-mode css-ts-mode js-ts-mode))
  (treesit-auto-install-grammar 'ask)
  :config
  (setopt treesit-language-source-alist
          '((go    "https://github.com/tree-sitter/tree-sitter-go")
            (gomod "https://github.com/camdencheek/tree-sitter-go-mod")
            (astro "https://github.com/virchau13/tree-sitter-astro"))))

(use-feature eglot
  :custom
  (eglot-autoshutdown t)
  (eglot-events-buffer-config '(:size 0)) ; drop JSON-RPC logging, noticeably faster
  :config
  (setq-default eglot-workspace-configuration
                '(:gopls (:gofumpt t
                                   :staticcheck t
                                   :usePlaceholders t
                                   :hints (:parameterNames t :assignVariableTypes t))))
  (add-to-list 'eglot-server-programs
               '((typescript-ts-mode tsx-ts-mode) . ("tsc" "--lsp" "--stdio")))
  (add-to-list 'eglot-server-programs
               '(astro-ts-mode . ("astro-ls" "--stdio"
                                  :initializationOptions
                                  (:typescript (:tsdk "./node_modules/typescript/lib"))))))

;; Report Eglot diagnostics through Flycheck
(use-package flycheck-eglot
  :after (flycheck eglot)
  :demand t
  :config
  (global-flycheck-eglot-mode 1))

;; Show color strings in their color
(use-package rainbow-mode
  :hook ((css-ts-mode emacs-lisp-mode) . rainbow-mode)
  :custom
  (rainbow-x-colors nil))

;; --------------------------------------------------------------------------------
;; Lisps

;; Keep parentheses balanced
(use-package paredit
  :hook ((emacs-lisp-mode lisp-mode scheme-mode) . paredit-mode))

;; Keep Lisp code indented as it's edited
(use-package aggressive-indent
  :hook ((emacs-lisp-mode lisp-mode scheme-mode clojure-mode) . aggressive-indent-mode))

;; Emacs Lisp: semantic highlighting and highlighting of the variable at point
(setopt elisp-fontify-semantically t
        elisp-variable-at-point t)
(set-face-attribute 'elisp-variable-at-point nil
                    :background custom/bg-selection)

;; Show whether the buffer uses lexical or dynamic binding in the mode name
(add-hook 'emacs-lisp-mode-hook
          (lambda ()
            (setq mode-name
                  '("Elisp" (lexical-binding " \uf0ec Lexical" " \uf0ec Dynamic")))))

;; Scheme (Chez Scheme)
(use-package geiser-chez
  :custom
  (geiser-chez-binary "chez"))

;; Clojure
(use-package flycheck-clj-kondo)
(use-package cider
  :config
  (require 'flycheck-clj-kondo))

;; --------------------------------------------------------------------------------
;; Forth (GForth)

(use-package forth-mode
  :mode ("\\.fs\\'" . forth-mode)
  :commands (forth-mode run-forth)
  :config
  (require 'forth-block-mode)
  (require 'forth-interaction-mode))

;; --------------------------------------------------------------------------------
;; Web

(use-package emmet-mode
  :hook ((mhtml-ts-mode astro-ts-mode) . emmet-mode))

(use-feature mhtml-ts-mode
  :custom
  (mhtml-ts-mode-css-fontify-colors nil))

(use-feature css-ts-mode
  :custom
  (css-fontify-colors nil))

(use-feature typescript-ts-mode
  :hook (typescript-ts-mode . eglot-ensure))

(use-package astro-ts-mode
  :mode "\\.astro\\'"
  :hook (astro-ts-mode . eglot-ensure)
  :config
  (require 'typescript-ts-mode)
  ;; Astro embeds these languages.  astro-ts-mode doesn't install missing
  ;; grammars itself, so do it here following `treesit-auto-install-grammar'.
  (dolist (lang '(astro css typescript tsx))
    (unless (treesit-language-available-p lang)
      (when (pcase treesit-auto-install-grammar
              ('never nil)
              ('ask (y-or-n-p (format "Install the tree-sitter grammar for %s? " lang)))
              (_ t))
        (treesit-install-language-grammar lang)))))

;; --------------------------------------------------------------------------------
;; Go

(use-feature go-ts-mode
  :mode (("\\.go\\'"     . go-ts-mode)
         ("/go\\.mod\\'" . go-mod-ts-mode))
  :custom
  (go-ts-indent-offset 4)
  :hook
  ((go-ts-mode . eglot-ensure)
   (go-ts-mode . (lambda () (setq-local tab-width 4)))))

;;; init.el ends here
