# Zig setup (pinned version — required to build libghostty-vt for towles-tool)
# https://ziglang.org/download/

ZIG_VERSION="0.15.2"
ZIG_ROOT="$HOME/.local/share/zig/$ZIG_VERSION"

# Add zig to PATH (idempotent)
case ":$PATH:" in
  *":$ZIG_ROOT:"*) ;;
  *) export PATH="$ZIG_ROOT:$PATH" ;;
esac

if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  if [[ -x "$ZIG_ROOT/zig" ]]; then
    echo " Zig already installed: $("$ZIG_ROOT/zig" version)"
  else
    echo " Installing Zig $ZIG_VERSION..."
    case "$(uname -s)-$(uname -m)" in
      Darwin-arm64) zig_target="aarch64-macos" ;;
      Darwin-x86_64) zig_target="x86_64-macos" ;;
      Linux-aarch64) zig_target="aarch64-linux" ;;
      *) zig_target="x86_64-linux" ;;
    esac
    mkdir -p "$ZIG_ROOT"
    curl -fsSL "https://ziglang.org/download/$ZIG_VERSION/zig-$zig_target-$ZIG_VERSION.tar.xz" \
      | tar -xJ -C "$ZIG_ROOT" --strip-components=1
    echo " Zig installed: $("$ZIG_ROOT/zig" version)"
  fi
fi
