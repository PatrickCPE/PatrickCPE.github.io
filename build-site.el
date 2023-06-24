

;; Set the package installation directory so that packages aren't stored in the
;; ~/.emacs.d/elpa path.
(require 'package)
(setq package-user-dir (expand-file-name "./.packages"))
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

;; Initialize the package system
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Install dependencies
(package-install 'htmlize)


;; Load the publishing system
(require 'ox-publish)



;; Define the publishing project
(setq org-publish-project-alist
      (list
       (list "patrickcpe"
             :recursive t
             :base-directory "./src"
             :publishing-directory "./build"
             :publishing-function 'org-html-publish-to-html
             :with-author nil           ;; Don't include author name
             :with-creator t            ;; Include Emacs and Org versions in footer
             :with-toc t                ;; Include a table of contents
             :section-numbers nil       ;; Don't include section numbers
             :time-stamp-file nil)))    ;; Don't include time stamp in file

;; Customize the HTML output
;;(setq org-html-validation-link nil)            ;; Don't show validation link
(setq org-html-validation-link nil            ;; Don't show validation link
      org-html-head-include-scripts nil       ;; Use our own scripts
      org-html-head-include-default-style nil ;; Use our own styles
      org-html-head "<link rel=\"stylesheet\" href=\"../src/worg.css\" />

")
    ;;  org-html-head "<link rel=\"stylesheet\" href=\"https://orgmode.org/worg/style/worg.css"/>" />")
;; 7/10 reccomended by system craft;; org-html-head "<link rel=\"stylesheet\" href=\"https://cdn.simplecss.org/simple.min.css\" />")
;; 6/10 solarized dark ;; org-html-head "<link rel=\"stylesheet\" href=\"http://thomasf.github.io/solarized-css/solarized-dark.min.css\" />")

;; Generate the site output
(org-publish-all t)

(message "Build complete!")
