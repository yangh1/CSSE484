//
//  PostsViewController.swift
//  Sharer
//
//  Created by 杨桦 on 7/26/16.
//  Copyright © 2016 Rose-Hulman. All rights reserved.
//

import UIKit
import Firebase
import Material

class PostsViewController: UITableViewController {
    
    @IBOutlet weak var SavesButton: UIBarButtonItem!
    @IBOutlet weak var friendButton: UIBarButtonItem!
    @IBOutlet weak var postButton: UIBarButtonItem!
    let postToFriends = "PostToFriends"
    let postIdentifier = "PostIdentifier"
    let showPostDetail = "ShowPostDetail"
    let postsToSaves = "PostsToSaves"
    var userRef: FIRDatabaseReference!
    var postsRef: FIRDatabaseReference!
    var user: User? = nil
    var userInfo : User?
    var friends = [User]()
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated:true);
        
        self.SavesButton.enabled = false
        self.friendButton.enabled = false
        self.postButton.enabled = false
        
        self.userRef = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!)
        self.postsRef = FIRDatabase.database().reference().child("posts")
        self.tableView.rowHeight = 150
        
        
        self.userRef.observeEventType(FIRDataEventType.Value, withBlock: { (snapshot: FIRDataSnapshot) -> Void in
            let user = User(snapshot: snapshot)
            self.user = user
            self.title = user.username
            
            self.SavesButton.enabled = true
            self.friendButton.enabled = true
            self.postButton.enabled = true
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.posts.removeAll()
        self.friends.removeAll()
        self.tableView.reloadData()
        
        self.searchFriend { () -> Void in
            self.postsRef.observeEventType(FIRDataEventType.ChildAdded) { (snapshot: FIRDataSnapshot) -> Void in
                if (!snapshot.exists()) {
                    return
                }
                let post = Post(snapshot: snapshot)
                if let friend = self.checkEmail(post.author) {
//                    post.username = friend.username
                    self.posts.insert(post, atIndex: 0)
                    let newIndexPath = NSIndexPath(forRow: 0, inSection: 0)
                    self.tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                }
            }
            
            self.postsRef.observeEventType(FIRDataEventType.ChildRemoved) { (snapshot: FIRDataSnapshot) -> Void in
                if (!snapshot.exists()) {
                    return
                }
                let removedPost = Post(snapshot: snapshot)
                
                var indexToRemove: Int!
                for (i,post) in self.posts.enumerate() {
                    if post.key == removedPost.key {
                        indexToRemove = self.posts.indexOf(post)!
                        self.posts.removeAtIndex(indexToRemove)
                        let indexPath = NSIndexPath(forRow: i, inSection: 0)
                        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                        break
                    }
                }
            }
            
            self.postsRef.observeEventType(FIRDataEventType.ChildChanged) { (snapshot: FIRDataSnapshot) -> Void in
                if (!snapshot.exists()) {
                    return
                }
                let changedPost = Post(snapshot: snapshot)
                for (i,post) in self.posts.enumerate() {
                    if post.key == changedPost.key {
                        post.postText = changedPost.postText
                        post.location = changedPost.location
                        self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: i, inSection: 0)], withRowAnimation: .Automatic)
                        break
                    }
                }
            }
        }
        
        
    }
    
    func checkEmail(email: String) -> User? {
        for friend in self.friends {
            if friend.email == email {
                return friend
            }
        }
        return nil
    }
    
    func searchFriend(callback:() -> Void) {
        self.userRef.child("friends").observeEventType(FIRDataEventType.Value) { (snapshots:FIRDataSnapshot) -> Void in
            if (!snapshots.exists()) {
                return
            }
            for (_, value) in snapshots.value as! [String: AnyObject] {
                let email = value.valueForKey("email")! as! String
                let username = value.valueForKey("username")! as! String
                self.friends.insert(User(email: email, username: username), atIndex: 0)
            }
            callback()
        }
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.postsRef.removeAllObservers()
        self.userRef.removeAllObservers()
    }
    @IBAction func pressedLogout(sender: AnyObject) {
        appDelegate.handleLogout()
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
        return self.posts.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCellIdentifier", forIndexPath: indexPath) as! PostTableViewCell
        
        cell.updateViewForCell(self.posts[indexPath.row])
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 150;
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == postsToSaves {
            let controller = segue.destinationViewController as! SavesViewController
            controller.user = self.user
        }
        if segue.identifier == postToFriends {
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
                let post = self.posts[indexPath.row]
                let controller = segue.destinationViewController as! PostDetailViewController
                controller.postRef = self.postsRef.child(post.key)
                controller.currentUserRef = self.userRef
                controller.user = self.user
            }
        }
    }
    

}
