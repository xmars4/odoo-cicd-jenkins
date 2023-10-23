#!/bin/bash

source "${PIPELINE_UTILS_SCRIPT_PATH}"

[ -z $SONAR_URL ] && SONAR_URL=http://localhost:9000
PROJECT_KEY="ODOO_CICD"

${SONARQUBE_SCANNER_HOME}/bin/sonar-scanner -e -Dsonar.host.url=$SONAR_URL -Dsonar.login=${SONAR_TOKEN} -Dsonar.projectName=sonarqube-odoo -Dsonar.projectKey=$PROJECT_KEY -Dsonar.projectBaseDir="${WORKSPACE}/" >/dev/null 2>&1

result_url="$SONAR_URL/dashboard?id=$PROJECT_KEY"
result_url=$(echo $result_url | sed "s/\/\//\//2")
echo "$result_url"
