//
//  LoginViewController.swift
//  Sharer
//
//  Created by 杨桦 on 7/12/16.
//  Copyright © 2016 Rose-Hulman. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var warmingLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let kLoginSegueIdentifier = "LoginSegueIdentifier"
    let kRegisterSegueIdentifier = "RegisterSegueIdentifier"
    var userInfo : FIRUser? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        warmingLabel.text = ""
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
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
    
    @IBAction func login(sender: AnyObject) {
        self.view.frame.origin.y = 0
        view.endEditing(true)
        let email = emailTextField.text
        let password = passwordTextField.text
        
        let container: UIView = UIView()
        container.frame = self.view.frame
        container.center = self.view.center
        container.backgroundColor = UIColor(white: 0xffffff, alpha: 0.3)
        
        self.view.addSubview(container)
        
        let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        myActivityIndicator.center = view.center
        myActivityIndicator.startAnimating()
        container.addSubview(myActivityIndicator)
        
        FIRAuth.auth()?.signInWithEmail(email!, password: password!) { (user, error) in
            if (error != nil) {
                myActivityIndicator.removeFromSuperview()
                container.removeFromSuperview()
                self.warmingLabel.text = error?.localizedDescription;
            } else {
                self.userInfo = user
                self.performSegueWithIdentifier(self.kLoginSegueIdentifier, sender: nil)
            }
        }
    }

    @IBAction func register(sender: AnyObject) {
        
    }
    
    //
    
    func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y = -150
    }
    
    func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = 0
    }

    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == kLoginSegueIdentifier {
            let navigation = segue.destinationViewController as! UINavigationController
            let controller = navigation.topViewController as! PostsViewController
            controller.userInfo = self.userInfo
        }

    }
    
}
