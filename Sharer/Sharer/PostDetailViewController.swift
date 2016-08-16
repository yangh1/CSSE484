//
//  PostDetailViewController.swift
//  Sharer
//
//  Created by 杨桦 on 8/9/16.
//  Copyright © 2016 Rose-Hulman. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class PostDetailViewController: UIViewController{
    
    @IBOutlet weak var goButton: UIBarButtonItem!
    @IBOutlet weak var postTextView: UITextView!
    
    var rightNavButton: UIBarButtonItem?
    var post: Post?
    var user: User?
    var ifSave: Bool?
    var currentUserRef: FIRDatabaseReference!
    var postRef: FIRDatabaseReference!
    var saves = [Save]()
    var loading = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.goButton.enabled = false
        self.saves.removeAll()
        self.currentUserRef.child("saves").observeEventType(FIRDataEventType.Value) { (snapshot:FIRDataSnapshot) in
            
            if !(snapshot.value is NSNull) {
                let savesDict = snapshot.value as! [String : AnyObject]
                for (key, value) in savesDict {
                    self.saves.insert(Save(key: key, postKey: value["saveID"] as! String), atIndex: 0)
                }
            }
            
            if (self.loading) {
                self.postRef.observeEventType(FIRDataEventType.Value) { (snapshot:FIRDataSnapshot) in
                    
                    if !snapshot.exists() {
                        return
                    }
                    
                    self.post = Post(snapshot: snapshot)
                    self.prepareView()
                }
                self.loading = false
            }
        }

    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.currentUserRef.removeAllObservers()
        self.postRef.removeAllObservers()
    }
    
    func checkSave(key: String) -> Save? {
        for save in saves {
            if save.postKey == key {
                return save
            }
        }
        return nil
    }
    
    func prepareView() {
        self.goButton.enabled = true
        
        self.ifSave = self.checkSave(self.post!.key) != nil
        if self.user?.email == self.post?.author {
            
            self.rightNavButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: #selector(showEditDialog))
            
        } else {
            self.rightNavButton = UIBarButtonItem()
            self.rightNavButton?.target = self
            self.rightNavButton?.action = #selector(pressedSave)
            if self.ifSave! {
                self.rightNavButton!.title = "Saved"
                self.rightNavButton!.tintColor = UIColor.greenColor()
            } else {
                self.rightNavButton!.title = "Save"
                self.rightNavButton!.tintColor = UIColor.blueColor()
            }
            
        }
        self.navigationItem.rightBarButtonItem = self.rightNavButton
        
    
        self.title = post?.username
        
        postTextView.text = "\(post!.postText)\n\nI am in \(post!.location)"
        let contentSize = postTextView.sizeThatFits(postTextView.bounds.size)

        
        let imageWidth: CGFloat = self.view.frame.width - 20
        let imageHeight: CGFloat = self.view.frame.width - 50
        var yPostion: CGFloat = contentSize.height+10
        var scrollViewContentSize: CGFloat = contentSize.height+10
        if let images = self.post?.getImagesUrl() {
            for i in 0..<images.count {
                
                let imgString = images[i]
                    if let imgUrl = NSURL(string: imgString as! String) {
                        if let imgData = NSData(contentsOfURL: imgUrl) {
                            let image = UIImage(data: imgData)
                            let imageView = UIImageView(image: image)
                            imageView.frame.size.width = imageWidth
                            imageView.frame.size.height = imageHeight
                            imageView.frame.origin.x = 10
                            imageView.frame.origin.y = yPostion
                            
                            self.postTextView.addSubview(imageView)
                            yPostion+=imageHeight
                            scrollViewContentSize+=imageHeight
                            self.postTextView.contentSize = CGSize(width: imageWidth, height: scrollViewContentSize)
                        } else {
                            print("No Data for \(imgString)")
                        }
                    }

            }
        }
        

    }
    
    func showEditDialog() {
        let ac = UIAlertController(title: "Edit Options", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let savePost = UIAlertAction(title: !self.ifSave! ? "Save" : "Saved", style:!self.ifSave! ? UIAlertActionStyle.Default : UIAlertActionStyle.Destructive) { (UIAlertAction) -> Void in
            self.pressedSave()
        }
        
        let deletePost = UIAlertAction(title: "Deleted", style:UIAlertActionStyle.Destructive) { (UIAlertAction) -> Void in
            self.postRef.removeValue()
            self.navigationController?.popViewControllerAnimated(true)
            
        }
        
        let cancel = UIAlertAction(title: "Cancel", style:UIAlertActionStyle.Cancel) { (UIAlertAction) -> Void in
        }

        ac.addAction(savePost)
        ac.addAction(deletePost)
        ac.addAction(cancel)
        presentViewController(ac, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pressedSave() {
        saveHelper { (bool: Bool) in
            self.ifSave = !self.ifSave!
            if bool {
                let save = Save()
                save.postKey = self.post?.key
                save.key = self.currentUserRef.child("saves").childByAutoId().key
                self.currentUserRef.child("saves").child(save.key).setValue(save.getSnapshotValue())
            } else {
                self.currentUserRef.child("saves").child((self.checkSave(self.post!.key)?.key)!).removeValue()
            }
        }
    }
    
    func saveHelper(callback:(Bool) -> Void) {
        if self.user?.email != self.post?.author {
            if self.rightNavButton!.title == "Save" {
                self.rightNavButton!.title = "Saved"
                self.rightNavButton!.tintColor = UIColor.greenColor()
                callback(true)
            } else {
                self.rightNavButton!.title = "Save"
                self.rightNavButton!.tintColor = UIColor.blueColor()
                callback(false)
            }
        } else {
            if !self.ifSave! {
                callback(true)
            } else {
                callback(false)
            }
    
        }
        
    }

    @IBAction func pressedGo(sender: AnyObject) {
        
        let location = "http://maps.apple.com/?address=\(self.post!.location!)"
        
        if let encodedLocation = location.stringByAddingPercentEncodingWithAllowedCharacters(
            NSCharacterSet.URLFragmentAllowedCharacterSet()),
            url = NSURL(string: encodedLocation) {
            print(url)
            UIApplication.sharedApplication().openURL(url)
        }

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
