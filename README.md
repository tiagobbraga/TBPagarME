# TBPagarME

[![CI Status](http://img.shields.io/travis/tiagobsbraga/TBPagarME.svg?style=flat)](https://travis-ci.org/tiagobsbraga/TBPagarME)
[![Version](https://img.shields.io/cocoapods/v/TBPagarME.svg?style=flat)](http://cocoapods.org/pods/TBPagarME)
[![License](https://img.shields.io/cocoapods/l/TBPagarME.svg?style=flat)](http://cocoapods.org/pods/TBPagarME)
[![Platform](https://img.shields.io/cocoapods/p/TBPagarME.svg?style=flat)](http://cocoapods.org/pods/TBPagarME)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

TBPagarME is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "TBPagarME"
```

### Init

Store initial keys

```swift
// https://dashboard.pagar.me/#/myaccount/apikeys
TBPagarME.storeKeys("api_key", encryptionKey: "credential_key")
```

### Transaction

Pay

```swift
TBPagarME.sharedInstance.cardNumber = "xxxxxxxxxxxxxxxx"
TBPagarME.sharedInstance.cardHolderName = "Swift Code"
TBPagarME.sharedInstance.cardExpirationMonth = "02"
TBPagarME.sharedInstance.cardExpirationYear = "22"
TBPagarME.sharedInstance.cardCVV = "123"

TBPagarME.sharedInstance.transaction("1000") // 10,00
```

## Author

Tiago Braga, contato@tiagobraga.cc

## License

TBPagarME is available under the MIT license. See the LICENSE file for more info.