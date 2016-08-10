//
//  AppDelegate.swift
//  Sharer
//
//  Created by 杨桦 on 7/8/16.
//  Copyright © 2016 Rose-Hulman. All rights reserved.
//

import UIKit
import CoreData
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?

    func application(application: UIApplication,
                     openURL url: NSURL, options: [String: AnyObject]) -> Bool {
        return GIDSignIn.sharedInstance().handleURL(url,
                                                    sourceApplication: options[UIApplicationOpenURLOptionsSourceApplicationKey] as? String,
                                                    annotation: options[UIApplicationOpenURLOptionsAnnotationKey])
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        FIRApp.configure()
        
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        // To give the iOS status bar light icons & text
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        // Programatically initialize the first view controller.
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        let showLoginScreen = FIRAuth.auth()?.currentUser == nil
        if showLoginScreen {
            showLoginViewController();
        } else {
            showPasswordViewController();
        }
        window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
//        self.saveContext()
    }
    
    func handleLogin() {
        showPasswordViewController()
    }
    
    func handleLogout() {
        GIDSignIn.sharedInstance().signOut()
        try! FIRAuth.auth()?.signOut()
        showLoginViewController()
    }
    
    func showLoginViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        window!.rootViewController = storyboard.instantiateViewControllerWithIdentifier("LoginViewController")
    }
    
    func showPasswordViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        window!.rootViewController = storyboard.instantiateViewControllerWithIdentifier("NavigationController")
    }
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!,
                withError error: NSError!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        let name = user.profile.name
        let authentication = user.authentication
        let credential = FIRGoogleAuthProvider.credentialWithIDToken(authentication.idToken,
                                                                     accessToken: authentication.accessToken)
        FIRAuth.auth()?.signInWithCredential(credential, completion: { (user: FIRUser?, error: NSError?) in
            if error != nil {
                print("error with google auth")
                print(error?.localizedDescription)
                return
            }
            
            FIRDatabase.database().reference().child("users").child((user?.uid)!).observeEventType(FIRDataEventType.Value, withBlock: { (snapshot: FIRDataSnapshot) -> Void in
                print(snapshot.value)
                if snapshot.value! is NSNull {
                    let newUser = User(userInfo: user, username: name)
                    
                    newUser.registerUserInfo()
                }
            })

            self.handleLogin()
        })
    }

}

extension UIViewController {
    var appDelegate : AppDelegate {
        get {
            return UIApplication.sharedApplication().delegate as! AppDelegate
        }
    }
}

