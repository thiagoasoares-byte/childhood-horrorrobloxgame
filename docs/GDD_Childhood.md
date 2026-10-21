# GDD: Childhood

Versão 0.1 (reformulação) · 2026-10-21 · Status: etapas A, B e C aprovadas; etapa D em revisão.

> **Fonte de verdade.** `GDD_Saudade.md`, `ARTE_PROMPTS.md`, `MODULOS_IMPLEMENTACAO.md` e `diagramas_visual_v2.html` são arquivo histórico e não valem como referência.
>
> **Base psicológica.** O estudo de Costa e Londero (*Disciplinarum Scientia*, v. 27, n. 1, 2026) é tratado como **hipótese a validar em playtest**. Ele não tem pesquisa com jogadores e não cobre co-op nem Roblox. Todo valor numérico deste documento é um valor inicial de ajuste, salvo quando indicado.

---

## 1. Visão

### 1.1 Premissa

*Childhood* é um jogo de terror analógico cooperativo para 2 a 4 jogadores, em primeira pessoa. Cada fase se inspira no **gênero** de jogos clássicos do Roblox de cerca de 2010 a 2014, com identidade totalmente original.

Tema central: **"Esse jogo que eu jogava na infância não era assim."**

A regra emocional é que o conforto é a isca. Nada ataca o jogador sem aviso; o jogo o convence, noite após noite, de que a memória dele é que estava errada.

### 1.2 Público e classificação

- **Público:** adolescentes e adultos jovens, em grupos de 2 a 4 amigos.
- **Conteúdo:** sustos intensos e temas perturbadores. Sem gore, sangue ou nojo (só Terror e Horror, sem Repulsa).
- **Classificação:** a mais baixa que ainda permita terror psicológico. A classificação final sai do questionário de maturidade vigente, preenchido com o jogo pronto (ver P3).
- **Divulgação:** o tema da infância não pode ser usado como atrativo para menores. O jogo não é divulgado como jogo infantil.

### 1.3 Pilares

1. **Conforto antes do erro.** Toda fase começa familiar e só depois fica errada.
2. **Cópia, não dano.** O horror vem do que está levemente errado, nunca de alguém ferido.
3. **O que não se vê.** A Nameless só se move quando ninguém olha, então o olhar vira recurso.
4. **Co-op que depende de vigiar.** Alguém precisa olhar, e quem olha não produz.
5. **Respeito ao jogador.** Todo susto é anunciado, escalonado e evitável por quem prestou atenção.

---

## 2. Decisões fechadas

| ID | Decisão |
|---|---|
| D01 | Nome do jogo: **Childhood**. Os nomes BANZO e SAUDADE.EXE ficam só no histórico |
| D02 | Jogo em primeira pessoa, 2 a 4 jogadores, crosshair pontual, blur suave proporcional à velocidade da câmera |
| D03 | Elenco fechado em três: **Nameless** (principal), **entidade secundária** (antenas) e **Mímicos** |
| D04 | Nameless: silhueta preta chapada, muito alta e magra, sem textura, sem rosto pálido, sem chapéu, sem espinhos, olhos só com a esclera branca contornando a bola preta |
| D05 | Entidade secundária: aparência redesenhada neste documento (ver 6.2) |
| D06 | Só Terror e Horror. Sem gore, sangue ou nojo, por acessibilidade e classificação |
| D07 | Simbologia de **infância corrompida**, sem simbologia religiosa ou demoníaca |
| D08 | Fase 1 com três noites e trajeto casa, parquinho, pizzaria, parquinho, casa. A Noite 3 não tem volta |
| D09 | Parquinho com a **memória do jogador**: aparência de infância do próprio jogador brincando, vista só por ele |
| D10 | Memória na opção C: avatar atual em versão infância como base e outfit salvo escolhido pelo jogador como bônus opcional |
| D11 | Aparência de amigos nos clientes: opt-out do jogador obrigatório, com a opção **ligada** por padrão (ver D18) |
| D12 | Aparência dos jogadores reais da sessão pode ser usada nos Mímicos da Praça, com opt-out e sem nome |
| D13 | Nameless visível a todos na manifestação da Noite 3, mantendo "só se move quando ninguém olha" |
| D14 | Captura pela Nameless (opção A): o jogador reaparece no último ponto seguro após cerca de 10 s, em estado de "fita parada" com visual próprio |
| D15 | MVP de fases: Pizzaria, Instalação, Praça, Baseplate |
| D16 | Escolha dividida nos finais gera cena curta e nova votação, com saída narrativa após algumas tentativas |
| D17 | Nível de Medo existe no servidor e se expressa pelo VHS. O HUD não mostra barra de Medo (padrão reversível) |
| D18 | **Amigos ausentes (P1, opção c):** clientes podem usar a aparência de amigos do jogador mesmo ausentes, sempre distorcida, sem opt-out do amigo. **Risco aceito pelo autor.** Mantém: opt-out do jogador (D11), sem nome, nunca ferido, aparência só em memória, só amigos do próprio jogador. Interruptor de configuração no servidor para desligar rápido se a plataforma ou a moderação exigir |
| D19 | Entidade secundária: nome definitivo **Antena** e redesenho aprovados (6.2) |
| D20 | Persistência (P4): o M1 não persiste nada, opt-out e acessibilidade valem na sessão. A persistência mínima entra no M2, com esquema versionado apresentado para aprovação antes de implementar |
| D21 | Um jogador (P8): a Fase 1 é jogável sozinho, em escala reduzida e com convite para amigos. As fases 2 em diante exigem 2 a 4 jogadores. Reversível |

