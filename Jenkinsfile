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
      withSonarQubeEnv('MySonar') {
        sh '''
          mvn -B sonar:sonar \
            -Dsonar.projectKey=Student-Management \
            -Dsonar.projectName="Student Management"
        '''
      }
    }
  }




    stage('Build Docker image') {
      steps {
        sh '''
          echo "$DOCKER_USER_PSW" | docker login -u "$DOCKER_USER_USR" --password-stdin || true
          # use lowercase repo/tag names
          docker build -t $DOCKER_USER_USR/student-management:alpine .
          # To push later, uncomment:
           docker push $DOCKER_USER_USR/student-management:alpine
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
