# Continuous integration

The `Flutter CI` GitHub Actions workflow runs the repository's quality gates on
every pull request targeting `main` and every push to `main`.

## Toolchain and caching

CI runs on GitHub-hosted Ubuntu and installs the stable Flutter version pinned
in `.fvmrc` (currently Flutter 3.44.8). The Flutter SDK and Dart pub dependency
caches are enabled. The committed `pubspec.lock` is enforced when dependencies
are installed so CI does not silently resolve a different dependency graph.

## Checks

The workflow runs these commands from the repository root:

```text
flutter pub get --enforce-lockfile
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test test/architecture
flutter test
```

The targeted architecture command gives the existing layer-boundary tests a
distinct CI result before the full Flutter test suite runs. The full suite also
discovers those tests.

## Limitations

- CI covers dependency resolution, formatting, static analysis, architecture
  boundaries, and host-compatible Flutter tests only.
- It does not run an Android emulator, build an APK or app bundle, validate
  Bluetooth/ELM327 hardware, or test the reference BYD Dolphin.
- It does not perform deployment, signing, release, Play Store, analytics, or
  cloud-service work.
- GitHub caches are an optimisation and may be evicted; a cache miss should
  only make the job slower.
- Repository branch protection must require the `Flutter quality gates` check
  if merges are to be blocked automatically when CI fails.
