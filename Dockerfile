FROM ubuntu:20.04
LABEL maintainer="Jesus Palencia sinfallas@gmail.com"
ENV DEBIAN_FRONTEND="noninteractive"
ENV JAVA_VERSION="17"
ENV ANDROID_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip"
ENV ANDROID_VERSION="29"
ENV ANDROID_BUILD_TOOLS_VERSION="29.0.3"
ENV ANDROID_ARCHITECTURE="x86_64"
ENV ANDROID_SDK_ROOT="/usr/local/android-sdk"
ENV FLUTTER_CHANNEL="stable"
ENV FLUTTER_VERSION="3.19.6"
ENV GRADLE_VERSION="7.2"
ENV GRADLE_USER_HOME="/opt/gradle"
ENV GRADLE_URL="https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip"
ENV FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/$FLUTTER_CHANNEL/linux/flutter_linux_$FLUTTER_VERSION-$FLUTTER_CHANNEL.tar.xz"
ENV FLUTTER_ROOT="/opt/flutter"
ENV PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/platforms:$FLUTTER_ROOT/bin:$GRADLE_USER_HOME/bin:$PATH"
ENV FLUTTER_STORAGE_BASE_URL=https://mirrors.tuna.tsinghua.edu.cn/flutter
ENV PUB_HOSTED_URL=https://mirrors.tuna.tsinghua.edu.cn/dart-pub
ENV GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no"

RUN apt-get update -qq && apt-get -y install --no-install-recommends --no-install-suggests nginx nano openjdk-$JAVA_VERSION-jdk curl unzip sed git bash xz-utils libglvnd0 ssh xauth x11-xserver-utils libpulse0 libxcomposite1 libgl1-mesa-glx && rm -rf /var/lib/{apt,dpkg,cache,log} && apt-get clean

RUN curl -L $GRADLE_URL -o gradle-$GRADLE_VERSION-bin.zip
RUN unzip gradle-$GRADLE_VERSION-bin.zip
RUN mv gradle-$GRADLE_VERSION $GRADLE_USER_HOME
RUN rm gradle-$GRADLE_VERSION-bin.zip

RUN mkdir /root/.android
RUN touch /root/.android/repositories.cfg
RUN mkdir -p $ANDROID_SDK_ROOT
RUN curl -o android_tools.zip $ANDROID_TOOLS_URL
RUN unzip -qq -d "$ANDROID_SDK_ROOT" android_tools.zip
RUN rm android_tools.zip
RUN mv $ANDROID_SDK_ROOT/cmdline-tools $ANDROID_SDK_ROOT/latest
RUN mkdir -p $ANDROID_SDK_ROOT/cmdline-tools
RUN mv $ANDROID_SDK_ROOT/latest $ANDROID_SDK_ROOT/cmdline-tools/latest
RUN yes "y" | sdkmanager "build-tools;$ANDROID_BUILD_TOOLS_VERSION"
RUN yes "y" | sdkmanager "platforms;android-$ANDROID_VERSION"
RUN yes "y" | sdkmanager "platform-tools"

RUN curl -o flutter.tar.xz $FLUTTER_URL
RUN mkdir -p $FLUTTER_ROOT
RUN tar xf flutter.tar.xz -C /opt/
RUN rm flutter.tar.xz
RUN git config --global --add safe.directory /opt/flutter
RUN flutter config --no-analytics
RUN flutter precache
RUN yes "y" | flutter doctor --android-licenses
RUN flutter doctor
RUN flutter update-packages

EXPOSE 80
CMD /usr/sbin/nginx -g "daemon off;"
