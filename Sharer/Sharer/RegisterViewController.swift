//
//  RegisterViewController.swift
//  Sharer
//
//  Created by 杨桦 on 7/12/16.
//  Copyright © 2016 Rose-Hulman. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var warmingLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repasswordTextField: UITextField!
    
    var move = false;
    var touchHeight = CGFloat(0);
    var userInfo: FIRUser?
    
    let kAccountCreateSegueIdentifier = "AccountCreateSegueIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        self.emailTextField.delegate = self
        self.usernameTextField.delegate = self
        self.passwordTextField.delegate = self
        self.repasswordTextField.delegate = self
        warmingLabel.text = ""
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        
        self.passwordTextField.addTarget(self, action: "doesMove:", forControlEvents: UIControlEvents.TouchDown)
        self.repasswordTextField.addTarget(self, action: "doesMove:", forControlEvents: UIControlEvents.TouchDown)
    }
    
    func doesMove(textField: UITextField) {
        self.move = true;
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

    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back(sender: AnyObject) {
    }

    @IBAction func register(sender: AnyObject) {
        self.view.frame.origin.y = 0
        view.endEditing(true)
        let email = emailTextField.text
        let username = usernameTextField.text
        let password = passwordTextField.text
        let repassword = repasswordTextField.text
        
        if (password != repassword) {
            warmingLabel.text = "repassword is not same to your password!"
            return
        }
        
        let container: UIView = UIView()
        container.frame = self.view.frame
        container.center = self.view.center
        container.backgroundColor = UIColor(white: 0xffffff, alpha: 0.3)
        
        self.view.addSubview(container)
        
        let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        myActivityIndicator.center = view.center
        myActivityIndicator.startAnimating()
        container.addSubview(myActivityIndicator)
        
        FIRAuth.auth()?.createUserWithEmail(email!, password: password!) { (user, error) in
            if ((error) != nil) {
                myActivityIndicator.removeFromSuperview()
                container.removeFromSuperview()
                self.warmingLabel.text = error?.localizedDescription
                print(error?.description)
            } else {
                self.userInfo = user
                let newUser = User(userInfo: user, username: username);
                newUser.registerUserInfo();
                self.performSegueWithIdentifier(self.kAccountCreateSegueIdentifier, sender: nil);
            }
        }
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == kAccountCreateSegueIdentifier {
            let navigation = segue.destinationViewController as! UINavigationController
            let controller = navigation.topViewController as! PostsViewController
            controller.userInfo = self.userInfo
        }
    }


}
