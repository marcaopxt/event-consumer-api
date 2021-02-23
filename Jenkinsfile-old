pipeline {
    environment {
        registryCredential = "docker"
    }
    agent {
        label "jenkins-maven"
    }
/*    
    tools {
        maven 'maven-default'
        jdk 'jdk11'
    }
*/    
    stages {
        stage('Build and Test') {
            steps {
               container('jenkins-maven') {
                   script {
		            	sh 'mvn -B clean compile test verify package -Dspring.profiles.active=test'
		            	def scannerHome = tool('sonarqube')
		            	sh "echo ScannerHome: ${scannerHome}"
		            	withSonarQubeEnv('sonarqube') {
			            	sh "{scannerHome}/bin/sonar-scanner"
		            	}
					    timeout(time: 1, unit: 'HOURS') { // Just in case something goes wrong, pipeline will be killed after a timeout
							    def qg = waitForQualityGate() // Reuse taskId previously collected by withSonarQubeEnv
							    if (qg.status != 'OK') {
							      error "Pipeline aborted due to quality gate failure: ${qg.status}"
							    }
						}

                        sh "npm install semantic-release -y"
                        sh "ndx semantic-release"
                        sh "git add package.json"
                        sh "git commit -m "
                        
                   }
            	}
            }
        }
        stage('Build Image') {
            steps{
                container('jenkins-docker') {
	                script {
	                    app = docker.build("mapx/order-publisher-api")
	                }
                }
            }
        }
        stage('Deploy') {
            steps{
                container('jenkins-docker') {
                    script {
			            sh 'whoami'
		            	sh 'pwd'
	                    docker.withRegistry( "https://registry.hub.docker.com", registryCredential ) {
	                        dockerImage.push()
	                        app.push("latest")
	                    }
                    }

                }
            }
        }
        /*
        stage('Deploy to ACS'){
            steps{
                withCredentials([azureServicePrincipal('dbb6d63b-41ab-4e71-b9ed-32b3be06eeb8')]) {
                    sh 'echo "logging in" '
                    sh 'az login --service-principal -u **************************** -p ********************************* -t **********************************’
                    sh 'az account set -s ****************************'
                    sh 'az aks get-credentials --resource-group ilink --name    mycluster'
                    sh 'kubectl apply -f sample.yaml'
                }
            }
        }
        */
    }
}