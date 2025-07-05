# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Structure

This is a personal dotfiles repository containing:
- **CLI tool** (`/cli/`) - A TypeScript CLI application called "towles-tool" with commands for branch management, AWS console login, and daily utilities
- **Dotfiles** (root) - Shell configuration files (`.zshrc`) and setup scripts
- **Documentation** (`/docs/`) - Setup guides for various applications and tools

## Development Commands

### CLI Tool Development (in `/cli/` directory)

```bash
# Install dependencies
pnpm i

# Development mode with debugging
pnpm dev

# Build the CLI tool
pnpm build

# Run tests
pnpm test

# Run specific test file
pnpm test branchCommand.spec.ts

# Type checking
pnpm typecheck

# Linting
pnpm lint

# Install globally for testing
pnpm install --global .
```

### CLI Tool Usage

The CLI tool is available as both `towles-cli` and `tt` commands and includes:
- `branch` - Create Git branches from GitHub issues
- `branch-cleanup` - Clean up old branches
- `aws-console-login` - AWS console login utilities
- `today` - Daily utility commands

## Architecture

### CLI Tool Structure

- **Entry point**: `src/cli.ts` - Sets up Commander.js program with all commands
- **Commands**: `src/commands/` - Individual command implementations
  - Commands use Commander.js for CLI parsing
  - Interactive prompts with `prompts` library
  - Fuzzy finding with `fzf` library
  - Colored output with `picocolors`
- **Utilities**: `src/utils/` - Wrappers for external tools
  - `gh-cli-wrapper.ts` - GitHub CLI integration
  - `git-wrapper.ts` - Git operations
- **Configuration**: Uses TypeScript with ESLint (@antfu/eslint-config)
- **Testing**: Vitest with globals enabled
- **Build**: Unbuild for compilation

### Key Dependencies

- **Commander.js** - CLI framework
- **GitHub CLI** - Required for branch command (checks installation)
- **Prompts** - Interactive CLI prompts
- **Lodash** - Utility functions
- **zx** - Shell command execution

## Development Notes

- The CLI tool requires GitHub CLI to be installed for branch management features
- Uses pnpm for package management
- Follows @antfu eslint configuration
- Debug mode available with `DEBUG=towles-cli:*` environment variable