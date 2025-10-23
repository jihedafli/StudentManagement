pipeline {
  agent any


  environment {
    DOCKER_USER = credentials('dockerhub-credentials')
    SONARQUBE_CREDENTIALS = credentials('studentmanagement')
  }

  stages {
    stage('Checkout GitHub Repository') {
      steps {
        git branch: 'main', url: 'https://github.com/jihedafli/StudentManagement'
      }
    }

    stage('Clean and Build Project') {
      steps {
        sh 'mvn -B clean'
        sh 'mvn -B package -DskipTests'
      }
    }

   stage('SonarQube Analysis') {
     steps {
       sh '''
         mvn -B sonar:sonar \
           -Dsonar.projectKey=student-management \
           -Dsonar.projectName="Student Management" \
           -Dsonar.host.url=http://192.168.33.10:9000 \
           -Dsonar.token=${SONARQUBE_CREDENTIALS}
       '''
     }
   }


    stage('Build Docker image') {
      steps {
        sh '''
          echo "$DOCKER_USER_PSW" | docker login -u "$DOCKER_USER_USR" --password-stdin || true
          # use lowercase repo/tag names
          docker build -t $DOCKER_USER_USR/student-management:alpine .
          # To push later, uncomment:
          # docker push $DOCKER_USER_USR/student-management:alpine
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
