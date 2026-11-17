# Daftari

A small Flutter notebook for Android. Write pages, change the date on any page, and edit or delete saved pages. Everything is stored locally in SQLite; the app does not need an internet connection.

## Build an APK with GitHub

1. Create an empty repository on GitHub.
2. In this folder, initialize Git and push the project to the repository's `main` branch:

   ```powershell
   git init
   git add .
   git commit -m "Create Daftari Flutter app"
   git branch -M main
   git remote add origin https://github.com/YOUR-NAME/YOUR-REPOSITORY.git
   git push -u origin main
   ```

3. On GitHub, open **Actions** and wait for **Build Android APK** to finish.
4. Download the APK from the workflow run's `daftari-android-apk` artifact or from the repository's **Releases** page.

The workflow runs Flutter tests and analysis before building the APK. Pushes to `main` or `master` trigger a build; you can also start one manually from the Actions tab. Each successful run uploads an artifact and creates a prerelease with the APK. The generated APK is signed with the default debug key for testing and direct installation. Publishing through Google Play requires configuring your own release signing key.

## Build locally

Install Flutter 3.24 or newer and the Android SDK, then run:

```powershell
flutter pub get
flutter test
flutter build apk --release
```

The APK is written to `build/app/outputs/flutter-apk/app-release.apk`.
