# ArabamiSat
ArabamiSat is a smartphone application that helps users sell their car faster than ever.
With ArabamiSat, the user can:

* Add a new car for selling
* Pick an image from his gallery
* Work on offline mode

## Requirements

* Xcode 11
* CocoaPods 1.9

### Other used tools
* [Swiftlint](https://github.com/realm/SwiftLint) - A tool to enforce Swift style and conventions.

## First launch

1. Clone the repo
1. Execute the `pod install` in the project directory to install dependencies
1. Open the workspace `ArabamiSat.xcworkspace`
1. Run the target

## Dependencies

The project uses CocoaPods for dependencies and third-party libraries.
Here is a full list:

1. `Realm` and `RealmSwift` - Used as a DB for storing images for offline mode.
1. `Firebase/Firestore` - Used as a Cloud DB to sync the cars with the Cloud.
1. `Firebase/Core`, `Firebase/Analytics`, `Firebase/Performance`, `Firebase/Crashlytics` - Also used for product analytics, feedback collection and reporting/fixing crashes.
1. `SwiftLint` - Linter for code style improvement.

## Localization

Struct with localized strings could be found in `LocalizedStrings.swift` file.

## AuthenticationManager.swift
Constains logic for authenticating the user with Facebook and Google. (Firebase OAuth)

## DBManager.swift
Contains logic for writing and reading from local Realm database for images and for writing and reading the FirestoreDB.
