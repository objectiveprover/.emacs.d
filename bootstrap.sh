#!/usr/bin/env bash
# Install programs this Emacs config uses.
#
# In Emacs, M-x Minimalist/install-tools asks which tools and directories
# to use and runs this script.  Directly:
#
#   ./bootstrap.sh [OPTIONS] [TOOL...] [build]
#
# With no TOOL, installs the ones every setup uses: aspell, compiler and
# clipboard.  Language tools are only installed when named.
# Anything already installed is skipped.
#
#   ./bootstrap.sh build
#
# rebuilds the packages in site-lisp/ (autoloads, byte-compilation and
# manuals), which is needed after adding, updating or editing one.  On its
# own it installs nothing; with TOOLs, it rebuilds after installing them.
#
# Tools (keep in sync with `Minimalist/tools' in init.el):
#   aspell     aspell and its English dictionary, for spell checking
#   compiler   git and a C compiler, to build tree-sitter grammars
#   clipboard  xclip and wl-clipboard, to paste from the system clipboard (Linux)
#   clojure    Clojure CLI, Java and clojure-lsp
#   elixir     expert, the Elixir language server
#   scheme     Chez Scheme
#   forth      Gforth
#
# Options:
#   --bin-dir DIR   where clojure-lsp and expert go (~/.local/bin)
#   --prefix DIR    where the Clojure CLI goes on Linux, in DIR/bin (~/.local)
#   --dry-run       only print what would be done
#
# System packages come from Homebrew on macOS, and on Linux from apt
# (Debian, Ubuntu) or pacman (Arch), with sudo; their locations are up to
# the package manager.  On Arch, Chez Scheme and Gforth are only in the
# AUR, and are installed with paru or yay if one of them is there.

set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
bin_dir="$HOME/.local/bin"
prefix="$HOME/.local"
dry_run=
build=
tools=()

usage() { sed -n '2,/^$/{s/^# \{0,1\}//;p}' "$0"; }

while (($#)); do
  case "$1" in
    --bin-dir) bin_dir="$2"; shift ;;
    --prefix) prefix="$2"; shift ;;
    --dry-run) dry_run=1 ;;
    -h | --help) usage; exit 0 ;;
    build) build=1 ;;
    aspell | compiler | clipboard | clojure | elixir | scheme | forth)
      tools+=("$1") ;;
    *) echo "Unknown argument: $1" >&2; usage >&2; exit 1 ;;
  esac
  shift
done

want() { [[ " ${tools[*]-} " == *" $1 "* ]]; }
have() { command -v "$1" >/dev/null 2>&1; }
run() { echo "+ $*"; [[ -n $dry_run ]] || "$@"; }
step() { printf '\n== %s\n' "$*"; }

# Rebuild the packages in site-lisp/, as site-lisp/site-lisp.el describes
build_packages() {
  have emacs || { echo "emacs is needed to build the packages" >&2; exit 1; }
  step "Building the packages in site-lisp/"
  run emacs --batch -l "$here/site-lisp/site-lisp.el" -f Minimalist/site-lisp-build
}

