pipeline {
  agent { label 'flutter' }

  options {
    timestamps()
    skipDefaultCheckout(true)
    timeout(time: 30, unit: 'MINUTES')
  }

  environment {
    ANDROID_SDK_ROOT = '/opt/android-sdk'
    ANDROID_HOME     = '/opt/android-sdk'
    FLUTTER_HOME     = '/opt/flutter'
    PATH             = "${FLUTTER_HOME}/bin:${ANDROID_SDK_ROOT}/platform-tools:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${env.PATH}"

    // Mémoire et stabilité Gradle côté CI
    // -Xmx4g (RAM conteneur = 6 Go) ; Metaspace 1g ; pas de daemon, pas de watcher, peu de workers
   GRADLE_OPTS = "-Dorg.gradle.daemon=false -Dorg.gradle.vfs.watch=false -Dorg.gradle.workers.max=1 -Dfile.encoding=UTF-8 -Dkotlin.compiler.execution.strategy=in-process"
JAVA_TOOL_OPTIONS = "-Dfile.encoding=UTF-8 -Xmx4g -XX:MaxMetaspaceSize=1g"


    GRADLE_USER_HOME = "${WORKSPACE}/.gradle"
    CI = "true"
  }

  stages {
    stage('Checkout') {
      steps {
        retry(2) {
          checkout([$class: 'GitSCM',
            branches: [[name: '*/main']],
            userRemoteConfigs: [[
              url: 'https://github.com/YaseminKasikci/move_m8-FLUTTER.git',
              credentialsId: 'github-pat'
            ]]
          ])
        }
      }
    }

    stage('Env sanity') {
      steps {
        sh '''
          set -eux
          echo "Running on: $(hostname)"
          uname -m
          java -version
          git --version
          adb version || true
          git config --global --add safe.directory /opt/flutter || true
        '''
      }
    }

    stage('Flutter doctor (info)') {
      steps {
        sh 'flutter --version && flutter doctor -v || true'
      }
    }

    stage('Pub get') {
      steps {
        sh 'flutter pub get'
      }
    }

    stage('Configure Gradle memory') {
      steps {
        sh '''
          set -eux
          # S'assure que gradle.properties impose bien la RAM côté Gradle ET daemon Kotlin
          mkdir -p android
          PROP_FILE=android/gradle.properties
          touch "$PROP_FILE"

          # Supprime d'anciennes lignes potentiellement contradictoires
          sed -i.bak '/^org\\.gradle\\.jvmargs=/d' "$PROP_FILE" || true
          sed -i.bak '/^org\\.gradle\\.daemon=/d' "$PROP_FILE" || true
          sed -i.bak '/^org\\.gradle\\.vfs\\.watch=/d' "$PROP_FILE" || true
          sed -i.bak '/^org\\.gradle\\.workers\\.max=/d' "$PROP_FILE" || true
          sed -i.bak '/^kotlin\\.daemon\\.jvm\\.options=/d' "$PROP_FILE" || true

          cat >> "$PROP_FILE" <<'EOF'
org.gradle.jvmargs=-Xmx4g -XX:MaxMetaspaceSize=1g -Dfile.encoding=UTF-8
org.gradle.daemon=false
org.gradle.vfs.watch=false
org.gradle.workers.max=2
kotlin.daemon.jvm.options=-Xmx3g,-XX:MaxMetaspaceSize=1g
EOF

          echo "==== android/gradle.properties ===="
          cat "$PROP_FILE"
        '''
      }
    }

    stage('Build APK') {
      steps {
        sh '''
          set -eux
          [ -f android/gradlew ] && chmod +x android/gradlew || true

          # Nettoyage défensif des daemons/caches qui peuvent casser sur CI
          (cd android && ./gradlew --stop) || true
          rm -rf "${GRADLE_USER_HOME}/daemon" || true
          rm -rf "${GRADLE_USER_HOME}/caches/journal-1" || true

          yes | sdkmanager --licenses || true

          # Build release (Gradle lira android/gradle.properties)
          flutter build apk --release -v
        '''
      }
    }

    stage('Archive APK') {
      steps {
        archiveArtifacts artifacts: 'build/app/outputs/flutter-apk/*.apk', fingerprint: true
      }
    }
  }

  post {
    always {
      sh 'ls -lah build/app/outputs/flutter-apk || true'
    }
    failure {
      echo 'Build en échec — mémoire JVM augmentée (4 Go). Si ça replante encore, passe -Xmx à 5g et/ou augmente la RAM du conteneur à 8 Go.'
      sh 'docker inspect jenkins --format "{{.State.OOMKilled}}" || true'
    }
  }
}
