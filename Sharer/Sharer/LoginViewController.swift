//
//  LoginViewController.swift
//  Sharer
//
//  Created by 杨桦 on 8/8/16.
//  Copyright © 2016 Rose-Hulman. All rights reserved.
//

import UIKit
import Material
import Firebase
import Rosefire

class LoginViewController: UIViewController , GIDSignInUIDelegate{

    @IBOutlet weak var emailPasswordCard: CardView!
    @IBOutlet weak var emailPasswordCardContent: UIView!
    @IBOutlet weak var emailTextField: TextField!
    @IBOutlet weak var passwordTextField: TextField!
    @IBOutlet weak var rosefireLoginButton: RaisedButton!
    @IBOutlet weak var googleLoginButton: GIDSignInButton!
    
    var container: UIView = UIView()
    
    let ROSEFIRE_REGISTRY_TOKEN = "573eecd6-1faf-4edc-97b3-6073b5fb7890"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        googleLoginButton.style = .Wide
        prepareView()
    }
    
    func prepareView() {
//        self.view.backgroundColor = MaterialColor.indigo.base
////        titleLabel.font = RobotoFont.thinWithSize(36)
        
        // Email / Password
        prepareEmailPasswordCard()
        
        // Rosefire
        rosefireLoginButton.setTitle("Rosefire Login", forState: .Normal)
        rosefireLoginButton.titleLabel!.font = RobotoFont.mediumWithSize(18)
        rosefireLoginButton.backgroundColor = UIColor(red: 0.5, green: 0, blue: 0, alpha: 1.0)
        
        // Google OAuth
    }
    
    func prepareEmailPasswordCard() {
        emailPasswordCard.contentView = emailPasswordCardContent
        
        emailTextField.placeholder = "Email"
        emailTextField.enableClearIconButton = true
        emailTextField.placeholderActiveColor = MaterialColor.grey.darken2
        
        passwordTextField.placeholder = "Password"
        passwordTextField.clearButtonMode = .WhileEditing
        passwordTextField.enableVisibilityIconButton = true
        passwordTextField.placeholderActiveColor = MaterialColor.grey.darken2
        
        let signUpBtn: FlatButton = FlatButton()
        signUpBtn.pulseColor = MaterialColor.blue.lighten1
        signUpBtn.setTitle("Sign up", forState: .Normal)
        signUpBtn.setTitleColor(MaterialColor.blue.darken1, forState: .Normal)
        signUpBtn.addTarget(self, action: #selector(LoginViewController.handleEmailPasswordSignUp),
                            forControlEvents: .TouchUpInside)
        emailPasswordCard.leftButtons = [signUpBtn]
        
        let loginBtn: FlatButton = FlatButton()
        loginBtn.pulseColor = MaterialColor.blue.lighten1
        loginBtn.setTitle("Login", forState: .Normal)
        loginBtn.setTitleColor(MaterialColor.blue.darken1, forState: .Normal)
        loginBtn.addTarget(self, action: #selector(LoginViewController.handleEmailPasswordLogin),
                           forControlEvents: .TouchUpInside)
        emailPasswordCard.rightButtons = [loginBtn]
    }

    func loginCompletionCallback(user: FIRUser?, error: NSError?) {
        self.container.removeFromSuperview()
        if error == nil {
            self.appDelegate.handleLogin()
        } else {
            let alertController = UIAlertController(title: "Login failed", message: error?.localizedDescription, preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            
            print(error?.localizedDescription)
            print(error?.description)
        }
    }
    
    
    func handleEmailPasswordSignUp() {
        self.performSegueWithIdentifier("RegisterSegue", sender: nil)
    }
    
    
    func handleEmailPasswordLogin() {
        container.frame = self.view.frame
        container.center = self.view.center
        container.backgroundColor = UIColor(white: 0xffffff, alpha: 0.3)
        
        self.view.addSubview(container)
        
        let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        myActivityIndicator.center = view.center
        myActivityIndicator.startAnimating()
        container.addSubview(myActivityIndicator)

        FIRAuth.auth()?.signInWithEmail(emailTextField.text!, password: passwordTextField.text!, completion: loginCompletionCallback)
    }

    @IBAction func rosefireLogin(sender: AnyObject) {
    
        
        Rosefire.sharedDelegate().uiDelegate = self
        Rosefire.sharedDelegate().signIn(self.ROSEFIRE_REGISTRY_TOKEN) { (error: NSError!, result: RosefireResult!) in
            
            if (error) != nil {
                print("Error communicating with Rosefire")
                return
            }
            self.container.frame = self.view.frame
            self.container.center = self.view.center
            self.container.backgroundColor = UIColor(white: 0xffffff, alpha: 0.3)
            
            self.view.addSubview(self.container)
            
            let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
            myActivityIndicator.center = self.view.center
            myActivityIndicator.startAnimating()
            self.container.addSubview(myActivityIndicator)
           
            
            FIRAuth.auth()?.signInWithCustomToken(result.token, completion: { (user: FIRUser?, error: NSError?) in
                
                if error != nil {
                    print(error?.localizedDescription)
                    print(error?.description)
                    return
                }
                
                FIRDatabase.database().reference().child("users").child((user?.uid)!).observeEventType(FIRDataEventType.Value, withBlock: { (snapshot: FIRDataSnapshot) -> Void in
                    print(snapshot.value)
                    if snapshot.value! is NSNull {
                        let newUser = User(email: result.email, username: result.name, key: user?.uid)
                        newUser.registerUserInfo()
                    }
                    self.container.removeFromSuperview()
                    self.appDelegate.handleLogin()
                })

            })
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
