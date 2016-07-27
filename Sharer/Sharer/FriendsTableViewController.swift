//
//  FriendsTableViewController.swift
//  Sharer
//
//  Created by 杨桦 on 7/20/16.
//  Copyright © 2016 Rose-Hulman. All rights reserved.
//

import UIKit

class FriendsTableViewController: UITableViewController {
    
    let friendsToPost = "FriendsToPost"
    
    var user: User? = nil
    var userInfo: FIRUser? = nil
    var friendsList: NSMutableArray = []
    var friendsRefHandle : FIRDatabaseHandle?
    var friendsRef: FIRDatabaseReference?
    var userInfoRef: FIRDatabaseReference?
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // Uncomment the following line to preserve selection between presentations
//        // self.clearsSelectionOnViewWillAppear = false
//
//        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
//    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.setHidesBackButton(true, animated:true);
        self.friendsRef = FIRDatabase.database().reference().child("users").child((self.userInfo?.uid)!).child("friends")
        self.userInfoRef = FIRDatabase.database().reference().child("usersInfo")
        friendsRefHandle = self.friendsRef!.observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
            
            self.friendsList = []
            if !(snapshot.value is NSNull) {
                let postDict = snapshot.value as! [String : AnyObject]
                for (key, value) in postDict {
                    let email = value.valueForKey("email")! as! String
                    let username = value.valueForKey("username")! as! String
                    let friend = User(email: email, username: username, key: key)
                    self.friendsList.addObject(friend)
                }
            }
            
            self.friendsList.sortUsingComparator{
                (obj1: AnyObject, obj2:AnyObject) -> NSComparisonResult in
                let user1 = obj1 as! User
                let user2 = obj2 as! User
                return user1.username.compare(user2.username)
            }
            
            self.tableView.reloadData()
        })
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.friendsRef?.removeObserverWithHandle(self.friendsRefHandle!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func addFriend(sender: AnyObject) {
        let alertController = UIAlertController(title: "Add new friend", message: "", preferredStyle: .Alert)
        
        alertController.addTextFieldWithConfigurationHandler {
            (textField) -> Void in
            textField.placeholder = "e-mail for new friend"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
            (action) -> Void in
            print("Pressed Cancel")
        }
        
        let addAction = UIAlertAction(title: "Add", style: UIAlertActionStyle.Default) {
            (action) -> Void in
            let emailTextField = alertController.textFields![0]
            
            var newFriend: User?
            
            self.searchFriendInUserInfo(emailTextField.text!, callback: { (user) -> Void in
                newFriend = user
    
                self.searchFriendInFriends(emailTextField.text!, callback: { (Bool) -> Void in
                    
                    if (newFriend != nil) && Bool {
                        let key = self.friendsRef?.childByAutoId().key
                        let friend = ["email": newFriend!.email, "username": newFriend!.username]
                        newFriend?.key = key;
                        self.friendsRef?.child(key!).setValue(friend)
                    }
                    
                })
            })
            
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(addAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func searchFriendInUserInfo (email: String, callback:(User)->Void) {
        var result : User?
        self.userInfoRef?.observeEventType(FIRDataEventType.Value, withBlock: { (FIRDataSnapshot) -> Void in
            if !(FIRDataSnapshot.value is NSNull) {
                let postDict = FIRDataSnapshot.value as! [String : AnyObject]
                for (_, info) in postDict {
                    let friEmail = info.valueForKey("email")! as! String
                    if email == friEmail {
                        result = User(email: email, username: info.valueForKey("username")! as! String)
                    }
                }
            }
            
            if result == nil {
                let alertController = UIAlertController(title: "Friend not found", message: "", preferredStyle: .Alert)
                let cancelAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel) {
                    (action) -> Void in
                    print("Pressed Cancel")
                }
                alertController.addAction(cancelAction)
                self.presentViewController(alertController, animated: true, completion: nil)
                return;
            }
            callback(result!)
        })
    }
    
    func searchFriendInFriends (email: String, callback:(Bool)->Void) {
        var result = true
        self.friendsRef!.observeEventType(FIRDataEventType.Value, withBlock: { (FIRDataSnapshot) -> Void in
            if !(FIRDataSnapshot.value is NSNull) {
                let postDict = FIRDataSnapshot.value as! [String : AnyObject]
                for (_, info) in postDict {
                    let friEmail = info.valueForKey("email")! as! String
                    if email == friEmail {
                        result = false
                    }
                }
            }
            callback(result)
        })
    }
    
    // MARK: - Table view data source

//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.friendsList.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FriendCell", forIndexPath: indexPath)
        let friend = self.friendsList.objectAtIndex(indexPath.row) as! User
        cell.textLabel?.text = friend.username
        cell.detailTextLabel?.text = friend.email
        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }


    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            self.friendsRef?.child(self.friendsList.objectAtIndex(indexPath.row).key!!).removeValue()
            self.friendsList.removeObjectAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        print(self.friendsList.count)
    }

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
        if segue.identifier == friendsToPost {
            let controller = segue.destinationViewController as! PostsViewController
            controller.userInfo = self.userInfo
        }
    }
    

}
