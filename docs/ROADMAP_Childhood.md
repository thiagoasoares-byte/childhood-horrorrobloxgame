# Roadmap e módulos Luau: Childhood

Versão 0.1 · 2026-10-21 · Complementa `GDD_Childhood.md` (referências "GDD x.y" apontam para ele).

> **Estado do código.** Listei `src/` sem ler o conteúdo dos módulos. A coluna "Mudança" dos módulos existentes é a **intenção**, a confirmar ao abrir cada arquivo. O repositório não tem `src/client`, embora `default.project.json` o mapeie, e o projeto Rojo ainda se chama `banzo`. Há um `docs/legacy/firstperson.lua` não lido.

## 1. Visão geral

| Milestone | Foco | Entrega jogável |
|---|---|---|
| M1 | Fundação visual e de conforto | Primeira pessoa com VHS, blur, Medo e configurações de acessibilidade |
| M2 | Fase 1 base | Trajeto, parquinho e loop de pizza da Noite 1, com consentimento |
| M3 | Entidades e aparições | Antena, Nameless client-side, memória do jogador |
| M4 | Noites 2 e 3 e clímax | Curva completa, blackout, Nameless visível a todos, captura, armário |
| M5 | Fase 2: Instalação | Câmeras com atraso, patrulha, elevador |
| M6 | Fase 3, Baseplate, finais e polimento | Mímicos sociais, votação, finais, publicação |

Ordem fixa: M1, M2, M3, M4, M5, M6. Os milestones M5 e M6 só começam depois do playtest de M4.

## 2. Milestones

### M1: Fundação visual e de conforto

- **Objetivo:** primeira pessoa com câmera própria (bob, inclinação ao girar, variação de FOV, corpo visível sem a cabeça), pilha VHS P0, blur de câmera, Medo no servidor e interpolado no cliente, aviso de fotossensibilidade e configurações de acessibilidade.
- **Sistemas:** câmera, VHS, Medo, acessibilidade, perfis de qualidade.
- **Módulos que mudam:** `shared/VisualConfig` (constantes por faixa de Medo e por perfil), `shared/Remotes` (`FearChanged`, `SettingsChanged`), `server/FearService` (por jogador, clamp, replicação), `server/init.server`. Novos: `client/HorrorCamera`, `client/VhsFilter`, `client/FearVisualController`, `client/AccessibilitySettings`, `client/QualityProfile`, `client/ContentNotice`.
- **Dependências:** P5 (celular de referência). Sem persistência no M1 (D20). Renomear o projeto Rojo.
- **Critérios de conclusão:**
  1. Pilha P0 funciona nos três perfis de qualidade (GDD 9.1, 9.4).
  2. Mudar o Medo no servidor muda o VHS no cliente sem salto (interpolação em cerca de 0,4 s).
  3. Cada efeito tem opção de desligar e a opção funciona.
  4. Aviso de fotossensibilidade aparece antes de qualquer cena.
  5. Nenhum efeito pisca mais de 3 vezes por segundo (medido).
- **Validação:** captura de tela em três níveis de Medo para conferir opacidade e blur; teste em desktop e no celular de referência; leitura de FPS por perfil.
- **Riscos:** custo do ruído e do blur em celular; `src/client` ausente no repositório; blur global do `BlurEffect` em dispositivos fracos.

### M2: Fase 1 base

- **Objetivo:** trajeto casa, parquinho, pizzaria e o loop de pizza da Noite 1, com consentimento e opt-out funcionando.
- **Sistemas:** mapa, pedidos, estações, `NightDirector` (Noite 1), consentimento, clientes.
- **Módulos que mudam:** `server/PizzeriaBuilder` (pizzaria, parquinho, quarteirão), `server/OrderService`, `server/PizzaStation`, `server/NightDirector` (blocos ida, turno, volta), `shared/Remotes`. Novos: `server/ConsentService`, `server/CustomerAppearanceService`, `server/PhaseService`, `client/ConsentPrompt`, `client/Hud`.
- **Dependências:** M1; D18 (amigos ausentes, risco aceito), D20 (persistência), D21 (1 jogador).
- **Critérios de conclusão:**
  1. Grupo de 2 a 4 completa a Noite 1 do começo ao fim.
  2. Com opt-out ativo, nenhuma aparência de terceiro é carregada (log do servidor).
  3. Nenhum nome de usuário em nameplate, UI ou texto.
  4. O turno só começa com todos presentes.
  5. Pedidos certos e errados mudam o ritmo como especificado (GDD 4.1).
  6. Opt-out e acessibilidade persistem entre sessões, com o esquema aprovado antes de implementar.
  7. A Fase 1 é jogável com 1 jogador, em escala reduzida.
- **Validação:** partida de 2, 3 e 4 jogadores; desconexão no meio; auditoria de nomes na tela.
- **Riscos:** aparência de terceiros (D18) é risco aceito e precisa de revisão nas políticas vigentes antes de publicar; mapa do parquinho dentro do orçamento de celular; texto dinâmico dos pedidos precisa passar pelo filtro do Roblox.

