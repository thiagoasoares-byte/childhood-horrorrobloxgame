---
name: roblox-unified
description: "Use for Roblox development, design, analytics, Luau, Studio, tooling, security, data, networking, UI, audio, VFX, performance, publishing, monetization, growth, or collaboration. This is a lightweight router: load the smallest relevant project skill instead of loading a monolithic reference."
user-invocable: true
---

# Roblox Unified

Use this skill as a router, not as a replacement for the domain skills. Keep the context small: load `roblox-collaboration-mode` first, then load only the specialized skill(s) needed for the request.

## Routing

- Every Roblox task: [roblox-collaboration-mode](../roblox-collaboration-mode/SKILL.md) first
- Building maps, props, geometry, or generated assets: [roblox-building](../roblox-building/SKILL.md)
- Animations, particles, beams, trails, tweens, camera shake, or VFX: [roblox-animation-vfx](../roblox-animation-vfx/SKILL.md)
- Camera placement, first/third person, shoulder views, or cutscenes: [roblox-camera](../roblox-camera/SKILL.md)
- Menus, HUDs, shops, dialogs, or responsive UI: [roblox-gui](../roblox-gui/SKILL.md)
- Keyboard, mouse, touch, gamepad, or action binding: [roblox-input](../roblox-input/SKILL.md)
- Audio playback, spatial sound, music, effects, or SoundGroups: [roblox-audio](../roblox-audio/SKILL.md)
- NPCs, enemies, pathfinding, or AI state machines: [roblox-npc-ai](../roblox-npc-ai/SKILL.md)
- Physics, vehicles, projectiles, constraints, or network ownership: [roblox-physics](../roblox-physics/SKILL.md)
- Lighting, atmosphere, day/night, or post-processing: [roblox-lighting](../roblox-lighting/SKILL.md)
- AnalyticsService, economy/funnel events, onboarding traces, or rate limits: [roblox-analytics](../roblox-analytics/SKILL.md)
- Game loop, FTUE, levels, economy, retention, or player behavior: [roblox-game-design](../roblox-game-design/SKILL.md) and [roblox-player-psychology](../roblox-player-psychology/SKILL.md)
- Discovery, thumbnails, growth, experiments, or LiveOps: [roblox-growth-design](../roblox-growth-design/SKILL.md)
- DataStore, ProfileStore, saves, session locks, schemas, or migrations: [roblox-data](../roblox-data/SKILL.md)
- Cross-server data, leaderboards, MessagingService, MemoryStore, or seasons: [roblox-server-data](../roblox-server-data/SKILL.md)
- Purchases, GamePasses, Developer Products, subscriptions, or private servers: [roblox-monetization](../roblox-monetization/SKILL.md)
- Remotes, server authority, validation, rate limits, or exploit prevention: [roblox-networking](../roblox-networking/SKILL.md) and [roblox-security](../roblox-security/SKILL.md)
- Feature ownership, code layout, dependencies, startup, or boundaries: [roblox-architecture](../roblox-architecture/SKILL.md)
- Luau syntax/control flow: [roblox-luau-core](../roblox-luau-core/SKILL.md)
- Luau modules, lifecycles, signals, cleanup, scheduling, or `pcall`: [roblox-luau-patterns](../roblox-luau-patterns/SKILL.md)
- Luau annotations, generics, unions, or strict typing: [roblox-luau-types](../roblox-luau-types/SKILL.md)
- Studio MCP editing, asset generation, playtesting, input, or screenshots: [roblox-studio-mcp](../roblox-studio-mcp/SKILL.md)
- Rojo, Wally, pesde, Selene, StyLua, Lune, Rokit, tests, or CI: [roblox-tooling](../roblox-tooling/SKILL.md)
- Open Cloud APIs, OAuth, webhooks, keys, or scopes: [roblox-cloud](../roblox-cloud/SKILL.md)
- Localization and translation tables: [roblox-localization](../roblox-localization/SKILL.md)
- Publishing or release gates: [roblox-publish-checklist](../roblox-publish-checklist/SKILL.md)

## Cross-cutting rules

1. Keep shared definitions and client-safe configuration in `src/shared`.
2. Keep authoritative gameplay, validation, persistence, and services in `src/server`.
3. Keep camera, input, HUD, overlays, and presentation in `src/client`.
4. Use `src/shared/Remotes.luau` for gameplay remotes; validate every client request on the server.
5. Never put secrets or server authority in shared modules.
6. Preserve ownership boundaries: do not add a second persistence, receipt, or remote owner.
7. Prefer existing helpers and patterns; make precise, typed, reversible changes.
8. Verify behavior with the smallest relevant test, lint, build, or Studio playtest.
9. For live-tunable values, feature flags, or experiments, use ConfigService rather than hard-coded values or a manual restart.
10. For high-risk changes (data, purchases, moderation, publishing), surface the plan and require explicit approval before irreversible actions.

## Project conventions

- `default.project.json` is the Rojo source of truth.
- Source assets belong in `assets/blender`; exported models belong in `assets/models`.
- Design documents, diagrams, and legacy references belong in `docs`.
- When available, validate with `rojo build default.project.json --output build.rbxlx`, `selene src`, and `stylua --check src`.

## Loading policy

Do not load every linked skill. Select the minimum set from the routing table, and load additional skills only when the task crosses domains. The detailed domain guidance remains in each linked skill's `SKILL.md` and `references/` files.
