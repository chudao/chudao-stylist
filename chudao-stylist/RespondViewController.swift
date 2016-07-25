//
//  RespondViewController.swift
//  chudao
//
//  Created by xuanlin yang on 7/18/16.
//  Copyright © 2016 chudao888. All rights reserved.
//

import UIKit

class RespondViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var userId: Int = -1
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var authToken: String = "undefined"
    var identity: String = "undefined"
    var responseDetail: [String:AnyObject] = [:]
    var recommendedProduct: [[String:AnyObject]] = []

    @IBOutlet var userNote: UILabel!
    @IBOutlet var stylistNote: UITextView!
    @IBAction func finishResponding(sender: AnyObject) {
        performSegueWithIdentifier("respondToHome", sender: self)
    }
    @IBOutlet var searchRequirement: UISearchBar!
    @IBAction func search(sender: AnyObject) {
        if searchRequirement.text == "" {
            
        }else{
            performSegueWithIdentifier("respondToSearch", sender: self)
        }
    }
    
    @IBOutlet var userDefaultImage: UIImageView!
    @IBOutlet var requestSpecificImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        
        if responseDetail["stylistNote"] as? String != "" {
            stylistNote.text = responseDetail["stylistNote"] as? String
        }
        
        if responseDetail["userNote"] as? String != "" {
            userNote.text = responseDetail["userNote"] as? String
        }
        
        if responseDetail["userDefaultImage"] != nil {
            userDefaultImage.image = UIImage(data: (responseDetail["userDefaultImage"] as? NSData)!)
        }
        
        if responseDetail["requestSpecificImage"] != nil {
            requestSpecificImage.image = UIImage(data: (responseDetail["requestSpecificImage"] as? NSData)!)
        }
        
        
        //activity indicator
        activityIndicator = UIActivityIndicatorView(frame: self.view.bounds)
        activityIndicator.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)

        //gesture to dismiss keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ProductDetailViewController.imageTapped(_:)))
        
        userDefaultImage.userInteractionEnabled = true
        userDefaultImage.addGestureRecognizer(tapRecognizer)
        
        requestSpecificImage.userInteractionEnabled = true
        requestSpecificImage.addGestureRecognizer(tapRecognizer)
    }
    
    func imageTapped(sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        let newImageView = UIImageView(image: imageView.image)
        newImageView.frame = self.view.frame
        newImageView.backgroundColor = .blackColor()
        newImageView.contentMode = .ScaleAspectFit
        newImageView.userInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(ProductDetailViewController.dismissFullscreenImage(_:)))
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
    }
    
    func dismissFullscreenImage(sender: UITapGestureRecognizer) {
        sender.view?.removeFromSuperview()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recommendedProduct.count
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            recommendedProduct.removeAtIndex(indexPath.row)
            tableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("respondToProductDetail", sender: indexPath.row)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellForRespond", forIndexPath: indexPath)
        cell.textLabel?.text = recommendedProduct[indexPath.row]["productName"] as? String
        cell.detailTextLabel?.text = recommendedProduct[indexPath.row]["productBrand"] as? String
        return cell
    }
    
    func submittRespond(){}

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "respondToHome" {
            let destinationViewController = segue.destinationViewController as! UITabBarController
            let navigationController = destinationViewController.viewControllers?.first as! UINavigationController
            let requestTableVIewController = navigationController.topViewController as! RequestTableViewController
            requestTableVIewController.userId = userId
            requestTableVIewController.identity = identity
            requestTableVIewController.authToken = authToken
        }
        
        if segue.identifier == "respondToSearch" {
            responseDetail["stylistNote"] = stylistNote.text
            let destinationViewController = segue.destinationViewController as! UINavigationController
            let productSearchReultController = destinationViewController.topViewController as! ProductSearchResultTableViewController
            productSearchReultController.userId = userId
            productSearchReultController.searchRequirement = searchRequirement.text!
            productSearchReultController.authToken = authToken
            productSearchReultController.identity = identity
            productSearchReultController.responseDetail = responseDetail
            productSearchReultController.recommendedProduct = recommendedProduct
        }

        if segue.identifier == "respondToProductDetail" {
            let destinationViewController = segue.destinationViewController as! RespondProductDetailViewController
            destinationViewController.authToken = authToken
            destinationViewController.identity = identity
            destinationViewController.userId = userId
            destinationViewController.productIndex = sender as! Int
            destinationViewController.recommendedProduct = recommendedProduct
            destinationViewController.responseDetail = responseDetail
        }
    }
    
    //dismiss keyboard by clicking anywhere else
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //dimiss keyboard by pressing return key
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    //display alert
    func displayAlert(title: String, message: String, enterMoreInfo: Bool) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        var title = "Ok"
        if enterMoreInfo == true {
            title = "Cancel"
            alert.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.Default, handler: { (action) in
                
            }))
        }
        alert.addAction(UIAlertAction(title: title, style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

}
