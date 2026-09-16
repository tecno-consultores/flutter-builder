# flutter-builder

Environment designed to be used in CI/CD flows to compile modern Android APKs or App Bundles

Get this image on:
* [Docker Hub: sinfallas/flutter-builder](https://hub.docker.com/r/sinfallas/flutter-builder)

## 🛠️ Stack & Versions

* **OS:** Ubuntu 26.04
* **Java:** JDK 21
* **Gradle:** 8.7
* **Android SDK:** API 35 (Build Tools 35.0.0)
* **Flutter:** 3.24.0 (Stable Channel)

## 🚀 Usage (Docker Compose)

This image is built to act as an ephemeral CI/CD runner. It mounts your code, executes the build commands, outputs the artifacts directly to your host machine, and shuts down securely.

### 1. Project Structure
Place your Flutter project inside a folder (e.g., `codigo_flutter`) in the same directory as your `docker-compose.yml`:
```text
.
├── docker-compose.yml
└── codigo_flutter/
    ├── pubspec.yaml
    ├── lib/
    └── ...
```

### 2. docker-compose.yml
Use the following configuration to ensure the pipeline always pulls the latest image and executes the build correctly

```yaml
services:
  flutter-builder:
    image: sinfallas/flutter-builder:latest
    container_name: flutter_ci_runner
    hostname: flutter_ci_runner
    pull_policy: always
    volumes:
      - ./codigo_flutter:/app
    working_dir: /app
    command: bash -c "flutter pub get && flutter build apk --release"
```

### 3. Trigger the Build
Run the following command in your pipeline or local environment. The flags ensure the CI catches any compilation errors:
```bash
docker compose pull flutter-builder
docker compose up flutter-builder --abort-on-container-exit --exit-code-from flutter-builder
docker compose down -v
```

Once the container exits with code `0`, your generated APK will be available safely on your host machine at:
`./codigo_flutter/build/app/outputs/flutter-apk/app-release.apk`

## 🏗️ Building the Image (Maintainers)

To rebuild and push this image to Docker Hub, use the provided `build` script. The script uses Docker Buildx to compile strictly for `linux/amd64` (to maintain Android SDK binary compatibility) and performs an aggressive system prune afterwards to keep the build node clean.

```bash
chmod +x build
./build
```
