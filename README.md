# flutter-builder

 [![Descargas de Docker](https://img.shields.io/docker/pulls/sinfallas/flutter-builder?style=flat&logo=docker&color=blue)](https://hub.docker.com/r/sinfallas/flutter-builder)

Environment designed to be used in CI/CD flows to compile modern Android APKs or App Bundles, and automate releases to Google Play Store using Fastlane.

## 🛠️ Stack & Versions

* **OS:** Ubuntu 26.04
* **Java:** JDK 26
* **Gradle:** 9.7.1
* **Android SDK:** API 35 (Build Tools 35.0.0)
* **Flutter:** 3.47.4 (Stable Channel)
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
    container_name: ${hostname} 
    hostname: ${hostname}
    pull_policy: ${pull_policy}
    volumes:
      - ./codigo_flutter:/app
    working_dir: /app
    command: bash -c "flutter pub get && flutter build apk --release"

  build-publish-aab:
    image: sinfallas/flutter-builder:latest
    profiles: ["pro"]
    container_name: ${hostname} 
    hostname: ${hostname}
    pull_policy: ${pull_policy}
    volumes:
      - ./codigo_flutter:/app
      - ${PLAY_STORE_JSON_PATH}:/secrets/play_store_key.json:ro
    working_dir: /app
    environment:
      - KEYSTORE_PASSWORD=${KEYSTORE_PASSWORD}
      - KEY_ALIAS=${KEY_ALIAS}
      - KEY_PASSWORD=${KEY_PASSWORD}
      - PACKAGE_NAME=${PACKAGE_NAME}
    command: >
      bash -c "flutter pub get && 
      flutter build appbundle --release && 
      cd android && 
      fastlane supply --track production --aab ../build/app/outputs/bundle/release/app-release.aab --json_key /secrets/play_store_key.json --package_name $$PACKAGE_NAME"
```

### 4. Trigger the Build

**For Development / Pre-release (Builds APK):**
```bash
docker compose --profile dev pull
docker compose --profile dev up --abort-on-container-exit
docker compose --profile dev down -v
```
*Artifact location:* `./codigo_flutter/build/app/outputs/flutter-apk/app-release.apk`

**For Production (Builds AAB & Publishes to Play Store):**
*Ensure your `.env` variables are correctly set or exported in your CI runner before executing.*
```bash
docker compose --profile pro pull
docker compose --profile pro up --abort-on-container-exit
docker compose --profile pro down -v
```

## 🏗️ Building the Image (Maintainers)

To rebuild and push this image to Docker Hub, use the provided `build` script. The script uses Docker Buildx to compile strictly for `linux/amd64` (to maintain Android SDK binary compatibility) and performs an aggressive system prune afterwards to keep the build node clean.

```bash
chmod +x build
./build
```
