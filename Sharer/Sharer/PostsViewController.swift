//
//  PostsViewController.swift
//  Sharer
//
//  Created by 杨桦 on 7/26/16.
//  Copyright © 2016 Rose-Hulman. All rights reserved.
//

import UIKit
import Firebase

class PostsViewController: UITableViewController {
    
    let postToFriends = "PostToFriends"
    let postIdentifier = "PostIdentifier"
    
    var userRef: FIRDatabaseReference!
    var postsRef: FIRDatabaseReference!
    var user: User? = nil
    var userInfo: FIRUser? = nil
    var friends = [User]()
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated:true);
        
        self.userRef = FIRDatabase.database().reference().child("users").child((self.userInfo?.uid)!)
        self.postsRef = FIRDatabase.database().reference().child("posts")
        self.tableView.rowHeight = 80
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.posts.removeAll()
        self.friends.removeAll()
        
        self.userRef.observeEventType(FIRDataEventType.Value, withBlock: { (snapshot: FIRDataSnapshot) -> Void in
            self.navigationItem.title = User(snapshot: snapshot).username
        })
        
        self.searchFriend { () -> Void in
            self.postsRef.observeEventType(FIRDataEventType.ChildAdded) { (snapshot: FIRDataSnapshot) -> Void in
                if (!snapshot.exists()) {
                    return
                }
                let post = Post(snapshot: snapshot)
                if let friend = self.checkEmail(post.author) {
                    post.username = friend.username
                    self.posts.insert(post, atIndex: 0)
                }
                self.tableView.reloadData()
            }
            
            self.postsRef.observeEventType(FIRDataEventType.ChildRemoved) { (snapshot: FIRDataSnapshot) -> Void in
                if (!snapshot.exists()) {
                    return
                }
                let removedPost = Post(snapshot: snapshot)
                
                var indexToRemove: Int!
                for post in self.posts {
                    if post.key == removedPost.key {
                        indexToRemove = self.posts.indexOf(post)!
                        self.posts.removeAtIndex(indexToRemove)
                        break
                    }
                }
                
                self.tableView.reloadData()
            }
            
            self.postsRef.observeEventType(FIRDataEventType.ChildChanged) { (snapshot: FIRDataSnapshot) -> Void in
                if (!snapshot.exists()) {
                    return
                }
                let changedPost = Post(snapshot: snapshot)
                for post in self.posts {
                    if post.key == changedPost.key {
                        post.postText = changedPost.postText
                        post.location = changedPost.location
                        break
                    }
                }
                self.tableView.reloadData()
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
            for (key, value) in snapshots.value as! [String: AnyObject] {
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
        print(self.posts.count)
        return self.posts.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCellIdentifier", forIndexPath: indexPath) as! PostTableViewCell
        
        cell.updateViewForCell(self.posts[indexPath.row])
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80;
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
        if segue.identifier == postToFriends {
            let controller = segue.destinationViewController as! FriendsTableViewController
            controller.userInfo = self.userInfo
            print(self.userInfo?.email!)
        }
        if segue.identifier == postIdentifier {
            let controller = segue.destinationViewController as! PostViewController
            controller.postRef = FIRDatabase.database().reference().child("posts")
            controller.email = self.userInfo?.email
        }
    }
    

}
