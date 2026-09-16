FROM ubuntu:26.04
LABEL maintainer="Jesus Palencia sinfallas@gmail.com"

ENV DEBIAN_FRONTEND="noninteractive" 
ENV JAVA_VERSION="21"
ENV TZ="America/Caracas"
ENV GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no"
ENV GRADLE_VERSION="8.7"
ENV GRADLE_USER_HOME="/opt/gradle"
ENV GRADLE_URL="https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip"
ENV ANDROID_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-15859902_latest.zip" 
ENV ANDROID_VERSION="35"
ENV ANDROID_BUILD_TOOLS_VERSION="35.0.0"
ENV ANDROID_ARCHITECTURE="x86_64"
ENV ANDROID_SDK_ROOT="/usr/local/android-sdk"
ENV FLUTTER_CHANNEL="stable"
ENV FLUTTER_VERSION="3.24.0"
ENV FLUTTER_ROOT="/opt/flutter"
ENV FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/$FLUTTER_CHANNEL/linux/flutter_linux_$FLUTTER_VERSION-$FLUTTER_CHANNEL.tar.xz"
ENV PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/platforms:$FLUTTER_ROOT/bin:$GRADLE_USER_HOME/bin:$PATH"

RUN apt-get update -qq && apt-get -y dist-upgrade && apt-get -y install --no-install-recommends --no-install-suggests nginx awscli nano openjdk-$JAVA_VERSION-jdk curl unzip sed git bash xz-utils libglvnd0 ssh xauth x11-xserver-utils libpulse0 libxcomposite1 libgl1 && apt-get clean && apt-get -y autoremove && rm -rf /var/lib/apt/lists/* /tmp/*

RUN curl -f -L $GRADLE_URL -o gradle.zip && unzip -q gradle.zip && mv gradle-${GRADLE_VERSION} $GRADLE_USER_HOME && rm -fv gradle.zip

RUN mkdir -p /root/.android $ANDROID_SDK_ROOT && touch /root/.android/repositories.cfg && curl -o android_tools.zip $ANDROID_TOOLS_URL && unzip -qq -d "$ANDROID_SDK_ROOT" android_tools.zip && rm android_tools.zip && mkdir -p $ANDROID_SDK_ROOT/cmdline-tools/latest && mv $ANDROID_SDK_ROOT/cmdline-tools/bin $ANDROID_SDK_ROOT/cmdline-tools/latest/ && mv $ANDROID_SDK_ROOT/cmdline-tools/lib $ANDROID_SDK_ROOT/cmdline-tools/latest/ && yes "y" | sdkmanager "build-tools;$ANDROID_BUILD_TOOLS_VERSION" && yes "y" | sdkmanager "platforms;android-$ANDROID_VERSION" && yes "y" | sdkmanager "platform-tools"

RUN curl -o flutter.tar.xz $FLUTTER_URL && mkdir -p $FLUTTER_ROOT && tar xf flutter.tar.xz -C /opt/ && rm flutter.tar.xz && git config --global --add safe.directory /opt/flutter && flutter config --no-analytics && flutter precache && yes "y" | flutter doctor --android-licenses && flutter doctor && flutter update-packages

EXPOSE 80
CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
