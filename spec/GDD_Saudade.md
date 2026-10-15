# GDD: Jogo de Terror Analógico para Roblox (título de trabalho: SAUDADE.EXE)

Co-op de 2 a 4 jogadores. Estética Roblox clássico (2010-2014) corrompida por VHS, PSX e vale da estranheza.

---

## 1. Nome do jogo

Todos remetem a "nostalgia" sem usar a marca Roblox. Evitar "Roblox", "Classic" ou "Bloxy" no título (marca registrada).

### 1.1 Top 3 recomendados

| Nome | Por quê |
|---|---|
| **SAUDADE.EXE** | "Saudade" é a nostalgia em português, soa como arquivo corrompido, funciona em BR e fora. |
| **NOSTOS** | Raiz grega de "nostalgia" (nostos = retorno ao lar + algos = dor). Curto, sinistro, ótimo ícone. |
| **Fita 2012** | Remete direto à fita VHS e ao ano de ouro. Combina com a mecânica de "gravação". |

### 1.2 Outras opções

- Baseplate Memories
- Welcome Back (Nostalgia)
- Studs & Static
- Volta ao Bloco
- Nostalgia Tape 03
- 2012 Nunca Fechou
- Servidor Saudade
- Algos (a dor do retorno)

### 1.3 Tagline sugerida

> "O servidor nunca fechou. Você só nunca saiu."

---

## 2. Conceito e premissa

Os jogadores recebem um convite para um servidor antigo, preservado desde 2012 e nunca desligado. Cada fase é uma "memória" de um jogo clássico, reconstruída pelo **Anfitrião**, uma entidade que se alimenta de nostalgia. Ele usa os avatares dos amigos dos jogadores como "clientes", "NPCs" e "moradores" para que ninguém queira ir embora.

Tema central: nostalgia como armadilha. Quanto mais confortável o lugar, mais perturbador o detalhe errado.

### 2.1 Pilares

1. **Conforto → desconforto.** Toda fase começa familiar e acaba errada.
2. **Você nunca está sozinho, e nunca sabe se é um jogador de verdade.**
3. **O que você não vê é pior.** Escuridão e aparições que somem ao serem vistas.
4. **Co-op solidário.** Quase tudo exige comunicação e confiança. Os Mímicos atacam essa confiança.

---

## 3. Estrutura da história

### 3.1 Prólogo: a fita
Tela de "gravação encontrada" (REC, data 03/11/2012). Aviso de fotossensibilidade e som alto. Os jogadores entram no lobby como avatares de baseplate.

### 3.2 Fase 1: Pizzaria Saudade (3 noites)
Ver seção 4.

### 3.3 Fase 2 em diante
Ver seção 5.

### 3.4 Final
Os jogadores chegam ao **Baseplate Original**, o primeiro spawn. Há uma porta de saída e um botão "Continuar jogando". Todos precisam escolher ao mesmo tempo.

- **Final A, Sair:** todos escolhem a porta. A tela de "desconectado" aparece (estilo original do jogo, nunca o do sistema real). Cena final: o servidor segue aberto e um avatar com o nome de um dos jogadores continua jogando.
- **Final B, Ficar:** os jogadores viram os novos "clientes" da pizzaria. O loop recomeça com os avatares deles.
- **Final C (secreto):** se ninguém foi atacado por Mímico, os jogadores desligam o servidor manualmente no console da sala de fitas.

---

## 4. Fase 1: Pizzaria Saudade (minigame de pizza)

Inspiração: Work at a Pizza Place. **Não copiar:** layout, nomes, logo, modelos, músicas, cores exatas do prédio. Mantém só o conceito genérico de "pizzaria de blocos com cozinha e balcão".

### 4.1 Loop de jogo
1. Cliente chega ao balcão da frente com um pedido.
2. Um jogador lê o pedido (quadro), outro prepara, outro entrega.
3. Receita: massa → molho → ingredientes → forno (timer) → caixa → balcão.
4. Pedidos certos reduzem o "Medo"; pedidos errados ou atrasados aumentam.
5. Ao fechar a noite, o gerente "conta" o caixa (tela de resumo VHS).

### 4.2 Clientes = amigos do jogador
Usar o avatar de amigos do host (`Players:GetFriendsAsync`) para vestir NPCs via `HumanoidDescription`. Recomendações de segurança e boa convivência:

