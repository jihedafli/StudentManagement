pipeline {
  agent any
  environment {
    DOCKER_USER = credentials('dockerhub-credentials')
    IMAGE_REPO = "${DOCKER_USER_USR}/student-management"
    IMAGE_TAG  = "alpine"         // or "${BUILD_NUMBER}"
    NS         = "spring-app"
  }
  options { timestamps() }

  stages {
    stage('Checkout') {
      steps {
        git branch: 'main', url: 'https://github.com/jihedafli/StudentManagement'
      }
    }

    stage('Build & Package') {
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

    stage('Docker Build & Push') {
      steps {
        sh """
          echo "$DOCKER_USER_PSW" | docker login -u "$DOCKER_USER_USR" --password-stdin
          docker build -t ${IMAGE_REPO}:${IMAGE_TAG} .
          docker push  ${IMAGE_REPO}:${IMAGE_TAG}
        """
      }
    }

    stage('K8s Deploy: MySQL') {
      steps {
        sh """
          kubectl get ns ${NS} >/dev/null 2>&1 || kubectl create ns ${NS}
          kubectl apply -f k8s/mysql/mysql-deployment.yaml
          kubectl -n ${NS} wait --for=condition=available deploy/mysql --timeout=180s || true
          kubectl -n ${NS} get pods -l app=mysql -o wide
        """
      }
    }

    stage('K8s Deploy: Spring App') {
      steps {
        sh """
          kubectl apply -f k8s/spring/spring-deployment.yaml
          kubectl -n ${NS} set image deploy/spring-app spring-app=${IMAGE_REPO}:${IMAGE_TAG} --record=true
          kubectl -n ${NS} rollout status deploy/spring-app --timeout=180s
          kubectl -n ${NS} get svc spring-service -o wide
        """
      }
    }

    stage('Show URL') {
      steps {
        sh """
          NODE_PORT=\$(kubectl -n ${NS} get svc spring-service -o jsonpath='{.spec.ports[0].nodePort}')
          NODE_IP=\$(minikube ip || kubectl get node -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
          echo "App URL: http://\${NODE_IP}:\${NODE_PORT}/student"
        """
      }
    }
  }

  post {
    always {
      archiveArtifacts artifacts: 'target/*.jar', onlyIfSuccessful: false
      sh 'docker logout || true'
    }
  }
}