### M3: Entidades e aparições

- **Objetivo:** Antena nas telas, Nameless client-side nas Noites 1 e 2, memória do jogador no parquinho e regras de justiça dos sustos.
- **Sistemas:** aparições, relatório de olhar, memória, telemetria.
- **Módulos que mudam:** `server/EntityAppearanceService` (quando, para quem, cooldown, teto), `server/FearService`, `shared/Remotes` (`ApparitionCue`, `LookReport`). Novos: `server/GazeService`, `server/TelemetryService`, `client/ClientEntityRenderer`, `client/MemoryRenderer`, `client/LookReporter`, `client/FakeScreens`.
- **Dependências:** M2; T1 (leituras de avatar); P2 (nome da Antena); arte da Nameless e da Antena.
- **Critérios de conclusão:**
  1. Aparições client-side não alteram estado de gameplay (teste com cliente alterado).
  2. Cooldown e teto de intensidade respeitados em 100% dos eventos registrados.
  3. A memória some se observada e cai para o fallback se a leitura falhar.
  4. Entre dois sustos pontuais de intensidade 3 ou mais há sempre um vale de pelo menos 30 s.
  5. Eventos de telemetria chegam sem dado pessoal.
- **Validação:** logs de eventos por sessão; playtest com 3 grupos para calibrar cooldown; verificação visual da legibilidade dos olhos por distância.
- **Riscos:** T1 negativo (memória cai para a opção A pura); semelhança da Antena com personagens existentes; aparições "sem graça" se o olhar for dominante demais.

### M4: Noites 2 e 3 e clímax

- **Objetivo:** curva completa das Noites 2 e 3, blackout, Nameless visível a todos, regra do olhar, captura, armário co-op e transição.
- **Sistemas:** olhar autoritativo, Nameless autoritativa, captura, checkpoints, armário.
- **Módulos que mudam:** `server/NightDirector` (curvas 2 e 3), `server/EntityAppearanceService` (modo Noite 3), `server/PizzeriaBuilder` (garagem, corredor, armário), `server/GazeService`, `shared/Remotes`. Novos: `server/EntityAuthorityService`, `server/CaptureService`, `server/CheckpointService`, `server/TransitionService`, `client/CaptureScreen`.
- **Dependências:** M3; **P6** (olhar) e **P7** (arquitetura de fases).
- **Critérios de conclusão:**
  1. Nenhuma captura sem os dois sinais prévios (log).
  2. Jogador capturado reaparece no último ponto seguro em cerca de 10 s.
  3. O armário só transiciona com todos os presentes dentro; desconexão não trava.
  4. A Nameless não se move enquanto o servidor tem pelo menos um jogador a observando.
  5. Intensidade 5 ocorre uma única vez por partida.
- **Validação:** testes de desconexão no armário; teste com cliente que mente sobre o olhar; playtest com 3 grupos medindo capturas e abandono.
- **Riscos:** o relatório de olhar ser trapaceado; escuridão total frustrando em celular; frustração com capturas encadeadas.

### M5: Fase 2, Instalação

- **Objetivo:** terminais, câmeras com atraso, Nameless patrulhando, elevador coletivo.
- **Sistemas:** terminais, monitores, patrulha, transição.
- **Módulos que mudam:** `server/PhaseService`, `server/EntityAuthorityService` (patrulha), `server/TransitionService` (elevador). Novos: `server/TerminalService`, `client/MonitorFeed`, `server/FacilityBuilder`.
- **Dependências:** M4.
- **Critérios de conclusão:**
  1. Grupo conclui a fase com a rota de fuga aberta pelos terminais.
  2. Câmeras mostram o atraso especificado.
  3. O elevador só parte com todos dentro.
  4. A fase roda no perfil Baixo sem queda abaixo da meta de FPS.
- **Validação:** playtest de 2 a 4 jogadores; medição de FPS com vários monitores ativos.
- **Riscos:** várias câmeras ao mesmo tempo em celular; semelhança de layout com jogos existentes.

### M6: Fase 3, Baseplate, finais e polimento

- **Objetivo:** Praça com Mímicos, Baseplate, votação e finais, posterização aproximada, aberração e publicação.
- **Sistemas:** Mímicos sociais, votação, finais, P2 do VHS, publicação.
- **Módulos que mudam:** `server/CustomerAppearanceService` (Mímicos), `server/PhaseService`, `client/VhsFilter` (aberração e posterização aproximadas), `shared/Remotes` (`VoteCast`). Novos: `server/VoteService`, `server/FinalService`, `server/PlazaBuilder`, `client/FinalScenes`.
- **Dependências:** M5; P3 (classificação), P9 (monetização).
- **Critérios de conclusão:**
  1. Os três finais são alcançáveis; o secreto só com a condição.
  2. Escolha dividida termina com saída narrativa após as tentativas.
  3. Mímicos nunca mostram nome de usuário, e o opt-out vale na Praça.
  4. Checklist de publicação com evidência por item; resultado READY ou READY WITH ACCEPTED RISK.
