# Shared Github Actions workflows

This repository contains reusable GitHub Actions and Workflows for GetStream projects.

## Actions

### Allure Launch

This action launches Allure TestOps jobs for test reporting and analysis. It's designed to work with Fastlane for test execution and reporting.

#### Usage

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: GetStream/actions_workflows/actions/allure-launch@main
        with:
          allure-token: ${{ secrets.ALLURE_TOKEN }}
          cron: 'false' # Optional: Set to true for scheduled runs
```

#### Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `allure-token` | Allure TestOps authentication token | Yes | - |
| `cron` | Indicates if this is a scheduled cron job run | No | false |

#### Environment Variables

The action sets the following environment variables:
- `ALLURE_TOKEN`: Authentication token for Allure TestOps
- `GITHUB_EVENT`: GitHub event data in JSON format

### Enable KVM

This action enables hardware accelerated Android virtualization on Actions Linux larger hosted runners. It's required for running Android emulators in GitHub Actions workflows.

#### Usage

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: GetStream/actions_workflows/actions/enable-kvm@main
      - name: Run Android tests
        run: ./gradlew connectedCheck
```

#### Details

The action performs the following operations:
- Creates a udev rule for KVM device access
- Sets appropriate permissions for the KVM group
- Reloads udev rules to apply changes

### Setup Java

This action sets up a Java environment with version 17 and Adopt distribution by default. 

#### Usage

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: GetStream/actions_workflows/actions/setup-java@main
        with:
          java-version: '17'      # Optional: Java version (default: 17)
          distribution: 'adopt'   # Optional: Java distribution (default: adopt)
```

#### Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `java-version` | Java version to install (e.g., 8, 11, 17, 21) | No | 17 |
| `distribution` | Java distribution (adopt, temurin, zulu, amazon, microsoft) | No | adopt |

### Gradle Cache

This action caches Gradle dependencies to speed up your workflow execution. It's designed to be used in any Gradle-based project.

#### Usage

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: GetStream/actions_workflows/actions/gradle-cache@main
        with:
          cache-name: 'my-workflow' # Optional: Custom cache name
```

#### Details

The action will cache the following Gradle directories:
- `~/.gradle/caches`
- `~/.gradle/wrapper`

The cache key is based on:
- Runner OS
- Custom cache name (if provided)
- Hash of Gradle files (*.gradle*, gradle-wrapper.properties, and libs.versions.toml)

## Workflows

### Android SDK Size

This workflow measures the size of Android SDK modules and reports the metrics.

#### Usage

```yaml
jobs:
  my-job:
    uses: GetStream/actions_workflows/.github/workflows/android-sdk-size.yml@main
    with:
      modules: "stream-chat-android-client stream-chat-android-compose"
      metricsProject: "stream-chat-android-metrics"
```

#### Requirements

**ℹ️ Make sure to set up a metrics project with build favors that match with the module. See an example in the [Chat SDK](https://github.com/GetStream/stream-chat-android/blob/develop/metrics/stream-chat-android-metrics/build.gradle.kts)**
