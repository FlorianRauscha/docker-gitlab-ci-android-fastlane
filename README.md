# docker-gitlab-ci-android-fastlane
Docker Container for building and testing Android Applications on GitLab CI

## Description

This docker image is inspired by [ekreative/android-docker](https://github.com/ekreative/android-docker) and [peterturza/gitlab-ci-android-fastlane](https://github.com/peterturza/gitlab-ci-android-fastlane).

## Example .gitlab-ci.yml

```
image: florianrauscha/gitlab-ci-android-fastlane:latest

stages:
    - build
    - test

before_script:
    - export GRADLE_USER_HOME=`pwd`/.gradle
    - mkdir -p $GRADLE_USER_HOME
    - chmod +x ./gradlew

cache:
    paths:
        - .gradle/wrapper
        - .gradle/caches

build:
    stage: build
    script:
        - ./gradlew :app:assembleDebug
    artifacts:
        paths:
            - app/build/outputs/

unitTests:
    stage: test
    script:
        - ./gradlew :app:test

functionalTests:
    stage: test
    before_script:
        - android-avdmanager-create "avdmanager create avd --package \"$ANDROID_EMULATOR_ARM\" --name test --abi \"$ANDROID_ABI_ARM\""
        # Start the emulator in the background
        - $ANDROID_HOME/emulator/emulator -avd test -no-skin -no-audio -no-window &
    script:
        - android-wait-for-emulator
        - adb devices
        # Simulate hitting the menu button
        - adb shell input keyevent 82 &
        - ./gradlew :app:connectedAndroidTest
    artifacts:
        paths:
            - app/build/reports/androidTests/
```
