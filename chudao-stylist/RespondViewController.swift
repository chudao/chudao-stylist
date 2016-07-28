//
//  RespondViewController.swift
//  chudao
//
//  Created by xuanlin yang on 7/18/16.
//  Copyright © 2016 chudao888. All rights reserved.
//

import UIKit

class RespondViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var userId: Int = -1
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var authToken: String = "undefined"
    var identity: String = "undefined"
    var requestSpecificImageAsData = NSData()
    var userDefaultImageAsData = NSData()
    var stylistImageAsData = NSData()
    var responseDetail: [String:AnyObject] = [:]
    var requestDetail: [String:AnyObject] = [:]
    var recommendedProduct: [[String:AnyObject]] = []

    @IBOutlet var userNote: UILabel!
    @IBOutlet var age: UITextField!
    @IBOutlet var budget: UITextField!
    @IBOutlet var stylistNote: UITextView!
    @IBAction func finishResponding(sender: AnyObject) {
        if stylistImage.image != nil {
            uploadImage()
        }else{
            responseDetail["file-key"] = ""
            submittResponse()
        }
        performSegueWithIdentifier("respondToHome", sender: self)
    }
    @IBOutlet var searchRequirement: UISearchBar!
    @IBAction func search(sender: AnyObject) {
        if searchRequirement.text == "" {
            displayAlert("Invalid search", message: "Please enter a valid input to proceed", enterMoreInfo: false)
        }else{
            performSegueWithIdentifier("respondToSearch", sender: self)
        }
    }
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var userDefaultImage: UIImageView!
    @IBOutlet var requestSpecificImage: UIImageView!
    @IBOutlet var stylistImage: UIImageView!
    @IBAction func existingImage(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
            imagePicker.allowsEditing = true
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    @IBAction func newImage(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera;
            imagePicker.allowsEditing = false
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
        else{
            displayAlert("Camera Not Found", message: "This device has no Camera", enterMoreInfo: false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        
        if responseDetail["user-message"] as? String != "" {
            stylistNote.text = responseDetail["stylistNote"] as? String
        }
 
        if responseDetail["budget"] as? String != "" {
            budget.text = responseDetail["budget"] as? String
        }
        
        if requestDetail["user-message"] as? String != "" {
            userNote.text = requestDetail["user-message"] as? String
        }
        
        if requestSpecificImageAsData == NSData() {
            if requestDetail["file-key"] as? String != "" {
                downLoadImage((requestDetail["file-key"] as? String)!, placeHolder: "requestSpecificImage")
            }
        }else{
            self.requestSpecificImage.image = UIImage(data: requestSpecificImageAsData)
        }
        
        if responseDetail["stylistImageAsData"] as? UIImage != UIImage() {
            self.stylistImage.image = UIImage(data: stylistImageAsData)
        }
        
        if userDefaultImageAsData != NSData() {
            self.userDefaultImage.image = UIImage(data: userDefaultImageAsData)
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
        userDefaultImage.clipsToBounds = true
        userDefaultImage.contentMode = UIViewContentMode.ScaleAspectFit
        
        requestSpecificImage.userInteractionEnabled = true
        requestSpecificImage.addGestureRecognizer(tapRecognizer)
        requestSpecificImage.clipsToBounds = true
        requestSpecificImage.contentMode = UIViewContentMode.ScaleAspectFit
        
        
        //setup scrollView
        scrollView.delegate = self
        scrollView.scrollEnabled = true;
        scrollView.contentSize = CGSize(width:self.view.frame.width, height:9000.0)
        
        
        
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
    
    //post response to request
    func submittResponse(){
        //activate activity indicator and disable user interaction
        dispatch_async(dispatch_get_main_queue()) {
            self.activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        }
        
        // Setup the session to make REST POST call
        let postEndpoint: String = "http://chudao.herokuapp.com/query/XXX"
        let url = NSURL(string: postEndpoint)!
        let session = NSURLSession.sharedSession()
        
        var productIds = ""
        for product in recommendedProduct {
            productIds+=product["product-id"] as! String
        }
        productIds = productIds.substringToIndex(productIds.endIndex)
        responseDetail["user-message"] = stylistNote.text
        
        let postParams : [String: String] = ["user-id": "\(userId)", "file-key": responseDetail["file-key"] as! String, "request-id":requestDetail["request-id"] as! String, "user-message":responseDetail["user-message"] as! String, "product-id":productIds]
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
            dispatch_async(dispatch_get_main_queue()) {
                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
            }
            
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

                }else{
                    dispatch_async(dispatch_get_main_queue()) {
                        self.displayAlert("Unable to submit", message: jsonResponse["response-message"]! as! String, enterMoreInfo: false)
                    }
                }
            }catch  {
                print("error trying to convert data to JSON")
                return
            }
        }.resume()
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
    
    //download request image
    func downLoadImage(fileKey: String, placeHolder: String){
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
                    switch (placeHolder){
                    case ("requestSpecificImage"):
                        self.requestSpecificImageAsData = data!
                        self.requestSpecificImage.image = image
                    case ("userDefaultImage"):
                        self.userDefaultImageAsData = data!
                        self.userDefaultImage.image = image
                    default: break
                    }
                }
            }else{
                dispatch_async(dispatch_get_main_queue()) {
                    self.displayAlert("Unable to display image", message: "Sorry, we are having issue displaying the image", enterMoreInfo: false)
                }
            }
        }.resume()
    }

    
    //display alert
    func displayAlert(title: String, message: String, enterMoreInfo: Bool) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        var title = "Ok"
        if enterMoreInfo == true {
            title = "Cancel"
            alert.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.Default, handler: { (action) in
                //todo for warning stylist to finish editing before returning to request table
            }))
        }
        alert.addAction(UIAlertAction(title: title, style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //upload image
    func uploadImage()
    {
        let url = NSURL(string: "http://chudao.herokuapp.com/binary/upload")
        
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        
        let boundary = generateBoundaryString()
        
        //define the multipart request type
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        if (stylistImage.image == nil)
        {
            print("image is nil")
            return
        }
        
        let image_data = UIImagePNGRepresentation(stylistImage.image!)
        
        if(image_data == nil)
        {
            print("image png representation is nil")
            return
        }
        
        
        let body = NSMutableData()
        
        let fname = "\(userId).png"
        
        let mimetype = "image/png"
        
        body.appendData("--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding,allowLossyConversion: true)!)
        body.appendData("Content-Disposition:form-data; name=\"user-id\"\r\n\r\n\(self.userId)\r\n".dataUsingEncoding(NSUTF8StringEncoding,allowLossyConversion: true)!)
        
        body.appendData("--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding,allowLossyConversion: true)!)
        body.appendData("Content-Disposition:form-data; name=\"product-id\"\r\n\r\n1\r\n".dataUsingEncoding(NSUTF8StringEncoding,allowLossyConversion: true)!)
        
        body.appendData("--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding,allowLossyConversion: true)!)
        body.appendData("Content-Disposition:form-data; name=\"file\"; filename=\"\(fname)\"\r\n".dataUsingEncoding(NSUTF8StringEncoding,allowLossyConversion: true)!)
        body.appendData("Content-Type: \(mimetype)\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding,allowLossyConversion: true)!)
        
        body.appendData(image_data!)
        body.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding,allowLossyConversion: true)!)
        
        body.appendData("--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding,allowLossyConversion: true)!)
        body.appendData("Content-Disposition:form-data; name=\"submit\"\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding,allowLossyConversion: true)!)
        body.appendData("submit\r\n".dataUsingEncoding(NSUTF8StringEncoding,allowLossyConversion: true)!)
        
        body.appendData("--\(boundary)--\r\n".dataUsingEncoding(NSUTF8StringEncoding,allowLossyConversion: true)!)
        
        request.HTTPBody = body
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) {
            (
            let data, let response, let error) in
            
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("error: \(error!)")
                return
            }
            
            let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("Response: \(dataString!)")
            
            do{
                guard let jsonResponse = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? [String: AnyObject] else{
                    print("Error reading JSON data")
                    return
                }
                if jsonResponse["response-code"]! as! String == "010" {
                    dispatch_async(dispatch_get_main_queue()) {
                        print("Image uploaded: \(jsonResponse)")
                        self.responseDetail["file-key"] = jsonResponse["file-key"]! as! String
                        self.submittResponse()
                    }
                }else{
                    dispatch_async(dispatch_get_main_queue()) {
                        self.displayAlert("Unable to upload", message: jsonResponse["response-message"]! as! String, enterMoreInfo: false)
                    }
                }
            }catch  {
                print("error trying to convert data to JSON")
                return
            }
            
        }
        task.resume()
    }
    
    
    func generateBoundaryString() -> String
    {
        return "Boundary-\(NSUUID().UUIDString)"
    }
    
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
            let destinationViewController = segue.destinationViewController as! UINavigationController
            let productSearchReultController = destinationViewController.topViewController as! ProductSearchResultTableViewController
            productSearchReultController.userId = userId
            productSearchReultController.searchRequirement = searchRequirement.text!
            productSearchReultController.authToken = authToken
            productSearchReultController.identity = identity
            responseDetail["user-message"] = stylistNote.text
            responseDetail["stylistImage"] = UIImagePNGRepresentation((stylistImage.image!))
            productSearchReultController.responseDetail = responseDetail
            productSearchReultController.recommendedProduct = recommendedProduct
            productSearchReultController.requestDetail = requestDetail
            productSearchReultController.userDefaultImageAsData = userDefaultImageAsData
            productSearchReultController.requestSpecificImageAsData = requestSpecificImageAsData
        }
        
        if segue.identifier == "respondToProductDetail" {
            let destinationViewController = segue.destinationViewController as! RespondProductDetailViewController
            destinationViewController.authToken = authToken
            destinationViewController.identity = identity
            destinationViewController.userId = userId
            destinationViewController.productIndex = sender as! Int
            destinationViewController.recommendedProduct = recommendedProduct
            responseDetail["user-message"] = stylistNote.text
            responseDetail["stylistImage"] = UIImagePNGRepresentation((stylistImage.image!))
            destinationViewController.responseDetail = responseDetail
            destinationViewController.requestDetail = requestDetail
            destinationViewController.userDefaultImageAsData = userDefaultImageAsData
            destinationViewController.requestSpecificImageAsData = requestSpecificImageAsData
        }
    }

}
