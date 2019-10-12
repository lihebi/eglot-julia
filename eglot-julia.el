;; The initial version is from
;; https://github.com/julia-vscode/LanguageServer.jl/wiki/Emacs
;;
;; I might make changes

(require 'cl-generic)

(defcustom julia-default-depot ""
  "The default depot path, used if `JULIA_DEPOT_PATH' is unset"
  :type 'string
  :group 'julia-config)

(defcustom julia-default-environment "~/.julia/environment/v1.2"
  "The default julia environment"
  :type 'string
  :group 'julia-config)

(defun julia/get-depot-path ()
  (if-let (env-depot (getenv "JULIA_DEPOT_PATH"))
      (expand-file-name env-depot)
    (if (equal julia-default-depot "")
        julia-default-depot
      (expand-file-name julia-default-depot))))

(defun julia/get-environment (dir)
  (expand-file-name (if dir (or (locate-dominating-file dir "JuliaProject.toml")
                                (locate-dominating-file dir "Project.toml")
                                julia-default-environment)
                      julia-default-environment)))

;; Make project.el aware of Julia projects
(defun julia/project-try (dir)
  (let ((root (or (locate-dominating-file dir "JuliaProject.toml")
                  (locate-dominating-file dir "Project.toml"))))
    (and root (cons 'julia root))))
(add-hook 'project-find-functions 'julia/project-try)

(cl-defmethod project-roots ((project (head julia)))
  (list (cdr project)))

(defun julia/get-language-server-invocation (interactive)
  `("julia"
    ;; FIXME use platform independent name
    ,(expand-file-name "~/.emacs.d/straight/repos/eglot-julia/eglot.jl")
    ,(julia/get-environment (buffer-file-name))
    ,(julia/get-depot-path)))

;; Setup eglot with julia
;; FIXME autoload??
(with-eval-after-load 'eglot
  (setq eglot-connect-timeout 100)
  (add-to-list 'eglot-server-programs
               ;; function instead of strings to find project dir at runtime
               '(julia-mode . julia/get-language-server-invocation))
  (add-hook 'julia-mode-hook 'eglot-ensure))

(provide 'eglot-julia)
