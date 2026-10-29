# Status do M1: Fundação visual e de conforto

Branch: `nicolas-camera-vhs` (câmera `HorrorCamera` e `VhsFilter` do Nicolas no lugar das implementações anteriores). Critérios de conclusão conforme `ROADMAP_Childhood.md`.

## 1. Critérios de conclusão

| # | Critério | Estado |
|---|---|---|
| 1 | Pilha P0 funciona nos três perfis de qualidade | Implementado. NÃO VERIFICADO em jogo |
| 2 | Mudar o Medo no servidor muda o VHS sem salto (cerca de 0,4 s) | Interpolação e `sampleFear` implementados; a lógica de faixas foi verificada. NÃO VERIFICADO em jogo |
| 3 | Cada efeito tem opção de desligar e funciona | Implementado: moldura, scanlines, vinheta, cor, blur (normal, reduzido, desligado) e movimento. NÃO VERIFICADO em jogo |
| 4 | Aviso de fotossensibilidade antes de qualquer cena | Implementado (`ContentNotice`). NÃO VERIFICADO em jogo |
| 5 | Nenhum efeito pisca mais de 3 vezes por segundo | Por construção, o único elemento intermitente é o ponto REC, a cerca de 1,2 Hz (período de 0,8 s), além do ruído e do glitch do filtro, que dependem de "reduzir movimento". NÃO MEDIDO |

## 2. Verificações executadas

### 2.1 Lógica pura, rodada no Studio

20 verificações passaram para `VisualConfig`:

- `sampleFear` é exato nos centros das faixas (12,5, 38, 63 e 88) e interpola linearmente entre eles.
- Saturação cai, vinheta e scanlines sobem de forma monotônica de 0 a 100.
- `sanitizeSettings` rejeita brightness fora de 0 a 1, NaN, tipos errados, enums inválidos, chave ausente e payload que não é tabela, e descarta chaves desconhecidas.

### 2.2 Ferramentas

| Ferramenta | Resultado |
|---|---|
| `stylua --check src` (2.6.0) | Passou |
| `selene src` | NÃO EXECUTADO: o binário não pôde ser obtido no ambiente de trabalho |
| `rojo build` | NÃO EXECUTADO: o binário não pôde ser obtido no ambiente de trabalho. O CI roda este passo |

## 3. Pendente

### 3.1 Verificação em jogo (precisa do Rojo sincronizado com a branch)

- Captura de tela em três níveis de Medo (0, 50 e 100) para conferir opacidade da vinheta, das scanlines e o blur.
- Mudar o Medo no servidor e observar a transição.
- Girar a câmera rápido e conferir que o blur sobe e volta a 0 em repouso.
- Testar cada opção do menu e o aviso de conteúdo.
- Testar `FearService` e `SettingsService` no servidor (clamp, rate limit, sincronização inicial).

### 3.2 Decisões abertas

- P5 (celular de referência e meta de FPS): os tetos de blur (24, 14 e 6) e o limite de 28 FPS da seleção automática são provisórios.
- Volume: não entrou no M1, pois ainda não há áudio. Entra junto com os primeiros sons.
- Perfis de qualidade agora afetam só a contagem de scanlines e o FPS do ruído; o teto de blur vem do `HorrorCamera` e o menu escala (normal, reduzido 0,4, desligado).
- Engrenagem e menu P do `VhsFilter` foram removidos; o menu único é o `SettingsMenu` (tecla O).
- Ruído e glitch ainda não seguem o Medo (M2).
- Idioma dos textos de interface: assumido português, pois o GDD não define.
- Scanlines, vinheta e moldura são procedurais (instâncias de GUI), porque não há texturas enviadas ao Roblox. Trocar por imagens pré-preparadas é uma otimização possível depois de medir no celular.

### 3.3 Limites conhecidos

- O servidor guarda as configurações por jogador só em memória (D20).
- Ruído, tracking glitch, aberração e posterização ficam para M2 e M6; as constantes por faixa já estão em `VisualConfig`.

## 4. M2 em andamento

| Passo | Estado |
|---|---|
| 2.1 `PhaseService` e `NightDirector` | Escrito. NÃO VERIFICADO em jogo |
| 2.2 `PizzeriaBuilder` | Escrito. Usa `ServerStorage.MapKit` quando existe e blocos de mesmo tamanho quando não. NÃO VERIFICADO em jogo |
| 2.3 Pedidos, estações, forno e `Hud` | Escrito. NÃO VERIFICADO em jogo |
| 2.4 e 2.5 | Pendentes |

- Os modelos do kit estão em `assets/models` (FBX) e `assets/blender`. Falta importar no Studio e colocar em `ServerStorage.MapKit` com os nomes `SM_*`.
- Distâncias do trajeto (casa 0, parquinho 180, pizzaria 400 studs) são provisórias até medir o tempo de caminhada.
