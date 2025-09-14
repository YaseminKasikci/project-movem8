pipeline {
    agent any

    tools {
        // Tu dois les avoir configurés dans "Global Tool Configuration"
        jdk 'jdk-21'
        maven 'maven-3.9.9'
    }

    environment {
        // Adresse de ton serveur SonarQube (configuré dans Manage Jenkins > Configure System)
        SONARQUBE_ENV = credentials('sonarqube-token')
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/YaseminKasikci/project-movem8.git'
            }
        }

        stage('Build Backend') {
            steps {
                dir('movem8') {
                    sh 'mvn -B clean package -DskipTests'
                }
            }
        }

        stage('Build Frontend') {
            steps {
                dir('move-m8') {
                    sh 'flutter build web --release'
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                dir('movem8') {
                    withSonarQubeEnv('MySonarQube') {
                        sh 'mvn sonar:sonar'
                    }
                }
            }
        }

        stage('Docker Build & Deploy') {
            steps {
                sh 'docker compose down'
                sh 'docker compose up -d --build'
            }
        }
    }
}
