
# About

This package for Emacs improves the built-in `tmm-menubar`
(text-mode-menu) in a few ways.

- Makes it look nicer.

  Removes extraneous text from the top and bottom of the
  *\*Completions\** buffer and from the minibuffer.  Removes the
  modeline from the *\*Completions\** buffer.

  These changes are only effective when displaying the `tmm-menubar`
  and will not alter Emacs's default completions system.

- Allows more customization, such as changing the prompt in the
  minibuffer. 

- Makes the shortcuts more consistent, so your muscle memory can
  rely on them with fewer surprises.  For example, in the File
  menu, the shortcut for Save is "s", and the shortcut for Save As
  is "S".  But if your file is unmodified, then the Save menu item
  is inactive, so Save As would suddenly get the shortcut "s"
  instead of "S".  Nicer-tmm gives you the option to prevent that,
  so you can usually rely on menu shortcuts being the same.

- Prevents double menus from appearing when a minibuffer completion
  package is enabled and configured to appear before input.  (For
  example, when `icomplete-vertical-mode` is on with
  `icomplete-show-matches-on-no-input' enabled.)

# Configuration

Once installed, "M-x nicer-tmm-mode RET" enables the mode.

You can toggle the `nicer-tmm-mode` variable from its Customization
group.  Just do "M-x customize-group RET nicer-tmm RET".  Click the
toggle button next to "Nicer Tmm Mode" and then click "Apply and
Save" to save it for future sessions.

Alternatively, you could copy this line to your init file:
`(customize-set-variable 'nicer-tmm-mode t)`

The easiest way to set options for this package is from the
Customization group, as described above.  But if you prefer to
manually code all Emacs settings in your init file, please be aware
that the `nicer-tmm-improve-shortcut-consistency` option has a
custom :set property.  So if you wish to turn that off, you will
need to use `customize-set-variable` (not `setq`) for that.

# Keybindings

In Emacs, the default binding for `tmm-menubar` is "M-\`".  In some
desktop environments, that key is used for navigating between
applications.  So you may want to create an additional keybinding for
`tmm-menubar`.  One candidate for this is "<f10>", which by default
brings up a graphical menu.  (Another potential candidate is the
"<menu>" key.)

`(global-set-key (kbd "<menu>") 'tmm-menubar)`

In addition, it's convenient to use the same key for exiting
`tmm-menubar`.  This gives you the ability to check what commands are
accessible from the menu, and then exit from it without moving your
hand.  An example is shown below.

`(define-key minibuffer-mode-map (kbd "<menu>") 'keyboard-escape-quit)`

Selecting menu items

There are 4 ways to select a menu item in `tmm-menubar`:
+ Using the shortcut keys displayed next to the menu-items (my
  personal preference),
+ Minibuffer history (up/down movement without leaving the
  minibuffer), or
+ Jumping into the *\*Completions\** buffer (by pressing "PgUp" or
  "M-v"), moving to an item, and selecting it by pressing "RET".
+ Clicking on an item with the mouse.  (Comments in the `tmm` package
  indicate that mouse usage may not be dependable, but it has worked
  when I've tried it.)
