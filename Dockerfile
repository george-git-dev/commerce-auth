# Keycloak da Nani: imagem oficial com versão FIXADA + tema da loja + realm.
# Atualizar: trocar KEYCLOAK_VERSION quando sair correção de segurança
# (ver README, "Atualizar o Keycloak").
ARG KEYCLOAK_VERSION=26.8.1

FROM quay.io/keycloak/keycloak:${KEYCLOAK_VERSION} AS builder
# Opções de build (ficam gravadas na imagem otimizada)
ENV KC_DB=postgres \
    KC_HEALTH_ENABLED=true \
    KC_HTTP_RELATIVE_PATH=/auth
COPY themes/nani /opt/keycloak/themes/nani
RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:${KEYCLOAK_VERSION}
COPY --from=builder /opt/keycloak/ /opt/keycloak/
# Realm versionado: importado só se ainda não existir no banco.
COPY realms /opt/keycloak/data/import
ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
# Produção: TLS termina no Caddy; o Keycloak confia nos cabeçalhos X-Forwarded.
CMD ["start", "--optimized", "--import-realm", "--http-enabled=true", "--proxy-headers=xforwarded"]
