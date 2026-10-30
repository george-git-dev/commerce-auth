#!/bin/sh
# Roda uma única vez, quando o volume do Postgres é criado.
# Usuário próprio do Keycloak com acesso só ao schema "keycloak" (A7).
set -eu
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<EOSQL
  CREATE ROLE keycloak LOGIN PASSWORD '${KEYCLOAK_DB_PASSWORD}';
  CREATE SCHEMA keycloak AUTHORIZATION keycloak;
  ALTER ROLE keycloak SET search_path = keycloak;
  REVOKE ALL ON SCHEMA public FROM PUBLIC;
  REVOKE ALL ON DATABASE ${POSTGRES_DB} FROM PUBLIC;
  GRANT CONNECT ON DATABASE ${POSTGRES_DB} TO keycloak;
EOSQL
