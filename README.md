# kitchin

## Your Kitchen. Your Way.

# Table of Contents
1. [Introduction](#introduction)
2. [Installation](#installation)
3. [Usage](#usage)
4. [Contributing](#contributing)
5. [License](#license)

## Introduction

Still under development...

## Installation

KitchIN is a mobile application that can be downloaded from the App Store or Google Play Store. To deploy the application locally, follow the instructions below:

1. Download the necessary files from the GitHub repository, located at [https://github.com/joshualim30/kitchin](https://github.com/joshualim30/kitchin).

2. Install a code editor, such as [Visual Studio Code](https://code.visualstudio.com/).

    2.1. Install Android Studio and the Android Emulator.

    2.2. (Optional, Mac only) Install Xcode and the iOS Simulator.

3. Install [Flutter](https://flutter.dev/) and [Dart](https://dart.dev/) on your local machine. More detailed instructions can be found in the [Flutter documentation](https://flutter.dev/docs/get-started/install).

4. Open the project in Visual Studio Code and run the following command in the terminal:

    ```
    flutter pub get
    ```

5. Download the [Firebase CLI](https://firebase.google.com/docs/cli) and set up a Firebase project (if you were not invited to the existing project).

6. Authenticate the Firebase CLI with your Google account by running the following command in the terminal:

    ```
    firebase login
    ```

    You will be prompted to sign in with your Google account. More detailed instructions can be found in the [Firebase documentation](https://firebase.google.com/docs/flutter/setup).

7. Create a .ENV file in the root directory of the project and add the following environment variables:

    `TODO: Add environment variables`

8. Run the following command in the terminal to deploy the application locally:

    ```
    flutter run
    ```

    Or to run a release build:

    ```
    flutter run --release
    ```