#!/usr/bin/env bash
# Contas de teste do realm "nani" — SÓ DESENVOLVIMENTO (as mesmas do mock do front).
# Idempotente: conta que já existe é pulada.
# 2 etapas da equipe NÃO vêm daqui: o fluxo de login "nani browser" (realm) exige o código
# de quem tem a permissão admin:access e obriga a configurar no primeiro login.
set -euo pipefail

KCADM=/opt/keycloak/bin/kcadm.sh
REALM=nani

$KCADM config credentials --server "$KC_URL" --realm master \
  --user "$KEYCLOAK_ADMIN_USER" --password "$KEYCLOAK_ADMIN_PASSWORD"

# create_user <email> <nome> <sobrenome> [papéis...]
create_user() {
  local email=$1 first=$2 last=$3
  shift 3
  local existing
  existing=$($KCADM get users -r "$REALM" -q email="$email" -q exact=true --fields id --format csv --noquotes)
  if [[ -n "$existing" ]]; then
    echo "já existe: $email"
    return
  fi
  $KCADM create users -r "$REALM" \
    -s username="$email" -s email="$email" \
    -s firstName="$first" -s lastName="$last" \
    -s enabled=true -s emailVerified=true
  $KCADM set-password -r "$REALM" --username "$email" --new-password "$DEV_USERS_PASSWORD"
  for role in "$@"; do
    $KCADM add-roles -r "$REALM" --uusername "$email" --rolename "$role"
  done
  echo "criada: $email $*"
}

# ROLE_CUSTOMER vem automático (papel padrão do realm).
create_user superadmin@email.com Super Admin ROLE_SUPER_ADMIN
create_user admin@email.com Admin Loja ROLE_ADMIN
create_user viewer@email.com Visualizador Loja ROLE_VIEWER
create_user ana@email.com Ana Souza
create_user bia@email.com Bia Lima
create_user julia.afiliada@email.com Julia Afiliada ROLE_AFFILIATE
create_user vizinho@email.com Vizinho Entrega

echo "Seed concluído."
