;; -*- lexical-binding: t; -*-

(setq native-comp-async-report-warnings-errors 'silent)

;; Work around libgccjit 14.x miscomputing the macOS version on macOS 27
;; (Darwin 27 - 9 = "18.0", which clang rejects).
(when (eq system-type 'darwin)
  (setenv "MACOSX_DEPLOYMENT_TARGET"
          (or (getenv "MACOSX_DEPLOYMENT_TARGET")
              (string-trim (shell-command-to-string "sw_vers -productVersion")))))
