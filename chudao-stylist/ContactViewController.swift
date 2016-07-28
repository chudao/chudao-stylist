//
//  ContactViewController.swift
//  chudao-user
//
//  Created by xuanlin yang on 7/28/16.
//  Copyright © 2016 chudao888. All rights reserved.
//

import UIKit

class ContactViewController: UIViewController {
    
    var userId: Int = -1
    var authToken: String = "undefined"
    var identity:String = "undefined"

    @IBAction func done(sender: AnyObject) {
        performSegueWithIdentifier("contactToHome", sender: self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Suggestpage serid: \(userId)")
        print("Suggestpage identity: \(identity)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if  segue.identifier == "contactToHome" {
            let destinationViewController = segue.destinationViewController as! TabBarViewController
            var sharedUserInfo = SharedUserInfo()
            sharedUserInfo = destinationViewController.sharedUserInfo
            sharedUserInfo.userId = userId
            sharedUserInfo.identity = identity
            sharedUserInfo.authToken = authToken
            destinationViewController.switchTo = "2"
        }
    }
    

}
