;;; -*- lexical-binding: t; -*-
;; Key-bindings

;; get rid of the menu bar
(menu-bar-mode -1)

;; navigation
(global-set-key (kbd "C-o") 'scroll-down)

;; make pretty colors in the shell
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

;; Add to load-path
(add-to-list 'load-path (expand-file-name "~/dotfiles/modes"))

;; cucumber feature mode
(add-to-list 'auto-mode-alist '("\.feature$" . feature-mode))

;; Files that begin with Makefile should use makefile-mode
(add-to-list 'auto-mode-alist '("Makefile.*\\'" . makefile-mode))

;; jump to definition for C++
;; (require 'dumb-jump)
;; (defun c++-jump-hook ()
;;   (global-set-key (kbd "C-c C-j") 'dumb-jump-go)
;;   (global-set-key (kbd "M-*") 'dumb-jump-back)
;;   )
;; (add-hook 'c++-mode-hook 'c++-jump-hook)

;; tcl mode for expect
(add-to-list 'auto-mode-alist '(".exp$" . tcl-mode))
(add-to-list 'interpreter-mode-alist '("expect" . tcl-mode))

;; packages
(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                         ("marmalade" . "http://marmalade-repo.org/packages/")
                         ("melpa" . "http://melpa.milkbox.net/packages/")))

;; No bell
(setq ring-bell-function 'ignore)

;; auto-save and backup config
(setq temporary-file-directory "~/.emacs.files/tmp/")
(setq backup-directory-alist
      `((".*" . , temporary-file-directory)))
(setq auto-save-file-name-transforms
                `((".*" , temporary-file-directory t)))

;; common lisp extensions
(require 'cl)

;; julia
;; (require 'julia-mode)
;; (add-to-list 'auto-mode-alist '("\\.jl$" . julia-mode))

;; Go
;; (setq gofmt-command "goimports")
;; (require 'go-mode-autoloads)
;; (add-hook 'before-save-hook #'gofmt-before-save)
;; (global-set-key (kbd "C-c d") 'godoc-at-point)
;; (setq compilation-always-kill t)
;; (setq compilation-scroll-output t)
;; (global-set-key (kbd "C-c C-r") 'recompile)
;; (global-set-key (kbd "C-c C-k") 'kill-compilation)
;; (global-set-key (kbd "C-c C-f") 'save-and-compile-program)
;; (global-set-key (kbd "C-c C-i") 'save-and-install-program)
;; (global-set-key (kbd "C-c C-t") 'save-and-test-program)

;; save all files then run M-x compile
(defun save-and-compile-program()
  "Save any unsaved buffers and compile"
  (interactive)
  (save-some-buffers t)
  (compile "bash -c 'godep go build -o /tmp/a.out'"))

;; save all files then run M-x compile
(defun save-and-install-program()
  "Save any unsaved buffers and compile"
  (interactive)
  (save-some-buffers t)
  (compile "bash -c 'go install'"))

;; save all files then run M-x compile
(defun save-and-test-program()
  "Save any unsaved buffers and compile"
  (interactive)
  (save-some-buffers t)
  (compile "make test"))

(add-to-list 'auto-mode-alist '("\\.js\\'" . web-mode))

(add-hook 'web-mode-hook
	  (lambda ()
	    (web-mode-set-content-type "jsx")
	    (setq web-mode-attr-indent-offset 2)
	    (setq web-mode-attr-value-indent-offset 2)
	    (setq web-mode-enable-control-block-indentation 2)
	    (setq web-mode-code-indent-offset 2)
	    (setq web-mode-css-indent-offset 2)
	    (setq web-mode-markup-indent-offset 2)
	    (setq web-mode-sql-indent-offset 2)

	    (setq js-indent-level 2)
	    (setq jsx-indent-level 2)
	    (setq indent-tabs-mode nil)

	    (setq web-mode-enable-auto-indentation t)
	    (setq web-mode-enable-auto-closing t)
	    (setq web-mode-enable-auto-expanding t)
	    (setq web-mode-enable-auto-opening t)
	    (setq web-mode-enable-auto-pairing t)
	    (setq web-mode-enable-auto-quoting t)
	    (setq web-mode-enable-block-face t)
	    (setq web-mode-enable-comment-interpolation t)
	    (setq web-mode-enable-css-colorization t)
	    (setq web-mode-enable-current-column-highlight t)
	    (setq web-mode-enable-current-element-highlight t)
	    (setq web-mode-enable-element-content-fontification t)
	    (setq web-mode-enable-element-tag-fontification t)
	    (setq web-mode-enable-engine-detection t)
	    (setq web-mode-enable-heredoc-fontification t)
	    (setq web-mode-enable-html-entities-fontification t)
	    (setq web-mode-enable-inlays t)
	    (setq web-mode-enable-part-face t)
	    (setq web-mode-enable-sexp-functions t)
	    (setq web-mode-enable-sql-detection t)
	    (setq web-mode-enable-string-interpolation t)
	    (flycheck-add-mode 'javascript-eslint 'web-mode)
	    ;; Disable jshint in favor of eslint.
	    (setq-default flycheck-disabled-checkers
			  (append flycheck-disabled-checkers
				    '(javascript-jshint)))
	    ))

;; additional configuration
(global-set-key (kbd "C-c C-l") 'linum-mode)
(setq indent-tabs-mode nil)
(setq tab-width 8)
(setq default-tab-width 8)
(defvaralias 'c-basic-offset 'tab-width)
