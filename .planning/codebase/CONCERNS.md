# Codebase Concerns

**Analysis Date:** 2026-05-26

## Tech Debt

**Auto-upgrade disabled on `kirby` (NixOS):**
- Issue: `system.autoUpgrade` is fully commented out instead of being toggled via a flag. Comment "Twice weekly updates (Monday and Thursday)" remains while the body is dead code, and the commit message ("disable autoupgrade for now") gives no reason or expiry.
- Files: `nix/hosts/nixos/kirby/default.nix:62-75`
- Impact: `kirby` no longer pulls flake input updates automatically; security patches now require manual `make nixos`. `AGENTS.md` still documents the feature as active (see "Auto-Upgrade" section), so onboarding docs are misleading.
- Fix approach: Either delete the dead block and the AGENTS.md section, or wrap it in `lib.mkIf` with a host-level option (e.g., `myCfg.autoUpgrade.enable`) and a TODO with a tracking issue link explaining why it was disabled.

**Hyprland pinned to 0.53.3 via overlay:**
- Issue: Entire flake input `nixpkgsHyprland` exists solely to pin Hyprland to a single commit (`dd9b079222d43e1943b6ebd802f04fd959dc8e61`) because hy3 0.53.0.1 is incompatible with 0.54.x.
- Files: `nix/flake.nix:42-44`, `nix/hosts/nixos/kirby/default.nix:13-23`
- Impact: `kirby` is stuck on an old Hyprland revision; security/perf fixes from upstream are blocked until hy3 catches up. Overlay also forces `hyprlandPlugins` to be pulled from the pinned set, so any new plugin must coexist with stale upstream APIs.
- Fix approach: Track hy3 issue tracker, drop the overlay + `nixpkgsHyprland` input as soon as hy3 supports 0.54.x. Document the unblock criteria in the comment.

