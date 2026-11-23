# dotfiles

Arch + Hyprland (Lua config) + fish + tmux + kitty + eww.

- `home/` is a [GNU Stow](https://www.gnu.org/software/stow/) package mirroring `$HOME`, linked with `--no-folding` so only files (not directories) are symlinks.
- `system/` holds root-owned files, copied into place by `mise run system`.
- [mise](https://mise.jdx.dev) installs dev tools (`home/.config/mise/config.toml`) and runs the repo tasks (`mise.toml`).

## New machine

```sh
sudo pacman -S --needed git mise stow
git clone <this repo> ~/dotfiles && cd ~/dotfiles
mise trust
mise run link:check     # preview
mise run bootstrap      # packages, system files, link, services, tools
git config --file ~/.config/git/identity user.name  "..."
git config --file ~/.config/git/identity user.email "..."
```

Files that are in the way are moved to `~/.dotfiles-backup/<timestamp>/`, never overwritten.

## Per-machine config

- **Hyprland:** `hyprland.lua` loads `hypr/hosts/<hostname>.lua`, which sets monitors, GPU env and quirks, and returns `{ main_monitor = ... }`. An unknown host gets Hyprland's defaults.
- **eww:** the topbar goes on the monitor whose description contains `$MAIN_MONITOR` (set by the host file), or the first monitor.
- **git:** name/email live in `~/.config/git/identity`, which is not committed.
- **SSH:** `~/.ssh/config` is deliberately not in this repo.

## Secrets

None are committed. When one is needed:

```sh
age-keygen -o ~/.config/mise/age.txt          # back this up in a password manager
# create .sops.yaml with the printed public key, then:
sops home/.config/mise/secrets.enc.yaml
```

and uncomment the `_.file` line in `home/.config/mise/config.toml`.
`mise run hooks:install` adds a gitleaks pre-commit hook; `mise run scan` checks the whole history.