- Opção nas configurações: "Usar avatares de amigos" (ligado por padrão, com opt-out).
- Mostrar apenas a aparência, nunca o nome de usuário.
- O cliente "perturbador" nunca é mostrado machucado ou morto. É sempre **uma cópia errada** (rosto em branco, proporção estranha). Isso evita assédio e problemas de moderação.

### 4.3 Progressão das noites

| Noite | Tom | Pedidos | Eventos |
|---|---|---|---|
| **1** | Quase normal | Pizza normal, mas o relógio anda para trás às vezes | Um cliente repete a mesma frase. Uma luz pisca. Um Mímico de relance. |
| **2** | Uncanny | "Pizza de carne especial", "olho extra", ingredientes que vêm de uma caixa que ninguém abastece | Tela de internet falha falsa, jogador falso no servidor (Mímico), Antena na janela, sons altos |
| **3** | Terror | Pedidos em texto corrompido, clientes sem rosto | BANZO atravessa a janela da frente, as luzes caem, todos correm até o armário da garagem |

### 4.4 Pedidos estranhos (estilo, não gore)
Os ingredientes bizarros são props estilizados (gelatina vermelha, esferas brancas, massa que se mexe levemente). Textos como "carne de ontem", "olhos, bem abertos", "o de sempre (você sabe)". Isso mantém a sensação "maior de idade" sem sangue explícito, o que ajuda na classificação do Roblox.

### 4.5 Clímax da noite 3
1. Os pedidos param de fazer sentido e a fila na frente da pizzaria some.
2. A luz corta. Escuridão forte. Só o brilho das telas.
3. BANZO (entidade que não pertence à pizzaria) entra pela janela da frente. Só se veem dois pontos brancos no escuro.
4. Os jogadores precisam atravessar cozinha → corredor → garagem (claustrofóbico) sem olhar de frente para ele.
5. O armário da garagem exige que **todos** entrem (mecânica co-op). O teleporte leva à fase 2.

---

## 5. Próximas fases (sugestões)

Todas as fases usam **layout inspirado no gênero**, não o mapa real, e nomes originais.

| # | Fase | Inspiração (gênero) | Terror analógico | Mecânica principal |
|---|---|---|---|---|
| 2 | **Complexo Beta** | Flee the Facility (fuga de instalação) | Corredores com computadores que mostram câmeras de segurança com coisas que não estão lá | Hackear terminais enquanto uma entidade patrulha |
| 3 | **Praça Hangout** | MeepCity (cidade social) | Praça ensolarada com NPCs parados e "jogadores" que repetem o mesmo emote | Descobrir quem é Mímico e quem é jogador real |
| 4 | **Ilha das Frutas Murchas** | Blox Fruits (ilhas e barcos) | Mar de névoa com ilhas vazias, uma frutinha que ninguém deveria pegar | Navegar de barco, ouvir antes de ver |
| 5 | **Torre Infinita** | Obbys/Tower of Hell (obby) | Plataformas que somem, voz no áudio | Plataforma cooperativa com timing |
| 6 | **Casa Suburbana** | Welcome to Bloxburg / Brookhaven (casas) | Casa familiar com cômodos que não existem na planta | Procurar objetos de infância |
| 7 | **Sobrevivência Natural** | Natural Disaster Survival | Desastres anunciados por um locutor com voz distorcida | Sobreviver e se esconder |
| 8 | **Prisão de Blocos** | Jailbreak / Prison Life | Cela com câmera que mostra os jogadores de frente | Fuga em cadeia |
| 9 | **Baseplate Original** | O primeiro spawn | Só o chão, o céu e uma porta | Final e escolha |

### 5.1 Sugestão de ordem para o MVP
1. Pizzaria (3 noites)
2. Complexo Beta
3. Praça Hangout
4. Baseplate Original (final)

As fases 4 a 8 ficam como expansão.

---

## 6. Entidades (originais, inspiradas na estética analog horror)

Nenhuma replica personagens existentes. As silhuetas das referências servem só como **tom** (figuras alongadas, olhos de ponto, rostos pálidos).

