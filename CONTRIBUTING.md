# Contribuindo

Este repositório define como os agentes de IA se comportam no trabalho de todo
mundo. Mudança aqui muda a revisão que o time recebe — o padrão de cuidado é o
mesmo de código de produção.

## O que entra aqui e o que não entra

| Entra | Não entra |
|---|---|
| Regra que vale para qualquer projeto do time | Regra específica de um projeto — vai no `.cursor/rules/` dele |
| Exigência de qualidade que já é consenso | Preferência pessoal de estilo ainda não discutida |
| Linguagem nova que o time passou a usar | Framework que uma pessoa está experimentando |
| Correção de regra que gera falso positivo | Regra que o linter já cobre |

Se o linter, o formatador ou o type checker já resolvem, **não vire regra**. Toda
regra redundante gasta contexto do agente e produz comentário de review inútil.

## Formato

**Rules** — `.cursor/rules/*.mdc`, sempre com frontmatter:

```markdown
---
description: Uma linha dizendo quando esta regra é relevante.
globs: **/*.ts,**/*.tsx      # opcional: ativa só nesses arquivos
alwaysApply: false           # true = entra em toda conversa
---
```

- `alwaysApply: true` só para o que vale em 100% dos casos. Hoje são quatro
  arquivos; cada novo custa contexto em toda interação.
- Regra de linguagem usa `globs` e `alwaysApply: false`.
- Extensão tem que ser `.mdc` — o Cursor ignora `.md` dentro de `rules/`.
- Máximo de 500 linhas por arquivo. Passou disso, divida.
- Escreva imperativo e concreto: "sem `any`; use `unknown` e estreite" em vez de
  "prefira tipagem forte".

**Agentes** — `.cursor/agents/*.md`:

```markdown
---
name: nome-do-agente
description: Frase curta — é isso que o modelo lê para decidir quando acionar.
model: inherit
readonly: true        # true para agentes de análise; eles não devem editar
is_background: false
---
```

Agente de revisão ou auditoria nasce `readonly: true`. Se um deles precisar
escrever, isso é decisão de time, não ajuste silencioso num PR.

**Skills** — `.cursor/skills/<nome>/SKILL.md`, com `name` e `description` no
frontmatter. Skill é procedimento de vários passos; rule é restrição curta. Se o
que você quer escrever tem "primeiro… depois… por fim", é skill.

## Fluxo

1. Branch a partir de `main`.
2. Uma mudança conceitual por PR. "Endurecer testes" e "adicionar rules de Go"
   são dois PRs.
3. **Teste antes de abrir.** Instale a versão da sua branch (`./install.sh global`
   e `./install.sh project <um repo real> --force`) e rode `/code-review` em um
   diff de verdade. Cole no PR um trecho da saída mostrando o efeito da mudança.
4. Na descrição do PR responda: o que mudou no comportamento do agente, qual
   problema real motivou, e o que passou a ser bloqueado ou deixou de ser.
5. Revisão de outra pessoa antes do merge — inclusive para mudança em texto de
   prompt.

## Cuidado com prompt

Prompt não tem compilador; regressão aqui é silenciosa.

- Instrução nova pode entrar em conflito com uma existente. Antes de adicionar,
  procure (`grep`) se o assunto já está tratado em outro arquivo e edite lá em
  vez de duplicar.
- Instrução em negação (`não faça X`) funciona melhor acompanhada da alternativa
  (`faça Y no lugar`).
- Não afrouxe severidade sem discussão. Rebaixar "lógica sem teste" de Blocker
  para Minor é mudança de política do time, não de redação.
- Mantenha um único idioma por arquivo.

## Segurança

- Nunca commite `.cursor/mcp.json` — só o `.example`, com valores por variável de
  ambiente. O `.gitignore` já bloqueia, não force.
- Nada de token, URL interna, nome de cliente ou trecho de código proprietário
  nos exemplos das rules.
