//
//  PostViewController.swift
//  Sharer
//
//  Created by 杨桦 on 7/27/16.
//  Copyright © 2016 Rose-Hulman. All rights reserved.
//

import UIKit
import Firebase
import BSImagePicker
import Photos
import AddressBookUI

class PostViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var addressTextField1: UITextField!
    @IBOutlet weak var addressTextField2: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    var imagePicker = UIImagePickerController()
    var locationManager: CLLocationManager!
    
    var location: CLLocation!
    var move = false
    var assets: [PHAsset]!
    var isUseCurrentLocation = false
    var address: String!
    var postRef: FIRDatabaseReference!
    var email: String!
    var post: Post!
    
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        

        self.addressTextField1.delegate = self
        self.addressTextField2.delegate = self
        self.cityTextField.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        
        self.addressTextField2.addTarget(self, action: "doesMove:", forControlEvents: UIControlEvents.TouchDown)
        self.cityTextField.addTarget(self, action: "doesMove:", forControlEvents: UIControlEvents.TouchDown)
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        checkCoreLocationPermission()
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func doesMove(textField: UITextField) {
        self.move = true
    }
    
    func keyboardWillShow(sender: NSNotification) {
        if (self.move) {
            self.view.frame.origin.y = -150
        }
    }
    
    func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = 0
        self.move = false;
    }
    
    func checkCoreLocationPermission() {
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else if CLLocationManager.authorizationStatus() == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if CLLocationManager.authorizationStatus() == .Restricted {
            
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
        locationManager.stopUpdatingLocation()
    }

    @IBAction func pressedCamera(sender: AnyObject) {
        let vc = BSImagePickerViewController()
        vc.maxNumberOfSelections = 6
        
        bs_presentImagePickerController(vc, animated: true,
            select: { (asset: PHAsset) -> Void in
                print("Selected: \(asset)")
            }, deselect: { (asset: PHAsset) -> Void in
                print("Deselected: \(asset)")
            }, cancel: { (assets: [PHAsset]) -> Void in
                print("Cancel: \(assets)")
            }, finish: { (assets: [PHAsset]) -> Void in
                print("Finish: \(assets)")
                self.assets = assets
            }, completion: nil)
    }
    
    func getAssetThumbnail(asset: PHAsset, size: CGFloat) -> UIImage {
        let retinaScale = UIScreen.mainScreen().scale
        let retinaSquare = CGSizeMake(size * retinaScale, size * retinaScale)
        let cropSizeLength = min(asset.pixelWidth, asset.pixelHeight)
        let square = CGRectMake(0, 0, CGFloat(cropSizeLength), CGFloat(cropSizeLength))
        let cropRect = CGRectApplyAffineTransform(square, CGAffineTransformMakeScale(1.0/CGFloat(asset.pixelWidth), 1.0/CGFloat(asset.pixelHeight)))
        
        let manager = PHImageManager.defaultManager()
        let options = PHImageRequestOptions()
        var thumbnail = UIImage()
        
        options.synchronous = true
        options.deliveryMode = .HighQualityFormat
        options.resizeMode = .Exact
        options.normalizedCropRect = cropRect
        
        manager.requestImageForAsset(asset, targetSize: retinaSquare, contentMode: .AspectFit, options: options, resultHandler: {(result, info)->Void in
            thumbnail = result!
        })
        return thumbnail
    }
    
    @IBAction func pressedGetCurrentLocation(sender: AnyObject) {
        self.isUseCurrentLocation = true
        locationManager.startUpdatingLocation()
        self.reverseGeocoding(self.location.coordinate.latitude, longitude: self.location.coordinate.longitude) { (container: UIView) -> Void in
            container.removeFromSuperview()
        }
    }
    
    func reverseGeocoding(latitude: CLLocationDegrees, longitude: CLLocationDegrees,callback:(UIView)->Void) {
        let container: UIView = UIView()
        container.frame = self.view.frame
        container.center = self.view.center
        container.backgroundColor = UIColor(white: 0xffffff, alpha: 0.3)
        self.view.addSubview(container)
        
        let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        myActivityIndicator.center = view.center
        myActivityIndicator.startAnimating()
        container.addSubview(myActivityIndicator)
        
        let location = CLLocation(latitude: latitude, longitude: longitude)
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                print(error)
                return
            }
            else if placemarks?.count > 0 {
                let pm = placemarks![0]
                let address = ABCreateStringWithAddressDictionary(pm.addressDictionary!, false)
                self.address = ""
                
                for c in address.characters {
                    print(c)
                    if  c != Character("\n") {
                        self.address.append(c)
                    } else {
                        self.address.append(Character(","))
                        self.address.append(Character(" "))
                    }
                }

                
                print("\(self.address)")
                if pm.areasOfInterest?.count > 0 {
                    let areaOfInterest = pm.areasOfInterest?[0]
                    print(areaOfInterest)
                } else {
                    print("No area of interest found.")
                }
            }
            callback(container)
        })
    }
    
    @IBAction func pressedCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func pressedPost(sender: AnyObject) {
        if !self.isUseCurrentLocation {
            if self.addressTextField2.text == "" {
                self.address = "\(self.addressTextField1.text!), \(self.cityTextField!.text!)"
            } else {
                self.address = "\(self.addressTextField1.text!), \(self.addressTextField2.text!), \(self.cityTextField.text!)"
            }
        }
        
        self.post = Post(author: self.email, postText: self.textField.text, location: self.address)
        self.post.key = self.postRef.childByAutoId().key
        self.postRef.child(self.post.key).setValue(self.post.getSnapshotValueWithoutImages())
        uploadImage()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func uploadImage() {
        var count = 0
        
        if self.assets == nil {
            return
        }
        
        for asset in self.assets {
            let pickedImage = self.getAssetThumbnail(asset, size: 1000)
            let storageRef = FIRStorage.storage().reference().child("\(self.post.key)\(count).png")
            if let uploadImage = UIImagePNGRepresentation(pickedImage) {
                storageRef.putData(uploadImage, metadata: nil, completion: { (metadata, error) -> Void in
                    
                    if error != nil {
                        print(error)
                        return
                    }
                    self.postRef.child(self.post.key).child("images").childByAutoId().setValue(metadata?.downloadURL()?.description)
                    print(metadata?.downloadURL())
                })
                print(count)
            }
            count++
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
