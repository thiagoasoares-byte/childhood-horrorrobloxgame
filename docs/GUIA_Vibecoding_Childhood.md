# Guia de vibecoding: Childhood

Versão 0.1 · 2026-10-21 · Complementa `GDD_Childhood.md` e `ROADMAP_Childhood.md`.

> **O que foi verificado em 2026-10-21.** O MCP do Roblox Studio e as regras de DevEx e de monetização vêm das páginas oficiais do Roblox (links no fim). O link com o computador do autor respondeu, mas **não havia nenhum Studio aberto e o Blender não estava rodando** (o addon não respondia em `localhost:9876`). Não li a documentação do addon do Blender.

## 1. Arquitetura de trabalho: três faixas

| Faixa | Ferramenta | Faz | Não faz |
|---|---|---|---|
| Código | Rojo, arquivos `.luau` no git, Claude editando arquivos | Todos os scripts de `src/shared`, `src/server`, `src/client` | Mapa e props |
| Studio | MCP do Roblox Studio | Mapa, props, iluminação, UI em instâncias, playtest, console, captura de tela | Editar script que o Rojo gerencia |
| Blender | MCP do Blender | Modelos low-poly PSX, texturas pequenas, exportação | Subir o modelo para o Roblox (passo manual ou Open Cloud) |

**Regra de ouro:** um script tem **um dono**. Se está em `src/`, só se edita o arquivo, nunca por `multi_edit` no Studio, ou a próxima sincronização do Rojo apaga a mudança. O Studio fica com o que o Rojo não mapeia.

### 1.1 Mapa e modelos fora do git de código

O mapa construído no Studio fica no arquivo do place. Para versionar, exporte as partes como modelos `.rbxm` em `assets/models` e mantenha os fontes do Blender em `assets/blender`, como o `CLAUDE.md` já define.

### 1.2 Segurança do place

O cliente MCP pode ler e alterar o place aberto. Trabalhe num **place de desenvolvimento separado do publicado**, e não conecte clientes em que você não confia.

## 2. Preparação, passo a passo

1. **Roblox Studio:** atualizar. No Assistant, menu `...`, **Manage MCP Servers**, ligar **Enable Studio as MCP server**.
2. **Claude Desktop:** em Assistant Settings, MCP Servers, **Quick connect**, ligar Claude Desktop. A alternativa é colocar a entrada `Roblox_Studio` em `mcpServers` no JSON do cliente.
   - Windows: comando `cmd.exe`, argumentos `/c` e `%LOCALAPPDATA%\Roblox\mcp.bat`.
   - macOS: `/Applications/RobloxStudio.app/Contents/MacOS/StudioMCP`.
3. **Reiniciar** o Claude Desktop e o Studio. Conferir o indicador verde de clientes conectados em Manage MCP Servers.
4. **Blender:** abrir o Blender, ativar o addon do MCP e **iniciar o servidor** (porta 9876).
5. **Rojo:** `rokit install`, `rojo serve`, conectar pelo plugin do Studio. Renomear o projeto de `banzo` para `childhood` e criar `src/client`.
6. **Teste de fumaça**, nesta ordem:
   - listar os Studios (`list_roblox_studios`) e escolher o place de desenvolvimento;
   - ler o estado do Studio (`get_studio_state`);
   - no Blender, pedir o resumo dos objetos da cena;
   - criar um script "olá" por arquivo, ver o Rojo sincronizar, dar play e ler o console.

Se um passo falhar, não siga em frente: o diagnóstico fica mais caro quanto mais camadas existem.

## 3. Economia de tokens

### 3.1 Estrutura da conversa

- **Uma conversa por milestone.** Ao fechar, peça um `docs/STATUS.md` de até 20 linhas com o estado, as decisões e as pendências. A próxima conversa começa por ele.
- **Contexto fixo curto:** `CLAUDE.md` mais a seção do milestone no roadmap mais só as seções do GDD que o milestone toca (por exemplo, M1 usa 9, 14 e 17). Nunca "leia o repositório".
- **Plano antes do código:** pedir plano de até 5 passos, aprovar, implementar passo a passo.
- **Só diffs na resposta.** Arquivo inteiro na conversa custa duas vezes: na escrita e na releitura.

### 3.2 Uso das ferramentas

- **Código por arquivo, não por MCP.** Editar um arquivo é mais barato do que ler e escrever scripts dentro do Studio.
- **Construir em lote:** uma chamada de `execute_luau` que cria vários objetos custa menos que dezenas de chamadas pequenas.
- **Buscar antes de ler:** `search_game_tree` e `script_grep` no lugar de percorrer a árvore ou ler scripts inteiros.
- **Captura de tela só para verificação visual.** Imagem é a parte mais cara de uma resposta de ferramenta.
- **Console com filtro:** ler só os erros e avisos do que se acabou de testar.
- **Subagente de playtest** para testes longos, para o contexto principal não receber o ruído.
- **Skills sob demanda:** só o skill do domínio da tarefa (gui, lighting, audio, networking), nunca todos.

### 3.3 Modelo e plano

Use o modelo mais leve para implementação mecânica e reserve o mais forte para arquitetura e design. O plano gratuito tem limites de uso que um fluxo com muito vai-e-vem consome rápido, então estas táticas pesam mais nele. Para uso contínuo, um plano pago ou a API aumentam o limite.

