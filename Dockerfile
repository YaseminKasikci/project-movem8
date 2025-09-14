# Agent Jenkins (Java 17)
# FROM jenkins/inbound-agent:latest-jdk17

# USER root

# # Dépendances de base
# RUN apt-get update && apt-get install -y \
#     curl unzip git ca-certificates xz-utils zip libglu1-mesa \
#     && rm -rf /var/lib/apt/lists/*

# # ---------- Android SDK ----------
# ENV ANDROID_SDK_ROOT=/opt/android-sdk
# ENV ANDROID_HOME=/opt/android-sdk
# RUN mkdir -p ${ANDROID_SDK_ROOT}

# # Command Line Tools
# RUN curl -fsSL https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -o /tmp/clt.zip \
#  && unzip -q /tmp/clt.zip -d ${ANDROID_SDK_ROOT} \
#  && rm /tmp/clt.zip \
#  && mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools/latest \
#  && mv ${ANDROID_SDK_ROOT}/cmdline-tools/* ${ANDROID_SDK_ROOT}/cmdline-tools/latest/ || true

# # PATH Android (tools/emulator/platform-tools)
# ENV PATH=${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools:${ANDROID_SDK_ROOT}/emulator

# # Licences + composants minimaux (ajuste si ton projet demande d'autres versions)
# RUN yes | sdkmanager --licenses || true \
#  && sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"

# # ---------- Flutter ----------
# ENV FLUTTER_HOME=/opt/flutter
# RUN git clone https://github.com/flutter/flutter.git -b stable ${FLUTTER_HOME}

# # Sécuriser permissions et dépôt
# RUN chown -R jenkins:jenkins ${FLUTTER_HOME} ${ANDROID_SDK_ROOT} \
#  && git config --system --add safe.directory /opt/flutter

# # Passer en jenkins AVANT le precache pour créer le cache avec les bons droits
# USER jenkins
# ENV PATH=${PATH}:${FLUTTER_HOME}/bin

# # Precache Flutter (en jenkins) — prépare l’engine pour l’arch de build
# RUN git config --global --add safe.directory /opt/flutter || true \
#  && flutter --version \
#  && flutter precache --android --force

# # Dossier de travail
# WORKDIR /home/jenkins/agent
