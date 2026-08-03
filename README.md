# cursor-config

Configuração de agentes de IA para o Cursor — rules de clean code, exigências de
teste e segurança, e um agente de code review rigoroso que percorre o diff hunk
por hunk comentando como um revisor humano.

Funciona também no Claude Code e no Codex: os agentes usam o mesmo formato de
frontmatter e o `AGENTS.md` é lido pelos três.

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
git clone git@github.com:iannak/cursor-config.git ~/workspace/github/project-pessoal/cursor-config
cd ~/workspace/github/project-pessoal/cursor-config

./install.sh global                    # symlink agents/skills/commands em ~/.cursor
./install.sh project ~/caminho/do/repo # copia rules + AGENTS.md para o projeto
./install.sh status                    # o que está instalado
```

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

## Adaptar

- Nova linguagem: crie `.cursor/rules/<lang>.mdc` com `globs:` no frontmatter.
- Regra específica de um projeto: mantenha no `.cursor/rules/` do próprio projeto
  e deixe este repo só com o que é transversal.
- Cursor ignora rules com extensão `.md` — dentro de `.cursor/rules/` tem que ser
  `.mdc`.
