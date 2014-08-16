;; @Author: Young Lee
;; @Email: youngleemails@gmail.com
;; @Time: Sat Aug 16 00:56:09 2014
(add-to-list 'load-path "~/.emacs.d/elisp")
(add-to-list 'load-path "~/.emacs.d/plugins/js2-mode")
(add-to-list 'load-path "~/.emacs.d/plugins/jquery-doc")


;; smart-tabs-mode
(require 'smart-tabs-mode)
(smart-tabs-insinuate 'c 'javascript)
(smart-tabs-advice js2-indent-line js2-basic-offset)
(smart-tabs-advice ruby-indent-line ruby-indent-level)
(setq ruby-indent-tabs-mode t)


;; js2-mode
(autoload 'js2-mode "js2-mode" nil t)
(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode)) 
(add-hook 'js2-post-parse-callbacks
          (lambda ()
            (when (> (buffer-size) 0)
              (let ((btext (replace-regexp-in-string
                            ": *true" " "
                            (replace-regexp-in-string "[\n\t ]+" " " (buffer-substring-no-properties 1 (buffer-size)) t t))))
                (mapc (apply-partially 'add-to-list 'js2-additional-externs)
                      (split-string
                       (if (string-match "/\\* *global *\\(.*?\\) *\\*/" btext) (match-string-no-properties 1 btext) "")
                       " *, *" t))))))

(add-hook 'js2-post-parse-callbacks
          (lambda ()
            (let ((buf (buffer-string))
                  (index 0))
              (while (string-match "\\(goog\\.require\\|goog\\.provide\\)('\\([^'.]*\\)" buf index)
                (setq index (+ 1 (match-end 0)))
                (add-to-list 'js2-additional-externs (match-string 2 buf))))))


;; js-flymake
(require 'flymake-easy)
(require 'flymake-cursor)
(require 'flymake-jslint)
(add-hook 'js-mode-hook 'flymake-jslint-load)
;; (add-hook 'js2-mode-hook 'flymake-jslint-load)
(custom-set-variables
 '(help-at-pt-timer-delay 0.9)
 '(help-at-pt-display-when-idle '(flymake-overlay)))


;; jquery doc
(require 'jquery-doc)
(add-hook 'js2-mode-hook 'jquery-doc-setup)


;; js2-highlight-vars
(require 'js2-highlight-vars)
(if (featurep 'js2-highlight-vars)
    (js2-highlight-vars-mode))


;; foldings
(add-hook 'js2-mode-hook
          (lambda ()
            ;; Scan the file for nested code blocks
            (imenu-add-menubar-index)
            ;; Activate the folding mode
            (hs-minor-mode t)))


;; js-comint
(require 'js-comint)
;; Use node as our repl
(setq inferior-js-program-command "node")
;; (setq inferior-js-program-command "/usr/bin/java org.mozilla.javascript.tools.shell.Main")
(add-hook 'js2-mode-hook '(lambda () 
                            (local-set-key "\C-x\C-e" 'js-send-last-sexp)
                            (local-set-key "\C-\M-x" 'js-send-last-sexp-and-go)
                            (local-set-key "\C-cb" 'js-send-buffer)
                            (local-set-key "\C-c\C-b" 'js-send-buffer-and-go)
                            (local-set-key "\C-cl" 'js-load-file-and-go)))
(setq inferior-js-mode-hook
      (lambda ()
        ;; We like nice colors
        (ansi-color-for-comint-mode-on)
        ;; Deal with some prompt nonsense
        (add-to-list 'comint-preoutput-filter-functions
                     (lambda (output)
                       (replace-regexp-in-string ".*1G\.\.\..*5G" "..."
                     (replace-regexp-in-string ".*1G.*3G" "&gt;" output))))))


;; --- Syntax Table And Parsing ---
(defvar javascript-mode-syntax-table
  (let ((table (make-syntax-table)))
    (c-populate-syntax-table table)
    (modify-syntax-entry ?' "." table)
    (modify-syntax-entry ?\" "." table)
    (modify-syntax-entry ?_ "w" table)
    table))
(defconst js-quoted-string-re "\\(\".*?[^\\]\"\\|'.*?[^\\]'\\)")
(defconst js-quoted-string-or-regex-re "\\(/.*?[^\\]/\\w*\\|\".*?[^\\]\"\\|'.*?[^\\]'\\)")


;; Mozilla mode
;; use moz-repl to work interactively with mozilla browser
;; use following snippets if you are using js2-mode
(autoload 'moz-minor-mode "moz"
  "Mozilla Minor and Inferior Mozilla Modes"
  t)
(add-hook 'js2-mode-hook 'js2-custom-setup)
(defun js2-custom-setup () (moz-minor-mode 1))

;; js-lookup
(require 'js-lookup)
