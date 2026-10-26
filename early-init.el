;;; early-init.el --- Settings needed before the first frame  -*- lexical-binding: t; -*-

;;; Commentary:
;; Emacs loads this before the package system and before drawing the first
;; frame, so it holds what must be in effect before either: the environment
;; for native compilation, and which UI elements the frame has.

;;; Code:

;; --------------------------------------------------
;; Native compilation

;; Log native-compilation warnings to *Warnings* without popping it up.
;; This option has no setter, so `setq' does the same as `setopt' here
;; without loading the Customize library before the first frame.
(setq native-comp-async-report-warnings-errors 'silent)

;; Work around libgccjit 14.x miscomputing the macOS version on macOS 27: it
;; derives the version from the Darwin kernel version, and clang rejects the
;; result.  Set before any compilation starts, since the compiler subprocesses
;; inherit the environment.  An existing value is respected.
(when (and (eq system-type 'darwin)
           (native-comp-available-p)
           (not (getenv "MACOSX_DEPLOYMENT_TARGET")))
  (when-let* ((version (ignore-errors
                         (car (process-lines "sw_vers" "-productVersion")))))
    (setenv "MACOSX_DEPLOYMENT_TARGET" version)))

;; Make cargo binaries available
(when (eq system-type 'darwin)
  (let ((cargo-bin (expand-file-name "~/.cargo/bin")))
    (add-to-list 'exec-path cargo-bin)
    (setenv "PATH" (concat cargo-bin ":" (getenv "PATH")))))

;; --------------------------------------------------
;; Frame

;; Turning UI elements off here, as frame parameters, means they're never
;; drawn; doing it in init.el makes them flash at startup.
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)

;; Keep the modes' variables in sync with the frame parameters, so toggling
;; one of these modes later works on the first try
(setq menu-bar-mode nil
      tool-bar-mode nil
      scroll-bar-mode nil)

;;; early-init.el ends here
