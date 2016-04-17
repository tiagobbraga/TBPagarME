//
//  TBPagarME.swift
//  PassaPraFrente
//
//  Created by Tiago Braga on 4/14/16.
//  Copyright © 2016 Tiago Braga. All rights reserved.
//

import Foundation
import SwiftLuhn
import SwiftyRSA

typealias SuccessCardHash = (card_hash: String) -> Void

public class TBPagarME: NSObject {
    
    // API pagar.me
    static private let baseURL: String = "https://api.pagar.me/1"
    static private let card_hash = transactions + "/card_hash_key?encryption_key=%@" // generate card_hash
    static private let transactions = "/transactions" // create transaction
    
    static private let API_KEY: String = "apiKey"
    static private let ENCRYPTION_KEY: String = "encryptionKey"
    
    public var cardNumber: String?
    public var cardHolderName: String?
    public var cardExpirationMonth: String?
    public var cardExpirationYear: String?
    public var cardCVV: String?
    
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
    
    public func transaction(amount: String) {
        self.generateNewPublicKey { (card_hash) in
            
            var params: [String: AnyObject] = [String: AnyObject]()
            params["api_key"] = self.apiKey()
            params["amount"] = amount
            params["card_hash"] = card_hash
            
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
                        let err = json["error"] as? [String: AnyObject]
                        if let _ = err {
                            print("err \(err)")
                        } else {
                            print("json \(json)")
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
        // validate encryptionKey
        // validate data card
        
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
                } else {
                    print("json \(json)")
                }
                
                let _id = json["id"] as! Int
                let publicKeyPEM = json["public_key"] as! String
                let swiftRSA = try SwiftyRSA.encryptString(self.cardHash(), publicKeyPEM: publicKeyPEM)
                
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
    
    private func cardHash() -> String {
        return String(format: "card_number=%@&card_holder_name=%@&card_expiration_date=%@%@&card_cvv=%@",
                      cardNumber!, cardHolderName!, cardExpirationMonth!, cardExpirationYear!, cardCVV!)
    }
}