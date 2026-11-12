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

;; No package manager: package.el is off (early-init.el).  Third-party
;; packages are copied into site-lisp/ as part of this config, free to edit
;; and not tied to their original repositories.  site-lisp/site-lisp.el
;; explains how to add and build them.
(load (expand-file-name "site-lisp/site-lisp" user-emacs-directory) nil t)
(declare-function Minimalist/site-lisp-activate "site-lisp/site-lisp")
(Minimalist/site-lisp-activate)

;; Don't load packages at startup so Emacs starts faster.  A package only loads
;; through :demand, :init, :hook, :bind, :mode, :autoload or similar.
(setopt use-package-always-defer t)

;; Make it obvious where a package comes from: `use-package' is for the
;; third-party packages in site-lisp/ and `use-feature' for built-in libraries.
;; Both take the library name, not the package name (see `locate-library').
(defmacro use-feature (name &rest args)
  "Alias for `use-package NAME :ensure nil ... ARGS'."
  (declare (indent defun))
  `(use-package ,name :ensure nil ,@args))

;; --------------------------------------------------------------------------------
;; Colors
;;
;; Two layers, as in a design system:
;; - Palette: literal colors, named by what they look like.  Only tokens use them.
;; - Tokens: what a color is for.  The rest of the config uses only tokens, so
;;   restyling means remapping a token instead of hunting for hex values.
;; Constants rather than a lookup table so the byte compiler (and Flymake)
;; flags a misspelled name.

;; Palette: neutrals, warm grays from darkest to lightest
(defconst Minimalist/black    "#100F0F")
(defconst Minimalist/base-950 "#1C1B1A")
(defconst Minimalist/base-900 "#282726")
(defconst Minimalist/base-850 "#343331")
(defconst Minimalist/base-800 "#403E3C")
(defconst Minimalist/base-700 "#575653")
(defconst Minimalist/base-600 "#6F6E69")
(defconst Minimalist/base-500 "#878580")
(defconst Minimalist/base-300 "#B7B5AC")
(defconst Minimalist/base-200 "#CECDC3")
(defconst Minimalist/base-150 "#DAD8CE")
(defconst Minimalist/base-100 "#E6E4D9")
(defconst Minimalist/base-50  "#F2F0E5")
(defconst Minimalist/paper    "#FFFCF0")

;; Palette: accents.  Flexoki uses the 600s on light backgrounds and the 400s
;; on dark ones, so the tokens below use 600s and the 400s are for a dark
;; variant.
(defconst Minimalist/red-400     "#D14D41")
(defconst Minimalist/orange-400  "#DA702C")
(defconst Minimalist/yellow-400  "#D0A215")
(defconst Minimalist/green-400   "#879A39")
(defconst Minimalist/cyan-400    "#3AA99F")
(defconst Minimalist/blue-400    "#4385BE")
(defconst Minimalist/purple-400  "#8B7EC8")
(defconst Minimalist/magenta-400 "#CE5D97")

(defconst Minimalist/red-600     "#AF3029")
(defconst Minimalist/orange-600  "#BC5215")
(defconst Minimalist/yellow-600  "#AD8301")
(defconst Minimalist/green-600   "#66800B")
(defconst Minimalist/cyan-600    "#24837B")
(defconst Minimalist/blue-600    "#205EA6")
(defconst Minimalist/purple-600  "#5E409D")
(defconst Minimalist/magenta-600 "#A02F6F")

;; Tokens: text
(defconst Minimalist/fg           Minimalist/base-950    "Body text, code and the cursor.")
(defconst Minimalist/fg-string    Minimalist/base-900    "String literals.")
(defconst Minimalist/fg-comment   Minimalist/magenta-600 "Comments.")
(defconst Minimalist/fg-secondary Minimalist/base-800    "Secondary UI text: mode line, buttons.")
(defconst Minimalist/fg-subtle    Minimalist/base-600    "Header line.")
(defconst Minimalist/fg-faint     Minimalist/base-300    "Line numbers, Git signs.")
(defconst Minimalist/fg-ghost     Minimalist/base-200    "Barely visible syntax: parentheses.")

;; Tokens: surfaces
(defconst Minimalist/bg           "#FFFFFF"           "Buffer background.")
(defconst Minimalist/bg-surface   "#F0F0F0"           "Raised surfaces: the mode line.")
(defconst Minimalist/bg-selection Minimalist/base-50 "Region, search matches and highlights.")

;; Tokens: markers and states
(defconst Minimalist/marker       Minimalist/base-300  "Whitespace, saved dot.")
(defconst Minimalist/modified     Minimalist/green-600 "Unsaved-changes dot.")
(defconst Minimalist/read-only    Minimalist/black     "Read-only dot.")
(defconst Minimalist/accent       Minimalist/blue-600  "Directories.")
(defconst Minimalist/paren-match  Minimalist/red-600   "Matching parenthesis.")

;; Tokens: diagnostics
(defconst Minimalist/error        Minimalist/red-600    "Errors.")
(defconst Minimalist/warning-text Minimalist/orange-600 "Text flagged with a warning.")

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

;; Remove trailing whitespace on save, but only from lines I edited, so files
;; in shared repositories don't get unrelated whitespace changes
(use-package ws-butler
  :hook ((prog-mode text-mode) . ws-butler-mode))

;; Keep buffers in sync with changes on disk, directories included
(setopt global-auto-revert-non-file-buffers t)
(global-auto-revert-mode 1)

;; Track recently opened files (C-x C-r)
(recentf-mode 1)

;; Persist minibuffer history over restarts; completion sorts by it
(use-feature savehist
  :init
  (savehist-mode))

;; Enable narrowing: C-x n n narrows to the region, C-x n w widens back
(put 'narrow-to-region 'disabled nil)

;; Navigate visible windows
(defvar-keymap Minimalist/windmove-map
  :doc "Move between windows by direction."
  :repeat t
  "w" #'windmove-up
  "a" #'windmove-left
  "s" #'windmove-down
  "d" #'windmove-right)

(keymap-set global-map "C-c b" Minimalist/windmove-map)
(repeat-mode 1)

;; Global keybindings
(require 'bind-key)
(bind-keys
 ("C-a"     . Minimalist/beginning-of-line)
 ("C-x C-r" . recentf-open)
 ("C-c ;"   . comment-line)
 ("C-c ^"   . enlarge-window)
 ("C-c >"   . enlarge-window-horizontally)
 ("C-c c"   . Minimalist/copy-to-clipboard)
 ("C-c v"   . Minimalist/paste-from-clipboard)
 ("C-c l"   . dictionary-lookup-definition)
 ("C-c r"   . compile))

;; Avoid pressing C-x C-b (list-buffers) when meaning C-x b
(keymap-global-unset "C-x C-b")

;; --------------------------------------------------------------------------------
;; Editing

(defun Minimalist/beginning-of-line ()
  "Toggle between the first non-whitespace character and the beginning of the line."
  (interactive)
  (let ((orig-point (point)))
    (back-to-indentation)
    (when (= orig-point (point))
      (move-beginning-of-line 1))))

;; M-x duplicate-line (built in): move point to the copy
(setopt duplicate-line-final-position 1)

;; The opposite of `fill-paragraph'.  By Stefan Monnier.
(defun Minimalist/unfill-paragraph (&optional region)
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

(defconst Minimalist/clipboard-paste-command
  (cond ((eq system-type 'darwin) "pbpaste")
        ((getenv "WAYLAND_DISPLAY") "wl-paste --no-newline")
        ((getenv "DISPLAY") "xclip -selection clipboard -o")
        (t nil))
  "Shell command writing the system clipboard to stdout, or nil if unavailable.")

(defun Minimalist/osc52-copy (text)
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

(defun Minimalist/copy-to-clipboard (beg end)
  "Copy the active region between BEG and END to the system clipboard."
  (interactive (if (region-active-p)
                   (list (region-beginning) (region-end))
                 (user-error "No active region to copy")))
  (if (display-graphic-p)
      (clipboard-kill-ring-save beg end)
    (Minimalist/osc52-copy (buffer-substring-no-properties beg end)))
  (deactivate-mark)
  (message "Copied region to clipboard"))

(defun Minimalist/paste-from-clipboard ()
  "Insert the system clipboard at point."
  (interactive)
  (cond ((display-graphic-p) (clipboard-yank))
        (Minimalist/clipboard-paste-command
         (let ((text (with-temp-buffer
                       ;; Discard stderr so error messages never get inserted
                       (when (zerop (call-process-shell-command
                                     Minimalist/clipboard-paste-command nil '(t nil)))
                         (buffer-string)))))
           (if text
               (insert text)
             (message "Couldn't read the clipboard"))))
        (t (message "No clipboard reader available; use the terminal's paste"))))

;; Match delimiters
(setopt electric-pair-preserve-balance t
        electric-pair-delete-adjacent-pairs t)
(electric-pair-mode)

;; Select and edit multiple things at the same time
(use-package multiple-cursors
  :bind (("C-c m f" . mc/mark-next-like-this)
         ("C-c m b" . mc/mark-previous-like-this)
         ("C-c m a" . mc/mark-all-like-this)))

;; Increase selection in a semantic way: C-c SPC, then SPC to grow it
;; further and - to shrink it.  Uses tree-sitter in -ts- modes.
(declare-function expreg-contract "expreg")
(declare-function expreg--sentence "expreg")
(defvar-keymap Minimalist/expreg-repeat-map
  :doc "Keep growing or shrinking the selection after `expreg-expand'."
  :repeat t
  "SPC" #'expreg-expand
  "-" #'expreg-contract)

(defvar expreg-functions)
(defun Minimalist/expreg-add-sentences ()
  "Also select by sentence, for prose."
  (require 'expreg)
  (setq-local expreg-functions (cons #'expreg--sentence expreg-functions)))

(use-package expreg
  :bind ("C-c SPC" . expreg-expand)
  :hook (text-mode . Minimalist/expreg-add-sentences))

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
  :functions yas-global-mode
  :custom
  (yas-snippet-dirs (list (expand-file-name "snippets" user-emacs-directory)))
  :init
  (yas-global-mode 1))

;; --------------------------------------------------------------------------------
;; Completion

;; Vertical minibuffer completion (M-x, find-file...)
;; RET picks the highlighted candidate and M-RET submits what was typed,
;; e.g. a new file name.  TAB inserts the candidate, e.g. to enter a directory.
;; icomplete-scroll keeps the list in order and moves the highlight through it,
;; instead of rotating the selected candidate to the top.
(use-feature icomplete
  :custom
  (icomplete-scroll t)
  (icomplete-show-matches-on-no-input t)
  (icomplete-compute-delay 0)
  (icomplete-prospects-height 12)
  (icomplete-vertical-render-prefix-indicator t)
  :bind (:map icomplete-minibuffer-map
              ("RET" . icomplete-force-complete-and-exit)
              ("M-RET" . exit-minibuffer))
  :init
  (icomplete-vertical-mode))

;; Descriptions next to the candidates: docstrings for commands, functions
;; and variables, sizes and dates for files, modes for buffers...
(use-package marginalia
  :functions marginalia-mode
  :init
  (marginalia-mode))

;; Find functions, variables, etc. without being precise in the spelling.
;; partial-completion matches each word anywhere in the candidate, in order.
;; Separate words with - or *, not a space: "kill-buf" and "k*buf" match
;; kill-buffer, "kill buf" and "buf-kill" don't.  flex is the fallback for
;; typos and abbreviations.
(setopt completion-styles '(partial-completion flex basic)
        completion-category-overrides '((file (styles partial-completion)))
        completion-pcm-leading-wildcard t
        completion-ignore-case t
        read-buffer-completion-ignore-case t
        read-file-name-completion-ignore-case t)

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
(use-feature ispell
  :custom
  (ispell-program-name "aspell")
  (ispell-dictionary "en_US")
  ;; UTF-8 instead of the dictionary's default Latin-1, so words like
  ;; "hernández" in the personal dictionary are read correctly
  (ispell-local-dictionary-alist
   '(("en_US" "[[:alpha:]]" "[^[:alpha:]]" "['’]" t ("-d" "en_US") nil utf-8)))
  ;; There are lots of technical words that we don't want flagged as typos,
  ;; so they go in a local custom dictionary.
  (ispell-personal-dictionary
   (expand-file-name "personal-dictionary.pws" user-emacs-directory)))

;; Prose is checked everywhere; code only in comments and strings.
;; Words are checked as they're typed or the cursor passes them, so typos
;; already in a file show up only after M-x flyspell-buffer.
(defun Minimalist/flyspell-prog-maybe ()
  "Enable `flyspell-prog-mode', except in JSON."
  (unless (derived-mode-p 'json-ts-mode)
    (flyspell-prog-mode)))

(use-feature flyspell
  :hook ((text-mode . flyspell-mode)
         (prog-mode . Minimalist/flyspell-prog-maybe))
  :custom
  (flyspell-delay-use-timer t)
  (flyspell-issue-message-flag nil)
  (flyspell-issue-welcome-flag nil)
  ;; Keep M-TAB for `completion-at-point'
  (flyspell-use-meta-tab nil))

;; Code checking
;; Only Emacs Lisp: it's the only mode here with a built-in Flymake backend
;; whose tools are installed.  The scratch buffer is left out.
(defun Minimalist/flymake-maybe-enable ()
  "Enable `flymake-mode', except in `lisp-interaction-mode'."
  (unless (derived-mode-p 'lisp-interaction-mode)
    (flymake-mode)))

(use-feature flymake
  :hook (emacs-lisp-mode . Minimalist/flymake-maybe-enable)
  :custom
  (flymake-no-changes-timeout 2.0)
  :config
  (set-face-attribute 'flymake-warning nil
                      :foreground Minimalist/warning-text :weight 'normal))

;; The Elisp byte-compile check only runs in trusted files, and needs this
;; session's `load-path' to find installed packages.
(setopt trusted-content '("~/.emacs.d/"))
(use-feature elisp-mode
  :custom
  (elisp-flymake-byte-compile-load-path (cons "./" load-path)))

(declare-function flymake-running-backends "flymake")
(declare-function flymake-reporting-backends "flymake")
(defun Minimalist/flymake-mode-line ()
  "Error, warning and note counts for the mode line, or nil without Flymake."
  (when (and (bound-and-true-p flymake-mode) (flymake-running-backends))
    (propertize
     (if (seq-difference (flymake-running-backends) (flymake-reporting-backends))
         " 󰔟:E  󰔟:W  󰔟:I "
       (let ((counts (list (cons :error 0) (cons :warning 0) (cons :note 0))))
         (dolist (diag (flymake-diagnostics))
           (when-let* ((cell (assq (flymake-diagnostic-type diag) counts)))
             (setcdr cell (1+ (cdr cell)))))
         (format " %d:E  %d:W  %d:I "
                 (alist-get :error counts)
                 (alist-get :warning counts)
                 (alist-get :note counts))))
     'face `(:foreground ,Minimalist/fg-secondary))))

;; --------------------------------------------------------------------------------
;; Files and version control

;; File manager
;; C-c d opens the current file's directory, C-c t toggles a side panel with
;; the project (or current directory).  In the panel, RET on a file opens it
;; in the main window; directories open in the panel.
(defun Minimalist/dired-side-window ()
  "The Dired side panel's window in this frame, or nil."
  (seq-find (lambda (w) (window-parameter w 'Minimalist/dired-side))
            (window-list)))

(defun Minimalist/dired-side-toggle ()
  "Toggle a Dired side panel for the current project or directory."
  (interactive)
  (if-let* ((win (Minimalist/dired-side-window)))
      (delete-window win)
    (let* ((file buffer-file-name)
           (proj (project-current))
           (dir (if proj (project-root proj) default-directory))
           (win (display-buffer-in-side-window
                 (dired-noselect dir)
                 '((side . left)
                   (slot . 0)
                   (window-width . 35)
                   (preserve-size . (t . nil))
                   (window-parameters . ((no-delete-other-windows . t)
                                         (Minimalist/dired-side . t)))))))
      (select-window win)
      (when file
        (dired-goto-file file)))))

(declare-function dired-goto-file "dired")
(declare-function dired-get-file-for-visit "dired")
(declare-function dired-find-file "dired")
(defun Minimalist/dired-find-file ()
  "Like `dired-find-file', but files from the side panel open in the main window."
  (interactive)
  (let ((file (dired-get-file-for-visit)))
    (if (and (window-parameter nil 'Minimalist/dired-side)
             (not (file-directory-p file)))
        (progn
          (select-window (or (get-mru-window nil nil t) (window-main-window)))
          (find-file file))
      (dired-find-file))))

(use-feature dired
  :custom
  (dired-listing-switches "-alh")
  (dired-dwim-target t)
  ;; macOS ls has no --dired option
  (dired-use-ls-dired nil)
  ;; Moving to another directory replaces the Dired buffer instead of
  ;; leaving one behind for every directory visited
  (dired-kill-when-opening-new-dired-buffer t)
  :bind (("C-c d" . dired-jump)
         ("C-c t" . Minimalist/dired-side-toggle)
         :map dired-mode-map
         ("RET" . Minimalist/dired-find-file))
  :config
  (set-face-foreground 'dired-directory Minimalist/accent))

(use-feature project
  :custom
  ;; `touch .project` marks a root
  (project-vc-extra-root-markers '(".project")))

(use-package magit)

;; Git indicators, only in code buffers: git-gutter and visual-fill-column
;; both use the left margin and would fight over it in text buffers.
;; The signs need a Nerd Font.
(declare-function git-gutter:update-all-windows "git-gutter")
(use-package git-gutter
  :hook (prog-mode . git-gutter-mode)
  :custom
  (git-gutter:modified-sign "\uf440")
  (git-gutter:added-sign "\uf067")
  (git-gutter:deleted-sign "\uf068")
  :config
  (add-hook 'magit-post-refresh-hook #'git-gutter:update-all-windows)
  (dolist (face '(git-gutter:modified git-gutter:added git-gutter:deleted))
    (set-face-attribute face nil :foreground Minimalist/fg-faint :weight 'normal)))

;; --------------------------------------------------------------------------------
;; Tools

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
;; The menu bar, tool bar and scroll bars are turned off in early-init.el.

;; Stop the cursor from blinking.
;; In a terminal, what "visible" means depends on the emulator.
(setopt visible-cursor nil
        blink-cursor-mode nil)

;; Don't let mouse clicks in a terminal move the cursor (TTY only)
(xterm-mouse-mode -1)

(add-hook 'prog-mode-hook #'display-line-numbers-mode)
;; (add-hook 'text-mode-hook #'display-line-numbers-mode)

;; Mode line
;; The format below is fully custom, so the default mode-line-* pieces
;; (mule info, remote indicator, frame id, position, minor modes) never show.

(defconst Minimalist/vc-git-icon "\ue0a0"
  "Branch glyph (U+E0A0, Powerline/Nerd Font set).")

(defun Minimalist/vc-git-mode-line (s)
  "Swap the \"Git\" backend name in S for a branch icon.
S looks like \"Git-main\": the backend name, a state character, then the
branch.  Returns \"<icon> main \"; the state shows only through the face
copied from S.  If S doesn't have that shape (the format is internal to
vc-git and could change), it's returned unchanged rather than mangled.
The leading space is prepended later by `vc-mode-line'."
  (if (string-match "\\`Git[^[:alnum:]]\\(.+\\)\\'" s)
      (propertize (concat Minimalist/vc-git-icon " " (match-string 1 s) " ")
                  'face (get-text-property 0 'face s))
    s))

(advice-add 'vc-git-mode-line-string :filter-return #'Minimalist/vc-git-mode-line)

(defun Minimalist/file-status-indicator ()
  "Colored circle reflecting buffer save/modify/read-only state."
  (let ((color (cond
                (buffer-read-only Minimalist/read-only) ; read-only
                ((buffer-modified-p) Minimalist/modified) ; unsaved changes
                (t Minimalist/marker)))) ; saved
    (propertize " ●" 'face `(:foreground ,color))))

(defvar-local Minimalist/display-path-cache nil
  "Cons of (TRUENAME . DISPLAY-STRING) for the mode line.")

(defun Minimalist/buffer-display-path ()
  "Project name and project-relative path or the full path or the buffer name."
  (if-let* ((file buffer-file-truename))
      (if (equal (car Minimalist/display-path-cache) file)
          (cdr Minimalist/display-path-cache)
        (let* ((proj (project-current))
               (str (if proj
                        (concat (project-name proj) "/"
                                (file-relative-name file (project-root proj)))
                      file)))
          (setq Minimalist/display-path-cache (cons file str))
          str))
    (buffer-name)))

(defvar-local Minimalist/line-count-cache nil
  "Cons of (KEY . LINE-COUNT-STRING) for the mode line.
KEY is (CHARS-MODIFIED-TICK POINT-MIN POINT-MAX), so the count is
redone only after an edit or a change of narrowing.")

(defun Minimalist/buffer-line-count ()
  "Number of lines in the accessible part of the buffer, as a string.
`count-lines' scans the whole buffer, so the result is cached instead
of recomputed on every mode-line redisplay."
  (let ((key (list (buffer-chars-modified-tick) (point-min) (point-max))))
    (if (equal (car Minimalist/line-count-cache) key)
        (cdr Minimalist/line-count-cache)
      (let ((str (number-to-string (count-lines (point-min) (point-max)))))
        (setq Minimalist/line-count-cache (cons key str))
        str))))

(defconst Minimalist/mode-line-gap "    "
  "Space between mode-line segments.")

;; A list starting with a symbol is a conditional in `mode-line-format', so
;; lists that should just show `Minimalist/mode-line-gap' first start with "".
(setq-default mode-line-format
              '(" "
                (buffer-file-truename
                 ((:eval (Minimalist/file-status-indicator)) "  "))
                (:eval (propertize (Minimalist/buffer-display-path)
                                   'face '(:weight bold)))
                Minimalist/mode-line-gap
                "\uebd0  %l of "
                (:eval (Minimalist/buffer-line-count))
                Minimalist/mode-line-gap
                mode-name
                (vc-mode ("" Minimalist/mode-line-gap vc-mode))
                Minimalist/mode-line-gap
                (:eval (Minimalist/flymake-mode-line))))

;; Faces

(set-face-attribute 'default nil
                    :foreground Minimalist/fg
                    :background Minimalist/bg
                    :height 140
                    :family "JetBrainsMono Nerd Font")
(set-face-attribute 'header-line nil
                    :background Minimalist/bg
                    :foreground Minimalist/fg-subtle)
(set-face-attribute 'mode-line nil
                    :background Minimalist/bg-surface
                    :foreground Minimalist/fg-secondary
                    :box '(:style flat-button :line-width 4))
(set-face-attribute 'mode-line-inactive nil
                    :background Minimalist/bg-surface
                    :foreground Minimalist/fg-faint
                    :box '(:style flat-button :line-width 4))
(set-face-attribute 'button nil
                    :foreground Minimalist/fg-secondary)
(set-face-attribute 'show-paren-match nil
                    :foreground Minimalist/paren-match
                    :background Minimalist/bg
                    :weight 'bold)
(set-face-foreground 'line-number Minimalist/fg-faint)
(set-face-attribute 'line-number-current-line nil
                    :foreground Minimalist/fg-secondary
                    :weight 'bold)
(set-face-background 'region Minimalist/bg-selection)
(set-face-attribute 'highlight nil
                    :background Minimalist/bg-selection)
(set-face-attribute 'isearch nil
                    :background Minimalist/bg-selection
                    :foreground Minimalist/fg
                    :weight 'bold)
(set-face-attribute 'lazy-highlight nil
                    :background Minimalist/bg-selection
                    :foreground Minimalist/fg)
(set-face-attribute 'minibuffer-prompt nil
                    :foreground Minimalist/fg
                    :weight 'normal)
(set-face-attribute 'error nil
                    :foreground Minimalist/error
                    :underline `(:style wave :color ,Minimalist/error)
                    :weight 'normal)

;; Syntax highlighting: grayscale, structure shown through weight and slant
(set-face-attribute 'font-lock-function-name-face nil
                    :foreground Minimalist/fg
                    :weight 'bold)
(set-face-attribute 'font-lock-keyword-face nil
                    :foreground Minimalist/fg
                    :weight 'bold)
(set-face-attribute 'font-lock-builtin-face nil
                    :foreground Minimalist/fg
                    :weight 'bold
                    :slant 'italic)
(set-face-attribute 'font-lock-variable-name-face nil
                    :foreground Minimalist/fg
                    :slant 'italic)

(set-face-attribute 'font-lock-comment-face nil
                    :foreground Minimalist/fg-comment
                    :slant 'italic)
(set-face-attribute 'font-lock-doc-face nil
                    :foreground Minimalist/fg-comment
                    :slant 'italic)

(set-face-attribute 'font-lock-string-face nil
                    :foreground Minimalist/fg-string
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
  (set-face-attribute face nil :foreground Minimalist/fg))

;; Dim parentheses in code
(defface Minimalist/parenthesis
  `((t :foreground ,Minimalist/fg-ghost :weight normal))
  "Face for parentheses, brackets and braces in code."
  :group 'faces)

(defun Minimalist/dim-parentheses ()
  "Show parentheses, brackets and braces in `Minimalist/parenthesis'."
  (font-lock-add-keywords nil '(("[][(){}]" 0 'Minimalist/parenthesis))))

(add-hook 'prog-mode-hook #'Minimalist/dim-parentheses)

;; Whitespace indicators (M-x whitespace-mode)
(use-feature whitespace
  :custom
  (whitespace-style '(face tabs spaces space-before-tab newline indentation empty
                           space-after-tab space-mark tab-mark newline-mark
                           missing-newline-at-eof))
  :custom-face
  (whitespace-space ((t (:background nil :foreground ,Minimalist/marker)))))

;; --------------------------------------------------------------------------------
;; Text and markup

;; Width for wrapped comments and prose
;; Also applies to programming modes
(setq-default fill-column 80)

;; Soft-wrap prose at fill-column
(use-package visual-fill-column
  :hook ((text-mode . visual-line-mode)
         (visual-line-mode . visual-fill-column-mode)))

;; Indent wrapped continuation lines under list items
(use-feature visual-wrap
  :hook (text-mode . visual-wrap-prefix-mode))

(use-feature org
  :config
  (dolist (spec '((org-level-1 . 1.35)
                  (org-level-2 . 1.2)
                  (org-level-3 . 1.1)
                  (org-level-4 . 1.05)))
    (set-face-attribute (car spec) nil
                        :height (cdr spec)
                        :weight 'semibold)))

(use-feature markdown-ts-mode
  :mode ("\\.md\\'" "\\.markdown\\'"))

(use-feature json-ts-mode
  :mode ("\\.json\\'"))

;; --------------------------------------------------------------------------------
;; General programming

;; Hard-wrap comments, and only comments, in code
(setopt comment-auto-fill-only-comments t)
(add-hook 'prog-mode-hook #'auto-fill-mode)

;; Show hex colors like "#RRGGBB" in their color, with black or white text
;; depending on which is readable on it
(defun Minimalist/hex-color-face ()
  "Face for the hex color matched by font-lock."
  (let ((color (match-string-no-properties 0)))
    `(:background ,color
      :foreground ,(if (color-dark-p (color-name-to-rgb color)) "white" "black"))))

(defun Minimalist/show-hex-colors ()
  "Show hex colors in the current buffer in their color."
  (font-lock-add-keywords
   nil '(("#\\(?:[[:xdigit:]]\\{3\\}\\)\\{1,4\\}\\b"
          0 (Minimalist/hex-color-face) t))
   'append))

(add-hook 'emacs-lisp-mode-hook #'Minimalist/show-hex-colors)

;; --------------------------------------------------------------------------------
;; Lisps

;; Keep parentheses balanced
(use-package paredit
  :hook ((emacs-lisp-mode lisp-mode scheme-mode) . paredit-mode))

;; Keep Lisp code indented as it's edited
(use-package aggressive-indent
  :hook ((emacs-lisp-mode lisp-mode scheme-mode) . aggressive-indent-mode))

;; Emacs Lisp: semantic highlighting and highlighting of the variable at point
(setopt elisp-fontify-semantically t
        elisp-variable-at-point t)
(set-face-attribute 'elisp-variable-at-point nil
                    :background Minimalist/bg-selection)

;; Show whether the buffer uses lexical or dynamic binding in the mode name
(add-hook 'emacs-lisp-mode-hook
          (lambda ()
            (setq mode-name
                  '("Elisp" (lexical-binding " \uf0ec Lexical" " \uf0ec Dynamic")))))

;; Scheme (Chez Scheme)
(use-package geiser-chez
  :custom
  (geiser-chez-binary "chez")
  (geiser-active-implementations '(chez)))

;; --------------------------------------------------------------------------------
;; Forth (GForth)

(use-package forth-mode
  :mode ("\\.fs\\'" . forth-mode)
  :commands (forth-mode run-forth)
  :config
  (require 'forth-block-mode)
  (require 'forth-interaction-mode))

;; --------------------------------------------------------------------------------
;; Elixir and Phoenix

;; Tree-sitter grammars for the built-in elixir-ts-mode and heex-ts-mode.
;; Install them once with M-x treesit-install-language-grammar, first
;; "elixir", then "heex".  Building them needs git and a C compiler.
(use-feature treesit
  :config
  (add-to-list 'treesit-language-source-alist
               '(elixir "https://github.com/elixir-lang/tree-sitter-elixir"))
  (add-to-list 'treesit-language-source-alist
               '(heex "https://github.com/phoenixframework/tree-sitter-heex")))

;; Format with the language server (mix format) before saving, but only
;; when a server manages the buffer, so saving never fails without one
(declare-function eglot-managed-p "eglot")
(defun Minimalist/eglot-format-before-save ()
  "Format the buffer with its language server, if one is managing it."
  (when (and (fboundp 'eglot-managed-p) (eglot-managed-p))
    (eglot-format-buffer)))

(defun Minimalist/elixir-setup ()
  "Start the language server and format on save in Elixir buffers."
  (eglot-ensure)
  (add-hook 'before-save-hook #'Minimalist/eglot-format-before-save nil t))

;; Elixir code: .ex, .exs and mix.lock.  ~H sigils inside .ex files are
;; highlighted as HEEx by elixir-ts-mode itself.
(use-feature elixir-ts-mode
  :mode ("\\.exs?\\'" "mix\\.lock\\'")
  :hook (elixir-ts-mode . Minimalist/elixir-setup))

;; Phoenix templates in their own .heex files
(use-feature heex-ts-mode
  :mode ("\\.heex\\'")
  :hook (heex-ts-mode . Minimalist/elixir-setup))

;; Language servers.  Eglot turns on Flymake in the buffers it manages, so
;; their diagnostics show in the mode line like Emacs Lisp's.
(use-feature eglot
  :custom
  ;; Stop a server when the last buffer it manages is killed
  (eglot-autoshutdown t)
  ;; Don't log every message to the events buffer; it slows editing down
  (eglot-events-buffer-config '(:size 0 :format full))
  :bind (:map eglot-mode-map
              ("C-c e r" . eglot-rename)
              ("C-c e a" . eglot-code-actions)
              ("C-c e f" . eglot-format-buffer))
  :config
  ;; Expert, the official Elixir language server, found on PATH
  (add-to-list 'eglot-server-programs
               '((elixir-ts-mode heex-ts-mode) . ("expert" "--stdio"))))

;; --------------------------------------------------------------------------------

(provide 'init)
;;; init.el ends here
