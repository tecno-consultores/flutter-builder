FROM ubuntu:26.04
LABEL org.opencontainers.image.authors="sinfallas@gmail.com"

ENV DEBIAN_FRONTEND="noninteractive"
ENV JAVA_VERSION="21"
ENV JAVA_HOME="/usr/lib/jvm/java-21-openjdk-amd64"
ENV TZ="America/Caracas"
ENV GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no"
ENV GRADLE_VERSION="9.7.1"
ENV GRADLE_HOME="/opt/gradle"
ENV GRADLE_USER_HOME="/root/.gradle"
ENV GRADLE_OPTS="-Xmx2048m -Dorg.gradle.jvmargs=-Xmx2048m -Dorg.gradle.daemon=false -Dorg.gradle.workers.max=2 -Dorg.gradle.caching=true"
ENV GRADLE_URL="https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip"
ENV ANDROID_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-15859902_latest.zip"
ENV ANDROID_VERSION="36"
ENV ANDROID_BUILD_TOOLS_VERSION="36.0.0"
ENV ANDROID_NDK_VERSION="28.2.13676358"
ENV CMAKE_VERSION="3.22.1"
ENV ANDROID_ARCHITECTURE="x86_64"
ENV ANDROID_SDK_ROOT="/usr/local/android-sdk"
ENV ANDROID_HOME="/usr/local/android-sdk"
ENV FLUTTER_CHANNEL="stable"
ENV FLUTTER_VERSION="3.47.9"
ENV FLUTTER_ROOT="/opt/flutter"
ENV FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/$FLUTTER_CHANNEL/linux/flutter_linux_$FLUTTER_VERSION-$FLUTTER_CHANNEL.tar.xz"
ENV PATH="$JAVA_HOME/bin:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/platforms:$FLUTTER_ROOT/bin:$GRADLE_HOME/bin:$PATH"

WORKDIR /app

# dependencias
RUN rm -f /etc/dpkg/dpkg.cfg.d/excludes && mkdir -p /usr/share/man/man1
RUN apt-get update -qq && apt-get -o Acquire::Retries=5 -y dist-upgrade && apt-get -o Acquire::Retries=5 -y install --no-install-recommends --no-install-suggests ruby-full rubygems build-essential awscli nano openjdk-$JAVA_VERSION-jdk aria2 pixz curl unzip sed git bash xz-utils libglvnd0 ssh xauth x11-xserver-utils libpulse0 libxcomposite1 libgl1 && apt-get clean && apt-get -y autoremove && rm -rf /var/lib/apt/lists/* /tmp/* /usr/share/man/* /usr/share/doc/*

# fastlane
RUN gem install fastlane -NV

# gradle
RUN aria2c -x 16 -s 16 -k 1M --file-allocation=none --console-log-level=warn -d /app -o gradle.zip "$GRADLE_URL" && unzip -q gradle.zip && mv gradle-${GRADLE_VERSION} $GRADLE_HOME && rm -fv gradle.zip && mkdir -p $GRADLE_USER_HOME && printf "org.gradle.jvmargs=-Xmx2048m -XX:MaxMetaspaceSize=512m -XX:ReservedCodeCacheSize=256m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8\norg.gradle.daemon=false\norg.gradle.workers.max=2\norg.gradle.caching=true\n" > $GRADLE_USER_HOME/gradle.properties

# android sdk
RUN mkdir -p /root/.android $ANDROID_SDK_ROOT && touch /root/.android/repositories.cfg && aria2c -x 16 -s 16 -k 1M --file-allocation=none --console-log-level=warn -d /app -o android_tools.zip "$ANDROID_TOOLS_URL" && unzip -qq -d "$ANDROID_SDK_ROOT" android_tools.zip && rm -fv android_tools.zip && mkdir -p $ANDROID_SDK_ROOT/cmdline-tools/latest && mv $ANDROID_SDK_ROOT/cmdline-tools/bin $ANDROID_SDK_ROOT/cmdline-tools/latest/ && mv $ANDROID_SDK_ROOT/cmdline-tools/lib $ANDROID_SDK_ROOT/cmdline-tools/latest/ && yes "y" | sdkmanager --licenses && yes "y" | sdkmanager "platform-tools" "build-tools;$ANDROID_BUILD_TOOLS_VERSION" "platforms;android-$ANDROID_VERSION" "ndk;$ANDROID_NDK_VERSION" "cmake;$CMAKE_VERSION"

# flutter
RUN aria2c -x 16 -s 16 -k 1M --file-allocation=none --console-log-level=warn -d /app -o flutter.tar.xz "$FLUTTER_URL" && mkdir -p $FLUTTER_ROOT && tar -I pixz -xf flutter.tar.xz -C /opt/ && rm -fv flutter.tar.xz && git config --global --add safe.directory /opt/flutter && flutter config --no-analytics --jdk-dir=$JAVA_HOME && flutter precache --android && mkdir -p $GRADLE_USER_HOME/wrapper/dists/gradle-9.3.1-all/9ot9r568e8zfvvd4mn8rbu1j0 && aria2c -x 16 -s 16 -k 1M --file-allocation=none --console-log-level=warn -d $GRADLE_USER_HOME/wrapper/dists/gradle-9.3.1-all/9ot9r568e8zfvvd4mn8rbu1j0 -o gradle-9.3.1-all.zip "https://services.gradle.org/distributions/gradle-9.3.1-all.zip" && flutter create /tmp/warmup && cd /tmp/warmup/android && ./gradlew help --no-daemon && cd /app && rm -rf /tmp/warmup && flutter doctor

CMD ["/bin/bash"]
ARG BUILD_DATE
LABEL org.opencontainers.image.created=$BUILD_DATE
