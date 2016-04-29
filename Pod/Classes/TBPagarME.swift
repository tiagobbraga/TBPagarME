//
//  TBPagarME.swift
//
//  Created by Tiago Braga on 4/14/16.
//  Copyright © 2016 Tiago Braga. All rights reserved.
//

import Foundation
import SwiftLuhn
import SwiftyRSA

typealias SuccessCardHash = (card_hash: String) -> Void

public typealias SuccessTransaction = (data: [String: AnyObject]) -> Void
public typealias FailureTransaction = (message: String) -> Void

public struct Card {
    public var cardNumber: String?
    public var cardHolderName: String?
    public var cardExpirationMonth: String?
    public var cardExpirationYear: String?
    public var cardCVV: String?
    
    internal func cardHash() -> String {
        return String(format: "card_number=%@&card_holder_name=%@&card_expiration_date=%@%@&card_cvv=%@",
                      cardNumber!, cardHolderName!, cardExpirationMonth!, cardExpirationYear!, cardCVV!)
    }
    
    internal func check() -> String? {
        if let cn = self.cardNumber {
            if cn.isValidCardNumber() == false {
                return "invalid cardNumber"
            }
        } else {
            return "check the card number"
        }
        
        if self.cardHolderName == nil || self.cardHolderName?.characters.count <= 0 {
            return "check the card holder name"
        }
        
        if self.cardExpirationMonth == nil || self.cardExpirationMonth?.characters.count < 2 || (Int(self.cardExpirationMonth!)! <= 0 || Int(self.cardExpirationMonth!)! > 12) {
            return "check the card expiration month"
        }
        
        if self.cardExpirationYear == nil || self.cardExpirationYear?.characters.count < 2 || (Int(self.cardExpirationYear!)! <= 0 || Int(self.cardExpirationYear!)! > 99) {
            return "check the card expiration year"
        }
        
        if self.cardCVV == nil || self.cardCVV?.characters.count != 3 {
            return "check the card security code (CVV)"
        }
        
        return nil
    }
}

public struct Customer {
    public var name: String? = nil
    public var document_number: String? = nil
    public var email: String? = nil
    public var street: String? = nil
    public var neighborhood: String? = nil
    public var zipcode: String? = nil
    public var street_number: String? = nil
    public var complementary: String? = nil
    public var ddd: String? = nil
    public var number: String? = nil
    
    public init () { }
    
    public func data() -> [String: AnyObject] {
        var customer = [String: AnyObject]()
        
        customer["name"] = name
        customer["document_number"] = document_number
        customer["email"] = email
        
        var address = [String: AnyObject]()
        address["street"] = street
        address["neighborhood"] = neighborhood
        address["zipcode"] = zipcode
        address["street_number"] = street_number
        address["complementary"] = complementary
        customer["address"] = address
        
        var phone = [String: AnyObject]()
        phone["ddd"] = ddd
        phone["number"] = number
        customer["phone"] = phone
        
        return customer
    }
}

public class TBPagarME: NSObject {
    
    // API pagar.me
    static private let baseURL: String = "https://api.pagar.me/1"
    static private let transactions = "/transactions" // endPoint transaction
    static private let card_hash = transactions + "/card_hash_key?encryption_key=%@" // generate card_hash
    
    static private let API_KEY: String = "apiKey"
    static private let ENCRYPTION_KEY: String = "encryptionKey"
    
    public var card = Card()
    public var customer = Customer()
    
    // MARK: Singleton
    public class var sharedInstance: TBPagarME {
        struct Static {
            static var instance: TBPagarME?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) { () -> Void in
            Static.instance = TBPagarME()
        }
        
        return Static.instance!
    }
    
    // MARK: Public
    static public func storeKeys(apiKey: String, encryptionKey key: String) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setValue(apiKey, forKeyPath: API_KEY)
        userDefaults.setValue(key, forKeyPath: ENCRYPTION_KEY)
    }
    
    public func transaction(amount: String, success: SuccessTransaction, failure: FailureTransaction) {
        if let message = self.card.check() {
            failure(message: message)
            return
        }
        
        self.generateNewPublicKey { (card_hash) in
            
            var params: [String: AnyObject] = [String: AnyObject]()
            params["api_key"] = self.apiKey()
            params["amount"] = amount
            params["card_hash"] = card_hash
            params["customer"] = self.customer.data()
            
            do {
                let url = NSURL(string: String(format: "%@%@", TBPagarME.baseURL, TBPagarME.transactions))
                let request = NSMutableURLRequest(URL: url!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 20.0)
                request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                request.HTTPMethod = "POST"
                request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions())
                
                let session = NSURLSession.sharedSession()
                let dataTask = session.dataTaskWithRequest(request) { (data, response, error) in
                    do {
                        let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                        if let err = json["error"] as? [String: AnyObject] {
                            failure(message: String(err.first))
                        } else {
                            success(data: json as! [String : AnyObject])
                        }
                    } catch let err as NSError {
                        print(err.localizedDescription)
                    }
                }
                
                dataTask.resume()
            } catch let err as NSError {
                print(err.localizedDescription)
            }
        }
    }
    
    // MARK: Private
    private func generateNewPublicKey(success: SuccessCardHash) {
        let url = NSURL(string: String(format: "%@%@", TBPagarME.baseURL, String(format: TBPagarME.card_hash, self.encryptionKey())))
        let request = NSMutableURLRequest(URL: url!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 10.0)
        request.HTTPMethod = "GET"
        
        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithRequest(request) { (data, response, error) in
            if let _ = error {
                print("error \(error)")
                return;
            }
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                let err = json["error"] as? [String: AnyObject]
                if let _ = err {
                    print("err \(err)")
                }
                
                let _id = json["id"] as! Int
                let publicKeyPEM = json["public_key"] as! String
                let swiftRSA = try SwiftyRSA.encryptString(self.card.cardHash(), publicKeyPEM: publicKeyPEM)
                
                success(card_hash: String(format: "%@_%@", String(_id), swiftRSA))
                
            } catch let err as NSError {
                print(err.localizedDescription)
            }
        }
        
        dataTask.resume()
    }
    
    // MARK: Helper
    private func apiKey() -> String {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        return userDefaults.valueForKey(TBPagarME.API_KEY) as! String
    }
    
    private func encryptionKey() -> String {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        return userDefaults.valueForKey(TBPagarME.ENCRYPTION_KEY) as! String
    }
}