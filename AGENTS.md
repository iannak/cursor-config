# AGENTS.md

Instruções base para agentes de IA. Este arquivo é lido pelo Cursor, pelo Claude
Code e pelo Codex; as regras detalhadas ficam em `.cursor/rules/`.

Copie este arquivo para a raiz do projeto onde a configuração for instalada e
adapte a seção "Projeto".

## Projeto

<!-- Preencha por projeto -->
- Stack:
- Como rodar: `…`
- Como testar: `…`
- Como lintar: `…`

## Como trabalhar aqui

- Leia o código relevante inteiro antes de editar. O padrão que já existe no
  projeto vence a preferência do agente.
- Faça a menor mudança que resolve o problema por completo. Sem refactor carona.
- Comportamento novo entra com teste. Bug corrigido entra com teste de regressão
  que falha sem a correção.
- Rode build, lint e testes antes de dizer que terminou. Reporte o resultado
  real — nunca afirme que passa sem ter executado.
- Não commite nem faça push sem pedido explícito. Nunca commite segredo.
- Comunicação no idioma predominante do repositório; código e nomes em inglês,
  salvo convenção diferente do projeto.

## Regras detalhadas

| Arquivo | Escopo |
|---|---|
| `.cursor/rules/00-core.mdc` | Fluxo de trabalho e verificação |
| `.cursor/rules/10-clean-code.mdc` | Nomes, funções, estado, erros, duplicação |
| `.cursor/rules/20-testing.mdc` | Quando testar, o que cobrir, teste ruim |
| `.cursor/rules/30-security.mdc` | Injeção, authz, segredos, dependências |
| `.cursor/rules/typescript.mdc` | TS / Node / React |
| `.cursor/rules/python.mdc` | Python |

## Agentes

| Agente | Uso |
|---|---|
| `code-reviewer` | Revisão rigorosa do diff, hunk por hunk (readonly) |
| `test-auditor` | Auditoria de cobertura e qualidade dos testes (readonly) |
| `security-reviewer` | Revisão de segurança do diff (readonly) |
| `implementer` | Implementação de mudanças |
