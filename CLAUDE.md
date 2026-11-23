# dotfiles

Arch + Hyprland + eww + fish + tmux, linked into `$HOME` with GNU Stow, tasks via mise. See README.md for the user-facing overview.

## Public repo rules

- This repo is public (primary: git.dataverket.org, mirrored to GitHub). Never commit secrets, SSH config, git identity, work email, internal hostnames/IPs, or images/wallpapers.
- Machine-local files are gitignored: `*.local.*` (e.g. `packages/aur.local.txt`), `home/.config/git/identity`.
- Commits use the repo-local noreply email already set in `.git/config`. Push only to `origin` (the forge); GitHub follows via Forgejo push mirror. Never push to GitHub directly.
- The gitleaks pre-commit hook must pass; do not bypass it.

## Layout

- `home/` mirrors `$HOME`; `mise run link` stows it with `--no-folding` (files are symlinks, directories are real). Run it after adding a file. Conflicting files are moved to `~/.dotfiles-backup/<timestamp>/`.
- `system/` is root-owned config, copied by `mise run system`.
- `packages/` lists come from `mise run packages:dump`; don't edit them by hand.
- Shell scripts in `bin/` follow the bash-style conventions (functions with comment blocks, `|| return $?`, shellcheck clean).

## Hyprland

- Config is `hypr/hyprland.lua` (Lua API, 0.57+), not `hyprland.conf`. API stubs: `/usr/share/hypr/stubs/hl.meta.lua`.
- Machine-specific settings (monitors, GPU env, quirks, `BAR_MONITORS`) go in `hypr/hosts/<hostname>.lua`, which returns `{ main_monitor = ... }`. Keep `hyprland.lua` host-neutral.
- Verify before reloading. The config loads the host file from `$HOME/.config`, so test the repo copy with a fake home:
  `mkdir -p /tmp/fh/.config && ln -sfn ~/dotfiles/home/.config/hypr /tmp/fh/.config/hypr && HOME=/tmp/fh Hyprland --verify-config -c /tmp/fh/.config/hypr/hyprland.lua`
- Apply with `hyprctl reload`. `hyprland.start` handlers do not rerun on reload.

## eww

- One `topbar` window per monitor, id `topbar-<output>`, opened by `~/.local/bin/eww-bars`. Apply changes with `eww reload && eww-bars`.
- Widgets in the bar take a `screen` parameter. Hover/reveal state variables hold the hovered screen's name (or `"none"`), never a boolean: `update x=${screen}`, `:reveal {x == screen}`. A shared boolean makes every monitor's bar react.
- Popups open with `open --toggle --screen ${screen}`; don't hardcode `:monitor`.
- Test layout on the narrow monitor (portrait, ~1728px logical): hover each module (`eww update <var>=<output>`) and check `hyprctl layers -j` that width and height stay at bar size. Screenshot with `grim -g`.

## Wallpapers

hyprpaper picks one random image from `~/Pictures/wallpapers/current/{desktop,mobile}` at startup and never rotates (`mobile` on portrait monitors). The images live outside the repo.
