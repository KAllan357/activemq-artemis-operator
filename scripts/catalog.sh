#!/bin/sh

if [[ -z ${1} ]]; then
    CATALOG_NS="operator-lifecycle-manager"
else
    CATALOG_NS=${1}
fi

CSV=`cat deploy/catalog_resources/community/activemq-artemis-operator.v0.6.1.clusterserviceversion.yaml | sed -e 's/^/      /' | sed '0,/ /{s/      /    - /}'`
CRD=`cat deploy/crds/broker_v1alpha1_activemqartemis_crd.yaml | sed -e 's/^/      /' | sed '0,/ /{s/      /    - /}'`
PKG=`cat deploy/catalog_resources/community/activemq-artemis.package.yaml | sed -e 's/^/      /' | sed '0,/ /{s/      /    - /}'`

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: catalog-resources
  namespace: ${CATALOG_NS}
data:
  clusterServiceVersions: |
${CSV}
  customResourceDefinitions: |
${CRD}
  packages: >
${PKG}
EOF

cat <<EOF | kubectl apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: catalog-resources
  namespace: ${CATALOG_NS}
spec:
  configMap: catalog-resources
  displayName: Catalog Operators
  publisher: Red Hat
  sourceType: internal
status:
  configMapReference:
    name: catalog-resources
    namespace: ${CATALOG_NS}
EOF