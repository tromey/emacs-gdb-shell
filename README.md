This has some code for making gdb work more nicely with Emacs from a
terminal, and for adding some gdb (and other) handling to shell mode.

## egdb

The script `egdb` can be used from the terminal to invoke gdb inside
Emacs.  You must be running the Emacs server (see `server-start`) for
this to work.

`egdb` creates a new TTY frame in the current terminal, then starts
`gdb` in Emacs.  The current directory and the arguments to `egdb` are
passed to Emacs.

By default `egdb' uses the `gdb` from your `PATH`.  However you can
change this by setting the `GDB` environment variable.

`egdb` uses the variable `gdb-shell-gdb` to decide what interface to
use in Emacs.  The default is `gud-gdb`.  Other ones may be possible
but you may have to hack `gdb-shell-egdb` a bit.

## `gdb-shell-minor-mode`

This minor mode turns on some simple adaptive behavior in
`shell-mode`.  In particular it recognizes some commands that you
enter and tries to substitute built-in Emacs behavior instead:

* `gdb`.  Runs gdb in Emacs instead (via `gdb-shell-gdb`), preserving
  the command line and current directory.

* `ant`, `make`, or `valgrind`.  Enables   `compilation-shell-minor-mode`.
