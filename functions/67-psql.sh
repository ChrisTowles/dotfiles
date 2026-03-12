# PostgreSQL client (psql) setup
# https://www.postgresql.org/docs/current/app-psql.html

# PATH for Homebrew libpq (keg-only formula, client tools only)
if [[ "$(uname -s)" == "Darwin" && -d "/opt/homebrew/opt/libpq/bin" ]]; then
  case ":$PATH:" in
    *":/opt/homebrew/opt/libpq/bin:"*) ;;
    *) export PATH="/opt/homebrew/opt/libpq/bin:$PATH" ;;
  esac
fi

if [[ "$DOTFILES_SETUP" -eq 1 ]]; then
  if ! command -v psql >/dev/null 2>&1; then
    echo " Installing PostgreSQL client..."
    case "$(uname -s)" in
      Darwin) brew install libpq ;;
      Linux)
        sudo apt-get update -qq
        sudo apt-get install -y -qq postgresql-client
        ;;
    esac
  fi
fi
