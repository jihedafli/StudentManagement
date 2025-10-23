pipeline {
    agent any


    environment {
        DOCKER_USER = credentials('dockerhub-credentials')
        SONARQUBE_CREDENTIALS = credentials('studentmanagement')
    }

    stages {
        stage('Checkout GitHub Repository') {
            steps {

                git branch: 'main',
                    url: 'https://github.com/jihedafli/StudentManagement'
            }
        }

        stage('Clean and Build Project') {
            steps {
                sh 'mvn -B clean'
                sh 'mvn -B package -DskipTests'
            }
        }

        stage('Build Docker image (local)') {
            steps {

                sh '''
                  echo "$DOCKER_USER_PSW" | docker login -u "$DOCKER_USER_USR" --password-stdin || true
                  # Use lowercase name for Docker image/tag
                  docker build -t $DOCKER_USER_USR/student-management:alpine .
                  # To push later, uncomment:
                  # docker push $DOCKER_USER_USR/student-management:alpine
                '''
            }
        }

        stage('SonarQube Analysis') {
            steps {

                sh '''
                  mvn -B sonar:sonar \
                    -Dsonar.projectKey=student-management \
                    -Dsonar.projectName="Student Management" \
                    -Dsonar.host.url=http://192.168.33.10:9000 \
                    -Dsonar.login=${SONARQUBE_CREDENTIALS}
                '''
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'target/*.jar', onlyIfSuccessful: false
        }
    }
}