## 4. Modelos de prompt

### 4.1 Abrir um milestone

```
Milestone M<N>. Leia só CLAUDE.md, a seção M<N> de docs/ROADMAP_Childhood.md e as seções <x, y, z> de docs/GDD_Childhood.md.
Proponha um plano de até 5 passos, com os módulos que mudam. Espere minha aprovação.
Depois implemente um passo por vez, rodando selene, stylua --check e rojo build ao fim de cada passo.
Termine com: arquivos alterados, validações, pendências e uma mensagem de commit em inglês.
```

### 4.2 Fechar um milestone

```
Confira os critérios de conclusão do M<N> no roadmap, um por um, com a evidência de cada (log, captura, teste).
Marque como NÃO VERIFICADO o que não puder provar. Escreva docs/STATUS.md (até 20 linhas).
```

### 4.3 Asset no Blender

```
Modele <objeto> em low-poly PSX para o Roblox: orçamento de triângulos <N, definido no protótipo>, textura de até 64x64 com paleta restrita, sem nenhum elemento de obra existente.
Salve o .blend em assets/blender, exporte o modelo, renderize uma miniatura e me diga o caminho. Não envie imagens grandes.
```

## 5. Do Blender ao Roblox

1. Modelar e exportar (formato aceito pelo importador do Studio).
2. Importar pelo Studio (Asset Manager) ou enviar por Open Cloud. Chaves de API ficam fora do repositório e do chat.
3. Usar o `MeshId` resultante na instância. O upload passa pela moderação do Roblox e pode ser recusado.
4. Conferir as licenças de qualquer ferramenta de IA usada para gerar arte.

## 6. Dinheiro no Roblox

### 6.1 Expectativa realista

Não há garantia de receita. A maior parte das experiências rende pouco, e o que move receita é **retenção e sessões em grupo**, não gráficos. O plano é lançar cedo, medir e iterar.

### 6.2 Fatos verificados (páginas oficiais, atualizadas em 2026-10-20)

- **DevEx:** mínimo de **30.000 Robux ganhos** para sacar, no máximo um saque por mês.
- **Taxa padrão:** 0,0038 USD por Robux ganho (114 USD por 30.000). Há uma taxa maior, 0,0054, para certos ganhos de compras feitas por jogadores dos EUA com 18 anos ou mais verificados.
- **Requisitos da conta:** 13 anos ou mais, e-mail verificado, conta no DevEx Portal e formulário W-8 para quem não é contribuinte dos EUA. Documento de identidade não é exigido para ser elegível.
- **Formas de monetizar uma experiência:** passes, produtos de desenvolvedor, **servidores privados** (mensalidade em Robux), assinaturas, acesso pago e anúncios imersivos.
- **Itens aleatórios pagos:** exigem transparência e controle por `PolicyService`. Descontos devem ser genuínos, sem escassez falsa, contagem regressiva inexata ou linguagem insistente com menores.
- **Não encontrado na página consultada:** menção a pagamentos por engajamento de Premium e o percentual da comissão do catálogo. Conferir antes de planejar em cima disso.

### 6.3 Estratégia para Childhood

| Decisão | Escolha | Por quê |
|---|---|---|
| Primeira publicação | **Episódio 1: Fase 1 completa (M1 a M4)** | Medir retenção antes de gastar nas fases 2 e 3. M5 e M6 viram atualizações |
| Monetização principal | **Servidores privados** | Co-op de 2 a 4 amigos é exatamente quem paga por servidor privado |
| Passes | Cosméticos: molduras e etiquetas da fita VHS, aparência da memória | Não afetam o jogo e combinam com a identidade |
| Apoio | Passe de apoio ao desenvolvedor | Baixo atrito, sem vantagem |
| Evitar | Pay-to-win, "pular noite", item aleatório pago, oferta durante susto, urgência falsa, acesso pago no início | Quebram o terror justo, atraem risco de moderação e matam descoberta |
| Funil | Fase 1 jogável sozinho (D21), com convite fácil para amigos | Jogo só de grupo morre com servidores vazios |

### 6.4 O que medir no Episódio 1

Retenção no dia 1 e no dia 7, duração da sessão, onde os jogadores abandonam (por noite), paradas no parquinho, capturas e uso de opt-out e de acessibilidade. As metas de retenção do skill do projeto (dia 1: 20% bom, 30% ótimo, 40% excelente) são referência interna, não verificada em fonte externa.

### 6.5 Riscos que afetam a receita

- **Moderação e classificação:** a aparência de terceiros (D18, risco aceito) e a figura de aparência infantil podem gerar ação da plataforma. O interruptor no servidor existe para isso.
- **Descoberta:** miniatura e ícone, e o nome do jogo (não usar marcas de terceiros).
- **Escopo:** adiar fases 2 e 3 é o que protege o prazo.

## Fontes

- [Conectar ao servidor MCP do Roblox Studio](https://create.roblox.com/docs/en-us/studio/mcp)
- [Developer Exchange](https://create.roblox.com/docs/en-us/production/monetization/developer-exchange.md)
- [Monetização de experiências](https://create.roblox.com/docs/en-us/production/monetization)
