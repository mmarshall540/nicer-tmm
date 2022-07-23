;;; nicer-tmm.el --- improvements to the tmm-menu-bar  -*- lexical-binding: t; -*-

;; Copyright (C) 2022  Martin Marshall

;; Author: Martin Marshall <law@martinmarshall.com>
;; Version: 0.1
;; Keywords: convenience

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; This package improves the built-in `tmm-menubar'
;; (text-mode-menu)in a few ways.
;;
;; * Makes it look nicer.
;;
;;   Removes extraneous text from the top and bottom of the
;;   *Completions* buffer and from the minibuffer.  Removes the
;;   modeline from the *Completions* buffer.
;;
;;   These changes are only effective when displaying the
;;   `tmm-menubar' and will not alter Emacs's default Completions
;;   system when used for completions.
;; 
;; * Allows for more customization, such as changing the prompt in the
;;   minibuffer.
;; 
;; * Makes the shortcuts more consistent, so your muscle memory can
;;   rely on them with fewer surprises.  For example, in the File
;;   menu, the shortcut for Save is "s", and the shortcut for Save As
;;   is "S".  But if your file is unmodified, then the Save menu item
;;   is inactive, so Save As would suddenly get the shortcut "s"
;;   instead of "S".  Nicer-tmm gives you the option to prevent that,
;;   so you can usually rely on menu shortcuts being the same.
;;   
;; * Prevents double menus from appearing when a minibuffer completion
;;   package is enabled and configured to appear before input.  (For
;;   example, when `icomplete-vertical-mode' is on with
;;   `icomplete-show-matches-on-no-input' enabled.)

;; Configuration
;;
;; Once installed, "M-x nicer-tmm-mode RET" enables the mode.
;;
;; You can toggle the `nicer-tmm-mode' variable from its Customization
;; group.  Just do "M-x customize-group RET nicer-tmm RET".  Click the
;; toggle button next to "Nicer Tmm Mode" and then click "Apply and
;; Save" to save it for future sessions.
;;
;; Alternatively, you could copy this line to your init file:
;; (customize-set-variable 'nicer-tmm-mode t)
;;
;; The easiest way to set options for this package is from the
;; Customization group, as described above.  But if you prefer to
;; manually code all Emacs settings in your init file, please be aware
;; that the `nicer-tmm-improve-shortcut-consistency' option has a
;; custom :set property.  So if you wish to turn that off, you will
;; need to use `customize-set-variable' (not `setq') for that.

;; Keybindings
;; 
;; In Emacs, the default binding for `tmm-menubar' is "M-`".  In some
;; desktop environments, that key is used for navigating between
;; applications.  So you might want to create an additional keybinding
;; for `tmm-menubar'.  One candidate for this is <f10>, which by
;; default brings up a graphical menu.  (Another potential candidate
;; is the <menu> key.)
;;
;; (global-set-key (kbd "<menu>") 'tmm-menubar)
;;
;; In addition, it's convenient to use the same key for exiting the
;; tmm-menubar.  This gives you the ability to check what commands are
;; accessible from the menu, and then exit from it without moving your
;; hand.  An example of this is shown below.
;;
;; (define-key minibuffer-mode-map (kbd "<menu>") 'keyboard-escape-quit)

;; Selecting menu items
;; 
;; There are 4 ways to select menu items in `tmm-menubar':
;; + Using the shortcut keys displayed next to the menu-items (my
;;   personal preference),
;; + Minibuffer history (up/down movement without leaving the
;;   minibuffer), or
;; + Jumping into the *Completions* buffer (by pressing "PgUp" or
;;   "M-v"), moving to an item, and selecting it by pressing "RET".
;; + Clicking on an item with the mouse.  (Comments in the `tmm'
;;   package indicate that mouse usage is not dependable, but it has
;;   worked when I've tried it.)

;;; Code:

(require 'tmm)

(defgroup nicer-tmm nil
  "Settings for the nicer-tmm package."
  :group 'tmm
  :package-version '(nicer-tmm . "0.1"))

(defcustom nicer-tmm-nicer-mid-prompt " → "
  "Custom string to use as `tmm-mid-prompt'.
If a string, it replaces the original \"==>\".  Alternatively,
you can set this to nil, and change the value of `tmm-mid-prompt'
directly."
  :type '(choice (const :tag "Off" nil)
		 string)
  :group 'nicer-tmm)
;; Why not just change the default value of `tmm-mid-prompt', rather
;; than create this convoluted situation?

(defcustom nicer-tmm-remove-top-text t
  "Whether to remove the 'Possible completions are:' text.
That's the text that normally appears at the top of the top of
the `tmm-menubar' buffer."
  :type '(boolean)
  :group 'nicer-tmm)
;; Why not just change the default value of `tmm-completion-prompt',
;; rather than create this convoluted situation?

(defcustom nicer-tmm-minibuffer-prompt "Menu bar: "
  "Text to use as a prompt below the menu."
  :type '(string)
  :group 'nicer-tmm)

(defcustom nicer-tmm-completions-format
  (if (version< emacs-version "28")
      'vertical
    'one-column)
  "The format of the menu, i.e. how it is visually arranged.
If you are using Emacs 28 or higher, the `one-column' format
looks best (but also covers more of the screen).  For earlier
versions, only `horizontal' and `vertical' are available."
  :type '(symbol)
  :group 'nicer-tmm)

(defcustom nicer-tmm-completions-header-format nil
  "Format string to use as the header of the `tmm-menubar' buffer."
  :type '(string)
  :group 'nicer-tmm)

(defcustom nicer-tmm-completion-show-help nil
  "Whether to display the help message with `tmm-menubar'."
  :type '(boolean)
  :group 'nicer-tmm)

(defcustom nicer-tmm-hide-modeline t
  "Whether to hide the modeline of the '*Completions*' buffer."
  :type '(boolean)
  :group 'nicer-tmm)

(defcustom nicer-tmm-hide-cursor t
  "Whether to hide the cursor of the '*Completions*' buffer.
This only applies when using `tmm-menubar', and only when the
buffer's window is inactive."
  :type '(boolean)
  :group 'nicer-tmm)

(defcustom nicer-tmm-improve-shortcut-consistency t
  "Whether to prevent some changes to the `tmm-menu-bar' shortcuts.

This ensures that changes in the active or inactive status of
menu-items won't alter the automatically chosen shortcut keys of
menu-items below.

Note that this doesn't provide 100% consistency with the shortcut
keys.  Modes can still add *new* menu items, which could still
offset shortcut keys that are placed below them.  For example, if
you were not using `recentf-mode' but then enabled it, your
shortcut for \"Open File...\" in the \"File\" menu would change
from \"f o\" to \"f O\".  Of course, you can leave that mode on,
and the new shortcuts will be consistent from then on.

\(This option uses a custom :set property and must be set either
using the Customization buffer or with one of the customize
functions, such as `customize-set-variable'.)"
  :type '(boolean)
  :group 'nicer-tmm
  :set (lambda (symbol value)
	 (set symbol value)
	 (when nicer-tmm-improve-shortcut-consistency
	     (advice-add 'tmm-add-one-shortcut :override 'nicer-tmm-add-one-shortcut)
	     (advice-remove 'tmm-add-one-shortcut 'nicer-tmm-add-one-shortcut))))

;; (defvar nicer-tmm-old-tmm-key nil "Holder for key that was previously bound to `tmm-menubar'.")
;; (defvar nicer-tmm-old-keybinding nil "Holder for command previously bound to the new key.")

;; (defcustom nicer-tmm-new-tmm-key nil
;;   "Non-nil binds `tmm-menubar' to the key indicated.
;; Accepts a string that the `kbd' function can convert to Emacs's
;; internal keybinding notation."
;;   :type '(choice (const :tag "Off" nil)
;; 		 string)
;;   :group 'nicer-tmm
;;   :set (lambda (symbol value)
;; 	 (set symbol value)
;; 	 (if nicer-tmm-new-tmm-key
;; 	     (progn
;; 	       (when (and nicer-tmm-old-tmm-key
;; 			  (not (string= nicer-tmm-old-tmm-key nicer-tmm-new-tmm-key)))
;; 		 (global-set-key (kbd nicer-tmm-old-tmm-key) nicer-tmm-old-keybinding))
;; 	       (setq nicer-tmm-old-tmm-key nicer-tmm-new-tmm-key)
;; 	       (setq nicer-tmm-old-keybinding (lookup-key global-map (kbd nicer-tmm-new-tmm-key)))
;; 	       (global-set-key (kbd nicer-tmm-new-tmm-key) 'tmm-menubar))
;; 	   (when nicer-tmm-old-tmm-key
;; 	     (global-set-key (kbd nicer-tmm-old-tmm-key) nicer-tmm-old-keybinding)))))

;; (defvar nicer-tmm-old-minibuffer-key nil
;;   "Holder for key that was previously bound to `tmm-menubar'.")
;; (defvar nicer-tmm-old-minibuffer-keybinding nil
;;   "Holder for command previously bound to the new key.")
;; (defcustom nicer-tmm-new-minibuffer-key nil
;;   "Non-nil binds `minibuffer-keyboard-quit' to the key indicated.
;; Accepts a string that the `kbd' function can convert to
;; Emacs's internal keybinding notation."
;;   :type '(choice (const :tag "Off" nil)
;; 		 string)
;;   :group 'nicer-tmm
;;   :set (lambda (symbol value)
;; 	 (set symbol value)
;; 	 (if nicer-tmm-new-minibuffer-key
;; 	     (progn
;; 	       (setq nicer-tmm-old-minibuffer-key nicer-tmm-new-minibuffer-key)
;; 	       (setq nicer-tmm-old-minibuffer-keybinding (lookup-key global-map (kbd nicer-tmm-new-minibuffer-key)))
;; 	       (define-key minibuffer-mode-map (kbd nicer-tmm-new-minibuffer-key) 'minibuffer-keyboard-quit))
;; 	   (when nicer-tmm-old-minibuffer-key
;; 	     (define-key minibuffer-mode-map (kbd nicer-tmm-old-minibuffer-key) nicer-tmm-old-minibuffer-keybinding)))))

;; Update parenthetical in the `tmm-menubar' minibuffer prompt.
(defun nicer-tmm-change-prompt-advice (func p &rest r)
  "Function to temporarily add as advice to `completing-read'.

This allows the `tmm-menubar' prompt to be changed.

Calls FUNC with a modified prompt argument P and passes along any
other arguments R."
  (let ((prompt (replace-regexp-in-string
		 "Menu bar (up/down to change, PgUp to menu): "
		 nicer-tmm-minibuffer-prompt p)))
    (apply func prompt r)))

(defun nicer-tmm-hook ()
"Remove modeline and cursor from *Completions* buffer."
  (with-current-buffer "*Completions*"
    (when nicer-tmm-hide-modeline
      (setq-local mode-line-format nil))
    (when nicer-tmm-hide-cursor
      (setq-local cursor-in-non-selected-windows nil))))

;; Apply the above functions.  Also prevent a duplicate menu from
;; appearing when a minibuffer completion package is enabled.
;; Additionally, set the completions format and mid-prompt used by
;; `tmm-menubar'.
(defun nicer-tmm-advice (func &rest r)
  "The main function implementing `nicer-tmm'.
When `nicer-tmm-mode' is enabled, this function is added as
:around advice to the `tmm-prompt'.

Causes FUNC to be called with the arguments R.  But the
conditions required for `nicer-tmm' are enabled before the
functin call and disabled after the call."
  (advice-add 'completing-read-default :around 'nicer-tmm-change-prompt-advice)
  (when nicer-tmm-improve-shortcut-consistency
    (advice-add 'tmm-add-one-shortcut :override 'nicer-tmm-add-one-shortcut))
  (add-hook 'completion-list-mode-hook 'nicer-tmm-hook)
  (run-with-timer 0 nil 'nicer-tmm-finish)
  (let ((minibuffer-setup-hook nil) ; avoid duplicate menus
	(completions-format   ; use one-column format if available unless set differently by user
	 nicer-tmm-completions-format)
	(completions-header-format nicer-tmm-completions-header-format)
	(completion-show-help nicer-tmm-completion-show-help)
	(tmm-mid-prompt (or nicer-tmm-nicer-mid-prompt
			    tmm-mid-prompt))
	(tmm-completion-prompt (if (not nicer-tmm-remove-top-text)
				   tmm-completion-prompt
				 (if (version< "29" emacs-version)
				     ""
				   nil))))
    (apply func r)))

(defun nicer-tmm-finish (&rest _r)
  "Remove hooks and advice after finishing a call to `tmm-menubar'.
Arguments R are passed but ignored."
;; Needs to be done as :after advice.  If it's included in
;; `nicer-tmm-advice' (which is added as :around advice), it won't
;; get run when exiting the `tmm-menubar' with
;; `keyboard-escape-quit'.
  (remove-hook 'completion-list-mode-hook 'nicer-tmm-hook)
  (advice-remove 'completing-read-default 'nicer-tmm-change-prompt-advice))

;; A modified `tmm-add-one-shortcut' function, which causes shortcut
;; characters to be consistent when the active or inactive status of
;; menu items above them has changed.
;;
;; Unfortunately menu shortcuts can still change if a *new* menu item
;; is added.  But most modes that add to the menus will only add a new
;; menu to the top-level, so lower level menu items aren't rearranged.
;; Generally, such menus are placed near the end of the menu-bar, just
;; before the Help menu, so they usually won't affect menus appearing
;; further to the left.
(defvar tmm-short-cuts)
(defvar tmm-next-shortcut-digit)
(defun nicer-tmm-add-one-shortcut (elt)
  "A modified version of `tmm-add-one-shortcut' from tmm.el.

Takes the same argument ELT, but the order of events is altered
so that shortcut keys don't change depending on whether earlier
menu items are inactive."
  (let* ((str (car elt))
	 (paren (if (version< "28" emacs-version)
		    (string-search "(" str)
		  (string-match "(" str)))
	 (pos 0) (word 0) char)
    (catch 'done                             ; ??? is this slow?
      (while (and (or (not tmm-shortcut-words)   ; no limit on words
                      (< word tmm-shortcut-words)) ; try n words
		  (setq pos (string-match "\\w+" str pos)) ; get next word
		  (not (and paren (> pos paren)))) ; don't go past "(binding.."
	(if (or (= pos 0)
		(/= (aref str (1- pos)) ?.)) ; avoid file extensions
	    (dolist (shortcut-style ; try upcase and downcase variants
		     (if (listp tmm-shortcut-style) ; convert to list
			 tmm-shortcut-style
		       (list tmm-shortcut-style)))
              (setq char (funcall shortcut-style (aref str pos)))
              (if (not (memq char tmm-short-cuts)) (throw 'done char))))
	(setq word (1+ word))
	(setq pos (match-end 0)))
      (while (<= tmm-next-shortcut-digit ?9) ; no letter shortcut, pick a digit
	(setq char tmm-next-shortcut-digit)
	(setq tmm-next-shortcut-digit (1+ tmm-next-shortcut-digit))
	(if (not (memq char tmm-short-cuts)) (throw 'done char)))
      (setq char nil))
    (if char (setq tmm-short-cuts (cons char tmm-short-cuts)))
    (if (eq (cddr elt) 'ignore)
	(cons (concat " " (make-string (length tmm-mid-prompt) ?\-)
                      (car elt))
              (cdr elt))
      (cons (concat (if char (concat (char-to-string char) tmm-mid-prompt)
                      (make-string (1+ (length tmm-mid-prompt)) ?\s))
		    str)
	    (cdr elt)))))

(define-minor-mode nicer-tmm-mode
  "Improve the look and function of the `tmm-menubar'."
  :global t
  (if nicer-tmm-mode
      (progn
	(advice-add 'tmm-prompt :around 'nicer-tmm-advice))
    (progn
      (advice-remove 'tmm-prompt 'nicer-tmm-advice)
      (advice-remove 'tmm-add-one-shortcut 'nicer-tmm-add-one-shortcut))))

;;;###autoload (with-eval-after-load 'tmm (require 'nicer-tmm))

(when nicer-tmm-mode (nicer-tmm-mode))

(provide 'nicer-tmm)
;;; nicer-tmm.el ends here
