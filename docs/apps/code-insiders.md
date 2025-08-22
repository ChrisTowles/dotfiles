# VS Code Insiders Setup

Configuration for using VS Code Insiders as the default "code" command.

## Overview

Setting up VS Code Insiders so that other applications can use the `code` command to open files in the Insiders version instead of the stable release.

## macOS Setup

Make the `code` command open VS Code Insiders instead of regular VS Code:

```bash
cd /usr/local/bin
ls
sudo unlink code
sudo ln -s "/Applications/Visual Studio Code - Insiders.app/Contents/Resources/app/bin/code" code
```

## Configuration

### Auto Save Settings

Set files to auto save with `delay` for better development workflow:

1. Open VS Code Insiders
2. Go to `File > Preferences > Settings`
3. Search for "auto save"
4. Set `Files: Auto Save` to `afterDelay`
5. Adjust `Files: Auto Save Delay` as needed (default: 1000ms)

### Command Line Integration

After the symlink setup above, you can:
- Use `code .` to open current directory in VS Code Insiders
- Use `code filename.txt` to open specific files
- Other applications that rely on the `code` command will now use Insiders

## Benefits

- **Latest Features**: Access to the newest VS Code features before stable release
- **Extension Testing**: Test extensions with cutting-edge VS Code APIs
- **Feedback**: Help improve VS Code by using pre-release versions
- **Seamless Integration**: Other tools continue to work with the `code` command

## Notes

- VS Code Insiders updates daily with the latest changes
- May have occasional bugs or instability
- Settings and extensions are separate from stable VS Code
- Can run alongside stable VS Code installation