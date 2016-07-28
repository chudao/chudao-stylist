//
//  ProductDetailViewController.swift
//  chudao
//
//  Created by xuanlin yang on 7/9/16.
//  Copyright © 2016 chudao888. All rights reserved.
//

import UIKit

class ProductDetailViewController: UIViewController {

    var userId: Int = -1
    var identity: String = "undefined"
    var productId: String = ""
    var productName: String = ""
    var productBrand: String = ""
    var productLink: String = ""
    var productDescription: String = ""
    var authToken: String = "undefined"
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var imageAsNSData: NSData = NSData()
    var responseDetail: [String:AnyObject] = [:]
    var recommendedProduct: [[String:AnyObject]] = []
    var requestDetail: [String:AnyObject] = [:]
    var requestSpecificImageAsData = NSData()
    var userDefaultImageAsData = NSData()

    @IBOutlet var productImage: UIImageView!
    @IBOutlet var brand: UILabel!
    @IBOutlet var name: UILabel!
    @IBOutlet var descriptionInfo: UILabel!
    @IBAction func purchase(sender: AnyObject) {
            performSegueWithIdentifier("addToRespond", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        brand.text = productBrand
        descriptionInfo.text = productDescription
        name.text = productName
        productImage.clipsToBounds = true
        productImage.contentMode = UIViewContentMode.ScaleAspectFill

        //activity indicator
        activityIndicator = UIActivityIndicatorView(frame: self.view.bounds)
        activityIndicator.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        
        queryFileKey(productId)
        
        productImage.userInteractionEnabled = true
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ProductDetailViewController.imageTapped(_:)))
        productImage.addGestureRecognizer(tapRecognizer)
    
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
        // Dispose of any resources that can be recreated.
    }
    
    //display alert
    func displayAlert(title: String, message: String, enterMoreInfo: Bool) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        if enterMoreInfo == true {
            alert.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.Default, handler: { (action) in
                self.redirect()
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    //redirect to merchandiser's website using default internet browser
    func redirect(){
        UIApplication.sharedApplication().openURL(NSURL(string: self.productLink)!)
    }
    
    //query fileKey
    func queryFileKey(productId: String){
        //activate activity indicator and disable user interaction
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        // Setup the session to make REST POST call
        let postEndpoint: String = "http://chudao.herokuapp.com/query/file/product-ids"
        let url = NSURL(string: postEndpoint)!
        let session = NSURLSession.sharedSession()
        let postParams : [String: String] = ["product-ids": productId]
        
        // Create the request
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue(self.authToken, forHTTPHeaderField: "X-Auth-Token")
        
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(postParams, options: NSJSONWritingOptions())
            print("Request: \(postParams)")
        } catch {
            print("Error")
        }
        
        // Make the POST call and handle it in a completion handler
        session.dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) in
            //disable activiy indicator and re-activate user interaction
            self.activityIndicator.stopAnimating()
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
            
            // Make sure we get an OK response
            guard let realResponse = response as? NSHTTPURLResponse where
                realResponse.statusCode == 200 else {
                    print("Response code: \((response as? NSHTTPURLResponse)?.statusCode)")
                    return
            }

            
            // Read the JSON
            do{
                guard let jsonResponse = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? [String: AnyObject] else{
                    print("Error reading JSON data")
                    return
                }
                print(jsonResponse)
                if jsonResponse["response-code"]! as! String == "040" {
                    let productInfo = jsonResponse["response-data"] as? [[String:AnyObject]]
                    self.downloadImage(productInfo![0]["FileKey"] as! String)
                }else{
                    dispatch_async(dispatch_get_main_queue()) {
                        self.displayAlert("Unable to query", message: jsonResponse["response-message"]! as! String, enterMoreInfo: false)
                    }
                }
            }catch  {
                print("error trying to convert data to JSON")
                return
            }
            }.resume()
    }
    
    //download image by fileKey
    func downloadImage(fileKey: String){
        //activate activity indicator and disable user interaction
        dispatch_async(dispatch_get_main_queue()) {
            self.activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        }
        
        // Setup the session to make REST POST call
        let postEndpoint: String = "http://chudao.herokuapp.com/binary/download"
        let url = NSURL(string: postEndpoint)!
        let session = NSURLSession.sharedSession()
        let postParams : [String: String] = ["file-name": fileKey]
        
        // Create the request
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.setValue(self.authToken, forHTTPHeaderField: "X-Auth-Token")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(postParams, options: NSJSONWritingOptions())
            print("Request: \(postParams)")
        } catch {
            print("Error")
        }
        
        // Make the POST call and handle it in a completion handler
        session.dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) in
            //disable activiy indicator and re-activate user interaction
            dispatch_async(dispatch_get_main_queue()) {
                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
            }
            
            // Make sure we get an OK response
            guard let realResponse = response as? NSHTTPURLResponse where
                realResponse.statusCode == 200 else {
                    print("Not a 200 Response, code: \((response as? NSHTTPURLResponse)?.statusCode)")
                    return
            }
            print("Response \(response)")

            if let image = UIImage(data: data!){
                dispatch_async(dispatch_get_main_queue()) {
                    self.imageAsNSData = data!
                    self.productImage.image = image
                    self.productImage.clipsToBounds = true
                    self.productImage.contentMode = UIViewContentMode.ScaleAspectFit
                }
            }else{
                dispatch_async(dispatch_get_main_queue()) {
                    self.displayAlert("Unable to display image", message: "Sorry, we are having issue displaying the image", enterMoreInfo: false)
                }
            }
        }.resume()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addToRespond" {
            let destinationViewController = segue.destinationViewController as! RespondViewController
            destinationViewController.userId = userId
            destinationViewController.authToken = authToken
            destinationViewController.identity = identity
            recommendedProduct.append(["productId":productId,"productName":productName,"productBrand":productBrand,"productDescription":productDescription,"productImage":imageAsNSData])
            destinationViewController.recommendedProduct = recommendedProduct
            destinationViewController.responseDetail = responseDetail
            destinationViewController.requestDetail = requestDetail
            destinationViewController.userDefaultImageAsData = userDefaultImageAsData
            destinationViewController.requestSpecificImageAsData = requestSpecificImageAsData
        }
    }
}