**`mac-app-util` does not follow `nixpkgs`:**
- Issue: Input deliberately uses its own nixpkgs to avoid the SBCL 2.6.0 build failure.
- Files: `nix/flake.nix:20-23`
- Impact: Duplicate `nixpkgs` evaluations during `nix flake update`, larger closure, slower CI/rebuilds, and the workaround silently lingers until [hraban/mac-app-util#42](https://github.com/hraban/mac-app-util/issues/42) is fixed.
- Fix approach: Re-add `inputs.nixpkgs.follows = "nixpkgs-darwin"` once SBCL is fixed upstream; add a comment with the GH issue link to make the unblock obvious.

**Darwin `pre-commit` overlay from stable:**
- Issue: Darwin pulls `pre-commit` from `pkgs-stable` to avoid a `dotnet` dependency in unstable.
- Files: `nix/modules/darwin/default.nix:13-19`
- Impact: Two channels carry pre-commit; if stable updates lag, hooks may diverge between Darwin and NixOS hosts.
- Fix approach: Track [NixOS/nixpkgs#450554](https://github.com/NixOS/nixpkgs/issues/450554) and drop the overlay once upstream stops pulling `dotnet`.

**`allowBroken = true` in two places:**
- Issue: `nixpkgs.config.allowBroken = true` is set both in shared core (`nix/modules/common/nix-core.nix:31`) and again in Darwin (`nix/modules/darwin/default.nix:11`). Combined with `allowUnfree`, this silently lets `nix build` consume packages upstream has marked broken.
- Files: `nix/modules/common/nix-core.nix:29-32`, `nix/modules/darwin/default.nix:8-11`
- Impact: Builds may succeed locally that would fail for anyone with a stricter config; broken-package warnings are hidden. The Darwin duplicate is dead config.
- Fix approach: Remove the duplicate in `modules/darwin/default.nix`. Audit which package actually needs `allowBroken`; prefer `permittedInsecurePackages` / `allowBrokenPredicate` to narrow scope.

**Empty `lib/` and `scripts/` directories under `nix/`:**
- Issue: `nix/lib/` and `nix/scripts/` are committed-empty directories. `CLAUDE.md` advertises `lib/` as "Helper functions" but it has been empty since at least 2025-08-06.
- Files: `nix/lib/`, `nix/scripts/`
- Impact: Misleading project structure; documentation in `CLAUDE.md` overstates the architecture.
- Fix approach: Either remove the directories or move the `mk*` helpers from `nix/flake.nix:49-149` into `nix/lib/` as a real module.

**Stale refactoring docs:**
- Issue: `nix/docs/REFACTORING_SUMMARY.md` and `nix/docs/STRUCTURE_ANALYSIS.md` describe one-off refactor sessions from 2025-01 and have not been updated since.
- Files: `nix/docs/REFACTORING_SUMMARY.md`, `nix/docs/STRUCTURE_ANALYSIS.md`
- Impact: Future agents may treat them as current architectural intent; they conflict with the post-refactor reality (e.g., references to phases that have shipped).
- Fix approach: Move to `archive/` or delete; current truth lives in `AGENTS.md`.

**Orphaned WSL/Ubuntu configs:**
- Issue: `nix/hosts/nixos/wsl/default.nix`, `nix/home/nixos/wsl/default.nix`, and `nix/home/ubuntu/default.nix` reference a complete WSL workflow (including a discord-IPC `socat` shim and `npiperelay.exe`), but no flake output uses them. `AGENTS.md` already flags them as orphaned.
- Files: `nix/hosts/nixos/wsl/default.nix:1-61`, `nix/home/nixos/wsl/default.nix:1-39`, `nix/home/ubuntu/default.nix:1-46`
- Impact: Dead code that nobody currently builds (so nobody notices when it breaks). `CLAUDE.md` still lists Ubuntu (WSL) as supported.
- Fix approach: Either re-wire `wslConfigurations.wsl` / `homeConfigurations.sirwayne` outputs in `nix/flake.nix` and add `make wsl` / `make ubuntu` targets to match `CLAUDE.md`, or move both trees to `archive/` and delete the doc references.

**`CLAUDE.md` build commands diverge from actual `Makefile`:**
- Issue: `CLAUDE.md` documents `make wsl`, `make ubuntu`, and rebuild commands that no longer exist; the current `Makefile` only ships `darwin`, `nixos`, `clean`, `update`, `lint`, `format`.
- Files: `CLAUDE.md:23-46`, `nix/Makefile:1-29`
- Impact: New contributors run commands that fail. AGENTS.md is correct, CLAUDE.md is not; the two top-level guides contradict each other.
- Fix approach: Regenerate `CLAUDE.md` from `AGENTS.md` or delete `CLAUDE.md` and symlink it.

**Inconsistent `stateVersion` across hosts:**
- Issue: `kirby` is on `25.05`, the orphaned WSL config is on `24.05`, Home Manager is pinned to `24.11`, and Darwin uses the integer `5`. The 24.05 WSL value is from a NixOS release that is over a year old.
- Files: `nix/home/default.nix:36`, `nix/hosts/nixos/kirby/default.nix:95`, `nix/hosts/nixos/wsl/default.nix:60`, `nix/modules/darwin/system.nix:12`
- Impact: Mixing very-old WSL stateVersion with current nixpkgs is supported but eventually surfaces migration footguns. Inconsistency is fine on its own; staleness on WSL is the concern.
- Fix approach: When the WSL config is either revived or archived, snap its `stateVersion` to match the install or remove the file entirely.

**`xxd` listed without comment alongside categorised packages:**
- Issue: In `nix/home/packages.nix:31-33`, three trailing entries (`xxd`, `cachix`, `tmux`) sit under "General Utilities" without inline comments, and `act` was appended (line 82) under "DevOps & Cloud Tools" — a category mismatch (`act` runs GitHub Actions, not a cloud SDK).
- Files: `nix/home/packages.nix:31-33`, `nix/home/packages.nix:82`
- Impact: Categories drift; future contributors will keep appending at the end and the headers stop reflecting reality.
- Fix approach: Move `act` into a "Development Tools" section, add one-line `#`-comments to the trailing utilities, and enforce category placement via review.

**Backup `.bak` files committed locally:**
- Issue: Two `.bak` files sit in `opencode/` (`opencode.json.bak`, `tui.json.bak`) — untracked but present in the working tree. The `tui.json` and `tui.json.bak` files are byte-identical, so the `.bak` is purely a leftover.
- Files: `opencode/opencode.json.bak`, `opencode/tui.json.bak`
- Impact: Future runs may accidentally `git add .` them. The presence of a `.bak` next to live config is a footgun (which is canonical?).
- Fix approach: Delete the `.bak` files or move them under a single `opencode/backups/` directory listed in `opencode/.gitignore`.

**`tui.json` references plugin under unrelated namespace:**
- Issue: `opencode/tui.json` references `"oh-my-openagent/tui"` (note: `openagent`, not `opencode`), but the deleted file in `git status` is `opencode/oh-my-openagent.json` — i.e., the plugin source was removed but the consumer was not updated.
- Files: `opencode/tui.json:4-6`, deleted `opencode/oh-my-openagent.json`
- Impact: TUI plugin load will fail at runtime; the typo (`openagent` vs `opencode`) suggests a mid-rename that was abandoned.
- Fix approach: Decide whether the plugin is `oh-my-opencode-slim` (already loaded on line 5) or a separate package; remove the dead `oh-my-openagent/tui` reference if it is no longer published.

**Hardcoded user paths in shell config:**
- Issue: `programs.zsh.initContent` exports `$HOME/go` and prepends `/usr/local/go/bin` unconditionally even though Go is installed via Nix in `home.packages` (`go`, line 41). The PATH entry assumes a non-Nix Go install.
- Files: `nix/home/zsh.nix:29-41`
- Impact: Stale PATH entry; on hosts without `/usr/local/go/bin` it is harmless, but it can shadow the Nix-managed Go binary if a user manually installs Go from the upstream tarball.
- Fix approach: Drop `/usr/local/go/bin` from PATH (the Nix profile already exposes Go); keep `$GOPATH` if Go modules expect it.

**Stale comment about UV in `zsh.nix`:**
- Issue: Comment says "The command for UV can be removed when oh-my-zsh nixpkg is updated" but there is no corresponding command in the file — it appears to be a leftover after the workaround was already removed.
- Files: `nix/home/zsh.nix:28`
- Impact: Confusing reader expectations; suggests a missing workaround.
- Fix approach: Delete the stale comment.

## Known Bugs

**Mixed tab/space indentation in `app_icons.lua`:**
- Symptoms: Several lines use 2-space indentation while the file's convention is tab indentation; the diff against HEAD already shows the inconsistency on the `Android Studio`, `OmniFocus`, and `Twitter` lines.
- Files: `sketchybar/helpers/app_icons.lua:14`, `:201`, `:290`
- Trigger: Manual edits that did not respect the file's existing whitespace.
- Workaround: Run a formatter (none configured) or fix by hand. Project has no `stylua` config for `sketchybar/`.

**Sketchybar helpers rebuild C binaries from a Lua `os.execute` on every load:**
- Symptoms: `os.execute("(cd helpers && make)")` runs on every sketchybar config reload.
- Files: `sketchybar/helpers/init.lua:4`
- Trigger: Any reload (e.g., `sketchybar --reload`).
- Workaround: Once compiled, `make` no-ops fast, but a missing C toolchain or removed `event_providers/cpu_load` source silently breaks the bar with no log. The Makefile redirects all output to `/dev/null`.
- Fix approach: Move the build into `helpers/install.sh` (already exists) or a Nix derivation, and stop hiding stderr.

**Sketchybar `install.sh` is destructive and not invoked:**
- Issue: `sketchybar/helpers/install.sh` is a bare `bash` script that runs `brew install`, downloads a font via `curl` into `$HOME/Library/Fonts/`, and clones SbarLua into `/tmp/SbarLua` then removes it. It lacks `#!/usr/bin/env bash`, `set -euo pipefail`, or any idempotency checks.
- Files: `sketchybar/helpers/install.sh`
- Trigger: Manual execution. Not wired into any nix install path.
- Workaround: Most of what it installs is now handled by `nix/hosts/darwin/Sterling-MBP/homebrew.nix` (sketchybar, fonts), so the script is partly redundant and partly stale.
- Fix approach: Convert the SbarLua + font-download steps to a nix derivation or `home.activation` script; delete the rest.

**`grishka/grishka` Homebrew tap with no documented brews:**
- Issue: Tap is declared but no formula from it is installed via this config; it may be a vestige.
- Files: `nix/hosts/darwin/Sterling-MBP/homebrew.nix:13-19`
- Trigger: Every `darwin-rebuild` refreshes the tap.
- Workaround: None.
- Fix approach: Either remove the tap or add a code comment naming which app it provides (likely `vk-messenger` or similar — verify before removing).

**`programs.git.signing.format = null` disables signing globally:**
- Issue: Signing is explicitly nulled, so commits are unsigned regardless of any `.gitconfig` overrides.
- Files: `nix/home/git.nix:15`
- Trigger: Any `git commit`.
- Workaround: None; per-repo overrides via `git -c commit.gpgsign=true` are required.
- Fix approach: If commit signing is desired, configure `signing.format = "ssh"` with a Touch-ID-stored key (the existing `security.pam.services.sudo_local.touchIdAuth` shows TouchID is wired up).

## Security Considerations

**`networking.dns = "none"` plus self-hosted `dnscrypt-proxy`:**
- Risk: Single point of failure for the entire host's DNS; if `dnscrypt-proxy2` crashes or fails to start, NetworkManager will not fall back. AdGuard DNS-over-HTTPS via IPv6 is the only resolver, with no v4 fallback.
- Files: `nix/hosts/nixos/kirby/networking.nix`
- Current mitigation: `require_dnssec = true` is set.
- Recommendations: Add an IPv4 fallback server in `server_names`, monitor `systemctl status dnscrypt-proxy` via a `services.healthcheck`-style probe, and document recovery (e.g., `resolvectl dns wlan0 9.9.9.9`).

**Hardware UUIDs hardcoded in committed `hardware-configuration.nix`:**
- Risk: Not a leak — these are filesystem UUIDs, not secrets — but disk swaps or reinstalls require regenerating the file. The leading comment says "Do not modify this file" yet it is checked in alongside non-generated `hardware.nix` (which is fine but blurs the line).
- Files: `nix/hosts/nixos/kirby/hardware-configuration.nix`
- Current mitigation: Comment block warns against manual edits.
- Recommendations: Add a make target (`make regen-hw`) wrapping `nixos-generate-config --show-hardware-config > hardware-configuration.nix` so the regeneration path is discoverable.

**Howdy facial-auth uses `control = "sufficient"`:**
- Risk: With `sufficient`, a successful Howdy match alone unlocks sudo without requiring a password. This is by design but is a meaningful posture decision.
- Files: `nix/hosts/nixos/kirby/howdy.nix:10`
- Current mitigation: `dark_threshold = 85` rejects low-light frames.
- Recommendations: Document the security trade-off in the file. Consider `control = "required"` if the threat model includes shoulder-surfing or photo-spoofing.

**`uni-sync` device IDs hardcoded by serial number:**
- Risk: Not a security issue, but the serial `SN:6243168001` is hardware-specific and will silently no-op on another machine.
- Files: `nix/hosts/nixos/kirby/openrgb.nix:14-15`
- Current mitigation: Config is gated to the `kirby` host.
- Recommendations: Add a comment naming the physical device (LianLi SL Fans?) so future hw swaps are traceable.

**Determinate Nix manages the daemon on Darwin (`nix.enable = false`):**
- Risk: `nix-darwin`'s nix daemon module is disabled — any nix settings expected to flow through `nix-darwin` are ignored on macOS.
- Files: `nix/flake.nix:140`
- Current mitigation: Determinate handles upgrades.
- Recommendations: When adding new `nix.settings.*` options, verify they propagate to Determinate's config (it reads `/etc/nix/nix.custom.conf`) rather than `nix-darwin`'s generated file.

**Many MCP servers run remote/network commands without authentication review:**
- Risk: `opencode/opencode.json` and `nix/home/ai/mcp.nix` both register remote MCP servers (`astro`, `pulumi`) and local commands that fetch network resources (`uvx mcp-nixos`, `npx -y kubernetes-mcp-server@latest`). Each invocation pulls latest from registries.
- Files: `opencode/opencode.json:11-39`, `nix/home/ai/mcp.nix:1-26`
- Current mitigation: None — `npx -y` and `uvx` always pull the latest version on first run.
- Recommendations: Pin versions (`kubernetes-mcp-server@<semver>`), vendor MCP servers as nix derivations where possible, and remove duplicate declarations between `opencode.json` and `mcp.nix` (they currently drift independently).

## Performance Bottlenecks

**Double nixpkgs evaluation due to non-`follows` inputs:**
- Problem: `mac-app-util` and `nixpkgsHyprland` both ship independent nixpkgs trees rather than `follows = "nixpkgs-darwin"` / `follows = "nixpkgs"`. Determinate, lanzaboote, etc. all use their own pinned trees.
- Files: `nix/flake.nix:13-46`, `nix/flake.lock`
- Cause: Pinning workarounds noted above.
- Improvement path: Consolidate as workarounds expire; track `flake.lock` size (currently ~26KB) as a proxy for input bloat.

**`auto-optimise-store = true` increases rebuild time:**
- Problem: Comment on `nix/modules/nixos/default.nix:15` openly acknowledges "May make rebuilds longer but less size". Repeated on the orphaned WSL config (`nix/hosts/nixos/wsl/default.nix:47`).
- Files: `nix/modules/nixos/default.nix:14-21`
- Cause: Trade-off chosen intentionally.
- Improvement path: If long rebuilds bite, switch to `nix.optimise.automatic = true` only and drop `auto-optimise-store`; let optimization happen as a background job.

**Neovim plugin extras pull two Python versions:**
- Problem: `extraPackages` references both `python314Packages.flake8` and `python314Packages.debugpy`, plus `programs.neovim.withPython3 = true` (which is Python 3.11/3.12 in nixpkgs). This means two Python interpreters end up in the closure.
- Files: `nix/home/neovim.nix:50,56,64`
- Cause: Bleeding-edge `python314Packages` is picked explicitly while `withPython3` picks the default.
- Improvement path: Drop `python314Packages.*` (use `python3Packages.*`) so a single interpreter is shared; or set `withPython3 = false` and provide deps via `extraPackages`.

**`withRuby = true` for neovim despite no Ruby plugins listed:**
- Problem: Pulls the entire Ruby derivation into the Neovim wrapper even though no Ruby-based plugin is configured.
- Files: `nix/home/neovim.nix:65`
- Cause: Default-on flag never revisited.
- Improvement path: Set `withRuby = false` unless a plugin explicitly needs it. Closure size win on every host.

**Sketchybar workspaces.lua does N+1 `aerospace exec` calls per event:**
- Problem: `updateWindow` runs once per workspace, and `withWindows` chains three `sbar.exec` calls (windows → focus → visible workspaces) inside callbacks; on every `aerospace_focus_change` or `display_change`, this fans out across all workspaces.
- Files: `sketchybar/items/workspaces.lua:35-147`
- Cause: Async callback nesting rather than a single batched query.
- Improvement path: Cache `aerospace list-workspaces --all` output between events; debounce `display_change`.

## Fragile Areas

**`sketchybar/helpers/init.lua` writes its `package.cpath` from `$USER`:**
- Files: `sketchybar/helpers/init.lua:2`
- Why fragile: Reads `os.getenv("USER")` and concatenates into `/Users/$USER/.local/share/sketchybar_lua/?.so`. If `USER` is unset (e.g., launchd context) or if the user is not under `/Users` (would also break on Linux, though this is darwin-only), the SbarLua module fails to load.
- Safe modification: Replace with `os.getenv("HOME")` or pass the path explicitly during build.
- Test coverage: None.

**Brew alias in `zsh.nix` triggers sketchybar events:**
- Files: `nix/home/zsh.nix:34-40`
- Why fragile: `brew` is wrapped in a function that triggers `sketchybar --trigger brew_update` after any invocation containing `upgrade`/`update`/`outdated`. Pattern match uses unanchored `=~`, so unrelated subcommand args containing the substring (`brew tap outdated-stuff`) will trigger the event. Also fires on NixOS, where `sketchybar` does not exist.
- Safe modification: Gate the wrapper behind `if [[ $OSTYPE == darwin* ]]` and use word-boundary matching.
- Test coverage: None.

**`opencode/opencode.json` and `nix/home/ai/mcp.nix` are parallel sources of truth:**
- Files: `opencode/opencode.json:11-39`, `nix/home/ai/mcp.nix:1-26`
- Why fragile: Both files register the same four MCP servers (`nixos`, `astro`, `kubernetes`, `pulumi`) with slightly different shapes (the nix module omits `enabled: true` flags). Adding/removing a server requires editing both.
- Safe modification: Generate one from the other (e.g., write `opencode.json` from `home.activation`) or remove the duplicate.
- Test coverage: None.

**`opencode/` is a nested toolchain with its own `node_modules`/`bun.lock`:**
- Files: `opencode/node_modules/`, `opencode/bun.lock`, `opencode/package-lock.json`, `opencode/package.json`
- Why fragile: Both `bun.lock` and `package-lock.json` exist (mixed package manager state). `opencode/.gitignore` ignores `node_modules` and `bun.lock` but `package-lock.json` is committed. Future installs may diverge depending on which tool the user invokes.
- Safe modification: Pick one package manager; delete the other lockfile and document the choice.
- Test coverage: None.

**Many `opencode/` directories untracked but actively used:**
- Files: `opencode/agents/` (33 .md files), `opencode/command/` (67 .md files), `opencode/hooks/` (10+ files), `opencode/skills/`, `opencode/get-shit-done/`, `opencode/gsd-file-manifest.json`, `opencode/gsd-install-state.json`
- Why fragile: Git status shows these as untracked. There is no `.gitignore` rule excluding them in the repo root (only `opencode/.gitignore` ignores `node_modules`, `package.json`, `bun.lock`, `.gitignore`). Either they are intentional opt-outs that should be in `.gitignore`, or they are unstaged work that will be lost on a clean clone.
- Safe modification: Decide: (a) commit everything under `opencode/agents,command,hooks,skills,get-shit-done` and the gsd state JSON, or (b) add explicit `.gitignore` entries with a comment explaining they are user-local/cache.
- Test coverage: None.

**`.omo/` and `.sisyphus/` directories at repo root:**
- Files: `.omo/run-continuation`, `.sisyphus/run-continuation`
- Why fragile: Tool-generated state files at the repo root, untracked, with no `.gitignore` rules. They will appear in every `git status` run forever.
- Safe modification: Add to a root `.gitignore` if they are local-only state, or to the corresponding tool's config so they are written elsewhere.

**`nix/home/default.nix` open-codes home-directory branching:**
- Files: `nix/home/default.nix:3-11`
- Why fragile: Uses a string-compare against `"aarch64-darwin"` / `"x86_64-darwin"` to pick `/Users` vs `/home`. Misses any darwin variant not explicitly listed (e.g., a hypothetical `arm64-darwin` mislabel).
- Safe modification: Use `pkgs.stdenv.hostPlatform.isDarwin` instead, or import from `lib.systems`.

**`flake.nix` `mkSystem` does not pass `extraArgs` to `extraSpecialArgs`:**
- Files: `nix/flake.nix:80-122`
- Why fragile: `mkHomeManagerConfig` calls `mkSpecialArgs { inherit hostname system extraArgs; }` correctly, but `mkSystem` separately calls `mkSpecialArgs { inherit hostname system extraArgs; }`. Both work today because `kirby` is the only consumer, but the duplication means a future user could pass `extraArgs` to a `mkDarwin` call and silently lose it if either path is edited incorrectly.
- Safe modification: Hoist `mkSpecialArgs` so both paths reuse the same call site; add an assertion that all `extraArgs` keys are non-conflicting with `inputs`.

## Scaling Limits

**Two active hosts only:**
- Current capacity: `Sterling-MBP` (darwin) and `kirby` (nixos).
- Limit: Adding a third host means duplicating `mkSystem`/`mkDarwin` blocks in `flake.nix`. There is no host registry or auto-discovery.
- Scaling path: Build a `hosts/` directory walker (e.g., `builtins.readDir ./hosts/nixos`) and generate `nixosConfigurations` programmatically. The empty `nix/lib/` directory is the natural home for this.

**Homebrew `cleanup = "zap"` mode:**
- Current capacity: Any cask/brew not listed in `homebrew.nix` is removed on every `darwin-rebuild`.
- Limit: A manually installed brew package (e.g., a debugging tool) will be wiped without warning on the next rebuild.
- Scaling path: Either document the policy prominently in the host README or relax to `cleanup = "uninstall"`; communicate via banner in zshrc.

## Dependencies at Risk

**`numtide/llm-agents` flake input:**
- Risk: Single-vendor flake providing both `opencode` and `claude-code` packages. If numtide deprecates the project, both Home Manager modules (`nix/home/ai/claude-code.nix`, `nix/home/packages.nix:85`) break simultaneously.
- Impact: Loss of `claude-code` and `opencode` from the home profile.
- Migration plan: Track upstream `opencode` releases for a direct `nix run` path; mirror `claude-code` to a personal flake.

**`hraban/mac-app-util`:**
- Risk: Pinned independently due to upstream SBCL issue (see Tech Debt). The repo is a single-maintainer project — bus factor of 1.
- Impact: Without it, macOS Spotlight integration for nix-installed apps regresses.
- Migration plan: Watch for `nix-darwin` adopting trampolining natively; fall back to symlink-only behavior if needed.

**`numtide/blueprint` and `bun2nix` (transitive via llm-agents):**
- Risk: Recent flake inputs (`lastModified` 2026-01..2026-02) pulled into the closure transitively. Any breaking change in blueprint cascades to llm-agents and then to the home profile.
- Impact: `nix flake update` failures.
- Migration plan: Same as llm-agents.

**`nikitabobko/tap` and `FelixKratz/formulae` Homebrew taps:**
- Risk: External taps (aerospace, sketchybar/borders) bypass the nix supply chain.
- Impact: If a tap rotates ownership, casks may install unexpected binaries.
- Migration plan: Replace `sketchybar` and `borders` with nixpkgs versions when stable enough (sketchybar is in nixpkgs; aerospace and borders are not yet).

## Missing Critical Features

**No commit signing despite TouchID being available:**
- Problem: `programs.git.signing.format = null` (`nix/home/git.nix:15`) while `security.pam.services.sudo_local.touchIdAuth = true` (`nix/modules/darwin/security.nix:3`) shows the hardware supports it.
- Blocks: Verifiable commits, signed-tag releases.

**No CI / dry-run gating before `darwin-rebuild switch`:**
- Problem: Pre-commit runs `statix` and `treefmt`, but there is no `darwin-rebuild dry-activate` / `nixos-rebuild dry-build` step in either `pre-commit` or a CI workflow.
- Blocks: Catching evaluation errors before they hit the live system; reproducibility across machines.

**No declarative dotfile stow:**
- Problem: `.stowrc` targets `~/.config` but the actual `stow` invocation is manual. Nothing in `nix/` activates it; `sketchybar`, `aerospace`, `nvim` directories must be stowed by hand.
- Blocks: A fresh machine needs manual `cd ~/dotfiles && stow nvim sketchybar aerospace` after every rebuild. Should be automated via `home.activation` or `xdg.configFile`.

**No secrets management:**
- Problem: Nothing in `nix/home/` or `nix/modules/` references `sops-nix`, `agenix`, or any secret store. SSH keys, GitHub tokens, etc. are assumed to be present out-of-band.
- Blocks: Reproducible bootstrap on a fresh device; multi-host secret sync.

## Test Coverage Gaps

**No tests anywhere in `nix/`:**
- What's not tested: Module evaluation, helper functions in `flake.nix` (`mkSystem`, `mkDarwin`, `mkSpecialArgs`).
- Files: `nix/flake.nix`, `nix/modules/`
- Risk: Refactors to flake helpers can silently break one host while the other still evaluates.
- Priority: Medium. Add `nix flake check` to CI and write a `checks.${system}.eval-*` derivation per host that calls `pkgs.runCommand` over each `*.config.system.build.toplevel`.

**No tests for sketchybar Lua:**
- What's not tested: Workspace update logic, app-icon lookups.
- Files: `sketchybar/items/*.lua`, `sketchybar/helpers/*.lua`
- Risk: Indentation bugs (already present) and broken async chains go unnoticed until visible regressions.
- Priority: Low — sketchybar reloads quickly enough that manual testing is the norm. But `app_icons.lua` is a pure lookup table that would benefit from a busted-style unit test.

**No tests for `opencode/` agent definitions:**
- What's not tested: That every `command/*.md` references valid agent IDs in `agents/*.md`; that hooks under `opencode/hooks/` are executable.
- Files: `opencode/agents/`, `opencode/command/`, `opencode/hooks/`
- Risk: Renames or deletions silently break agent commands.
- Priority: Medium. Add a `gsd-verify` script run via pre-commit that lints cross-references.

**Pre-commit only checks Nix:**
- What's not tested: Lua (`stylua --check`), shell scripts (`shellcheck`), Markdown (`markdownlint`).
- Files: `nix/.pre-commit-config.yaml`
- Risk: Other file types degrade silently.
- Priority: Low. Add stylua/shellcheck hooks gated on file types.

---

*Concerns audit: 2026-05-26*
