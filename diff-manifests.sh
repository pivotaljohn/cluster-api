#!/usr/bin/env bash

set -e -o pipefail

TMPDIR=/tmp/cluster-manifest-compare

if [[ -d ${TMPDIR} ]]; then
  rm -rf ${TMPDIR}
fi

mkdir -p ${TMPDIR}
KUS_YAML=${TMPDIR}/kus-config.yaml
YTT_YAML=${TMPDIR}/ytt-config.yaml

kustomize build config/default/ | yq --slurp --sort-keys --yaml-output '. | sort' >${KUS_YAML}
ytt -f config-ytt | yq --slurp --sort-keys --yaml-output '. | sort' >${YTT_YAML}

KUS_RESOURCES=$( cat ${KUS_YAML} | yq --raw-output '.[] | .metadata.name' | sort )
YTT_RESOURCES=$( cat ${YTT_YAML} | yq --raw-output '.[] | .metadata.name' | sort )

colordiff <(echo "$KUS_RESOURCES") <(echo "${YTT_RESOURCES}")

for resource in $KUS_RESOURCES ; do
  echo $resource
  colordiff <( cat ${KUS_YAML} | yq -y ".[] | select(.metadata.name == \"$resource\")" ) \
            <( cat ${YTT_YAML} | yq -y ".[] | select(.metadata.name == \"$resource\")" )
done
