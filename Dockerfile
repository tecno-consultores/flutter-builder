FROM ubuntu:26.04
LABEL maintainer="Jesus Palencia sinfallas@gmail.com"

ENV DEBIAN_FRONTEND="noninteractive"
ENV JAVA_VERSION="17"
ENV ANDROID_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip"
ENV ANDROID_VERSION="34"
ENV ANDROID_BUILD_TOOLS_VERSION="34.0.0"
ENV ANDROID_ARCHITECTURE="x86_64"
ENV ANDROID_SDK_ROOT="/usr/local/android-sdk"
ENV FLUTTER_CHANNEL="stable"
ENV FLUTTER_VERSION="3.19.6"
ENV FLUTTER_ROOT="/opt/flutter"
ENV GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no"
ENV TZ="America/Caracas"
ENV PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/platforms:$FLUTTER_ROOT/bin:$GRADLE_USER_HOME/bin:$PATH"
ENV GRADLE_VERSION="8.4"
ENV GRADLE_USER_HOME="/opt/gradle"
ENV GRADLE_URL="https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip"

# 1. Instalación de dependencias del sistema operativo (en una sola capa)
RUN apt update -qq && apt -y dist-upgrade && apt -y install --no-install-recommends --no-install-suggests nginx awscli nano openjdk-$JAVA_VERSION-jdk curl unzip sed git bash xz-utils libglvnd0 ssh xauth x11-xserver-utils libpulse0 libxcomposite1 libgl1 && apt clean && apt -y autoremove && rm -rf /var/lib/{apt,dpkg,cache,log} && rm -rf /var/cache/* && rm -rf /var/log/apt/* && rm -rf /tmp/*

# 2. Instalación de Gradle
RUN curl -L $GRADLE_URL -o gradle.zip && unzip -q gradle.zip && mv gradle-${GRADLE_VERSION} $GRADLE_USER_HOME && rm -fv gradle.zip

# 3. Instalación de Android SDK
RUN mkdir -p /root/.android $ANDROID_SDK_ROOT && touch /root/.android/repositories.cfg && curl -o android_tools.zip $ANDROID_TOOLS_URL && unzip -qq -d "$ANDROID_SDK_ROOT" android_tools.zip && rm android_tools.zip && mkdir -p $ANDROID_SDK_ROOT/cmdline-tools/latest && mv $ANDROID_SDK_ROOT/cmdline-tools/bin $ANDROID_SDK_ROOT/cmdline-tools/latest/ && mv $ANDROID_SDK_ROOT/cmdline-tools/lib $ANDROID_SDK_ROOT/cmdline-tools/latest/ && yes "y" | sdkmanager "build-tools;$ANDROID_BUILD_TOOLS_VERSION" && yes "y" | sdkmanager "platforms;android-$ANDROID_VERSION" && yes "y" | sdkmanager "platform-tools"
