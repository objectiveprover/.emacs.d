;;; site-lisp.el --- Third-party packages kept in this config  -*- lexical-binding: t; -*-

;;; Commentary:
;; Each directory next to this file holds one package, copied in from its
;; original repository and now part of this config: free to edit, and only
;; changed when I change it.  package.el and the package archives aren't
;; used at all.
;;
;; init.el loads this file and calls `Minimalist/site-lisp-activate', which
;; puts every package on `load-path' and loads its autoloads.
;;
;; A package's Lisp files are in its directory, or in a lisp/ or elisp/
;; subdirectory if it has one.  Manuals are .texi files in the directory or
;; in doc/ or docs/.
;;
;; Add a package (or a new dependency of one): copy its files into
;; site-lisp/NAME.  Remove one: delete its directory.  After adding,
;; updating or editing packages, rebuild from ~/.emacs.d:
;;
;;   emacs --batch -l site-lisp/site-lisp.el -f Minimalist/site-lisp-build
;;
;; That generates autoloads, byte-compiles every package and builds the
;; Info manuals (C-h i) of those that have one.  Building the manuals needs
;; makeinfo and install-info from Homebrew's texinfo; macOS's own are too
;; old.  Without them, the manuals are skipped.
;;
;; Build output (*.elc, *-autoloads.el, *.info, dir) sits next to the
;; sources and is ignored by git (see .gitignore).

;;; Code:

(defconst Minimalist/site-lisp-root
  (file-name-directory (or load-file-name buffer-file-name))
  "Directory holding one git submodule per package.")

(defun Minimalist/site-lisp-packages ()
  "Alist of (NAME . LISP-DIRECTORY) for every package in site-lisp/.
LISP-DIRECTORY is the package's lisp/ or elisp/ subdirectory if it has
one (magit, with-editor, geiser), otherwise its top directory."
  (let (packages)
    (dolist (dir (directory-files Minimalist/site-lisp-root t "\\`[^.]"))
      (when (file-directory-p dir)
        (push (cons (file-name-nondirectory dir)
                    (seq-find #'file-directory-p
                              (list (expand-file-name "lisp" dir)
                                    (expand-file-name "elisp" dir)
                                    dir)))
              packages)))
    (nreverse packages)))

(defun Minimalist/site-lisp-autoloads-file (package)
  "Autoloads file for PACKAGE, an element of `Minimalist/site-lisp-packages'."
  (expand-file-name (concat (car package) "-autoloads.el") (cdr package)))

(defconst Minimalist/site-lisp-manual-directories '("." "doc" "docs")
  "Where packages keep their Texinfo manuals, relative to their top directory.")

(defun Minimalist/site-lisp-manual-locations ()
  "Existing directories in site-lisp/ where a package may keep its manual."
  (let (dirs)
    (dolist (package (directory-files Minimalist/site-lisp-root t "\\`[^.]"))
      (when (file-directory-p package)
        (dolist (sub Minimalist/site-lisp-manual-directories)
          (let ((dir (file-name-as-directory (expand-file-name sub package))))
            (when (file-directory-p dir)
              (push dir dirs))))))
    (nreverse dirs)))

(defvar Info-additional-directory-list)

(defun Minimalist/site-lisp-activate ()
  "Add every package to `load-path', load its autoloads and add its manual."
  ;; Only once Info is first used, so startup doesn't check for manuals
  (with-eval-after-load 'info
    (dolist (dir (Minimalist/site-lisp-manual-locations))
      (when (file-exists-p (expand-file-name "dir" dir))
        (add-to-list 'Info-additional-directory-list dir t))))
  (let ((missing nil))
    (dolist (package (Minimalist/site-lisp-packages))
      (add-to-list 'load-path (cdr package))
      (let ((autoloads (Minimalist/site-lisp-autoloads-file package)))
        (if (file-exists-p autoloads)
            (load autoloads nil t)
          (push (car package) missing))))
    (when missing
      (display-warning
       'site-lisp
       (format "Not built yet: %s.  Run from ~/.emacs.d:
emacs --batch -l site-lisp/site-lisp.el -f Minimalist/site-lisp-build"
               (string-join (nreverse missing) ", "))))))

(defconst Minimalist/site-lisp-skip-regexp
  (rx (or (seq (or "-test" "-tests" "-autoloads" "-pkg" "-debug") ".el" eos)
          (seq bos (or "test" "build") ".el" eos)))
  "Files that aren't part of a package proper: tests, build scripts, etc.")

(defun Minimalist/site-lisp-build-manuals ()
  "Build each package's Texinfo manual into an .info file next to its source.
Each manual is also listed in a dir file in the same directory, which is
what Info reads.  Only .texi files starting with \\input texinfo are
manuals; the rest are pieces that a manual @includes.  Returns the manuals
that failed."
  (let ((makeinfo (executable-find "makeinfo"))
        (install-info (executable-find "install-info"))
        (failed nil))
    (if (not (and makeinfo install-info))
        (message "\nmakeinfo or install-info not found: skipping the manuals")
      (dolist (dir (Minimalist/site-lisp-manual-locations))
        (dolist (texi (directory-files dir t "\\`[^.].*\\.texi\\'"))
          (when (with-temp-buffer
                  (insert-file-contents texi nil 0 200)
                  (looking-at-p "\\\\input texinfo"))
            (let* ((default-directory dir) ; For @include
                   (info (concat (file-name-base texi) ".info"))
                   (name (file-relative-name texi Minimalist/site-lisp-root)))
              (message "--- manual: %s" name)
              (with-temp-buffer
                (if (and (zerop (call-process makeinfo nil t nil
                                              "--no-split" "-o" info texi))
                         (zerop (call-process install-info nil t nil
                                              info "dir")))
                    (when (> (buffer-size) 0) (message "%s" (buffer-string)))
                  (message "%s" (buffer-string))
                  (push name failed)))))))
      (nreverse failed))))

(defun Minimalist/site-lisp-build ()
  "Generate autoloads for and byte-compile every package, and build manuals.
Meant for batch use; see the commentary for the command."
  (let ((packages (Minimalist/site-lisp-packages))
        (lisp-files "\\`[^.].*\\.el\\'")  ; Not .dir-locals.el
        (failed nil))
    ;; Everything on `load-path' first, so packages can find their
    ;; dependencies while compiling
    (dolist (package packages)
      (add-to-list 'load-path (cdr package)))
    (dolist (package packages)
      (let* ((dir (cdr package))
             (files (seq-remove
                     (lambda (file)
                       (string-match-p Minimalist/site-lisp-skip-regexp
                                       (file-name-nondirectory file)))
                     (directory-files dir t lisp-files))))
        (message "--- %s" (car package))
        (loaddefs-generate dir (Minimalist/site-lisp-autoloads-file package)
                           (seq-difference (directory-files dir t lisp-files)
                                           files))
        (dolist (file files)
          (unless (byte-compile-file file)
            (push (file-relative-name file Minimalist/site-lisp-root) failed)))))
    (setq failed (append (nreverse (Minimalist/site-lisp-build-manuals))
                         failed))
    (if failed
        (progn
          (message "\nFailed to compile:\n  %s"
                   (string-join (nreverse failed) "\n  "))
          (kill-emacs 1))
      (message "\nBuilt %d packages." (length packages)))))

(provide 'site-lisp)
;;; site-lisp.el ends here
