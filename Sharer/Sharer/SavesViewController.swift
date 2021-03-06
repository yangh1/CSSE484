//
//  SavesViewController.swift
//  Sharer
//
//  Created by 杨桦 on 8/9/16.
//  Copyright © 2016 Rose-Hulman. All rights reserved.
//

import UIKit

class SavesViewController: UITableViewController {

    var postsRef = FIRDatabase.database().reference().child("posts")
    var userRef = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!)
    var saves = [Post]()
    var user: User?
    let showPostDetail = "ShowPostDetail2"
    let postIdentifier = "SavesToPostPage"
    let SavesToFriends = "SavesToFriends"
    let savesToPosts = "SavesToPosts"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.saves.removeAll()
        self.tableView.reloadData()
        self.userRef.child("saves").observeEventType(FIRDataEventType.ChildAdded) { (snapshot: FIRDataSnapshot) in
            
            let save = Save(snapshot: snapshot)
            
            
            self.postsRef.child(save.postKey).observeEventType(FIRDataEventType.Value, withBlock: { (snapshot:FIRDataSnapshot) in
                if !snapshot.exists() || save.postKey != snapshot.key {
                    print(12345)
                    self.userRef.child("saves").child(save.key).removeValue()
                    return;
                }
                
                let post = Post(snapshot: snapshot)
                self.saves.insert(post, atIndex: 0)
                let newIndexPath = NSIndexPath(forRow: 0, inSection: 0)
                self.tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            })

        }
        
        self.userRef.child("saves").observeEventType(FIRDataEventType.ChildRemoved) { (snapshot: FIRDataSnapshot) in
            let deletedSave = Save(snapshot: snapshot)
            for (i, save) in self.saves.enumerate() {
                if deletedSave.postKey == save.key {
                    self.saves.removeAtIndex(i)
                    let indexPath = NSIndexPath(forRow: i, inSection: 0)
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                    break
                }
            }

        }

    }
    
    override func viewDidDisappear(animated: Bool) {
        self.postsRef.removeAllObservers()
        self.userRef.removeAllObservers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.saves.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SavesCell", forIndexPath: indexPath) as! PostTableViewCell
        cell.updateViewForCell(self.saves[indexPath.row])
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 150;
    }
    
    @IBAction func pressedLogout(sender: AnyObject) {
        appDelegate.handleLogout()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == savesToPosts {
            let controller = segue.destinationViewController as! PostsViewController
            controller.user = self.user
        }
        if segue.identifier == SavesToFriends {
            let controller = segue.destinationViewController as! FriendsTableViewController
            controller.user = self.user
        }
        if segue.identifier == postIdentifier {
            let controller = segue.destinationViewController as! PostViewController
            controller.postRef = FIRDatabase.database().reference().child("posts")
            controller.user = self.user
        }
        if segue.identifier == showPostDetail {
            if let indexPath = tableView.indexPathForSelectedRow {
                let post = self.saves[indexPath.row]
                let controller = segue.destinationViewController as! PostDetailViewController
                controller.postRef = self.postsRef.child(post.key)
                controller.currentUserRef = self.userRef
                controller.user = self.user
            }
        }
    }
    

}