- **Validação:** playtest completo com grupos novos; auditoria de privacidade e de acessibilidade; versão publicada conferida em execução.
- **Riscos:** aparência de jogadores reais nos Mímicos; revisão de classificação; tempo de polimento.

## 3. Módulos Luau afetados

### 3.1 Existentes (conteúdo não lido)

| Módulo | Lado | Mudança prevista | Milestones |
|---|---|---|---|
| `shared/Remotes.luau` | Shared | Novos remotes (`FearChanged`, `SettingsChanged`, `ApparitionCue`, `LookReport`, `VoteCast`) | M1, M3, M6 |
| `shared/VisualConfig.luau` | Shared | Constantes por faixa de Medo e por perfil de qualidade | M1, M6 |
| `server/init.server.luau` | Server | Registrar serviços novos | M1 a M6 |
| `server/FearService.luau` | Server | Medo por jogador, clamp, replicação | M1, M3 |
| `server/NightDirector.luau` | Server | Blocos ida, turno, volta; curvas das Noites 1, 2 e 3 | M2, M4 |
| `server/OrderService.luau` | Server | Pedidos conforme a curva e a escala por grupo | M2 |
| `server/PizzaStation.luau` | Server | Estações e forno | M2 |
| `server/PizzeriaBuilder.luau` | Server | Parquinho, quarteirão, garagem, armário | M2, M4 |
| `server/EntityAppearanceService.luau` | Server | Cooldown, teto, modo Noite 3 | M3, M4 |

### 3.2 Novos (propostos)

| Módulo | Lado | Função | Milestone |
|---|---|---|---|
| `client/HorrorCamera` | Client | Primeira pessoa scriptable (bob, FOV, corpo visível), letterbox, mira e `BlurEffect` por velocidade angular | M1 |
| `client/VhsFilter` | Client | Pilha VHS em camadas (moldura REC, scanlines, vinheta, ruído, grade de cor) | M1, M6 |
| `client/FearVisualController` | Client | Interpola o Medo e ajusta o VHS | M1 |
| `client/AccessibilitySettings` | Client | Opções de reduzir efeitos, volume, brilho | M1 |
| `client/QualityProfile` | Client | Perfis Alto, Médio, Baixo | M1 |
| `client/ContentNotice` | Client | Aviso de fotossensibilidade | M1 |
| `client/Hud` | Client | HUD mínimo (pedido atual, grupo) | M2 |
| `client/ConsentPrompt` | Client | Aviso e opt-out | M2 |
| `server/ConsentService` | Server | Guarda e aplica o opt-out | M2 |
| `server/CustomerAppearanceService` | Server | Clientes e Mímicos, nome genérico, nameplate desligada | M2, M6 |
| `server/PhaseService` | Server | Troca de fases (P7) | M2 a M6 |
| `client/ClientEntityRenderer` | Client | Renderiza Antena e Nameless client-side | M3 |
| `client/MemoryRenderer` | Client | Memória do jogador (opção C) | M3 |
| `client/LookReporter` | Client | Envia a direção da câmera | M3 |
| `client/FakeScreens` | Client | Telas de conexão perdida com visual próprio | M3 |
| `server/GazeService` | Server | Valida o olhar e a linha de visão | M3, M4 |
| `server/TelemetryService` | Server | Eventos agregados, sem dados pessoais | M3 |
| `server/EntityAuthorityService` | Server | Nameless autoritativa (Noite 3, Instalação) | M4, M5 |
| `server/CaptureService` | Server | Dois sinais e captura | M4 |
| `server/CheckpointService` | Server | Último ponto seguro | M4 |
| `server/TransitionService` | Server | Armário e elevador coletivos | M4, M5 |
| `client/CaptureScreen` | Client | Tela de fita parada | M4 |
| `server/TerminalService` | Server | Terminais da Instalação | M5 |
| `server/FacilityBuilder` | Server | Mapa da Instalação | M5 |
| `client/MonitorFeed` | Client | Monitores com atraso | M5 |
| `server/PlazaBuilder` | Server | Mapa da Praça | M6 |
| `server/VoteService` | Server | Votação dos finais | M6 |
| `server/FinalService` | Server | Resolve os finais | M6 |
| `client/FinalScenes` | Client | Cenas dos finais | M6 |

### 3.3 Mudanças de projeto

- Renomear o projeto de `banzo` para `childhood` em `default.project.json`.
- Criar `src/client`, ausente no repositório.
- Persistência de opt-out e acessibilidade (D20) entra no M2 e exige DataStore: o esquema é apresentado para aprovação antes de implementar.
