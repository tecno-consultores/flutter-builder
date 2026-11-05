# Changelog

Todos los cambios notables de este proyecto se documentarán en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/), y este proyecto se adhiere a [Semantic Versioning](https://semver.org/lang/es/).

## [Unreleased] - 2026-11-04

### 🐛 Corregido (Fixed)
* **Resolución de Bloqueos de Compilación (`Swap Thrashing` y Descargas Silenciosas en Segundo Plano):**
  * **Control de Memoria JVM y Concurrencia de Gradle (`Dockerfile`, `docker-compose.yml`, `env.example`):** Definido `GRADLE_OPTS` y preconfigurado `/root/.gradle/gradle.properties` (`$GRADLE_USER_HOME/gradle.properties`) con `-Xmx2048m -XX:MaxMetaspaceSize=512m -XX:ReservedCodeCacheSize=256m`, `org.gradle.daemon=false`, `org.gradle.workers.max=2` y `org.gradle.caching=true`. Al tener mayor precedencia que el archivo `android/gradle.properties` del proyecto, neutraliza la reserva excesiva de memoria (`-Xmx8G -XX:MaxMetaspaceSize=4G`) generada por las plantillas de Flutter sin necesidad de modificar el código fuente de la aplicación.
  * **Separación de `GRADLE_HOME` y `GRADLE_USER_HOME` (`Dockerfile`):** Corregida la colisión de rutas separando la instalación del binario de Gradle (`GRADLE_HOME="/opt/gradle"`) del directorio de caché y distribuciones del Wrapper (`GRADLE_USER_HOME="/root/.gradle"`).
  * **Compatibilidad de Java con Kotlin DSL y Gradle Wrapper (`Dockerfile`):** Ajustado `JAVA_VERSION` de `26` a `21` (OpenJDK 21 LTS), exportado `JAVA_HOME="/usr/lib/jvm/java-21-openjdk-amd64"` y vinculado en Flutter mediante `flutter config --jdk-dir=$JAVA_HOME`, garantizando compatibilidad total con el plugin Gradle de Flutter (`kotlin("jvm") 2.2.20`), Gradle `9.3.1` / `9.7.1`, AGP `9.1.0` y Kotlin `2.4.0`.

### 🚀 Añadido y Mejorado (Added & Changed)
* **Preinstalación Completa del Toolchain Android y Actualización a Flutter 3.47.9 (`Dockerfile`):**
  * Actualizado `FLUTTER_VERSION` de `3.47.4` a `3.47.9` (última versión del canal estable).
  * Incorporados `ANDROID_VERSION="36"`, `ANDROID_BUILD_TOOLS_VERSION="36.0.0"`, `ANDROID_NDK_VERSION="28.2.13676358"` y `CMAKE_VERSION="3.22.1"` (manteniendo además `platforms;android-35` y `build-tools;35.0.0` por retrocompatibilidad) para evitar la descarga en vivo de más de 1.5 GB durante la compilación.
  * Añadido paso de calentamiento (`warmup`) durante la construcción de la imagen (`flutter create /tmp/warmup && ./gradlew help --no-daemon`) para predescargar la distribución del Gradle Wrapper (`9.3.1`) y precompilar el plugin Gradle de Flutter dentro de la imagen.
* **Persistencia de Cachés y Trazabilidad en Docker Compose (`docker-compose.yml`, `env.example`):**
  * Añadidos los volúmenes `gradle-cache:/root/.gradle`, `pub-cache:/root/.pub-cache` y `android-sdk-cache:/usr/local/android-sdk` para conservar artefactos y posibles descargas futuras de SDK/NDK adicionales entre ejecuciones efímeras.
  * Añadidos valores por defecto seguros en variables de entorno (`${hostname:-flutter_ci_runner}`, `${pull_policy:-always}`) y el flag `--verbose` (`-v`) en `flutter build apk` y `flutter build appbundle` para exponer el progreso detallado en consola.
* **Documentación (`README.md`):**
  * Actualizada la tabla de versiones del stack, la plantilla de `.env`, la configuración de `docker-compose.yml` (omitiendo `-v` en `docker compose down` para preservar las cachés de compilación) y corregido el nombre del script de construcción de imagen a `./build-image`.
