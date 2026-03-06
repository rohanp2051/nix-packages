# Nix Packages

- Platform: `aarch64-darwin` unless specified otherwise

## Before Packaging: Existence Check (MANDATORY)

Before writing any new package, search **all four** and present a table to the user. Do not proceed without confirmation.

1. **Nixpkgs** — `nix search nixpkgs#<name>` or NixOS MCP tool
2. **Homebrew** — `brew info <name>`
3. **NUR** — https://nur.nix-community.org/
4. **GitHub** — search for existing Nix flakes/overlays packaging the app

Recommend existing packages over new derivations when quality is acceptable.

## Adding a Package

Follow existing `pkgs/*/package.nix` patterns. Every new package requires:

1. `pkgs/<name>/package.nix`
2. Entry in `flake.nix`
3. Update job in `.github/workflows/update-packages.yml` (in the same PR)
4. Verified with `nix build .#<name>`

## Gotchas

- For apps with entitlements (mic, camera, JIT), extract originals before re-signing and pass `--entitlements`
