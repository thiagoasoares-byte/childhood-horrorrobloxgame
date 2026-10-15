# SAUDADE.EXE — Módulos de implementação (contexto fixo)

Referências: `GDD_Saudade.md`, `diagramas_visual_v2.html`, `ARTE_PROMPTS.md`.

Use **este arquivo inteiro** como contexto em todo prompt de geração de código Luau.
rojo
Ordem do roadmap GDD §9: protótipo visual → pizzaria noite 1 → medo/aparições → noites 2–3 → fase 2 → polimento → playtest → fases 3 e final.

---

## M1 — Protótipo visual (cliente + Medo básico)

**Objetivo:** primeira pessoa travada, motion blur, pilha VHS, crosshair, HUD REC/timestamp/barra de Medo; servidor envia `FearChanged`; cliente interpola em 0,4 s.

**API**

| Lado | Símbolo | Contrato |
|------|---------|----------|
| Shared | `VisualConfig` | Constantes de blur, VHS, lerp de Medo |
| Shared | `Remotes.get(name)` | Retorna `RemoteEvent` em `ReplicatedStorage.Remotes` |
| Server | `FearService.setFear(player, value)` | Clampa 0–100, replica |
| Server | `FearService.addFear(player, delta)` | Idem |
| Remote | `FearChanged` | `(fear: number)` para o cliente |
| Client | `FirstPersonLock.start()` | FPS, cursor travado, oculta corpo local |
| Client | `CameraMotionBlur.start()` | `BlurEffect` local, `Size` ∝ velocidade angular |
| Client | `VhsOverlay.create()` | ScreenGui: scanlines, ruído, vinheta, glitch, REC |
| Client | `FearVisualController.start()` | Ouve `FearChanged`, lerp, aciona VHS + `ColorCorrection` |

**Critérios de aceite**

1. Câmera em primeira pessoa; crosshair 4×4 px, branco ~70% opacidade, centro da tela.
2. Ao girar a câmera rápido, blur sobe (máx. configurável ~6 studs equivalente, lerp ~0,2); repouso → 0.
3. Overlay VHS visível: scanlines, ruído animado ~12 fps, vinheta, glitch de tracking aleatório (intervalo diminui com Medo).
4. `ColorCorrection`: dessaturado, tom amarelado; intensidade escala com Medo (ver diagrama v2).
5. HUD: REC piscando, carimbo `03/11/2012`, barra de Medo discreta.
6. Servidor define Medo inicial (ex.: 30); alterações chegam via `FearChanged` sem saltos (lerp 0,4 s no cliente).
7. Mobile: loop leve, sem alocar centenas de instâncias por frame.

---

## M2 — Pizzaria Saudade noite 1 (loop)

**Objetivo:** mapa blocky original (não WPP), loop massa → molho → ingredientes → forno → caixa → balcão; pedidos certos reduzem Medo.

**API (planejado):** `OrderService`, `PizzaStation`, `NightDirector` (noite 1).

**Aceite:** 1 cliente NPC por vez; timer de forno; resumo VHS ao fechar noite; relógio pode regredir (evento noite 1).

---

## M3 — Aparições client-side

**Objetivo:** Antena/BANZO noites 1–2; cooldown 45 s/jogador; máx. 2 simultâneas; some com raycast 1,5 s.

**API (planejado):** `EntityAppearanceService`, `ClientEntityRenderer`.

**Aceite:** só susto + Medo; sem dano; `FireClient` por jogador.

---

## M4 — Noites 2–3 + armário

**Objetivo:** pedidos uncanny/terror, blackout, BANZO invasão, fuga garagem, armário co-op (todos dentro) → teleporte fase 2.

---

## M5 — Complexo Melancolia (MVP fase 2)

**Objetivo:** terminais + patrulha; câmeras falsas nos monitores.

---

## M6 — Praça Nostalgia + Baseplate Original (final)

**Objetivo:** Mímicos sociais; escolha co-op porta vs continuar.

---

## Prompt de geração (copiar por módulo)

```
Contexto fixo: spec/MODULOS_IMPLEMENTACAO.md + GDD_Saudade.md + diagramas_visual_v2.html.
Implemente apenas o módulo M<N> descrito acima.
Stack: Rojo 7, Luau, FilteringEnabled, pastas src/shared, src/server, src/client.
Não copiar IPs (WPP, mascotes, telas de erro Roblox).
```
