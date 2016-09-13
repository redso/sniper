# Sniper

[![CI Status](http://img.shields.io/travis/Paulo Lam/Sniper.svg?style=flat)](https://travis-ci.org/Paulo Lam/Sniper)
[![Version](https://img.shields.io/cocoapods/v/Sniper.svg?style=flat)](http://cocoapods.org/pods/Sniper)
[![License](https://img.shields.io/cocoapods/l/Sniper.svg?style=flat)](http://cocoapods.org/pods/Sniper)
[![Platform](https://img.shields.io/cocoapods/p/Sniper.svg?style=flat)](http://cocoapods.org/pods/Sniper)

Sniper help you to manage localization strings in Google Spread Sheet.

## Features

- [x] Sync strings file from Google Spread Sheet
- [x] Version control of strings in the same Google Spread Sheet
- [x] Cache latest strings file
- [x] Adding new language support on the fly, without submit new app
- [x] In App change language

## Example

To sync strings file from Google Spread Sheet, you just need to get the key of your spread sheet file (make sure your spread sheet is public)
Example: https://docs.google.com/spreadsheets/d/1Cx4POxesRmDHNcMGykQ3vOvEufKgcYhWZAyFMRZN5HQ/edit#gid=1964479930
```swift
Sniper.sharedInstance.retrieveRemoteWordDict("1Cx4POxesRmDHNcMGykQ3vOvEufKgcYhWZAyFMRZN5HQ")
```


To change language of the app
```swift
Sniper.saveSelectedLocaleIdentifier(locale)
```


Retrieve localized string
```swift
"TXT_test".localizedString()
```

## Installation

Sniper is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Sniper"
```

## Author

Paulo Lam, paulo@beyond-six.com

## License

Sniper is available under the MIT license. See the LICENSE file for more info.
