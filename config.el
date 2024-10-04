;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

(setq org-directory (or (getenv "ZETTEL_BASE") "~org"))
(setq templates_dir (or (getenv "ORG_TEMPLATES_DIR") "~org/templates"))
(setq org-track-ordered-property-with-tag t)
(setq org-use-property-inheritance t)
(setq org-clock-in-switch-to-state "IN PROGRESS")
(setq org-refile-targets '((org-agenda-files :maxlevel . 3))) ; any agenda file will show up in the list when choosing to refile
(setq org-log-into-drawer "LOGBOOK") ;when adding a note, put them in logbook drawer
;; TODO find out how to bring up menu to choose state when clocking out
(setq org-clock-out-switch-to-state "PEND SET STATE")
(setq org-log-reschedule 'time) ;puts a note in logbook drawer when a task is rescheudled
(setq org-tag-alist '(("NEW" . ?N)
                      (:startgroup . nil)
                      ("INCIDENT" . ?i)
                      ("NUCLEUS-INC" . ?n)
                      ("TRAINING" . ?r)
                      ("SCRIPTING" . ?s)
                      ("CUST-MEETING" . ?c)
                      ("TCS-MEETING" . ?t)
                      ("CRQ" . ?c)
                      ("MISC" . ?m)
                      ("W-O-REQ" . ?w)))
                                      ;TODO Updated these based on https://youtu.be/PVsSOmUB7ic?si=-jYPMOlGBHw_ihEa&t=1568
;; Save Org buffers after refiling!
(advice-add 'org-refile :after 'org-save-all-org-buffers)
(advice-add 'org-capture :after (lambda ()
                                  (interactive)
                                  (org-save-all-org-buffers)
                                  ;; (Re)set org-agenda files. Spacemacs auto-updates the list list above in custom-set-variables
                                  (setq org-agenda-files ;Adds all .org files to agenda unless they are in the archive folder
                                        (seq-filter (lambda(x) (not (string-match "/archive/"(file-name-directory x))))
                                                    (directory-files-recursively org-directory "\\.org$")
                                                    ))
                                  ))
