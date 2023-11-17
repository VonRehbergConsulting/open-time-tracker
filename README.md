# Open Time Tracker ![](https://github.com/VonRehbergConsulting/open-time-tracker/actions/workflows/build_and_test.yaml/badge.svg) ![](https://github.com/VonRehbergConsulting/open-time-tracker/actions/workflows/deploy-android.yaml/badge.svg) ![](https://github.com/VonRehbergConsulting/open-time-tracker/actions/workflows/deploy-ios.yaml/badge.svg)

This repo contains the source code for time tracking application. This app is a client for Open Project that allows users to easily track their time spent on various tasks, projects.  
You can also take a look at *[app's webpage](https://open-time-tracker.com)*

## How to run it locally

- Install flutter SDK
- Clone the repository
- Navigate to the cloned repository
- Download and install all the required dependencies
```
fvm flutter pub get
```
- Generate the required code for the app to run
```
fvm dart run build_runner build --delete-conflicting-outputs
```
- Connect your Android or iOS device to your computer, or launch an emulator
- Launch the app on your device or emulator
```
fvm flutter run
```
