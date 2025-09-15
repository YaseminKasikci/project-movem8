pipeline {
    agent any

    tools {
        // Configurés dans Jenkins > Global Tool Configuration
        jdk 'jdk-21'
        maven 'maven-3.9.9'
    }

    environment {
        // Ton token SonarQube (injecté via Credentials Jenkins)
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

        stage('Build Android') {
            steps {
                dir('move-m8') {
                    // génère un .aab pour Google Play
                    sh 'flutter build appbundle --release'
                }
            }
        }

        stage('Build iOS') {
            agent { label 'macos' } // ce stage doit tourner sur un agent macOS
            steps {
                dir('move-m8') {
                    // génère un .ipa sans signature
                    sh 'flutter build ios --release --no-codesign'
                }
            }
        }

        stage('SonarQube Analysis - Backend') {
            steps {
                dir('movem8') {
                    withSonarQubeEnv('MySonarQube') {
                        sh 'mvn sonar:sonar'
                    }
                }
            }
        }

        stage('SonarQube Analysis - Frontend') {
            steps {
                dir('move-m8') {
                    withSonarQubeEnv('MySonarQube') {
                        sh '''
                          flutter test --coverage
                          sonar-scanner -Dsonar.login=$SONARQUBE_ENV
                        '''
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
