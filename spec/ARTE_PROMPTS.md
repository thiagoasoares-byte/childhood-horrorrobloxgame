# Arte: nomes, monstro e prompts visuais

Este arquivo atualiza o GDD: o monstro principal deixa de ser o mascote da pizzaria e passa a ser BANZO, uma aparição fora do tema do mapa.

---

## 1. Nome do jogo (vocabulário: saudade, nostalgia, melancolia, banzo)

| Nome | Origem | Observação |
|---|---|---|
| **BANZO** | Saudade profunda, melancolia | Curto, forte, combina com o monstro. Nota: a palavra tem peso histórico (saudade de quem foi arrancado da terra natal), então vale tratá-la com respeito no marketing. |
| **SAUDADE.EXE** | Saudade + arquivo corrompido | Melhor equilíbrio entre BR e internacional. |
| **Melancolia 2012** | Melancolia + ano de ouro | Mais poético, menos "jogo de susto". |
| **Nostos** | Raiz grega de nostalgia | Ícone simples, sem tradução necessária. |
| **Banzo Baseplate** | Banzo + o chão do Roblox clássico | Tem a piada interna do baseplate. |
| **Saudade Não Fecha** | Frase de efeito | Combina com a tagline "o servidor nunca fechou". |

Recomendação: **BANZO** como título do jogo e **SAUDADE** como nome da primeira fase. A entidade também se chama BANZO, o que dá unidade: o monstro é a saudade que não passa.

### 1.1 Nomes das fases no mesmo vocabulário

1. Pizzaria Saudade
2. Complexo Melancolia
3. Praça Nostalgia
4. Ilha do Banzo
5. Baseplate Original

---

## 2. O monstro: BANZO

### 2.1 Conceito
Uma aparição de terror analógico que **não pertence a nenhum dos mapas**. Ele está "por cima" da realidade do servidor, como um erro de gravação com forma. Aparece na pizzaria, depois na fábrica, depois na praça, sempre como se tivesse sido colado ali.

### 2.2 Design (mesma família visual das referências, com assinatura própria)
Segue a linguagem do analog horror das imagens: silhueta preta chapada, corpo fino e alto, olhos de ponto branco, lâminas horizontais saindo da cabeça. Para ele ser **seu** e não uma cópia de um personagem existente, ele tem traços próprios:

- Altura de 3 a 4 vezes a de um avatar, com pescoço muito longo.
- Duas lâminas horizontais finas e retas no topo da cabeça (como asas de morcego achatadas).
- Dois olhos de ponto branco, sem pupila, sem boca. A boca só existe quando ele está a menos de 3 studs: uma linha vertical branca que se abre.
- Mãos longas demais, com 3 dedos.
- Um "timestamp" de VHS (03/11/2012) que treme ao redor dele, como se a imagem dele não coubesse na fita.
- Em tela, mesmo sob luz, a silhueta nunca mostra textura: é um buraco no cenário.

Evite acrescentar chapéu, capuz ou rosto pálido: essas são marcas de outros personagens da imagem de referência (Gerente e Casca no GDD).

### 2.3 Regras de gameplay
- **Noites 1 e 2:** aparições client-side. Parado, de pé, olhando. Some após 1,5 s de contato visual.
- **Noite 3:** invade o servidor e é visível a todos, mas na escuridão só se veem os dois pontos brancos. Cada flash de luz (lanterna, relâmpago de TV) revela a pose, **sempre mais perto**.
- Só se move quando ninguém olha para os olhos dele.
- Nunca mata sem aviso: dois flashes de proximidade, sussurro de áudio, depois o susto.

---

## 3. Prompts visuais por parte do mapa

Os prompts estão em inglês porque as IAs de imagem funcionam melhor assim. Cada um mostra **o assunto principal diretamente** (o objeto ou cômodo em foco), sem cenas atmosféricas genéricas.

Base de estilo, colar no fim de todos os prompts:

> `early 2010s blocky toy-brick low-poly look, flat shading, simple studs texture on floors, PS1 style low-resolution textures, 4:3 frame, VHS tape recording, scanlines, tracking noise, desaturated yellow tint, film grain`

Negative prompt comum:

> `photorealistic, smooth shading, high detail, logo, text, watermark, anime, cartoon mascot, famous character`

### 3.1 BANZO (a entidade)

3.1.1 **Turnaround (frente, perfil, costas)**
```
character turnaround sheet of a tall thin solid black humanoid silhouette, very long neck, two thin flat horizontal blades on top of the head, two small white dot eyes, no mouth, long arms with three fingers, plain light gray background, front side and back views, flat black shape, analog horror creature design
```
IA: **Midjourney** (consistência de estilo) ou **Flux** (via Replicate/ComfyUI) para mais controle.

3.1.2 **Close do rosto no escuro**
```
two small white dot eyes floating in complete darkness, faint outline of a flat black head with horizontal blades barely visible, extreme underexposure, VHS noise
```
IA: **Flux** ou **Stable Diffusion XL** (aceita bem negativos pesados).

3.1.3 **Boca aberta (jumpscare)**
```
close up of a flat black head with two white dot eyes and a thin vertical white mouth opening, stretched too tall, motion blur smear, VHS glitch distortion, tracking error bars
```
IA: **Midjourney**. Depois anime os frames no **Runway** ou **Kling**.

