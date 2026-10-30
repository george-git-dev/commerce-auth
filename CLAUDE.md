# CLAUDE.md

Orienta o Claude ao trabalhar neste repositório.

## O que é

`commerce-auth`: configuração do **Keycloak** (login, cadastro, senhas, 2 etapas, papéis e permissões) da plataforma commerce. **Não há código Java aqui.** Arquitetura completa no projeto: `claude/roadmap-mvp.md` (seção "Arquitetura") e `claude/contrato-api.md`.

- **Um realm por loja.** `nani` = Nani Perfumes. A loja de roupas terá o próprio realm (contas separadas).
- O `commerce-bff-nani` é o único cliente que faz login (código de autorização + PKCE). O token vai para a `commerce-api` (`aud`), com papéis e permissões.
- Senha só é digitada na página do Keycloak (tema `nani`), nunca no Angular nem no BFF.

## Regras

- **Nada de segredo no Git** (repositório público). Segredos por variável de ambiente; no realm, placeholders `${VAR}`.
- **Versão do Keycloak fixada** no `Dockerfile`. Atualizar só a partir de aviso de segurança ou correção, testando o fluxo inteiro.
- **Toda configuração do realm vai para o `realms/nani-realm.json`.** Mudou algo pelo console? Exportar e trazer para o arquivo — o console não é fonte da verdade.
- Papéis e permissões seguem o front (`commerce-web/src/app/core/config/permissions.ts`). Mudou lá, muda aqui.
- Contas de teste só no `scripts/seed-dev-users.sh` (desenvolvimento). Nunca no realm.
- Console de administração e realm `master` nunca expostos à internet.
- Tema: celular primeiro, mesmas cores e fontes do `commerce-web`, textos em português.
- Scripts e configs com fim de linha LF (`.gitattributes`).

## Git

Nunca executar add, commit, push ou comandos que alterem o histórico. Só sugerir, em uma linha com `&&`, terminando em `git pull --rebase origin develop && git push origin develop`. Mensagens em português, sem prefixo semântico. Ambiente: Windows com Git Bash.
