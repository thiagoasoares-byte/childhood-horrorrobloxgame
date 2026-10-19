# Childhood project guidance

## Architecture

- Keep shared definitions and client-safe configuration in `src/shared`.
- Keep authoritative gameplay, validation, persistence, and server services in `src/server`.
- Keep camera, input, HUD, overlays, and other presentation systems in `src/client`.
- Access gameplay remotes through `src/shared/Remotes.luau`; validate every client request on the server.
- Keep design documents, diagrams, and legacy references in `docs`.
- Keep source assets in `assets/blender` and exported models in `assets/models`.

## Tooling

- `default.project.json` is the source-of-truth Rojo mapping.
- Use the versions declared in `rokit.toml` for Rojo, Wally, Selene, and StyLua.
- Run `rojo build default.project.json --output build.rbxlx` to verify the project mapping.
- Run `selene src` and `stylua --check src` when those tools are available.

## Change boundaries

Gameplay state belongs to the server. Shared modules must not contain secrets or server-only authority. Do not add a second persistence, receipt, or remote owner without documenting the ownership boundary.
