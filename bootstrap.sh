#!/usr/bin/env bash
# Install programs this Emacs config uses.
#
# In Emacs, M-x Minimalist/install-tools asks which tools and directories
# to use and runs this script.  Directly:
#
#   ./bootstrap.sh [OPTIONS] [TOOL...]
#
# With no TOOL, installs the ones every setup uses: aspell, compiler and
# clipboard.  Language tools are only installed when named.
# Anything already installed is skipped.
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
# System packages come from Homebrew on macOS and apt (with sudo) on Linux;
# their locations are up to the package manager.

set -euo pipefail

bin_dir="$HOME/.local/bin"
prefix="$HOME/.local"
dry_run=
tools=()

usage() { sed -n '2,/^$/{s/^# \{0,1\}//;p}' "$0"; }

while (($#)); do
  case "$1" in
    --bin-dir) bin_dir="$2"; shift ;;
    --prefix) prefix="$2"; shift ;;
    --dry-run) dry_run=1 ;;
    -h | --help) usage; exit 0 ;;
    aspell | compiler | clipboard | clojure | elixir | scheme | forth)
      tools+=("$1") ;;
    *) echo "Unknown argument: $1" >&2; usage >&2; exit 1 ;;
  esac
  shift
done
((${#tools[@]})) || tools=(aspell compiler clipboard)

want() { [[ " ${tools[*]} " == *" $1 "* ]]; }
have() { command -v "$1" >/dev/null 2>&1; }
run() { echo "+ $*"; [[ -n $dry_run ]] || "$@"; }
step() { printf '\n== %s\n' "$*"; }

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
  packages=()
  if want aspell && { ! have aspell || ! aspell dump dicts 2>/dev/null | grep -qx en_US; }; then
    packages+=(aspell aspell-en)
  fi
  if want compiler; then
    have git || packages+=(git)
    have cc || packages+=(build-essential)
  fi
  if want clipboard; then
    have xclip || packages+=(xclip)
    have wl-paste || packages+=(wl-clipboard)
  fi
  want clojure && ! have java && packages+=(default-jdk-headless)
  want clojure && ! have unzip && packages+=(unzip)
  want scheme && ! have chezscheme && ! have chez && packages+=(chezscheme)
  want forth && ! have gforth && packages+=(gforth)
  if ((${#packages[@]})); then
    have apt-get || {
      echo "No apt-get; install these with your package manager: ${packages[*]}" >&2
      exit 1
    }
    step "apt: ${packages[*]}"
    run sudo apt-get update
    run sudo apt-get install -y "${packages[@]}"
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

printf '\nDone.\n'
