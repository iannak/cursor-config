---
name: code-review
description: Executa a revisão completa de um diff ou PR — coleta o contexto, percorre hunk por hunk, aciona auditoria de teste e de segurança e emite o veredito. Use quando pedirem review, revisão de PR ou "revisa minhas alterações".
---

# Revisão de código

Workflow completo de revisão. Escreva tudo no idioma predominante do
repositório. Você **não altera arquivos** durante a revisão.

## 1. Determinar o escopo

Na ordem de preferência:

- Se apontaram um PR: `gh pr diff <n>` e `gh pr view <n> --json title,body,commits`
- Se apontaram commit/range/arquivo: use o que foi apontado
- Caso contrário, a branch atual contra a base:

```bash
BASE=$(git merge-base HEAD origin/main 2>/dev/null \
    || git merge-base HEAD origin/master 2>/dev/null \
    || git merge-base HEAD origin/develop)
git diff --stat "$BASE"...HEAD
git log --oneline "$BASE"..HEAD
git diff "$BASE"...HEAD
```

Se o diff estiver vazio, diga isso e pare.
Se o diff for muito grande (>1500 linhas), avise, revise por completo os
arquivos de maior risco e liste explicitamente o que ficou de fora — nunca
trunque em silêncio.

## 2. Levantar contexto antes de julgar

- Intenção da mudança: descrição do PR e mensagens de commit.
- Convenções do projeto: `AGENTS.md`, `CONTRIBUTING.md`, `.cursor/rules/`,
  config de ESLint/Ruff/Prettier, estrutura de pastas.
- **Leia por inteiro cada arquivo alterado**, não só os hunks.
- Encontre os **call sites** do que mudou de assinatura, retorno ou
  comportamento. Mudança de contrato sem olhar quem consome é o defeito mais
  caro que passa em review.
- Localize os testes existentes que cobrem a área tocada.

## 3. Percorrer o diff

Arquivo por arquivo, hunk por hunk, na ordem do diff. Não pule config,
migration, YAML de CI nem deleção — é onde nasce incidente.

Em cada hunk, aplique `.cursor/rules/10-clean-code.mdc`, `20-testing.mdc` e
`30-security.mdc`, mais as regras da linguagem, e pergunte:

1. Está correto? (borda, nulo, vazio, zero, negativo, fuso, ordem, concorrência)
2. O que acontece quando falha? (erro engolido, recurso não fechado, retry
   infinito, estado parcial)
3. É seguro? (entrada não confiável, authz, segredo, dado sensível)
4. Está testado, e o teste prova alguma coisa?
5. Está claro para quem nunca viu o arquivo?
6. Está na camada certa?
7. Vai doer depois? (duplicação, acoplamento, N+1, contrato sem versão,
   migration sem rollback)

## 4. Auditorias de apoio

Quando o diff tiver lógica de negócio relevante, acione o subagente
`test-auditor`. Quando tocar autenticação, autorização, entrada de usuário,
dependências, cripto ou configuração de infra, acione `security-reviewer`.
Incorpore os achados na revisão, sem duplicar comentário.

## 5. Formato do comentário

Um comentário por problema, ancorado em `arquivo:linha`, com citação do trecho,
o problema, o impacto concreto e o código sugerido. Severidade:
🔴 Blocker · 🟠 Major · 🟡 Minor · 🔵 Nit · 💭 Pergunta · 👏 Elogio.

Não escreva comentário vago, não comente o que o linter já resolve, não repita o
mesmo nit em oito lugares (agrupe), não transforme problema pré-existente fora
do diff em bloqueio.

## 6. Veredito

Resumo em 2–4 frases, tabela de contagem por severidade, situação da cobertura
de teste e da segurança, e o veredito: **Aprovado** · **Aprovado com ressalvas**
· **Requer mudanças** · **Bloqueado**, seguido da lista numerada do que é
obrigatório para desbloquear.

Não infle a revisão para parecer diligente, e não aprove por gentileza.
