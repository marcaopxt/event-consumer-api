@NonCPS
def getMongServiceHost(String branchName) {
	def common="-Dspring.data.mongodb.host=mongodb.mongodb.svc.cluster.local -Dspring.data.mongodb.authentication-database=admin"
	def database="-Dspring.data.mongodb.database=marketplace_test_" + branchName
	def user="-Dspring.data.mongodb.username=marketplace_test_" + branchName
	def passwordStr="-Dspring.data.mongodb.password=marketplace_test_" + branchName
	return( common + " " + database + " " + user + " " + passwordStr); 
}

pipeline {
    agent {
     	kubernetes(label: 'jenkins-agent-spring-boot')
//        label:'jenkins-agent-spring-boot'
    }
    environment {
        DOCKER_CERT_PATH="regcred"
    }
	options {
	     disableConcurrentBuilds()
//         buildDiscarder(logRotator(daysToKeepStr: '', numToKeepStr: '5'))
//	     timeout(time: 10, unit: 'MINUTES')
//	     timestamps()
	} // end of options    
    stages {
	    stage('Build, Test and Report') {
	    	steps {
		        git branch: 'master',
	    			credentialsId: 'ssh_github',
	    			url: 'git@github.com:marcaopxt/event-producer-api.git'
		        script {
			        container('maven') {
						def mavenOpts = getMongServiceHost("${BRANCH_NAME}")		        	
			            withMaven(maven:'maven-default') {
			            	sh 'mvn --version'
				            sh "mvn -B clean compile test verify package spring-boot:repackage -Dspring.profiles.active=test " + mavenOpts 
	    					archiveArtifacts artifacts: '**/target/*.jar', fingerprint: true
	    					junit '**/**/**/TEST-*.xml'
				            
			      	    }
		      	    }
		        }
	    	}
      	}
	    stage('SAST') {
   	        steps {
				script {
			        container('maven') {
			    	    withSonarQubeEnv('sonarqube') {
		                    sh 'mvn sonar:sonar'
			        	// -Dsonar.branch="${BRANCH_NAME}"'
			    	    }
				        timeout(time: 1, unit: 'MINUTES') { // Just in case something goes wrong, pipeline will be killed after a timeout
		                    waitForQualityGate abortPipeline: true
					    }        
		            }
				}
	        }
        }
	    stage('Containerize it') {
            when {
                branch 'master'
            }
			steps {
			    script {
			        container('docker-dind') {
	      				dockerImage = docker.build "mapx/transactions-api:$BUILD_NUMBER"
						docker.withRegistry('','dockerhub_registry') {
	//						docker tag "mapx/transactions-api:$BUILD_NUMBER" "mapx/transactions-api:latest"
	        				dockerImage.push()
	      				}
					}
			    }
			}
		}
	    stage('Deploy it') {
            when {
                branch 'master'
            }	    
			steps {
			    script {
			        container('helm') {
		        		sh "helm version"
		        		sh "helm upgrade --install transactions-api \
		        				--namespace transactions kubernetes/chart/ \
		        				--set controller.production.enabled=true \
		        				--set controller.configValues={'JDBC_DRIVER=org.postgresql.driver','JDBC_USERNAME=postgresql'}"
					}
				}
			}
		}
    }
}


