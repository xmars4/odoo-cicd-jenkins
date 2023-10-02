#!/bin/bash

source "${WORKSPACE}/pipeline-scripts/utils.sh"
show_separator "hey u ${sonarqubeScannerHome}"
show_separator "addons here ${odoo_workspace}"

${sonarqubeScannerHome}/bin/sonar-scanner -e -Dsonar.host.url=http://sonarqube:9000 -Dsonar.login=${SONAR_TOKEN} -Dsonar.projectName=sonarqube-odoo -Dsonar.projectKey=GS -Dsonar.projectBaseDir="${odoo_workspace}/extra-addons"
