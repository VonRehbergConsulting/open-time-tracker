#!/bin/bash
VERSION=$1
BUILD_NUMBER=$(grep -oP 'version: \d+\.\d+\.\d+\+\K\d+' pubspec.yaml)
NEW_BUILD_NUMBER=$((BUILD_NUMBER + 1))

# Update pubspec.yaml
sed -i "s/version: .*/version: ${VERSION}+${NEW_BUILD_NUMBER}/" pubspec.yaml

# Update Android build.gradle
sed -i "s/versionName .*/versionName \"${VERSION}\"/" android/app/build.gradle
sed -i "s/versionCode .*/versionCode ${NEW_BUILD_NUMBER}/" android/app/build.gradle

# Update iOS project.pbxproj
sed -i "s/MARKETING_VERSION = .*/MARKETING_VERSION = ${VERSION};/" ios/Runner.xcodeproj/project.pbxproj
sed -i "s/CURRENT_PROJECT_VERSION = .*/CURRENT_PROJECT_VERSION = ${NEW_BUILD_NUMBER};/" ios/Runner.xcodeproj/project.pbxproj

echo "Updated version to ${VERSION}+${NEW_BUILD_NUMBER}"