if [[ -n $build ]] && ! ((${#tools[@]})); then
  build_packages
  exit
fi
((${#tools[@]})) || tools=(aspell compiler clipboard)

have curl || { echo "curl is needed to run this script" >&2; exit 1; }

case "$(uname -s)" in
  Darwin) os=macos ;;
  Linux) os=linux ;;
  *) echo "Unsupported system: $(uname -s)" >&2; exit 1 ;;
esac
case "$(uname -m)" in
  x86_64 | amd64) arch=amd64 ;;
  arm64 | aarch64) arch=arm64 ;;
  *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac

# Download URL to a temporary file and print its path
download() {
  local file
  file="$(mktemp)"
  curl -fsSL -o "$file" "$1"
  echo "$file"
}

# --------------------------------------------------------------------------
# System packages

if [[ $os == macos ]]; then
  if want compiler && { ! have git || ! have cc; }; then
    step "Xcode Command Line Tools (git, C compiler)"
    run xcode-select --install || true
    echo "Finish the installer that opened, then run this again."
    exit 0
  fi
  have brew || { echo "Homebrew is needed: https://brew.sh" >&2; exit 1; }
  formulae=()
  want aspell && ! have aspell && formulae+=(aspell)
  want scheme && ! have chez && formulae+=(chezscheme)
  want forth && ! have gforth && formulae+=(gforth)
  # Also installs Java (openjdk) as a dependency
  want clojure && ! have clojure && formulae+=(clojure/tools/clojure)
  if ((${#formulae[@]})); then
    step "Homebrew: ${formulae[*]}"
    run brew install "${formulae[@]}"
  fi
else
  if have apt-get; then pm=apt
  elif have pacman; then pm=pacman
  else pm=
  fi
  packages=()
  aur_packages=()
  # Add a package, by its Debian name or its Arch name
  pkg() { if [[ $pm == pacman ]]; then packages+=("$2"); else packages+=("$1"); fi; }
  # Add a package that Arch only has in the AUR
  aur() { if [[ $pm == pacman ]]; then aur_packages+=("$2"); else packages+=("$1"); fi; }

  if want aspell && { ! have aspell || ! aspell dump dicts 2>/dev/null | grep -qx en_US; }; then
    packages+=(aspell aspell-en)
  fi
  if want compiler; then
    have git || packages+=(git)
    have cc || pkg build-essential base-devel
  fi
  if want clipboard; then
    have xclip || packages+=(xclip)
    have wl-paste || packages+=(wl-clipboard)
  fi
  # Arch has no headless JDK
  want clojure && ! have java && pkg default-jdk-headless jdk-openjdk
  want clojure && ! have unzip && packages+=(unzip)
  # Both are called chez on Arch, as on macOS
  want scheme && ! have chezscheme && ! have chez && aur chezscheme chez-scheme
  want forth && ! have gforth && aur gforth gforth

  if ((${#packages[@]})); then
    case "$pm" in
      apt)
        step "apt: ${packages[*]}"
        run sudo apt-get update
        run sudo apt-get install -y "${packages[@]}"
        ;;
      pacman)
        step "pacman: ${packages[*]}"
        run sudo pacman -S --needed --noconfirm "${packages[@]}"
        ;;
      *)
        echo "No apt-get or pacman; install these with your package manager: ${packages[*]}" >&2
        exit 1
        ;;
    esac
  fi

  if ((${#aur_packages[@]})); then
    if have paru; then aur_helper=paru
    elif have yay; then aur_helper=yay
    else aur_helper=
    fi
    if [[ -n $aur_helper ]]; then
      # The helpers ask for sudo themselves
      step "AUR ($aur_helper): ${aur_packages[*]}"
      run "$aur_helper" -S --needed --noconfirm "${aur_packages[@]}"
    else
      printf '\nNo paru or yay; install these from the AUR: %s\n' \
        "${aur_packages[*]}" >&2
    fi
  fi

  if want clojure && ! have clojure; then
    step "Clojure CLI into $prefix"
    if [[ -z $dry_run ]]; then
      script="$(download https://github.com/clojure/brew-install/releases/latest/download/linux-install.sh)"
      bash "$script" --prefix "$prefix"
      rm -f "$script"
    else
      echo "+ linux-install.sh --prefix $prefix"
    fi
  fi
fi

# --------------------------------------------------------------------------
# Language servers, from their GitHub releases

if want clojure && ! have clojure-lsp; then
  step "clojure-lsp into $bin_dir"
  lsp_arch=$([[ $arch == arm64 ]] && echo aarch64 || echo amd64)
  url="https://github.com/clojure-lsp/clojure-lsp/releases/latest/download/clojure-lsp-native-$os-$lsp_arch.zip"
  if [[ -z $dry_run ]]; then
    mkdir -p "$bin_dir"
    zip="$(download "$url")"
    unzip -oq "$zip" clojure-lsp -d "$bin_dir"
    rm -f "$zip"
    chmod +x "$bin_dir/clojure-lsp"
  else
    echo "+ $url"
  fi
fi

if want elixir && ! have expert; then
  step "expert into $bin_dir"
  expert_os=$([[ $os == macos ]] && echo darwin || echo linux)
  url="https://github.com/elixir-lang/expert/releases/latest/download/expert_${expert_os}_$arch"
  run mkdir -p "$bin_dir"
  run curl -fsSL -o "$bin_dir/expert" "$url"
  run chmod +x "$bin_dir/expert"
fi

path_dirs=()
{ want clojure || want elixir; } && path_dirs+=("$bin_dir")
[[ $os == linux && $prefix/bin != "$bin_dir" ]] && want clojure && path_dirs+=("$prefix/bin")
# The ${a[@]+...} form because macOS's bash 3.2 rejects empty arrays with set -u
for dir in ${path_dirs[@]+"${path_dirs[@]}"}; do
  if [[ ":$PATH:" != *":$dir:"* ]]; then
    printf '\nAdd %s to PATH in your shell profile.\n' "$dir"
  fi
done

[[ -z $build ]] || build_packages

printf '\nDone.\n'