(setq org-capture-templates
      `(
        ("S" "Store" entry
         (file (lambda() (interactive) (my/generate-new-store-file-name)))
         (file  ,(concat templates_dir "/store-template.txt")))
        ("i" "Incident" entry
         (file (lambda() (interactive) (my/generate-new-inc-file-name)))
         (file  ,(concat templates_dir "/inc-template.txt")))
        ("t" "TODO entry" entry
         (file+headline "journal.org" "Capture")
         "* TODO %^{Description} :NEW:\n  Desired outcome: %?\n  :LOGBOOK:\n  - Added: %U\n  :END:"
         :empty-lines-before 1)
        ("i" "Incoming Phone call" entry
         (file+olp+datetree "journal.org")
         (file "templates/in-call-template.txt"))
        ("o" "Outgoing Phone call" entry
         (file+headline "journal.org" "Capture")
         (file  ,(concat templates_dir "/out-call-template.txt")))
        ("e" "Email" entry
         (file+headline "journal.org" "Capture")
         (file  ,(concat templates_dir "/email-template.txt")))
        ("s" "Script" entry
         (file (lambda() (interactive) (my/generate-new-script-file-name)))
         (file  ,(concat templates_dir "/script-template.txt")))
        ("m" "Meeting" entry
         (file+headline "journal.org" "Capture")
         (file  ,(concat templates_dir "/meeting-template.txt")))
        ("j" "Journal entry" entry
         (file+olp+datetree "journal.org")
         "* %U - %^{Activity}")
        ("d" "Daily plan" plain
         (file+olp+datetree "journal.org")
         (file  ,(concat templates_dir "/tpl-daily-plan.txt"))
         :immediate-finish t)
        ("w" "Daily plan" plain
         (file+olp+datetree "journal.org")
         (file  ,(concat templates_dir "/tpl-weekly-plan.txt"))
         :immediate-finish t)
        ("m" "Monthly plan" plain
         (file+olp+datetree "journal.org")
         (file  ,(concat templates_dir "/tpl-monthly-plan.txt"))
         :immediate-finish t)
        ))
(setq org-enforce-todo-dependencies t)
(setq org-agenda-dim-blocked-tasks t)
(setq org-agenda-custom-commands
      (quote
       (
        ("A" . "Agendas")
        ("AT" "Daily overview"
         ((tags-todo "URGENT"
                     ((org-agenda-overriding-header "Urgent Tasks")))
          (tags-todo "RADAR"
                     ((org-agenda-overriding-header "On my radar")))
          (tags-todo "PHONE+TODO=\"NEXT\""
                     ((org-agenda-overriding-header "Phone Calls")))
          (tags-todo "Depth=\"Deep\"/NEXT"
                     ((org-agenda-overriding-header "Next Actions requiring deep work")))
          (agenda ""
                  ((org-agenda-overriding-header "Today")
                   (org-agenda-span 1)
                   (org-agenda-sorting-strategy
                    (quote
                     (time-up priority-down)))))
          nil nil))
        ("AW" "Weekly overview" agenda ""
         ((org-agenda-overriding-header "Weekly overview")))
        ("AM" "Monthly overview" agenda ""
         ((org-agenda-overriding-header "Monthly overview"))
         (org-agenda-span
          (quote month))
         (org-deadline-warning-days 0)
         (org-agenda-sorting-strategy
          (quote
           (time-up priority-down tag-up))))
        ("D" . "DAILY Review Helper")
        ("Dn" "New tasks" tags "NEW"
         ((org-agenda-overriding-header "NEW Tasks")))
        ("Dp" "Pending Set State" tags-todo "PEND SET STATE"
         ((org-agenda-overriding-header "Tasks Pending Set State")))
        ("Dd" "Check DELEGATED tasks" todo "DELEGATED"
         ((org-agenda-overriding-header "DELEGATED tasks")))
        ("Db" "Check BLOCKED tasks" todo "BLOCKED"
         ((org-agenda-overriding-header "BLOCKED tasks")))
        ("Df" "Check finished tasks" todo "DONE|CANCELLED|FORWARDED"
         ((org-agenda-overriding-header "Finished tasks")))
        ("DP" "Planing ToDos (unscheduled) only" todo "TODO|NEXT"
         ((org-agenda-overriding-header "Planning overview")
          (org-agenda-skip-function
           (quote
            (org-agenda-skip-entry-if
             (quote scheduled)
             (quote deadline)))))))
       ))
(setq org-ellipsis " ▾")
;(setq org-superstar-headline-bullets-list '("⚫" "◎" "◉" "○" "►" "◇")) These mess up screen a bunch when not using graphical mode
(setq org-enforce-todo-checkbox-dependencies t)
(setq org-M-RET-may-split-line nil)
(setq org-agenda-include-diary t)
(setq org-agenda-files ;Adds all .org files to agenda unless they are in the archive folder
      (seq-filter (lambda(x) (not (string-match "/archive/"(file-name-directory x))))
                  (directory-files-recursively org-directory "\\.org$")
                  ))
(global-tab-line-mode t) ;tabs with buffer names at the top of the window
(global-unset-key (kbd "M-h"))
(global-set-key (kbd "M-h") (lambda () (interactive) (previous-buffer)))
(global-set-key (kbd "M-l") (lambda () (interactive) (next-buffer)))
(add-hook 'org-mode-hook
          (lambda ()
            (interactive)
            (setq doom-localleader-key ",")
            (map! :leader :desc "org-insert-heading-respect-content" "RET" #'org-insert-heading-respect-content)
            (map! :localleader (:prefix ("i" . "insert") "S" #'yas-insert-snippet))
                                      ;define-key also seems to work? TODO What's the difference?
            (define-key evil-normal-state-map (kbd "t") 'org-todo)
            (local-set-key (kbd "C-c C-i") 'org-clock-in)
            (local-set-key (kbd "C-c C-o") 'org-clock-out)
            (local-set-key (kbd "C-c RET") 'my/org-ctrl-c-ret)
            (org-indent-mode)
            ))
;;useful functions
(defun my/org-ctrl-c-ret ()
  "Call `org-table-hline-and-move' or `org-insert-heading'."
  (interactive)
  (cond
   ((org-at-table-p) (call-interactively 'org-table-hline-and-move))
   (t (call-interactively 'org-insert-heading-respect-content))))
(defun my/org-set-property-when-state-changes ()
  (interactive)
  (when (equal (org-get-todo-state) "BLOCKED")
    (let (msg (read-string "Describe blocker: "))
      (org-set-property "BLOCKED_BY" msg)))
  (when (equal (org-get-todo-state) "FORWARDED")
    (let (msg (read-string "To Whom?: "))
      (org-set-property "FORWARDED_TO" msg)))
  )
(defun my/generate-new-store-file-name () "Ask for a title and generate a file name based on it"
       (let* ((store_nbr (read-string "Store #: "))
              (my-path (concat
                        "2-areas/str"
                        store_nbr
                        ".org")))
         (setq my/org-capture-store_nbr store_nbr)
         (setq my/org-capture-store_nbr-file_path my-path)) ; Save variable to be used later in the template
       my/org-capture-store_nbr-file_path)
(defun my/generate-new-inc-file-name () "Ask for a title and generate a file name based on it"
       (let* ((inc (read-string "Incident #: "))
                                      ;(store (read-string "Store #: ")) #Might change to prompt user for addl details like store#, POC, phone #, summary later.
              (my-path (concat
                        "1-projects/"
                        inc
                        ".org")))
                                      ;(setq my/org-capture-store_nbr store_nbr)
         (setq my/org-capture-inc inc)
         (setq my/org-capture-inc-file_path my-path)) ; Save variable to be used later in the template
       my/org-capture-inc-file_path)
(defun my/generate-new-script-file-name () "Ask for a title and generate a file name based on it"
       (let* ((script_name (read-string "Script Name: "))
              (my-path (concat
                        "1-projects/script_"
                        script_name
                        ".org")))
         (setq my/org-capture-script-name script_name)
         (setq my/org-capture-script-file-path my-path)) ; Save variable to be used later in the template
       my/org-capture-script-file-path)
(defun my/org-insert-subheading (arg)
    "Insert a new subheading and demote it.
Works for outline headings and for plain lists alike.
The prefix argument ARG is passed to `org-insert-heading'.
Unlike `org-insert-heading', when point is at the beginning of a
heading, still insert the new sub-heading below. The version
shipping with spacemacs (9.7.11 at the time of logging this)
has an extra line after (interactive) that fudges things up.
What is the purpose?
  (when (and (bolp) (not (eobp)) (not (eolp))) (forward-char))
"
  (interactive "P")
  (org-insert-heading arg)
  (cond
   ((org-at-heading-p) (org-do-demote))
   ((org-at-item-p) (org-indent-item))))
(defun insert-now-timestamp() ;
  "Insert org mode timestamp at point with current date and time."
  (interactive)
  (org-insert-time-stamp (current-time) t))
(defun message-elements-of-list (list)
  "Print each element of LIST on a line of its own."
  (while list
    (message (car list) #'external-debugging-output)
    (setq list (cdr list))))
