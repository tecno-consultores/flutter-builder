# flutter-builder

 [![Descargas de Docker](https://img.shields.io/docker/pulls/sinfallas/flutter-builder?style=flat&logo=docker&color=blue)](https://hub.docker.com/r/sinfallas/flutter-builder)

Environment designed to be used in CI/CD flows to compile modern Android APKs or App Bundles, and automate releases to Google Play Store using Fastlane.

## 🛠️ Stack & Versions

* **OS:** Ubuntu 26.04
* **Java:** OpenJDK 21 (LTS)
* **Gradle:** 9.7.1 (System) & 9.3.1 (Pre-cached Flutter Wrapper)
* **Android SDK:** API 36 & API 35 (Build Tools 36.0.0 & 35.0.0)
* **Android NDK:** 28.2.13676358 & CMake 3.22.1
* **Flutter:** 3.47.9 (Stable Channel)
* **Publishing:** Ruby + Fastlane (Included)

## 🚀 Usage (Docker Compose)

This image is built to act as an ephemeral CI/CD runner. It supports Docker Compose profiles to separate standard APK builds from Production App Bundle generation and Google Play publishing.

### 1. Project Structure
Place your Flutter project inside a folder (e.g., `codigo_flutter`) in the same directory as your `docker-compose.yml` and `.env` file:
```text
.
├── docker-compose.yml
├── .env
└── codigo_flutter/
    ├── pubspec.yaml
    ├── lib/
    ├── android/
    │   └── fastlane/  <-- (Required for Play Store deployment)
    └── ...
```

### 2. Environment Variables (.env)
Create a `.env` file to manage the container setup and inject secure credentials for the production build:
```env
hostname=flutter_ci_runner
pull_policy=always
GRADLE_OPTS=-Dorg.gradle.jvmargs="-Xmx2048m -XX:MaxMetaspaceSize=512m -XX:ReservedCodeCacheSize=256m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8" -Dorg.gradle.daemon=false -Dorg.gradle.workers.max=2 -Dorg.gradle.caching=true

# Required for 'pro' profile (Google Play Publishing)
PLAY_STORE_JSON_PATH="/path/to/your/secrets/google-play.json"
PACKAGE_NAME="com.tu.empresa.app"
KEYSTORE_PASSWORD="your_keystore_password"
KEY_ALIAS="your_key_alias"
KEY_PASSWORD="your_key_password"
```

### 3. docker-compose.yml
Use the following configuration leveraging profiles (`dev`, `pre`, `pro`):

```yaml
services:
  build-apk:
    image: sinfallas/flutter-builder:latest
    profiles: ["dev", "pre"]
    container_name: ${hostname:-flutter_ci_runner}
    hostname: ${hostname:-flutter_ci_runner}
    pull_policy: ${pull_policy:-always}
    volumes:
      - ./codigo_flutter:/app
      - gradle-cache:/root/.gradle
      - pub-cache:/root/.pub-cache
      - android-sdk-cache:/usr/local/android-sdk
    working_dir: /app
    environment:
      - GRADLE_OPTS=${GRADLE_OPTS:--Dorg.gradle.jvmargs="-Xmx2048m -XX:MaxMetaspaceSize=512m -XX:ReservedCodeCacheSize=256m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8" -Dorg.gradle.daemon=false -Dorg.gradle.workers.max=2 -Dorg.gradle.caching=true}
    command: bash -c "flutter pub get && flutter build apk --release -v"

  build-publish-aab:
    image: sinfallas/flutter-builder:latest
    profiles: ["pro"]
    container_name: ${hostname:-flutter_ci_runner}
    hostname: ${hostname:-flutter_ci_runner}
    pull_policy: ${pull_policy:-always}
    volumes:
      - ./codigo_flutter:/app
      - gradle-cache:/root/.gradle
      - pub-cache:/root/.pub-cache
      - android-sdk-cache:/usr/local/android-sdk
      - ${PLAY_STORE_JSON_PATH:-/tmp/secrets/google-play.json}:/secrets/play_store_key.json:ro
    working_dir: /app
    environment:
      - GRADLE_OPTS=${GRADLE_OPTS:--Dorg.gradle.jvmargs="-Xmx2048m -XX:MaxMetaspaceSize=512m -XX:ReservedCodeCacheSize=256m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8" -Dorg.gradle.daemon=false -Dorg.gradle.workers.max=2 -Dorg.gradle.caching=true}
      - KEYSTORE_PASSWORD=${KEYSTORE_PASSWORD:-}
      - KEY_ALIAS=${KEY_ALIAS:-}
      - KEY_PASSWORD=${KEY_PASSWORD:-}
      - PACKAGE_NAME=${PACKAGE_NAME:-}
    command: >
      bash -c "flutter pub get && 
      flutter build appbundle --release -v && 
      cd android && 
      fastlane supply --track production --aab ../build/app/outputs/bundle/release/app-release.aab --json_key /secrets/play_store_key.json --package_name $$PACKAGE_NAME"

volumes:
  gradle-cache:
  pub-cache:
  android-sdk-cache:
```

### 4. Trigger the Build

**For Development / Pre-release (Builds APK):**
```bash
docker compose --profile dev up --abort-on-container-exit
docker compose --profile dev down
```
*Artifact location:* `./codigo_flutter/build/app/outputs/flutter-apk/app-release.apk`

**For Production (Builds AAB & Publishes to Play Store):**
*Ensure your `.env` variables are correctly set or exported in your CI runner before executing.*
```bash
docker compose --profile pro up --abort-on-container-exit
docker compose --profile pro down
```

## 🏗️ Building the Image (Maintainers)

To rebuild and push this image to Docker Hub, use the provided `build-image` script. The script uses Docker Buildx to compile strictly for `linux/amd64` (to maintain Android SDK binary compatibility) and performs an aggressive system prune afterwards to keep the build node clean.

```bash
chmod +x build-image
./build-image
```
