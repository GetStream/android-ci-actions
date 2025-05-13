# Shared Github Actions workflows

This repository contains reusable GitHub Actions and Workflows for GetStream projects.

## Actions

### Version Bumper

This action bumps major, minor, or patch version in a Kotlin Configuration.kt file. It's designed for Android projects using Kotlin DSL for version management.

#### Required File Format

The Configuration.kt file must contain the following version constants:
```kotlin
const val majorVersion = X
const val minorVersion = Y
const val patchVersion = Z
```

#### Usage

```yaml
jobs:
  bump:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: GetStream/android-ci-actions/actions/bump-version@main
        with:
          bump: 'patch'  # Required: major, minor, or patch
          file-path: 'buildSrc/src/main/kotlin/io/getstream/Configuration.kt'  # Required: Path to Configuration.kt
```

#### Inputs

| Input | Description | Required | Type | Options |
|-------|-------------|----------|------|---------|
| `bump` | Which part of the version to bump | Yes | choice | major, minor, patch |
| `file-path` | Path to Configuration.kt file containing the version information. The file must contain the required version constants. | Yes | string | - |

#### Outputs

| Output | Description |
|--------|-------------|
| `RELEASE_VERSION` | The new release version after bumping |

### Setup Ruby

This action sets up a Ruby environment with version 3.1 by default and enables bundler caching for faster dependency installation.

#### Usage

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: GetStream/android-ci-actions/actions/setup-ruby@main
        with:
          ruby-version: '3.1'     # Optional: Ruby version (default: 3.1)
          bundler-cache: 'true'   # Optional: Enable bundler caching (default: true)
```

#### Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `ruby-version` | Ruby version to install (e.g., 3.0, 3.1, 3.2) | No | 3.1 |
| `bundler-cache` | Whether to cache bundler dependencies | No | true |

### Allure Launch

This action launches Allure TestOps jobs for test reporting and analysis. It's designed to work with Fastlane for test execution and reporting.

#### Usage

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: GetStream/android-ci-actions/actions/allure-launch@main
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
      - uses: GetStream/android-ci-actions/actions/enable-kvm@main
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
      - uses: GetStream/android-ci-actions/actions/setup-java@main
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
      - uses: GetStream/android-ci-actions/actions/gradle-cache@main
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

### Release New Version

This workflow automates the complete process of releasing a new version, including version bumping, building, publishing to Maven Central, creating GitHub releases, and synchronizing branches.

#### Features
- Version bumping (major/minor/patch)
- Maven Central publication with support for different plugins:
  - Official Sonatype plugin (io.github.gradle-nexus.publish-plugin)
  - Alternative plugin (com.vanniktech.maven.publish)
- GitHub release creation
- Branch synchronization (release → main → develop)
- Custom changelog support
- Module exclusion for build

#### Required Secrets
| Secret | Description |
|--------|-------------|
| `OSSRH_USERNAME` | Sonatype username |
| `OSSRH_PASSWORD` | Sonatype password |
| `SIGNING_KEY_ID` | Signing key ID |
| `SIGNING_PASSWORD` | Signing key password |
| `SIGNING_KEY` | Signing key |
| `SONATYPE_STAGING_PROFILE_ID` | Sonatype staging profile ID |
| `STREAM_PUBLIC_BOT_TOKEN` | GitHub bot token |

#### Inputs
| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `ref` | Branch or ref to checkout | No | "release" |
| `bump` | Version bump type (major/minor/patch) | Yes | - |
| `file-path` | Path to Configuration.kt file containing version constants | Yes | - |
| `release-notes` | Content of the release notes to be used when publishing | No | "" |
| `excluded-modules` | Comma-separated list of modules to exclude | No | "stream-chat-android-ui-components-sample,stream-chat-android-compose-sample,stream-chat-android-docs" |
| `documentation-tasks` | Space-separated list of Gradle tasks to generate source and documentation JARs | No | "androidSourcesJar javadocJar" |
| `use-official-plugin` | Whether to use the official Sonatype plugin (io.github.gradle-nexus.publish-plugin) or the alternative (com.vanniktech.maven.publish) | No | true |

#### Jobs

##### 1. `publish`
**Purpose**: Builds and publishes the new version

**Steps**:
1. Checkout code from specified branch
2. Bump version using custom action
3. Commit version changes
4. Push to release branch
5. Setup Java environment
6. Build release version (with module exclusions)
7. Generate source and documentation JARs
8. Publish to Maven Central using the selected plugin
9. Create GitHub release

##### 2. `release_to_main`
**Purpose**: Syncs main branch with release

**Steps**:
1. Checkout main branch
2. Merge release into main
3. Push changes to main

##### 3. `main_to_develop`
**Purpose**: Syncs develop branch with main

**Steps**:
1. Checkout develop branch
2. Merge main into develop
3. Push changes to develop

#### Usage Examples

##### Using the official Sonatype plugin (default):
```yaml
- uses: GetStream/android-ci-actions/.github/workflows/release-new-version@main
  with:
    bump: 'minor'
    file-path: 'path/to/Configuration.kt'
    excluded-modules: 'sample-app,docs'
    release-notes: |
      ## What's Changed
      * Feature 1
      * Bug fix 1
      * Feature 2
  secrets:
    OSSRH_USERNAME: ${{ secrets.OSSRH_USERNAME }}
    OSSRH_PASSWORD: ${{ secrets.OSSRH_PASSWORD }}
    SIGNING_KEY_ID: ${{ secrets.SIGNING_KEY_ID }}
    SIGNING_PASSWORD: ${{ secrets.SIGNING_PASSWORD }}
    SIGNING_KEY: ${{ secrets.SIGNING_KEY }}
    SONATYPE_STAGING_PROFILE_ID: ${{ secrets.SONATYPE_STAGING_PROFILE_ID }}
    STREAM_PUBLIC_BOT_TOKEN: ${{ secrets.STREAM_PUBLIC_BOT_TOKEN }}
```

##### Using the alternative Maven publish plugin:
```yaml
- uses: GetStream/android-ci-actions/.github/workflows/release-new-version@main
  with:
    bump: 'minor'
    file-path: 'path/to/Configuration.kt'
    use-official-plugin: false
    documentation-tasks: 'sourcesJar dokkaJar'
  secrets:
    OSSRH_USERNAME: ${{ secrets.OSSRH_USERNAME }}
    OSSRH_PASSWORD: ${{ secrets.OSSRH_PASSWORD }}
    SIGNING_KEY_ID: ${{ secrets.SIGNING_KEY_ID }}
    SIGNING_PASSWORD: ${{ secrets.SIGNING_PASSWORD }}
    SIGNING_KEY: ${{ secrets.SIGNING_KEY }}
    SONATYPE_STAGING_PROFILE_ID: ${{ secrets.SONATYPE_STAGING_PROFILE_ID }}
    STREAM_PUBLIC_BOT_TOKEN: ${{ secrets.STREAM_PUBLIC_BOT_TOKEN }}
```

### Android SDK Size

This workflow measures the size of Android SDK modules and reports the metrics.

#### Usage

```yaml
jobs:
  my-job:
    uses: GetStream/android-ci-actions/.github/workflows/android-sdk-size.yml@main
    with:
      modules: "stream-chat-android-client stream-chat-android-compose"
      metricsProject: "stream-chat-android-metrics"
```

#### Requirements

**ℹ️ Make sure to set up a metrics project with build favors that match with the module. See an example in the [Chat SDK](https://github.com/GetStream/stream-chat-android/blob/develop/metrics/stream-chat-android-metrics/build.gradle.kts)**
