# actions_workflows
Shared Github Actions workflows

## Android SDK size

```yaml
jobs:
  my-job:
    uses: GetStream/actions_workflows/.github/workflows/android-sdk-size.yml@main
    with:
      modules: "stream-chat-android-client stream-chat-android-compose"
      metricsProject: "stream-chat-android-metrics"
```

** ℹ️ Make sure to set up a metrics project with build favors that match with the module. See an example as the [Chat SDK](https://github.com/GetStream/stream-chat-android/blob/develop/metrics/stream-chat-android-metrics/build.gradle.kts) **
