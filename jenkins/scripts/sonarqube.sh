#!/bin/bash

source "${PIPELINE_UTILS_SCRIPT_PATH}"

[ -z $SONAR_URL ] && SONAR_URL=http://sonarqube:9000
scanner_result=$(${SONARQUBE_SCANNER_HOME}/bin/sonar-scanner -e -Dsonar.host.url=$SONAR_URL -Dsonar.login=${SONAR_TOKEN} -Dsonar.projectName=sonarqube-odoo -Dsonar.projectKey=GS -Dsonar.projectBaseDir="${ODOO_WORKSPACE}/extra-addons")
echo $scanner_result
