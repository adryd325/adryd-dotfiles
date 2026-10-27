#!/usr/bin/env bash
# Environment variables
# Use this for environment setup

for editor in nvim vim vi nano; do
    if [[ -x "$(command -v "${editor}")" ]]; then
        export EDITOR="${editor}"
        export VISUAL="${editor}"
        break
    fi
done

## Homebrew on macOS
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

## nix multi-user on linux
if [[ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]]; then
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi

## pnpm
if [[ -e "${HOME}/.local/share/pnpm" ]]; then
  export PNPM_HOME="${HOME}/.local/share/pnpm"
  export PATH="${PNPM_HOME}:${PATH}"
fi

## cargo
if [[ -e "${HOME}/.cargo/bin" ]]; then
  export PATH="${HOME}/.cargo/bin:${PATH}"
fi