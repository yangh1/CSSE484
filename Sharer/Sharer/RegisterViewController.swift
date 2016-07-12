//
//  RegisterViewController.swift
//  Sharer
//
//  Created by 杨桦 on 7/12/16.
//  Copyright © 2016 Rose-Hulman. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth


class RegisterViewController: UIViewController {

    @IBOutlet weak var warmingLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        warmingLabel.text = ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back(sender: AnyObject) {
    }

    @IBAction func register(sender: AnyObject) {
        let email = emailTextField.text
        let username = usernameTextField.text
        let password = passwordTextField.text
        let repassword = repasswordTextField.text
        
        if (password != repassword) {
            warmingLabel.text = "repassword is not same to your password!"
            return
        }
        
        FIRAuth.auth()
        
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