---

## 3. Decisões pendentes

| ID | Pendência | Bloqueia |
|---|---|---|
| P3 | Classificação final de maturidade | Publicação |
| P5 | Celular de referência e meta de FPS | M1 |
| P6 | Como o servidor sabe se alguém está olhando para a Nameless (ver 11.3) | M4 |
| P7 | Arquitetura de fases: mesmo place ou places separados com `TeleportService`. Recomendo mesmo place no MVP | M4 |
| P9 | Monetização: proposta no `GUIA_Vibecoding_Childhood.md` (servidores privados, passes cosméticos, apoio). Sem pay-to-win, sem item aleatório pago, sem oferta durante sustos, sem urgência falsa. Decidir antes de publicar o Episódio 1 | Publicação |
| P10 | Fases de expansão (Casa e outras) | Pós-MVP |
| T1 | Técnico, validar no Studio: `AvatarEditorService:GetOutfitsAsync` exige prompt de permissão? roda no cliente? A aparência atual do próprio jogador é legível sem prompt? | M3 |

---

## 4. Loop e cooperação

### 4.1 Loop principal

Duas camadas. O trabalho é o disfarce do loop de tensão.

| Camada | O que o jogador faz | Função de medo |
|---|---|---|
| Trabalho | Lê pedido, prepara pizza, entrega | Rotina que cria segurança e permite a quebra |
| Tensão | Vigia cantos, portas e janelas; reage a pistas | Dilema: trabalhar ou olhar |

Ciclo da noite: servir clientes, perceber um erro, decidir o que fazer, voltar à rotina com a dúvida. Pedido certo dá calma; pedido atrasado ou errado tira a calma da cozinha.

### 4.2 Cooperação

| Papel (flexível, sem classe fixa) | Tarefa | Custo |
|---|---|---|
| Cozinha | Massa, molho, forno | Fica de costas para o salão |
| Balcão | Lê pedidos, atende | Vê o rosto dos clientes |
| Entrega | Leva caixas | Cruza o corredor escuro |
| Vigia | Olha as áreas ameaçadas | Não produz |

- **Escala por grupo:** com 2 jogadores o servidor reduz pedidos simultâneos e alarga intervalos; com 4 aumenta pedidos e a área a vigiar.
- **Desconexão no meio:** o jogo continua, papéis se redistribuem e o armário final conta só quem está conectado.
- **Comunicação:** chat do Roblox, já filtrado pela plataforma. Sem sistema de voz próprio.

---

## 5. Fase 1: Pizzaria

### 5.1 Estrutura

Cada noite tem três blocos: **ida**, **turno** e **volta**. O jogador repete o caminho casa, parquinho, pizzaria, e o jogo muda o que ele reconhece.

- **Casa:** cada jogador acorda na própria casa; as casas ficam no mesmo quarteirão para o grupo se encontrar a caminho.
- **Duração do trajeto:** cerca de 1 a 2 minutos (a testar).
- **Início do turno:** só começa quando todos chegam. Quem para para olhar o parquinho segura o grupo.
- **Noite 3:** sem volta. O armário da garagem substitui o caminho de casa e leva à fase seguinte.

### 5.2 Parquinho

Inspiração de arquitetura: escorregador de ferro, balanços, carrossel baixo, brinquedos de mola, árvores secas, névoa e uma estátua distante. Tudo recriado em blocos originais com textura PSX. Nenhuma imagem de referência é usada como textura nem reproduzida.

| Noite | Ida | Volta |
|---|---|---|
| 1 | Dia lavado. Memória brinca normalmente, com um erro pequeno | Entardecer. Um brinquedo mudou de lugar |
| 2 | Névoa. A memória repete o movimento e vira a cabeça quando o jogador não olha | Escuro. Várias memórias dessincronizadas |
| 3 | Vazio, balanços ainda se movem, estátua virou | Não existe |

### 5.3 Memória do jogador

