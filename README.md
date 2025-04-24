# Shared Github Actions workflows

This repository contains reusable GitHub Actions and Workflows for GetStream projects.

## Actions

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
