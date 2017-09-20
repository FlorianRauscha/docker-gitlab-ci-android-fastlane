FROM openjdk:8-jdk

MAINTAINER Florian Rauscha "florian.rauscha@gmail.com"

ENV ANDROID_EMULATOR_DEPS "file libqt5widgets5"
ENV ANDROID_SDK_URL https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip
ENV ANDROID_HOME /opt/android-sdk-linux

ENV ANDROID_PLATFORM_VERSION_26 26
ENV ANDROID_PLATFORM_VERSION_25 25

ENV ANDROID_BUILD_TOOLS_VERSION 26.0.1
ENV ANDROID_EXTRA_PACKAGES "build-tools;26.0.0"


ENV ANDROID_REPOSITORIES "extras;android;m2repository" "extras;google;m2repository"
ENV ANDROID_CONSTRAINT_PACKAGES "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2" "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.1" "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.0"
ENV ANDROID_EMULATOR_X86 "system-images;android-$ANDROID_PLATFORM_VERSION_26;google_apis_playstore;x86"
ENV ANDROID_EMULATOR_ARM "system-images;android-$ANDROID_PLATFORM_VERSION_25;google_apis;armeabi-v7a"

ENV ANDROID_API_X86 "google_apis_playstore/x86"
ENV ANDROID_API_ARM "google_apis/armeabi-v7a"

ENV PATH "$PATH:/opt/tools:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/emulator:${ANDROID_HOME}/platform-tools"
ENV DEBIAN_FRONTEND noninteractive

# Install Libs
RUN apt-get -qq update && \
    apt-get install -qqy --no-install-recommends \
      curl \
      html2text \
      libc6-i386 \
      lib32stdc++6 \
      lib32gcc1 \
      lib32ncurses5 \
      lib32z1 \
      wget \
      unzip \
      zip \
      git \
      ruby \
      ruby-dev \
      build-essential \
      file \
      ssh \
      libqt5widgets5 \
      libqt5svg5 \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Fastlane
RUN gem install fastlane

# Install Android Emulator Dependencies
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - \
    && apt-get update \
    && apt-get install -y nodejs expect $ANDROID_EMULATOR_DEPS \
    && apt-get autoclean

# Install the Android SDK
RUN cd /opt \
    && wget --output-document=android-sdk.zip --quiet $ANDROID_SDK_URL \
    && unzip android-sdk.zip -d android-sdk-linux \
    && rm -f android-sdk.zip \
    && chown -R root:root android-sdk-linux

# Install custom tools
COPY tools /opt/tools

# Install Android platform and things
RUN android-accept-licenses "sdkmanager --verbose \"platform-tools\" \"emulator\" \"platforms;android-$ANDROID_PLATFORM_VERSION_26\" \"platforms;android-$ANDROID_PLATFORM_VERSION_25\" \"build-tools;$ANDROID_BUILD_TOOLS_VERSION\" $ANDROID_EXTRA_PACKAGES $ANDROID_REPOSITORIES $ANDROID_CONSTRAINT_PACKAGES $ANDROID_EMULATOR_X86 $ANDROID_EMULATOR_ARM"

# Create Emulator
# android-avdmanager-create "avdmanager create avd --package \"$ANDROID_EMULATOR_X86\" --name test --abi \"$ANDROID_ABI_X86\""
# android-avdmanager-create "avdmanager create avd --package \"$ANDROID_EMULATOR_ARM\" --name test --abi \"$ANDROID_ABI_ARM\""

# Fix for emulator detect 64bit
ENV SHELL /bin/bash
