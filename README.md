# commerce-auth

Login e permissões da plataforma **commerce** (Nani Perfumes e, no futuro, outras lojas), usando o **Keycloak** — servidor de login open source. Este repositório não tem código Java: guarda a **configuração** do Keycloak para que ele seja recriado igual em qualquer máquina.

| Pasta / arquivo | O que é |
|---|---|
| `Dockerfile` | Imagem oficial do Keycloak com a **versão fixada** + o tema da Nani + o realm |
| `docker-compose.yml` | Ambiente de desenvolvimento: Keycloak + Postgres + Mailpit (e-mail falso) + seed |
| `realms/nani-realm.json` | O realm `nani` (loja Nani): regras de senha, bloqueio, cadastro, papéis, permissões, cliente do BFF. **Sem segredos** (vêm de variáveis de ambiente) |
| `themes/nani/` | Tela de login com o visual da Nani (CSS, fontes, logo, textos) |
| `scripts/seed-dev-users.sh` | Contas de teste — **só desenvolvimento** |
| `postgres/init/` | Cria o usuário de banco do Keycloak, com acesso só ao schema `keycloak` |

## Rodar na sua máquina

Precisa do Docker Desktop.

```bash
cp .env.example .env        # e troque as senhas
docker compose up -d --build
```

| Endereço | Para quê |
|---|---|
| http://localhost:8180/auth/realms/nani/account | Tela de login da Nani (entra e cai na conta) |
| http://localhost:8180/auth/admin | Console de administração (usuário/senha do `.env`) — **só local** |
| http://localhost:8025 | Mailpit: e-mails de verificação e de senha |

Contas de teste (senha `DEV_USERS_PASSWORD` do `.env`): `superadmin@`, `admin@`, `viewer@` (equipe — pedem 2 etapas no primeiro login), `ana@`, `bia@`, `julia.afiliada@`, `vizinho@` (todas `@email.com`).

**O realm só é importado se ainda não existir.** Mudou o `nani-realm.json`? Recrie do zero:

```bash
docker compose down -v && docker compose up -d --build
```

Mexendo só no CSS do tema: basta recarregar a página (o `start-dev` não guarda cache de tema).

## Papéis e permissões

Papéis do realm = papéis do front (`src/app/core/config/permissions.ts` do `commerce-web`); as permissões são papéis do cliente `commerce-api` e chegam no token em `resource_access.commerce-api.roles`. Todo cadastro nasce com `ROLE_CUSTOMER`.

## Produção (resumo — detalhes na Fase 3)

- Imagem pelo `Dockerfile` (`start --optimized`), Postgres com usuário próprio, segredos no SSM.
- `KC_HOSTNAME=https://www.naniperfumes.com.br/auth`; o Caddy termina o HTTPS.
- **Rotas públicas no Caddy (lista de permissões):** só `/auth/realms/nani/...` (login, tokens, chaves) e `/auth/resources/...`. **Nunca** `/auth/admin` nem `/auth/realms/master` — console só por túnel SSH.
- Sem o seed de contas de teste.

## Atualizar o Keycloak

1. Acompanhar os avisos de segurança: https://www.keycloak.org/security
2. Trocar `KEYCLOAK_VERSION` no `Dockerfile` (correções da mesma linha 26.x).
3. `docker compose up -d --build`, testar login, cadastro, senha e 2 etapas.
4. Commit e deploy.
