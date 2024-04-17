FROM ubuntu:22.04
LABEL maintainer="Jesus Palencia sinfallas@gmail.com"

USER root
WORKDIR /app
ENV PATH="/usr/bin/flutter/platform-tools:/usr/bin/flutter/emulator:/usr/bin/flutter/bin:/usr/bin/flutter/bin/cache/dart-sdk/bin:${PATH}"
ENV FLUTTER_STORAGE_BASE_URL=https://mirrors.tuna.tsinghua.edu.cn/flutter
ENV PUB_HOSTED_URL=https://mirrors.tuna.tsinghua.edu.cn/dart-pub
#ENV ANDROID_SDK_ROOT=/app/Android/sdk
#ENV ANDROID_HOME=/app/Android/sdk LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 LANGUAGE=en_US:en
#ENV PUB_HOSTED_URL=https://pub.flutter-io.cn
#ENV FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
RUN mkdir -p Android/sdk && mkdir -p .android && touch .android/repositories.cfg
RUN apt update -qq && apt -y dist-upgrade && apt -y install --no-install-recommends --no-install-suggests adb android-sdk locales libgtk-3-dev liblzma-dev build-essential ssh pkg-config unzip xz-utils libglu1-mesa clang cmake ninja-build libxtst6 libnss3-dev libnspr4 libxss1 libasound2 libatk-bridge2.0-0 libgtk-3-0 libgdk-pixbuf2.0-0 libsqlite3-dev openjdk-11-jdk sudo wget bc software-properties-common ruby-full ruby-bundler libstdc++6 libpulse0 curl file git zip && apt clean && rm -rf /var/lib/apt/lists/*
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen && update-locale LANG=en_US.UTF-8
RUN wget -O sdk-tools.zip https://dl.google.com/android/repository/platform-tools-latest-linux.zip?hl=es-419 && mv -f sdk-tools.zip /app/Android/sdk/sdk-tools.zip && cd /app/Android/sdk/ && unzip sdk-tools.zip && rm sdk-tools.zip
RUN mkdir -p /usr/bin/flutter/
RUN git clone https://github.com/flutter/flutter.git /usr/bin/flutter/
#COPY . ./
RUN flutter doctor -v
CMD ["/bin/bash"]
