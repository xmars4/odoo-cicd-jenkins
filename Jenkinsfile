pipeline {
  agent any
  environment {
    workspace = "${env.WORKSPACE}"
    odoo_folder = "${workspace}/odoo-addons"
    sonarqubeScannerHome = tool name: 'sonar', type: 'hudson.plugins.sonar.SonarRunnerInstallation'
  }
  stages {
    stage ('Preparation Source') {
      // https://www.jenkins.io/doc/pipeline/steps/git/
      steps {
        script {
          sh 'mkdir -p "${odoo_folder}"'
          dir (odoo_folder) {
            git branch: 'main',
                url: 'https://github.com/Sotatek-TruongPham2/demo-sonarqube-odoo'
          }

        }
            
      }
    }
    stage ('Sona scanner') {
      // use projectBaseDir property to specify start folder of sona, so 
      // it can start scanning source code in this folder and it's subfolder
      steps {
          withCredentials([string(credentialsId: 'sonar', variable: 'sonarLogin')]) {
            sh "${sonarqubeScannerHome}/bin/sonar-scanner -e -Dsonar.host.url=http://sonarqube:9000 -Dsonar.login=${sonarLogin} -Dsonar.projectName=demo-sonarqube-odoo  -Dsonar.projectKey=GS -Dsonar.projectBaseDir=\"${odoo_folder}\""
          }
        }
      }
    }

  }