| Entidade | Descrição | Comportamento |
|---|---|---|
| **Antena** | Silhueta preta e alta, cabeça com duas lâminas horizontais, olhos de ponto branco | Aparece client-side em cantos e janelas. Some ao ser olhada de frente por 1,5 s. |
| **Mímico** | Avatar de jogador com proporções erradas, sorriso largo, cabeça levemente inclinada | Anda entre os jogadores reais, copia emotes com atraso. Tocar nele causa susto e aumenta o Medo. |
| **Casca** | Figura encapuzada, boca deslocada, grito agudo | Perseguição curta na noite 3. Só se move quando ninguém olha. |
| **O Gerente** | Chapéu de aba larga com espinhos, rosto pálido, pescoço fino | Observa de longe da cozinha, nunca se aproxima. |
| **BANZO** | Entidade analog horror fora do tema do mapa: silhueta preta muito alta, membros finos, duas lâminas horizontais no lugar das orelhas, olhos de ponto branco. Ver ARTE_PROMPTS.md | Aparece client-side nas noites 1 e 2 (some ao ser visto). Na noite 3 invade o servidor, visível a todos, mas só como dois pontos no escuro. |
| **Fita** | Presença que só aparece nas telas, como um artefato de VHS | Dá pistas falsas e verdadeiras. |
| **O Anfitrião** | Nunca visto. Só voz e texto | Narra e comenta o que os jogadores fazem. |

### 6.1 Regras das aparições client-sided
- Servidor decide **quando** (`FireClient` para 1 jogador), cliente renderiza.
- Cooldown mínimo de 45 s por jogador, máximo de 2 aparições ao mesmo tempo no servidor.
- Some quando o centro da tela cruza a entidade por 1,5 s (raycast da câmera).
- Nunca dano direto. Só susto, som e aumento do Medo.

---

## 7. Especificações de design

### 7.1 Câmera e interface
- Primeira pessoa travada, crosshair de ponto (4 px, branco 70% de opacidade).
- Soft blur ao mover a câmera (BlurEffect proporcional à velocidade angular, máx. 6).
- HUD mínimo: Medo (barra discreta), pedido atual, lista de jogadores.

### 7.2 Filtro VHS
Camadas de overlay (ScreenGui): scanlines, ruído animado, vinheta, aberração cromática falsa (duas camadas deslocadas) e tracking glitch ocasional. Mais `ColorCorrection` dessaturado e granulado.

### 7.3 Estética PSX
Meshes de baixa contagem de polígonos, texturas pequenas sem filtro, luz sem sombras suaves, névoa próxima, jitter de vértice simulado nas entidades (animação em 12 fps).

### 7.4 Escuridão e claustrofobia
- Lighting em `Compatibility`/`ShadowMap`, `Ambient` quase preto, `FogEnd` curto.
- Corredores com 3 a 4 studs de largura, tetos baixos.
- Lanterna com bateria limitada (1 por jogador).

### 7.5 Áudio
- Sons muito altos como **momentos raros e anunciados por silêncio** (4 a 8 s antes).
- Aviso inicial e **controle de volume** para jumpscares (opção "Reduzido").
- Camadas: ambiente (zumbido de VHS), música de loja distorcida, vozes ao contrário.

### 7.6 Vale da estranheza
- Jogadores falsos (Mímicos) com nomes "quase certos", com tag `Player1234`.
- Telas de falha de internet falsas **com visual próprio** (nunca o diálogo real de desconexão do Roblox).
- Objetos fora do lugar: cadeira no teto, relógio girando ao contrário, porta que leva ao mesmo cômodo.

---

## 8. Riscos legais e de plataforma

1. **Copyright:** layouts, nomes, logos, músicas e modelos dos jogos de referência não podem ser usados. Só o gênero e a ideia geral. Personagens com cara de mascotes conhecidos (ratos de desenho antigo, etc.) devem ser evitados. Todos os assets devem ser originais ou com licença.
2. **Personificar o Roblox:** nada de falsos "erro 277", "você foi banido" ou telas de sistema reais. Isso viola os termos e pode derrubar o jogo.
3. **Classificação etária:** preencher o questionário de maturidade corretamente. Conteúdo: violência fantasiosa, temas perturbadores, sustos intensos. Sem sangue realista.
4. **Avatares de amigos:** opt-out, sem nomes de usuário, sem mostrar amigos sofrendo dano.
5. **Fotossensibilidade e volume:** aviso no início e opção de reduzir flashes e sons.
6. **Moderação:** textos de pedidos e vozes passam por filtro (`TextService`) quando forem digitados ou dinâmicos.

---

## 9. Roadmap resumido

1. Protótipo técnico (câmera, blur, VHS, crosshair)
2. Pizzaria noite 1 (loop de pizza)
3. Sistema de Medo e aparições client-side
4. Noites 2 e 3 + armário e teleporte
5. Fase 2 (Complexo Beta)
6. Polimento de áudio e VHS
7. Playtest com 2 a 4 jogadores
8. Fases 3 e final
