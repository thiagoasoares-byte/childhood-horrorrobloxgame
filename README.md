# SAUDADE.EXE

Jogo cooperativo de terror analógico para Roblox, com estética de Roblox
clássico, VHS, PSX e vale da estranheza.

> **O servidor nunca fechou. Você só nunca saiu.**

## Sobre o jogo

De 2 a 4 jogadores recebem um convite para um servidor antigo, preservado
desde 2012. Cada fase é uma memória de um gênero de jogo clássico,
reconstruída pelo Anfitrião, uma entidade que se alimenta de nostalgia.

A primeira fase acontece na **Pizzaria Saudade**. Os jogadores precisam
trabalhar juntos para preparar pedidos enquanto o ambiente, os clientes e o
próprio servidor começam a ficar cada vez mais errados.

### Pilares

- Conforto que se transforma gradualmente em desconforto.
- Cooperação, comunicação e confiança entre os jogadores.
- Aparições e eventos que são mais perturbadores quando apenas sugeridos.
- Nostalgia usada como uma armadilha, não apenas como decoração.

## Estado atual

O projeto está em desenvolvimento e usa o roadmap definido em
[`spec/MODULOS_IMPLEMENTACAO.md`](./spec/MODULOS_IMPLEMENTACAO.md):

1. Protótipo visual em primeira pessoa e sistema de Medo.
2. Loop da Pizzaria Saudade, noite 1.
3. Aparições client-side.
4. Noites 2 e 3, blackout e fuga para o armário.
5. Complexo Melancolia.
6. Praça Nostalgia e final cooperativo.

## Estrutura do projeto

```text
.
├── src/
│   ├── client/    # Câmera, HUD, efeitos VHS e renderização local
│   ├── server/    # Medo, pedidos, pizzaria, noites e aparições
│   └── shared/    # Remotes e configurações compartilhadas
├── spec/          # GDD, roadmap técnico e referências de arte
├── script/        # Scripts auxiliares
├── aftman.toml    # Ferramentas gerenciadas pelo Aftman
└── default.project.json
```

## Requisitos

- Roblox Studio
- [Rojo 7.7.1](https://github.com/rojo-rbx/rojo)
- [Aftman](https://github.com/LPGhatguy/aftman) (recomendado para instalar o
  Rojo na versão do projeto)

## Como executar

1. Clone ou abra este repositório.
2. Instale as ferramentas do projeto com o Aftman:

   ```powershell
   aftman install
   ```

3. Inicie o servidor do Rojo na raiz do projeto:

   ```powershell
   rojo serve default.project.json
   ```

4. Abra o Roblox Studio e conecte ao servidor Rojo pelo plugin do Rojo.
5. Inicie um playtest no Studio.

O arquivo `default.project.json` monta `src/shared`, `src/server` e
`src/client` nas respectivas áreas do DataModel do Roblox. O modo de câmera
em primeira pessoa e as configurações iniciais de iluminação também são
definidos nesse arquivo.

## Convenções

- Use Luau e mantenha o código separado entre `client`, `server` e `shared`.
- Validações de gameplay devem permanecer no servidor.
- Use `RemoteEvent` apenas através do módulo compartilhado de remotes.
- Preserve a identidade visual original do projeto; não copie mapas, logos,
  músicas ou modelos de experiências existentes.
- Evite gore explícito: o terror deve ser construído por atmosfera, som,
  comportamento estranho e aparições.

## Referências

- [`spec/GDD_Saudade.md`](./spec/GDD_Saudade.md): conceito, história e loop
  de jogo.
- [`spec/MODULOS_IMPLEMENTACAO.md`](./spec/MODULOS_IMPLEMENTACAO.md): módulos,
  APIs e critérios de aceite.
- [`spec/ARTE_PROMPTS.md`](./spec/ARTE_PROMPTS.md): referências para direção
  de arte.
- [`default.project.json`](./default.project.json): configuração do Rojo.

## Avisos de conteúdo

O jogo contém terror psicológico, atmosfera de suspense, efeitos VHS,
escurecimento da tela e sons potencialmente altos. A versão publicada deve
exibir avisos apropriados e oferecer opções para reduzir efeitos visuais e
sons intensos quando possível.
# childhood-horrorrobloxgame
