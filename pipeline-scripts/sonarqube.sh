#!/bin/bash

source "${WORKSPACE}/pipeline-scripts/utils.sh"

${sonarqubeScannerHome}/bin/sonar-scanner -e -Dsonar.host.url=http://sonarqube:9000 -Dsonar.login=${SONAR_TOKEN} -Dsonar.projectName=sonarqube-odoo -Dsonar.projectKey=GS -Dsonar.projectBaseDir=\"${ODOO_WORKSPACE}/extra-addons\"
