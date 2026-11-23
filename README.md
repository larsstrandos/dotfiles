# dotfiles

Primary: https://git.dataverket.org/lstrandos/dotfiles. Mirrored read-only to https://github.com/larsstrandos/dotfiles; changes go to the primary.

Arch + Hyprland (Lua config) + fish + tmux + kitty + eww.

- `home/` is a [GNU Stow](https://www.gnu.org/software/stow/) package mirroring `$HOME`, linked with `--no-folding` so only files (not directories) are symlinks.
- `system/` holds root-owned files, copied into place by `mise run system`.
- [mise](https://mise.jdx.dev) installs dev tools (`home/.config/mise/config.toml`) and runs the repo tasks (`mise.toml`).

## New machine

```sh
sudo pacman -S --needed git mise stow
git clone https://git.dataverket.org/lstrandos/dotfiles.git ~/dotfiles && cd ~/dotfiles
mise trust
mise run link:check     # preview
mise run bootstrap      # packages, system files, link, services, tools
git config --file ~/.config/git/identity user.name  "..."
git config --file ~/.config/git/identity user.email "..."
```

Files that are in the way are moved to `~/.dotfiles-backup/<timestamp>/`, never overwritten.

## Per-machine config

- **Hyprland:** `hyprland.lua` loads `hypr/hosts/<hostname>.lua`, which sets monitors, GPU env and quirks, and returns `{ main_monitor = ... }`. An unknown host gets Hyprland's defaults.
- **eww:** `~/.local/bin/eww-bars` opens one topbar per monitor (window id `topbar-<output>`), limited to the monitors listed in `$BAR_MONITORS` when the host file sets it. Hyprland re-runs it on monitor hotplug. Popups open on the screen whose bar was clicked.
- **git:** name/email live in `~/.config/git/identity`, which is not committed.
- **SSH:** `~/.ssh/config` is deliberately not in this repo.

## Wallpapers

hyprpaper rotates every 10 minutes through `~/Pictures/wallpapers/current/desktop`, and `current/mobile` on the portrait monitor. `current` is a symlink to the active set, so switching themes is `ln -sfn <set> ~/Pictures/wallpapers/current` and a hyprpaper restart. The images are not in this repo: they are someone else's artwork, and the repo is public.

## Secrets

None are committed. When one is needed:

```sh
age-keygen -o ~/.config/mise/age.txt          # back this up in a password manager
# create .sops.yaml with the printed public key, then:
sops home/.config/mise/secrets.enc.yaml
```

and uncomment the `_.file` line in `home/.config/mise/config.toml`.
`mise run hooks:install` adds a gitleaks pre-commit hook; `mise run scan` checks the whole history.
