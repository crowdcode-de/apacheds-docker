#!/bin/bash

#set -x

# Environment variables:
# APACHEDS_VERSION
# APACHEDS_INSTANCE
# APACHEDS_BOOTSTRAP
# APACHEDS_DATA
# APACHEDS_USER
# APACHEDS_GROUP
# APACHEDS_DOMAIN
# APACHEDS_TOP_DOMAIN

APACHEDS_INSTANCE_DIRECTORY=${APACHEDS_DATA}/${APACHEDS_INSTANCE}

function replaceDomain () {
  sed -i "s#\\\${APACHEDS_DOMAIN}#${APACHEDS_DOMAIN}#g" $1
}

function replaceTopDomain () {
  sed -i "s#\\\${APACHEDS_TOP_DOMAIN}#${APACHEDS_TOP_DOMAIN}#g" $1
}

function replaceAtFile () {
  replaceDomain $1
  replaceTopDomain $1
}

# When a fresh data folder is detected then bootstrap the instance configuration.
if [ ! -d ${APACHEDS_INSTANCE_DIRECTORY} ]; then
    mkdir ${APACHEDS_INSTANCE_DIRECTORY}
    cp -rv ${APACHEDS_BOOTSTRAP}/* ${APACHEDS_INSTANCE_DIRECTORY}
    chown -v -R ${APACHEDS_USER}:${APACHEDS_GROUP} ${APACHEDS_INSTANCE_DIRECTORY}
    replaceAtFile ${APACHEDS_INSTANCE_DIRECTORY}/conf/config.ldif
    replaceAtFile ${APACHEDS_INSTANCE_DIRECTORY}/ome.ldif
    replaceAtFile contextentry.template
    sed -i "s#\\\${CONTEXTENTRY}#`base64 contextentry.template | tr --delete '\n'`#" ${APACHEDS_INSTANCE_DIRECTORY}/conf/config.ldif
fi

# Execute the server in console mode and not as a daemon.
/opt/apacheds-${APACHEDS_VERSION}/bin/apacheds console ${APACHEDS_INSTANCE}
