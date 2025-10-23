pipeline {
    agent any
    environment {
        DOCKER_USER = credentials('dockerhub-credentials')



    }
    stages {
        stage('Checkout GitHub Repository') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/jihedafli/StudentManagement',
                    credentialsId: ''
            }
        }


        stage('Clean and Build Project') {
            steps {
                script {
                    echo 'Cleaning the project...'
                    sh 'mvn clean'

                    echo 'Building the project...'
                    sh 'mvn package -DskipTests'
                }
            }
        }



        stage("Build Docker image") {
            steps {
                script {
                    sh "docker build -t Student-management:alpine ."
                }
            }
        }


        stage('SonarQube') {
          steps {
            withSonarQubeEnv('MySonar') {
              sh 'mvn -B sonar:sonar -Dsonar.projectKey=student-management -Dsonar.projectName="Student Management"'
            }
          } .
        }



        stage("Start app and db") {
            steps {
                sh "docker-compose up -d"
            }
        }
    }
}