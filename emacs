; Preferences
(global-linum-mode 1)

(ido-mode 1)
(setq ido-enable-flex-matching t)
(setq ido-everywhere t)

(put 'upcase-region 'disabled nil)

(add-hook 'before-save-hook 'delete-trailing-whitespace)

(setq indent-tabs-mode nil)

; Enable package manager and make sure all packages are installed
(require 'package)

(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/"))
(add-to-list 'package-archives '("melpa-stable" . "http://stable.melpa.org/packages/"))

(setq package-list '('heroku-theme 'web-mode 'flycheck 'exec-path-from-shell 'json-mode 'npm 'yasnippet 'auto-complete))

(package-initialize)

(unless package-archive-contents
  (package-refresh-contents))

(dolist (package package-list)
  (unless (package-installed-p package)
    (package-install package)))

; Package preferences
(require 'web-mode)
(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.phtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.[agj]sp\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.mustache\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.djhtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.js[x]?\\'" . web-mode))
(defun my-web-mode-hook ()
  "Hooks for Web mode. Adjust indents"
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-css-indent-offset 2)
  (setq web-mode-code-indent-offset 2))
(add-hook 'web-mode-hook  'my-web-mode-hook)

(require 'flycheck)
(add-hook 'after-init-hook #'global-flycheck-mode)
(setq-default flycheck-disabled-checkers
  (append flycheck-disabled-checkers
    '(javascript-jshint)))
(flycheck-add-mode 'javascript-eslint 'web-mode)
(setq-default flycheck-disabled-checkers
  (append flycheck-disabled-checkers
    '(json-jsonlist)))

(require 'exec-path-from-shell)
(require 'json-mode)

(require 'npm)
(global-set-key (kbd "M-n i") 'npm-install)
(global-set-key (kbd "M-n n") 'npm-new)
(global-set-key (kbd "M-n d") 'npm-new-dependency)
(global-set-key (kbd "M-n e") 'npm-nodemon-exec)
(global-set-key (kbd "M-n p") 'npm-publish)
(global-set-key (kbd "M-n t") 'npm-test)
(global-set-key (kbd "M-n v") 'npm-version)

(require 'yasnippet)
(yas-global-mode 1)

(require 'auto-complete)
(ac-config-default)