3.1.4 **Silhueta na janela (aparição client-side)**
```
a tall black silhouette standing perfectly still outside a window at night, only two white dot eyes visible, the rest of the figure almost invisible, a blocky restaurant interior in the foreground, VHS security camera footage
```
IA: **Flux** com ControlNet (profundidade) se quiser encaixar na sua cena real.

### 3.2 Pizzaria Saudade

3.2.1 **Fachada**
```
front exterior of a small blocky pizzeria building, simple brick and plaster walls with a red awning, flat roof, a wide front window, empty street, blocky toy-brick low-poly style, daylight but washed out
```
IA: **Midjourney** ou **Leonardo**. Depois reconstrua no Studio como referência, não copie a imagem como textura.

3.2.2 **Balcão da frente**
```
interior counter of a small blocky pizzeria, long counter with a register and an order board on the wall, a line of simple blocky customers with blank pale faces, fluorescent lights, VHS tape look
```
IA: **Flux** (boa para composição interior).

3.2.3 **Cozinha**
```
cramped blocky pizzeria kitchen, dough table, sauce station, topping bins, brick oven glowing orange, low ceiling, tight space, one flickering light, PS1 style
```
IA: **Midjourney**.

3.2.4 **Corredor estreito**
```
narrow blocky corridor with low ceiling, a single flickering ceiling light, concrete walls, a door at the far end, claustrophobic, nearly black, PS1 style, VHS noise
```
IA: **Stable Diffusion XL + LoRA de PS1** (CivitAI) para o look de textura pequena.

3.2.5 **Depósito**
```
small blocky storage room, shelves with dusty boxes, one box slightly open with a faint wet red glow, chair placed on the ceiling, uncanny wrongness, VHS tape
```
IA: **Midjourney**.

3.2.6 **Garagem e armário**
```
blocky garage with a concrete floor, a single metal locker standing alone in the far wall, slightly open with total darkness inside, one bare bulb, low ceiling, VHS tape look
```
IA: **Flux**.

3.2.7 **Cliente Mímico (noite 2)**
```
blocky toy-brick style customer character standing at a pizzeria counter, face completely blank and pale, head tilted slightly too far, wide thin smile appearing only in shadow, wrong proportions, VHS tape look
```
IA: **Midjourney**. Para o modelo final, use **Blender**.

### 3.3 Telas falsas (design próprio, nunca o diálogo do Roblox)

3.3.1 **Sinal perdido**
```
a retro CRT television screen showing the words SINAL PERDIDO in white blocky letters on a blue-gray screen, horizontal tracking distortion, static noise, 4:3
```
IA: **Ideogram** (melhor para texto legível dentro de imagem).

3.3.2 **Fita travada**
```
paused VHS tape frame with a thick horizontal glitch band, REC text in red in the top left, a timestamp in the bottom right, tape smear
```
IA: **Ideogram** ou **Midjourney**.

### 3.4 Fases seguintes

3.4.1 **Complexo Melancolia (corredor com monitores)**
```
claustrophobic blocky facility corridor, rows of old computer monitors showing black and white security camera views, a tall black silhouette visible on only one monitor, flickering lights, PS1 style, VHS
```
IA: **Flux**.

3.4.2 **Praça Nostalgia**
```
blocky town plaza with a fountain, identical bland blocky characters standing in place, all with blank faces, bright washed out sunny daylight, one character is slightly taller than the rest, VHS tape look
```
IA: **Midjourney**.

3.4.3 **Baseplate Original**
```
a huge flat gray baseplate with studs texture stretching to the horizon under a flat pale sky, a single plain wooden door standing alone in the middle, VHS tape look
```
IA: **Flux** ou **Midjourney**.

---

## 4. Ferramentas sugeridas por tipo de trabalho

| Trabalho | Ferramenta | Por quê |
|---|---|---|
| Concept art de cenário e entidade | **Midjourney** | Melhor consistência estética. |
| Controle fino e LoRA de PS1 | **Stable Diffusion XL / Flux** (ComfyUI, Replicate) | Aceita LoRAs e ControlNet. |
| Telas com texto | **Ideogram** | Escreve texto legível. |
| Animar frames (VHS, jumpscare) | **Runway**, **Kling** ou **Pika** | Imagem para vídeo curto. |
| Modelos 3D iniciais | **Meshy** ou **Tripo**, depois **Blender** | Gera malha base. Reduza para PSX no Blender (Decimate + texturas 64x64). |
| Texturas pixeladas | **Blender** ou **Aseprite** | Reduzir resolução e paleta manualmente. |
| Sons e vozes | **ElevenLabs** (voz e efeitos), **Suno/Udio** (música distorcida) | Gere sussurros, ruído e música de loja. |

### 4.1 Fluxo recomendado
1. Gerar concept art (Midjourney/Flux).
2. Escolher uma imagem por parte do mapa como **referência**.
3. Construir no Roblox Studio com blocos e texturas próprias.
4. Gerar o áudio e as telas falsas.
5. Aplicar o VHS no cliente (ver `diagramas_visual_v2.html`).

### 4.2 Aviso de licença
- Confira os termos de uso comercial de cada IA antes de publicar o jogo (Midjourney e Meshy variam por plano).
- Não use as imagens geradas diretamente como asset final sem revisar: a IA pode reproduzir traços de personagens existentes. Se uma imagem gerada lembrar um personagem conhecido, descarte.
- Não gere modelos baseados nas imagens de referência que você enviou (elas contêm personagens de terceiros); use só o prompt acima.
