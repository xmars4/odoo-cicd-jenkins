#!/bin/bash

source "${PIPELINE_UTILS_SCRIPT_PATH}"

${sonarqubeScannerHome}/bin/sonar-scanner -e -Dsonar.host.url=http://sonarqube:9000 -Dsonar.login=${SONAR_TOKEN} -Dsonar.projectName=sonarqube-odoo -Dsonar.projectKey=GS -Dsonar.projectBaseDir="${ODOO_WORKSPACE}/extra-addons"
