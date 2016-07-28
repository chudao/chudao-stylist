//
//  RespondProductDetailViewController.swift
//  chudao
//
//  Created by xuanlin yang on 7/19/16.
//  Copyright © 2016 chudao888. All rights reserved.
//

import UIKit

class RespondProductDetailViewController: UIViewController {
    
    var userId: Int = -1
    var identity: String = "undefined"
    var authToken: String = "undefined"
    var productIndex: Int = -1
    var recommendedProduct: [[String:AnyObject]] = []
    var responseDetail: [String:AnyObject] = [:]
    var requestDetail: [String:AnyObject] = [:]
    var requestSpecificImageAsData = NSData()
    var userDefaultImageAsData = NSData()

    @IBOutlet var productImage: UIImageView!
    @IBOutlet var productBrand: UILabel!
    @IBOutlet var productName: UILabel!
    @IBOutlet var productDescription: UILabel!
    @IBAction func done(sender: AnyObject) {
        performSegueWithIdentifier("productDetailToRespond", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("RespondProductDetailpage userid: \(userId)")
        print("RespondProductDetailpage identity: \(identity)")
        
        let image = UIImage(data: (recommendedProduct[productIndex]["productImage"] as? NSData)!)
        productImage.image = image
        productImage.clipsToBounds = true
        productImage.contentMode = UIViewContentMode.ScaleAspectFit
        
        productBrand.text = recommendedProduct[productIndex]["productBrand"] as? String
        productName.text = recommendedProduct[productIndex]["productName"] as? String
        productDescription.text = recommendedProduct[productIndex]["productDescription"] as? String
        
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ProductDetailViewController.imageTapped(_:)))
        
        productImage.userInteractionEnabled = true
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
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "productDetailToRespond" {
            let destinationViewController = segue.destinationViewController as! RespondViewController
            destinationViewController.userId = userId
            destinationViewController.authToken = authToken
            destinationViewController.identity = identity
            destinationViewController.recommendedProduct = recommendedProduct
            destinationViewController.responseDetail = responseDetail
            destinationViewController.requestDetail = requestDetail
            destinationViewController.userDefaultImageAsData = userDefaultImageAsData
            destinationViewController.requestSpecificImageAsData = requestSpecificImageAsData
       }
    }

}
