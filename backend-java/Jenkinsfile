pipeline {
  agent any {
    docker {
      image 'maven:3.9.6-eclipse-temurin-21'   // Maven + JDK 21
      args '-v $HOME/.m2:/root/.m2'           // cache Maven local
    }
  }

  options { timestamps() }

  stages {
    stage('Checkout') {
      steps {
        git branch: 'main',
            url: 'https://github.com/YaseminKasikci/move_m8-JAVA.git',
            credentialsId: 'github-pat'
      }
    }

    stage('Build & Test') {
      steps {
        sh 'mvn clean verify'
      }
    }

    stage('Package') {
      steps {
        sh 'mvn package -DskipTests'
        archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
      }
    }

    // 👉 Optionnel si tu veux Sonar
    stage('SonarQube Analysis') {
      when { expression { return false } } // désactive si tu n’as pas encore configuré Sonar
      steps {
        withSonarQubeEnv('MySonarQube') {
          sh 'mvn sonar:sonar'
        }
      }
    }
  }
}
