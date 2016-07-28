//
//  ProductSearchResultTableViewController.swift
//  chudao
//
//  Created by xuanlin yang on 7/9/16.
//  Copyright © 2016 chudao888. All rights reserved.
//

import UIKit

class ProductSearchResultTableViewController: UITableViewController {
    
    var userId: Int = -1
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var searchRequirement: String = ""
    var productDetail: [[String:AnyObject]] = []
    var responseDetail: [String:AnyObject] = [:]
    var recommendedProduct: [[String:AnyObject]] = []
    var requestDetail: [String:AnyObject] = [:]
    var authToken: String = "undefined"
    var identity: String = "undefined"
    var requestSpecificImageAsData = NSData()
    var userDefaultImageAsData = NSData()
    
    @IBAction func cancel(sender: AnyObject) {
            performSegueWithIdentifier("searchResultToRespond", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        print("ProductSearchpage userid: \(userId)")
        print("ProductSearchpage identity: \(identity)")
        
        //activity indicator
        activityIndicator = UIActivityIndicatorView(frame: self.view.bounds)
        activityIndicator.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        
        if searchRequirement != ""{
            let preparedSearchRequirement = searchRequirement.componentsSeparatedByString(" ").joinWithSeparator(",")
            queryByTag(preparedSearchRequirement)
        }
        
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productDetail.count
    }
    
    //display alert
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: title, style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //Query by tag for productID
    func queryByTag(tags: String){
        //activate activity indicator and disable user interaction
        dispatch_async(dispatch_get_main_queue()) {
            self.activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        }
        
        // Setup the session to make REST POST call
        let postEndpoint: String = "http://chudao.herokuapp.com/query/product/tags"
        let url = NSURL(string: postEndpoint)!
        let session = NSURLSession.sharedSession()
        let postParams : [String: String] = ["product-tags": tags]
        
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
                    print("Not a 200 response, code: \((response as? NSHTTPURLResponse)?.statusCode)")
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
                    let productIds = jsonResponse["response-data"] as? NSDictionary
                    if productIds?.count > 0 {
                        self.queryByID(productIds!["ProductIds"]!.componentsJoinedByString(","))
                    }else{
                        dispatch_async(dispatch_get_main_queue()) {
                            self.displayAlert("No results matched", message: "Oops, please try something else")
                        }
                    }
                }else{
                    dispatch_async(dispatch_get_main_queue()) {
                        self.displayAlert("Unable to query", message: jsonResponse["response-message"]! as! String)
                    }
                }
            }catch  {
                print("error trying to convert data to JSON")
                return
            }
            }.resume()
    }
    
    //Qury by productID for detail
    func queryByID(productId: String){
        //activate activity indicator and disable user interaction
        dispatch_async(dispatch_get_main_queue()) {
            self.activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        }
        
        // Setup the session to make REST POST call
        let postEndpoint: String = "http://chudao.herokuapp.com/query/product/ids"
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
                    let productInfo = jsonResponse["response-data"] as? [[String:AnyObject]]
                    self.productDetail = productInfo!
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                    }
                }else{
                    dispatch_async(dispatch_get_main_queue()) {
                        self.displayAlert("Unable to query", message: jsonResponse["response-message"]! as! String)
                    }
                }
            }catch  {
                print("error trying to convert data to JSON")
                return
            }
            }.resume()
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.textLabel?.text = productDetail[indexPath.row]["ProductName"] as? String
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let productId: String = "\((productDetail[indexPath.row]["ProductId"]! as! Int))"
        let data:[String] = [productDetail[indexPath.row]["ProductName"]! as! String, productDetail[indexPath.row]["ProductBrand"]! as! String, productDetail[indexPath.row]["ProductDescription"]! as! String, productDetail[indexPath.row]["ProductLink"]! as! String, productId]
        performSegueWithIdentifier("resultToProductDetail", sender: data)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "resultToProductDetail" {
            let destinationViewController = segue.destinationViewController as! ProductDetailViewController
            destinationViewController.userId = userId
            destinationViewController.productName = sender![0] as! String
            destinationViewController.productBrand = sender![1] as! String
            destinationViewController.productDescription = sender![2] as! String
            destinationViewController.productLink = sender![3] as! String
            destinationViewController.productId = sender![4] as! String
            destinationViewController.identity = identity
            destinationViewController.authToken = authToken
            destinationViewController.recommendedProduct = recommendedProduct
            destinationViewController.responseDetail = responseDetail
            destinationViewController.requestDetail = requestDetail
            destinationViewController.userDefaultImageAsData = userDefaultImageAsData
            destinationViewController.requestSpecificImageAsData = requestSpecificImageAsData
        }
        
        if segue.identifier == "searchResultToRespond" {
            let destinationViewController = segue.destinationViewController as! RespondViewController
            destinationViewController.userId = userId
            destinationViewController.authToken = authToken
            destinationViewController.identity = identity
            destinationViewController.responseDetail = responseDetail
            destinationViewController.recommendedProduct = recommendedProduct
            destinationViewController.requestDetail = requestDetail
            destinationViewController.userDefaultImageAsData = userDefaultImageAsData
            destinationViewController.requestSpecificImageAsData = requestSpecificImageAsData
        }
    }
    
}