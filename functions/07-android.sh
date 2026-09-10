# Android SDK
# https://developer.android.com/tools
#
# Needed to build the Capacitor shell in ~/code/p/playpass. The JDK comes from mise
# (functions/06-mise.sh); this file only handles the SDK itself.

export ANDROID_HOME="$HOME/Android/Sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"

# Add the SDK tools to PATH (idempotent), only when actually installed
if [[ -d "$ANDROID_HOME" ]]; then
  for _android_dir in \
    "$ANDROID_HOME/cmdline-tools/latest/bin" \
    "$ANDROID_HOME/platform-tools"
  do
    [[ -d "$_android_dir" ]] || continue
    case ":$PATH:" in
      *":$_android_dir:"*) ;;
      *) export PATH="$_android_dir:$PATH" ;;
    esac
  done
  unset _android_dir
fi

# Gradle needs JAVA_HOME explicitly; mise knows where the JDK lives.
if [[ -z "$JAVA_HOME" ]] && command -v mise >/dev/null 2>&1; then
  _java_home="$(mise where java 2>/dev/null)"
  [[ -n "$_java_home" ]] && export JAVA_HOME="$_java_home"
  unset _java_home
fi

# Install the SDK in setup mode
if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  # cmdline-tools is the bootstrap: sdkmanager installs everything else.
  if [[ -x "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" ]]; then
    echo " Android cmdline-tools already installed"
  else
    echo " Installing Android command-line tools..."
    _cmdtools_url="https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip"
    mkdir -p "$ANDROID_HOME/cmdline-tools"
    _tmp="$(mktemp -d)"
    if curl -fsSL -o "$_tmp/cmdtools.zip" "$_cmdtools_url" && unzip -q "$_tmp/cmdtools.zip" -d "$_tmp"; then
      rm -rf "$ANDROID_HOME/cmdline-tools/latest"
      mv "$_tmp/cmdline-tools" "$ANDROID_HOME/cmdline-tools/latest"
      export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
    else
      echo " Failed to download Android command-line tools"
    fi
    rm -rf "$_tmp"
    unset _cmdtools_url _tmp
  fi

  if command -v sdkmanager >/dev/null 2>&1; then
    echo " Accepting Android SDK licences..."
    yes | sdkmanager --licenses >/dev/null 2>&1
    echo " Installing Android platform + build tools..."
    sdkmanager --install "platform-tools" "platforms;android-36" "build-tools;36.0.0" >/dev/null
  fi
fi
