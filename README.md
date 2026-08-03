# cursor-config

Configuração de agentes de IA para o Cursor — rules de clean code, exigências de
teste e segurança, e um agente de code review rigoroso que percorre o diff hunk
por hunk comentando como um revisor humano.

Funciona também no Claude Code e no Codex: os agentes usam o mesmo formato de
frontmatter e o `AGENTS.md` é lido pelos três.

## Começando (5 minutos)

Para quem está chegando agora:

1. **Clone e instale o global.** Um clone em pasta permanente, `./install.sh global`,
   e reinicie o Cursor. Isso dá acesso a `/code-review` e aos agentes `@` em
   qualquer projeto — sem mexer em nenhum repositório de código.
2. **Use.** Abra um projeto, faça sua alteração e digite `/code-review` no chat.
   Ele revisa o diff da sua branch contra a base. Nada é editado: a saída é a
   revisão.
3. **Quando quiser as rules valendo num projeto**, rode
   `./install.sh project <caminho>` na raiz dele e **commite** o `.cursor/rules/`
   junto com o `AGENTS.md`. A partir daí, toda a equipe daquele repo herda as
   mesmas regras, tenha instalado este aqui ou não.

Os passos 1 e 3 são independentes. O passo 1 é pessoal (fica na sua `$HOME`); o
passo 3 é do time (fica versionado no repositório do projeto). Um não depende do
outro.

O que **não** fazer: rodar `install.sh project` num repo do time e commitar sem
combinar antes — as rules mudam o comportamento do agente de todo mundo que abrir
aquele projeto no Cursor. Trate como mudança de convenção: abra PR e explique.

## Conteúdo

```
AGENTS.md                          instruções base (copiar para a raiz do projeto)
install.sh                         instalação global e por projeto
.cursor/
  agents/
    code-reviewer.md               revisão rigorosa do diff, hunk por hunk (readonly)
    test-auditor.md                cobertura e qualidade dos testes (readonly)
    security-reviewer.md           injeção, authz, segredos, deps, config (readonly)
    implementer.md                 implementação de mudanças
  rules/
    00-core.mdc                    fluxo de trabalho e verificação      [always]
    10-clean-code.mdc              nomes, funções, estado, erros        [always]
    20-testing.mdc                 quando testar, o que cobrir          [always]
    30-security.mdc                exigências de segurança              [always]
    typescript.mdc                 TS / Node / React        [glob: *.ts,*.tsx,*.js]
    python.mdc                     Python                        [glob: *.py]
  skills/code-review/SKILL.md      workflow completo de revisão
  commands/review.md               atalho /review
  mcp.json.example                 modelo de configuração de MCP
```

## Instalação

Agentes, skills e commands são globais (valem em todos os projetos). Rules são
por projeto — o Cursor só lê `.cursor/rules/` dentro do repositório aberto.

```bash
git clone git@github.com:iannak/cursor-config.git
cd cursor-config

./install.sh global                    # symlink agents/skills/commands em ~/.cursor
./install.sh project ~/caminho/do/repo # copia rules + AGENTS.md para o projeto
./install.sh status                    # o que está instalado
```

Clone em um diretório permanente — o modo `global` cria symlinks para cá, então
mover ou apagar a pasta quebra a instalação.

O symlink global faz com que `git pull` neste repo já atualize os agentes. As
rules são **copiadas** (não linkadas) porque cada projeto costuma ajustá-las.
Nada é sobrescrito sem `--force`.

MCP: copie `.cursor/mcp.json.example` para `~/.cursor/mcp.json` e preencha via
variáveis de ambiente. O `.gitignore` já bloqueia o `mcp.json` real.

## Uso no Cursor

| Como | O que faz |
|---|---|
| `/review` | revisão completa do diff da branch atual |
| `@code-reviewer revisa o PR #42` | invoca o revisor direto |
| `@test-auditor` | só auditoria de testes |
| `@security-reviewer` | só segurança |

Os agentes de revisão são `readonly: true`: eles comentam e sugerem código, mas
não editam arquivos. Quem aplica é você ou o `implementer`.

## Como é a revisão

O `code-reviewer` não emite parecer genérico. O fluxo é:

1. Coleta o diff (`merge-base`) e a intenção da mudança (commits, descrição do PR).
2. Lê os arquivos alterados **por inteiro** e os call sites do que mudou de contrato.
3. Percorre **hunk por hunk**, aplicando sete perguntas: correção, falha, segurança,
   teste, clareza, camada e custo futuro.
4. Comenta ancorado em `arquivo:linha`, com citação do trecho, o impacto concreto
   e o código sugerido — severidade 🔴 Blocker · 🟠 Major · 🟡 Minor · 🔵 Nit ·
   💭 Pergunta · 👏 Elogio.
5. Fecha com resumo, contagem por severidade, situação de teste e de segurança e o
   veredito, mais a lista do que é obrigatório para desbloquear.

Pontos em que ele é intransigente: lógica de negócio sem teste é Blocker; bug
corrigido sem teste que falhe antes do fix é Blocker; achado de segurança com
vetor concreto é Blocker. Em contrapartida, ele não comenta o que o linter já
resolve, não repete o mesmo nit em oito lugares, não transforma problema
pré-existente fora do diff em bloqueio e não infla a revisão para parecer
diligente.

O idioma da revisão segue o idioma predominante do repositório.

## Manter atualizado

```bash
cd cursor-config && git pull
```

Agentes, skills e commands atualizam sozinhos — são symlinks. **Rules não**: elas
foram copiadas para dentro de cada projeto. Depois do `pull`, rode de novo em
cada projeto que deva acompanhar:

```bash
./install.sh project ~/caminho/do/repo          # traz só as rules que faltam
./install.sh project ~/caminho/do/repo --force  # sobrescreve as locais
```

Sem `--force`, o que já existe no projeto é preservado — ajuste local nunca é
perdido por acidente.

## Adaptar

- Nova linguagem: crie `.cursor/rules/<lang>.mdc` com `globs:` no frontmatter.
- Regra específica de um projeto: mantenha no `.cursor/rules/` do próprio projeto
  e deixe este repo só com o que é transversal.
- Cursor ignora rules com extensão `.md` — dentro de `.cursor/rules/` tem que ser
  `.mdc`.

## Problemas comuns

| Sintoma | Causa provável |
|---|---|
| `/code-review` não aparece | `./install.sh global` não foi rodado, ou o Cursor não foi reiniciado depois |
| `@code-reviewer` não existe | mesma coisa — os agentes vivem em `~/.cursor/agents/` |
| As rules não são aplicadas | não estão no projeto aberto: rode `./install.sh project .` na raiz dele |
| Uma rule é ignorada | extensão `.md` em vez de `.mdc`, ou frontmatter mal formado |
| A revisão sai em inglês num repo em português | o agente segue o idioma predominante do repo; se commits e código estão em inglês, ele segue isso |
| O revisor tenta editar arquivos | ele é `readonly: true`; se editou, o frontmatter foi alterado localmente |
| `install.sh status` mostra "não é symlink" | havia um `~/.cursor/agents` anterior; use `--force` (o antigo vira `.bak`) |

## Contribuir

Regra que vale para todo mundo entra aqui; regra que vale para um projeto fica
no `.cursor/rules/` daquele projeto. Veja `CONTRIBUTING.md` para o formato e o
fluxo de PR.
