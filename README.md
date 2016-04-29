# TBPagarME

[![CI Status](http://img.shields.io/travis/tiagobsbraga/TBPagarME.svg?style=flat&branch=master)](https://travis-ci.org/tiagobsbraga/TBPagarME)
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
let pagarME = TBPagarME.sharedInstance
        
// card
pagarME.card.cardNumber = "xxxxxxxxxxxxxxxx"
pagarME.card.cardHolderName = "Name Owner Card"
pagarME.card.cardExpirationMonth = "12"
pagarME.card.cardExpirationYear = "17"
pagarME.card.cardCVV = "111"

// customer
pagarME.customer.name = "Onwer Card"
pagarME.customer.document_number = "09809889011"
pagarME.customer.email = "owner@card.com"
pagarME.customer.street = "Street"
pagarME.customer.neighborhood = "Neightborhood"
pagarME.customer.zipcode = "00000"
pagarME.customer.street_number = "1"
pagarME.customer.complementary = "Apt 805"
pagarME.customer.ddd = "031"
pagarME.customer.number = "986932196"

TBPagarME.sharedInstance.transaction("1000", success: { (data) in
    print("data transaction \(data)")
})
{ (message) in
    print("error message \(message)")
}
```

## Author

Tiago Braga, contato@tiagobraga.cc

## License

TBPagarME is available under the MIT license. See the LICENSE file for more info.
