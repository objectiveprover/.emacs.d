# The Minimalist Emacs

My personal Emacs configuration, built for clarity and simplicity. It runs in
the terminal only, lives in one `init.el`, and uses no package manager: every
third-party package is copied into this repository and loaded from there.

<img width="2035" height="1749" alt="image" src="https://github.com/user-attachments/assets/4c15a59c-3e8a-4480-b94f-bb154af5b97a" />

## Highlights

- **Terminal only.** The menu bar is turned off before the first frame is
  drawn. Copying goes to the system clipboard through OSC 52, so it also works
  over SSH and inside tmux.
- **No package manager.** `package.el` is off. 24 packages are vendored in
  `site-lisp/` and built automatically the first time Emacs starts.
- **A quiet theme.** Code is mostly black on white. Structure shows through
  bold and italics rather than color, comments are magenta and parentheses are
  dimmed. Colors come from the Flexoki palette and are used only through named
  tokens (`Minimalist/fg`, `Minimalist/accent`, …), so restyling means changing
  one token.
- **A custom mode line** showing the save state as a colored dot, the
  project-relative path, "line N of M", the major mode, the Git branch and
  Flymake error/warning counts.
- **Built-in completion.** Vertical `icomplete` with `marginalia` annotations,
  forgiving matching (`partial-completion` and `flex`), inline completion
  preview and `which-key`.
- **Languages:**
  - Clojure (clojure-ts-mode, CIDER, clojure-lsp)
  - Elixir and Phoenix (elixir-ts-mode, heex-ts-mode, Expert)
  - Scheme (Geiser with Chez Scheme)
  - Forth (Gforth)
- **Lisp editing** with paredit and aggressive-indent, Git with Magit and
  git-gutter, a terminal with eat, spell checking with Flyspell and Aspell.

## Requirements

- **Emacs 31** or newer.
- A terminal using a **Nerd Font**, for the icons in the mode line and the Git
  signs in the margin.
- For the tool installer: **macOS** with Homebrew, or **Linux** with apt
  (Debian, Ubuntu) or pacman (Arch). On Arch, Chez Scheme and Gforth are only
  in the AUR, so they need [paru](https://github.com/Morganamilo/paru) or
  [yay](https://github.com/Jguer/yay).

## Installation

```sh
git clone https://github.com/objectiveprover/.emacs.d.git ~/.emacs.d
emacs -nw
```

The first start byte-compiles everything in `site-lisp/`, which takes a minute
or two. The output goes to the `*site-lisp build*` buffer. If any of the tools
every setup needs are missing, Emacs warns about them at startup.

## External tools

`bootstrap.sh` installs the programs this config uses, skipping anything
already installed. System packages come from Homebrew on macOS, and from apt
or pacman on Linux (the AUR on Arch, for Chez Scheme and Gforth); language
servers come from their GitHub releases.

| Tool        | Installs                                       | Default |
|-------------|------------------------------------------------|---------|
| `aspell`    | Aspell and its English dictionary              | yes     |
| `compiler`  | Git and a C compiler, for tree-sitter grammars | yes     |
| `clipboard` | xclip and wl-clipboard, for pasting (Linux)    | yes     |
| `clojure`   | Clojure CLI, Java and clojure-lsp              | no      |
| `elixir`    | Expert, the Elixir language server             | no      |
| `scheme`    | Chez Scheme                                    | no      |
| `forth`     | Gforth                                         | no      |

From inside Emacs, `M-x Minimalist/install-tools` asks which tools and
directories to use and runs the script in a terminal buffer, where `sudo` can
ask for a password. With a prefix argument (`C-u`) it only shows what it would
do.

From a shell:

```sh
./bootstrap.sh                    # aspell, compiler and clipboard
./bootstrap.sh clojure elixir     # language tools are installed only when named
./bootstrap.sh --dry-run clojure  # only print what would be done
./bootstrap.sh build              # rebuild site-lisp/ (see Managing packages)
```

`--bin-dir DIR` sets where clojure-lsp and Expert go (default `~/.local/bin`),
and `--prefix DIR` where the Clojure CLI goes on Linux (default `~/.local`).
Make sure those directories are on your `PATH`.

## Key bindings

`M-x describe-personal-keybindings` lists every binding this config adds.

**Editing**

- `C-a` — move to the first non-blank character of the line; press again to go
  to the very beginning
- `C-c ;` — comment or uncomment the current line or region
- `C-c SPC` — select the surrounding syntactic unit; keep pressing `SPC` to grow
  the selection and `-` to shrink it
- `C-c m f` — add a cursor at the next occurrence of the selection
- `C-c m b` — add a cursor at the previous occurrence of the selection
- `C-c m a` — add a cursor at every occurrence of the selection
- `C-x u` — browse the undo history as a tree
- `C-c c` — copy the region to the system clipboard
- `C-c v` — paste from the system clipboard
- `C-c l` — look up the word at point in the dictionary

**Windows**

- `C-c b` then `w` / `a` / `s` / `d` — move to the window above, left, below or
  right; keep pressing the letters to keep moving
- `C-c ^` — make the window taller
- `C-c >` — make the window wider

**Files**

- `C-x C-r` — open a recently visited file
- `C-c d` — open the file manager (Dired) at the current file
- `C-c t` — toggle a file tree of the current project in a side panel

`C-x C-b` is unbound, to avoid hitting it when meaning `C-x b`.

**Code**

- `C-c f f` — fold or unfold the block at point
- `C-c f a` — fold every block in the buffer
- `C-c r` — run a compile command
- `C-c e r` — rename the symbol at point (language server)
- `C-c e a` — show code actions for point (language server)
- `C-c e f` — format the buffer (language server)

**Clojure (CIDER)**

- `C-c M-j` — start a REPL for the project
- `C-c C-e` — evaluate the form before point
- `C-c C-k` — evaluate the whole buffer
- `C-c C-z` — switch between the code and the REPL
- `C-c C-t t` — run the test at point

## Managing packages

Packages live in `site-lisp/`, one directory per package, and are part of this
repository: free to edit, and only changed when I change them.

- **Add** a package (or a new dependency of one): copy its files into
  `site-lisp/NAME`.
- **Remove** one: delete its directory.
- **Rebuild** after adding, updating or editing packages:

  ```sh
  ~/.emacs.d/bootstrap.sh build
  ```

  This generates autoloads, byte-compiles every package and builds the Info
  manuals (`C-h i`) of the packages that have one. Building the manuals needs
  `makeinfo` and `install-info`, from the `texinfo` package; on macOS, install
  Homebrew's, since the system versions are too old.

In `init.el`, `use-package` is used for packages in `site-lisp/` and
`use-feature` for libraries built into Emacs, so it's always clear where a
package comes from.

## Layout

```
early-init.el            Settings needed before the first frame
init.el                  The whole configuration
bootstrap.sh             Installs external tools
site-lisp/               Vendored third-party packages
site-lisp/site-lisp.el   Loads and builds them
snippets/                YASnippet snippets, by major mode
personal-dictionary.pws  Words the spell checker should accept
```

## Support & Advice

The only way to get support for all my projects is by [becoming a member on Patreon](https://patreon.com/getsupport). Value for value.

## License

My configuration (`init.el`, `early-init.el`, `bootstrap.sh`,
`site-lisp/site-lisp.el` and `snippets/`) is released under the BSD license in
[LICENSE](LICENSE).

The third-party packages vendored in `site-lisp/` are **not** covered by that
license. Each keeps its own license, found in its directory (`LICENSE`,
`COPYING`) or in the headers of its source files.
