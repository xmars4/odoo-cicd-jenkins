#!/bin/bash

source "${WORKSPACE}/pipeline-scripts/utils.sh"
show_separator "hey u ${sonarqubeScannerHome}"
show_separator "addons here ${ODOO_WORKSPACE}"

${sonarqubeScannerHome}/bin/sonar-scanner -e -Dsonar.host.url=http://sonarqube:9000 -Dsonar.login=${SONAR_TOKEN} -Dsonar.projectName=sonarqube-odoo -Dsonar.projectKey=GS -Dsonar.projectBaseDir=\"${ODOO_WORKSPACE}/extra-addons\"
