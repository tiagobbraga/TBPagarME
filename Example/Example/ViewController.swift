//
//  ViewController.swift
//  Example
//
//  Created by Tiago Braga on 4/18/16.
//  Copyright © 2016 Tiago Braga. All rights reserved.
//

import UIKit
import TBPagarME

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        transaction()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func transaction() {
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
    }


}