- **Quem vê:** cada jogador vê só a própria memória, no próprio cliente. O servidor não depende dela.
- **Aparência (opção C):** avatar atual em versão infância (proporção menor, cores clássicas, roupa genérica de época) como base. Se o jogador escolher, um outfit salvo vira o "dele de antes".
- **Fatos verificados:** o Roblox não expõe o histórico de aparência do jogador. Outfits salvos são lidos por `GetOutfitsAsync` ([docs](https://create.roblox.com/docs/en-us/reference/engine/classes/AvatarEditorService)). Permissão e execução em cliente: **não verificados** (T1).
- **Regras:** só o próprio jogador, nunca amigos. A memória nunca é ferida, perseguida nem ameaçada: ela brinca e fica errada. Some quando observada por alguns segundos.
- **Fallback:** se a leitura falhar ou o jogador desativar, o parquinho funciona sem memória, só com os balanços em movimento.

### 5.4 Noites

| Noite | Tom | O que muda | Teto de intensidade |
|---|---|---|---|
| 1: Rotina | Quase normal | Relógio atrasa, cliente repete a frase, objeto movido, Mímico de relance | 2 |
| 2: Padrões | Impossível | Padrões repetidos, cômodos que não batem, primeira aparição da Nameless (client-side) | 3 |
| 3: Fuga | Ameaça aberta | Pedidos ilegíveis, luzes caem, Nameless visível a todos, corrida até o armário | 5 |

Pedidos bizarros usam texto, som e props estilizados (gelatina vermelha, esferas brancas, massa que se mexe). Telas de conexão perdida têm identidade visual própria e nunca imitam mensagem do Roblox.

### 5.5 Clímax da Noite 3

1. Os pedidos viram ruído e a fila some.
2. Silêncio. O zumbido ambiente para.
3. As luzes caem em etapas.
4. A Nameless aparece a todos, na janela da frente.
5. Corrida cozinha, corredor, garagem. Quem desvia o olhar perde posição.
6. Armário: todos precisam entrar. O jogo conta só quem está conectado.

---

## 6. Entidades

### 6.1 Nameless (principal)

**Visual.** Silhueta preta chapada, sem textura, sem material reflexivo. Muito alta (cerca de 2,5 a 3 vezes um avatar, a testar) e magra, de membros finos e longos. Sem rosto, sem chapéu, sem espinhos, sem forma extra. Os olhos são a única informação: esclera branca contornando a bola preta.

**Legibilidade dos olhos por distância (hipótese de design):** longe, só pontos brancos; perto, a esclera ganha contorno e a pupila se desloca na direção do jogador. O corpo nunca ganha detalhe, e a silhueta é um buraco no cenário.

**Comportamento.**

| Regra | Valor inicial |
|---|---|
| Move-se | Só quando nenhum jogador a vê, em saltos discretos entre pontos de rota |
| Desaparece | Quando observada por alguns segundos (aparições client-side) |
| Aparece | Em cantos, portas e janelas |
| Noites 1 e 2 | Client-side, só para um jogador, intensidade máxima 3 |
| Noite 3 | Visível a todos, estado decidido pelo servidor |
| Ilhas de luz | Uma lâmpada acesa impede que ela avance enquanto alguém está sob ela (hipótese) |
| Captura | Só depois de dois sinais (luz oscila, sussurro). Ver 7.3 |

### 6.2 Entidade secundária: "Antena"

Redesenhada para não se confundir com a Nameless e não repetir nenhum traço do desenho antigo.

- **Presença:** vive só em superfícies de tela e vidro (TV, monitor, vidraça, espelho). Nunca existe como objeto do mundo.
- **Forma:** silhueta preta chapada de altura média, curvada para a frente, **sem olhos**. Duas antenas finas e curvas saem da cabeça, em assimetria (uma maior que a outra).
- **Função:** presságio. Aparece antes de picos da Nameless. Nunca persegue, nunca captura, nunca ataca.
- **Comportamento:** some quando a tela é olhada de frente por alguns segundos, ou quando o jogador se afasta.
- **Risco a revisar:** silhuetas com antenas são comuns no terror analógico. Antes da arte final, comparar com personagens existentes e descartar qualquer semelhança.

### 6.3 Mímicos

- **O que são:** cópias erradas de clientes e, na Praça, de jogadores da sessão. Proporções alteradas e rosto liso.
- **Comportamento:** copiam gestos com atraso, ocupam lugares onde deveria haver gente de verdade. Nunca atacam.
- **Regras:** nome do modelo genérico, sem nome de usuário em lugar nenhum, nameplate desligada (`DisplayDistanceType = None`). Nunca chamados pelo nome real em texto, áudio ou legenda.
- **Princípio:** o medo vem da cópia estar errada, nunca de reconhecer uma pessoa real.

---

## 7. Aparições e justiça dos sustos

### 7.1 Regras de justiça

1. **Aviso antes de consequência.** Nenhum susto grave sem pista anterior (luz, som, mudança de ambiente).
2. **Escalonamento.** O mesmo gatilho nunca produz o susto máximo na primeira vez.
3. **Dois sinais antes do contato.** Luz oscila, depois sussurro, só então a aproximação.
4. **Intervalos mínimos.** Cooldown por jogador entre aparições (valor inicial a calibrar).
5. **Servidor autoritativo.** Aparição client-side nunca decide dano, captura ou progresso.
6. **Respiro garantido.** Depois de um susto pontual ou de um bloco de ameaça de intensidade 3 ou mais, há uma ilha de luz de pelo menos 30 s sem eventos.
7. **Sem sustos pontuais consecutivos.** Trechos sustentados de ameaça, como a corrida da Noite 3, contam como um bloco único: têm duração limitada na curva e terminam em vale.

### 7.2 Aparições client-side

O servidor decide **quando** e **para quem** (`FireClient` para um jogador). O cliente só renderiza. Tudo que for gameplay acontece no servidor.

### 7.3 Captura

- Sequência: luz oscila, sussurro, aproximação, captura.
- Efeito (D14): o jogador vê a tela de "fita parada", com visual próprio, e reaparece no último ponto seguro depois de cerca de 10 s, com o nível de Medo elevado.
- Depois da captura, a Nameless recua por um período de graça (valor a calibrar) para não encadear capturas.
- Nunca letal, nunca com dano gráfico, nunca encerra a partida.

### 7.4 Telemetria

Eventos agregados de design, sem dados pessoais: aparições por noite, tempo até a primeira reação, paradas no parquinho, capturas, abandonos. Detalhes em 17.4.

---

## 8. Curva de medo

Escala de intensidade de 0 a 5. Minutos relativos ao início do bloco, aprox. O Anexo A traz o detalhe por trecho. Resumo:

| Bloco | Sequência de estados e intensidade (por trecho) |
|---|---|
| Noite 1 (teto 2) | segurança 0, suspeita 1, segurança 0, suspeita 1, confirmação 2, alívio 0, dúvida 2, suspeita 1 |
| Noite 2 (teto 3) | suspeita 2, alívio 0, segurança instável 1, confirmação 2, ameaça 3, alívio 1, dúvida 2, ameaça 3 |
| Noite 3 (teto 5) | dúvida 2, segurança falsa 2, suspeita 1, ameaça 4, ameaça 4, alívio 2, consequência 5, alívio 3 para 1 |
| Instalação | segurança 0, suspeita 1, confirmação 2, alívio 0, dúvida 3, alívio 1 (30 s), ameaça 4, consequência 3 |
| Praça | segurança 0 a 1, suspeita 1, confirmação 2, alívio 0, dúvida 3, alívio 1 (30 s), ameaça 4, consequência 2 |
| Baseplate | segurança falsa 0, suspeita 1, dúvida 2, ameaça 3, consequência variável |

O diagrama `diagramas_visual_v3.html` plota essas curvas.

---

## 9. VHS e posterização

O Roblox não oferece shaders arbitrários nem leitura do quadro renderizado. Tudo abaixo é composto de `ScreenGui`, imagens pré-preparadas, `ColorCorrectionEffect` e `BlurEffect`. A posterização é **aproximada**, nunca por pixel.

### 9.1 Viável em tempo real

| Efeito | Implementação sugerida | Custo | Fallback mobile | Acessibilidade | Prioridade |
|---|---|---|---|---|---|
| Moldura VHS (REC, PLAY, SP, VCR TAPE, timecode, volume) | `ScreenGui` com `TextLabel` | Baixo | Menos elementos animados | Opção de ocultar a moldura | P0 (M1) |
| Scanlines | `ImageLabel` com textura repetida e transparência alta | Baixo | Textura menor e estática | Opção de desligar | P0 (M1) |
| Vinheta | `ImageLabel` com gradiente radial pré-preparado | Baixo | Mantém | Intensidade ajustável | P0 (M1) |
| Cor (dessaturação e tom) | `ColorCorrectionEffect` | Baixo | Mantém | Brilho e contraste ajustáveis | P0 (M1) |
| Blur de câmera | `BlurEffect` com `Size` proporcional à velocidade angular, com teto | Baixo a médio | Teto menor ou desligado | Opção "reduzir blur" | P0 (M1) |
| Ruído | Poucas texturas pré-renderizadas trocadas em cerca de 12 fps | Médio | 6 fps ou estático | Desliga em "reduzir movimento" | P1 (M2) |
| Tracking glitch | Faixa horizontal animada com deslocamento | Baixo | Menos frequente | Desliga em "reduzir flashes" | P1 (M2) |
| Aberração cromática aproximada | Bandas vermelha e ciano deslocadas nas bordas, só em UI | Baixo a médio | Estática | Desliga em "reduzir movimento" | P2 (M6) |
| Posterização aproximada | Paleta restrita nos assets, bandas em degraus (gradiente de paradas duras) e contraste via `ColorCorrectionEffect` | Baixo | Só paleta restrita | Intensidade ajustável | P2 (M6) |

### 9.2 Possível, mas com custo

- Camadas adicionais de `ScreenGui`.
- Animação de ruído em taxa alta.
- Várias imagens sobrepostas.
- Pós-processamento pesado (`Bloom`, `DepthOfField`) em celular.
- Efeitos sincronizados em dispositivos móveis.

Cada item acima só entra com medição no celular de referência (P5) e com perfil de qualidade que o desligue.

### 9.3 Não prometer sem validação

- Shader customizado arbitrário.
- Posterização real por pixel em toda a tela.
- Qualquer efeito que dependa de ler o quadro renderizado.
- Filtros caros como requisito obrigatório para jogar.

### 9.4 Perfis de qualidade

| Perfil | Efeitos |
|---|---|
| Alto | Todos |
| Médio | Ruído a 6 fps, aberração estática, blur com teto menor |
| Baixo | Sem ruído animado, sem aberração, sem posterização, blur mínimo |

Seleção automática por desempenho medido, com troca manual no menu.

### 9.5 Controle por nível de Medo

O servidor mantém o nível de Medo por jogador (0 a 100) e o envia em `FearChanged`. O cliente interpola e ajusta o VHS. Os valores abaixo são de referência por faixa, e o cliente interpola linearmente entre as faixas. Valores iniciais:

| Faixa | Saturação (CC) | Scanlines | Ruído | Vinheta | Aberração | Intervalo de glitch |
|---|---|---|---|---|---|---|
| 0 a 25, calma | -0,15 | 10% | 6% | 35% | 0 px | 60 s |
| 26 a 50, tensa | -0,28 | 15% | 11% | 50% | 1 px | 35 s |
| 51 a 75, alerta | -0,40 | 21% | 16% | 65% | 2 px | 18 s |
| 76 a 100, pânico | -0,55 | 28% | 22% | 80% | 3 px | 8 s |

---

## 10. Fases futuras e finais

### 10.1 MVP

| Fase | Gênero de inspiração | Mecânica exclusiva | Transição |
|---|---|---|---|
| 2: Instalação | Fuga de complexo | Câmeras com atraso: o que o grupo vê já aconteceu | Elevador que só parte com todos |
| 3: Praça | Cidade social | "Quem é real?": testar gestos para separar jogadores de Mímicos | Fonte seca revela passagem |
| 4: Baseplate | O primeiro spawn | Escolha coletiva | Final |

Riscos comuns: layouts sem semelhança com jogos existentes; muitos NPCs ou câmeras simultâneas em celular; aparência de jogadores reais sujeita às regras da seção 12.

### 10.2 Expansão (fora do MVP)

Casa suburbana (cômodos que mudam), ilhas e barcos, obby cooperativo, desastres naturais e prisão. Sem trabalho de design até decisão (P10).

### 10.3 Finais

| Final | Condição | Resultado |
|---|---|---|
| Sair | Todos escolhem a porta | Tela de desconexão própria; um avatar segue "jogando" depois que os jogadores saem |
| Ficar | Todos escolhem continuar | O loop recomeça com os avatares do grupo como clientes, sem nome de usuário |
| Secreto | Nenhum jogador foi tocado por um Mímico e o grupo cumpriu a pista oculta | Desligam o servidor no console da sala de fitas |

**Escolha dividida (D16):** gera uma cena curta e reabre a votação. Depois de algumas tentativas, a porta "decide" pela maioria. Com 2 jogadores, empate gera nova votação. Quem sai da partida deixa de contar.

---

## 11. Servidor e cliente

### 11.1 Autoridade

| Servidor (autoritativo) | Cliente (apresentação) |
|---|---|
| Linha do tempo das noites e curva de medo | Primeira pessoa, câmera, blur |
| Nível de Medo por jogador | Pilha VHS e efeitos visuais |
| Pedidos, receita, forno, entrega | HUD e menus (configurações, opt-out, aviso) |
| Decidir quando e para quem uma aparição acontece | Renderizar Antena, Nameless e memória |
| Posição, visibilidade e captura da Nameless na Noite 3 | Telas falsas de conexão perdida |
| Checkpoints, armário, transições de fase | Áudio local e volume do jogador |
| Votação dos finais | Relatório de olhar (11.3) |
| Validação de todo pedido do cliente | Nada que decida gameplay |

### 11.2 Remotes (a nomear em `src/shared/Remotes.luau`)

| Remote | Direção | Conteúdo | Validação |
|---|---|---|---|
| `FearChanged` | S para C | Nível de Medo do jogador | Só o servidor envia |
| `ApparitionCue` | S para um C | Tipo, local, duração | Servidor decide, cliente só renderiza |
| `LookReport` | C para S | Vetor de olhar | Limite de taxa, bounds, plausibilidade (11.3) |
| `SettingsChanged` | C para S | Opt-out e acessibilidade | Tipos, valores permitidos, limite de taxa |
| `VoteCast` | C para S | Escolha do final | Uma vez por jogador por rodada |

### 11.3 Olhar autoritativo (P6)

A regra "só se move quando ninguém olha" na Noite 3 muda estado de gameplay, então o servidor precisa de uma fonte de olhar. O cliente envia a direção da câmera em taxa limitada e o servidor valida: velocidade angular plausível, consistência com a direção do personagem (primeira pessoa travada) e linha de visão calculada no servidor. Em co-op, trapacear afeta só o próprio grupo, então o risco é aceito como baixo. A confirmar no protótipo.

---

## 12. Privacidade

1. **Nunca** mostrar nome de usuário ou nome de exibição em UI, nameplate, chat, texto de pedido, áudio ou legenda.
2. **Opt-out** acessível no aviso inicial e no menu de pausa, com efeito imediato: clientes e Mímicos viram genéricos.
3. O opt-out cobre: usar aparência de amigos, ter a própria aparência usada em Mímicos de outros, e a memória do parquinho.
4. **Aparência de terceiros** só em memória durante a sessão. Não gravar, não registrar `UserId` de amigos em log nem em telemetria.
5. **Amigos ausentes (D18):** aparência sempre distorcida, só amigos do próprio jogador, sem opt-out do amigo (risco aceito). Interruptor no servidor para desligar.
6. **Sem dependência de idade declarada.** Todos os usuários são tratados como possivelmente menores.
7. **Telemetria** sem dados pessoais.
8. Nada de reconhecimento de pessoas reais como gatilho de medo. O horror vem de a cópia estar errada.

## 13. Segurança infantil

- A memória do jogador tem proporção de avatar bloco, tom de estranheza e nunca é vítima ou monstro.
- Nenhuma figura de aparência infantil é ferida, perseguida ou ameaçada.
- A Nameless não tem comportamento especial contra avatares de aparência infantil.
- Sem chat próprio, sem convites externos, sem incentivo a contato com desconhecidos.
- Sem compra ou oferta durante momentos de susto (P9).
- Aviso inicial claro sobre o tipo de conteúdo.

## 14. Acessibilidade

- Aviso de fotossensibilidade no início.
- Limite de flashes: no máximo 3 por segundo, e a opção "reduzir flashes" desliga glitch e clarões.
- Volume reduzido para sons altos; legenda para sons importantes (sussurro, passos, aviso de proximidade).
- Opções: reduzir blur, reduzir movimento (desliga ruído e glitch), ocultar moldura VHS.
- Brilho ajustável, para a escuridão não virar tela preta no celular.
- HUD com contraste legível e estados que não dependem só de cor.
- Alvos de toque de pelo menos 44 por 44 px (referência a testar).
- Todo susto grave tem sinal prévio perceptível por mais de um canal (luz e som).

## 15. Riscos legais e de plataforma

1. **Copyright:** só o gênero. Sem layouts, nomes, logos, modelos ou músicas de jogos existentes. A imagem de referência do parquinho não é usada como asset.
2. **Personificar o Roblox:** nunca reproduzir mensagens de erro, banimento ou desconexão reais.
3. **Classificação:** questionário preenchido com o jogo pronto (P3).
4. **Aparência de terceiros:** D18, risco aceito. Revisar nas políticas vigentes e no checklist de publicação antes de publicar.
5. **Figura de aparência infantil num jogo de terror:** revisar no questionário e nas diretrizes vigentes antes de publicar.
6. **Moderação:** texto dinâmico passa pelo filtro de texto do Roblox; texto estático é revisado.
7. **Semelhança de personagens:** revisar a entidade secundária (6.2).

## 16. Limites de conteúdo

Fora do jogo: gore, sangue, nojo, partes de corpo realistas, nudez, drogas, simbologia religiosa ou de ódio real, referência a suicídio ou automutilação, alusão a abuso, desaparecimento de crianças reais. A cena de cadáver do estudo-fonte não é usada.

Sustos: intensidade 5 uma vez por partida (Noite 3). Som muito alto só com intensidade 4 ou mais, precedido por silêncio.

## 17. Requisitos técnicos

### 17.1 Arquitetura

- Rojo 7, Luau. `src/shared` (contratos), `src/server` (autoridade), `src/client` (apresentação).
- `default.project.json` é a fonte de verdade do Rojo. Renomear o projeto de `banzo` para `childhood`.
- Remotes só por `src/shared/Remotes.luau`. Nenhum segredo nem autoridade em `shared`.

### 17.2 Rede

Validar tipos, limites, estado, propriedade e frequência em todo remote vindo do cliente.

### 17.3 Desempenho

- Meta inicial: 30 FPS estáveis no perfil Baixo em celular de referência (P5); 60 FPS em desktop.
- Perfis de qualidade e troca automática (9.4).
- Orçamento de partes, luzes e partículas do parquinho a definir no protótipo.

### 17.4 Telemetria

Eventos agregados via serviço de analytics do Roblox, sem dados pessoais. Validar a API antes de implementar.

| Evento | Pergunta que responde |
|---|---|
| Aparição disparada e reação | A curva está calibrada? |
| Parada no parquinho (tempo) | O trajeto prende ou entedia? |
| Captura | O clímax é justo? |
| Abandono por noite | Onde o jogo perde gente? |
| Uso de opt-out e acessibilidade | As opções estão visíveis? |

## 18. Critérios de aceite

### 18.1 Visual e conforto

- [ ] Pilha VHS completa funciona nos três perfis de qualidade, sem alocar centenas de instâncias por frame.
- [ ] O blur sobe com a velocidade da câmera e volta a 0 em repouso.
- [ ] Opacidades e desfoques renderizam como especificado (conferido por captura de tela).
- [ ] Todo efeito tem opção de desligar.

### 18.2 Justiça dos sustos

- [ ] Nenhuma captura sem os dois sinais prévios (conferido por log de eventos).
- [ ] Entre dois sustos pontuais de intensidade 3 ou mais há sempre um vale de pelo menos 30 s (conferido por log de eventos).
- [ ] Aparições client-side não alteram nenhum estado de gameplay (teste: com o cliente alterado, o servidor ignora).

### 18.3 Privacidade

- [ ] Com opt-out ativo, nenhuma aparência de terceiro é carregada (conferido por log do servidor).
- [ ] Nenhum nome de usuário aparece em UI, nameplate, chat ou texto.
- [ ] Nenhum `UserId` de amigo gravado em log ou telemetria.

### 18.4 Acessibilidade

- [ ] Aviso de fotossensibilidade exibido antes da primeira noite.
- [ ] Nenhum efeito pisca mais de 3 vezes por segundo.
- [ ] Volume reduzido e legendas funcionam.

### 18.5 Co-op e fluxo

- [ ] Grupos de 2, 3 e 4 jogadores completam a Noite 1.
- [ ] Desconexão de um jogador no armário não trava o grupo.
- [ ] Armário só transiciona com todos os presentes dentro.
- [ ] Escolha dividida nos finais termina com saída narrativa após as tentativas.

### 18.6 Publicação

- [ ] Checklist de publicação executado, com evidência por item.
- [ ] Questionário de maturidade preenchido (P3).

---

## Anexo A: curva de medo por trecho

Minutos relativos ao início do bloco (aprox., a calibrar). "Int." é a intensidade de 0 a 5.

### A.1 Noite 1 (teto 2)

| Minuto | Estado | Evento | Int. | Vale ou consequência |
|---|---|---|---|---|
| 0:00 a 1:00 | Segurança | Ida pelo quarteirão; rua mais silenciosa que o normal | 0 | O próprio caminho |
| 1:00 a 1:30 | Suspeita | Parquinho: memória brinca, balanço se mexe contra o vento | 1 | Memória some se observada |
| 1:30 a 3:30 | Segurança | Primeiros pedidos; relógio atrasa e volta | 0 | Rotina |
| 3:30 a 5:00 | Suspeita | Cliente repete a mesma frase | 1 | Pedido certo restaura a calma |
| 5:00 a 6:30 | Confirmação | Cliente com sorriso longo demais (Mímico de relance) | 2 | Some ao ser olhado |
| 6:30 a 7:30 | Alívio | Fecha o caixa, luz quente | 0 | Vale principal |
| 7:30 a 9:00 | Dúvida | Relógio marca hora impossível; tela de sinal perdido por 2 s | 2 | Volta a funcionar sozinha |
| 9:00 a 10:30 | Suspeita | Volta: um brinquedo mudou de lugar no parquinho | 1 | Luz de casa ao fundo |

### A.2 Noite 2 (teto 3)

| Minuto | Estado | Evento | Int. | Vale ou consequência |
|---|---|---|---|---|
| 0:00 a 1:30 | Suspeita | Ida em névoa; memória repete o movimento e vira a cabeça quando não olhada | 2 | Some ao ser vista |
| 1:30 a 2:00 | Alívio | Chega à pizzaria, luz quente | 0 | Local seguro |
| 2:00 a 4:00 | Segurança instável | Pedidos bizarros em props | 1 | Pedido errado atrasa o forno |
| 4:00 a 5:30 | Confirmação | Três clientes dizem a mesma frase juntos; porta leva ao mesmo cômodo | 2 | Quebra visível, sem perigo |
| 5:30 a 6:00 | Ameaça | Silêncio; Nameless na janela (client-side, um jogador) | 3 | Some ao ser vista; quem viu perde o foco |
| 6:00 a 7:30 | Alívio | Cozinha iluminada, sem eventos | 1 | Vale obrigatório |
| 7:30 a 9:00 | Dúvida | Chat: só um jogador viu a entidade | 2 | Desconfiança leve no grupo |
| 9:00 a 10:30 | Ameaça | Volta no escuro; memórias dessincronizadas; Nameless ao fundo | 3 | Quem para para olhar atrasa o grupo |

### A.3 Noite 3 (teto 5)

| Minuto | Estado | Evento | Int. | Vale ou consequência |
|---|---|---|---|---|
| 0:00 a 1:30 | Dúvida | Parquinho vazio; balanços ainda se movem; estátua virou | 2 | Entrada na pizzaria |
| 1:30 a 3:00 | Segurança falsa | Pedidos ilegíveis; a fila some | 2 | Cozinha ainda iluminada |
| 3:00 a 3:30 | Suspeita | Silêncio total | 1 | Preparação |
| 3:30 a 4:30 | Ameaça | Luzes caem em etapas; Nameless visível a todos na janela | 4 | Luz de emergência no corredor |
| 4:30 a 6:00 | Ameaça (mesmo bloco) | Corrida cozinha, corredor; regra do olhar | 4 | Quem desvia o olhar perde posição |
| 6:00 a 6:30 | Alívio | Lâmpada acesa no meio do corredor | 2 | Vale fixo e curto |
| 6:30 a 8:00 | Consequência | Garagem: luz oscila, sussurro, aproximação; captura só depois | 5 | Armário aberto |
| 8:00 a 8:30 | Alívio | Todos entram no armário; teletransporte | 3 para 1 | Avança de fase |

### A.4 Instalação

| Minuto | Estado | Evento | Int. | Vale ou consequência |
|---|---|---|---|---|
| 0:00 a 2:00 | Segurança | Sala inicial, terminais | 0 | Luz fria, ar parado |
| 2:00 a 4:00 | Suspeita | Monitores mostram a sala com atraso | 1 | Terminal consertado |
| 4:00 a 6:00 | Confirmação | Nameless num monitor, onde ninguém está | 2 | A sala real está vazia |
| 6:00 a 7:00 | Alívio | Rota abre, luz acende | 0 | Vale |
| 7:00 a 9:00 | Dúvida | Um monitor mostra o grupo de costas | 3 | O monitor se apaga |
| 9:00 a 9:30 | Alívio | Ilha de luz, sem eventos | 1 | Vale de 30 s |
| 9:30 a 11:00 | Ameaça | Nameless patrulha quando ninguém olha a sala | 4 | Perde tempo quem desvia o olhar |
| 11:00 a 12:00 | Consequência | Elevador só parte com todos dentro | 3 | Elevador iluminado |

### A.5 Praça

| Minuto | Estado | Evento | Int. | Vale ou consequência |
|---|---|---|---|---|
| 0:00 a 2:00 | Segurança | Praça ensolarada, NPCs parados | 0 a 1 | Dia lavado |
| 2:00 a 4:00 | Suspeita | NPCs repetem o mesmo gesto | 1 | Gestos param ao ser olhados |
| 4:00 a 7:00 | Confirmação | Teste de gestos; Mímicos copiam com atraso | 2 | Errar um teste atrasa o grupo |
| 7:00 a 8:00 | Alívio | Grupo identifica um Mímico | 0 | Vale |
| 8:00 a 10:00 | Dúvida | Mímicos passam a imitar o grupo | 3 | Gesto errado denuncia |
| 10:00 a 10:30 | Alívio | Sombra da fonte, sem eventos | 1 | Vale de 30 s |
| 10:30 a 12:00 | Ameaça | Nameless no horizonte, cresce quando ninguém olha | 4 | Quem desvia o olhar perde posição |
| 12:00 a 13:00 | Consequência | Fonte seca, passagem abre | 2 | Passagem iluminada |

### A.6 Baseplate

| Minuto | Estado | Evento | Int. | Vale ou consequência |
|---|---|---|---|---|
| 0:00 a 1:00 | Segurança falsa | Só chão e céu | 0 | Espaço aberto |
| 1:00 a 2:30 | Suspeita | Silêncio absoluto, caminha até a porta | 1 | Porta visível |
| 2:30 a 3:30 | Dúvida | Cada jogador vê a própria memória ao lado da porta | 2 | Sem perigo |
| 3:30 a 4:00 | Ameaça | Nameless longe, parada, olhando | 3 | Some se olhada |
| 4:00 em diante | Consequência | Votação e cena do final escolhido | variável | Cena curta |
