//
//  ViewController.swift
//  lsvrOne
//
//  Created by Micah Chiang on 3/7/16.
//  Copyright © 2016 Micah Chiang. All rights reserved.
//

import UIKit
import Alamofire

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    var resultsDict: Dictionary<String, String> = [:]
    
    
    //logout functionality
    @IBAction func unwindToVC(segue: UIStoryboardSegue){
        UserVariables.userName = nil
    //remove all files in documents directory
        removeAllFilesFromDocumentsDirectory()
        
        print("\(UserVariables.userName)")
        
        NSUserDefaults.standardUserDefaults().removeObjectForKey("username")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("password")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: self.view.window)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: self.view.window)
        
        passwordTextField.delegate = self
    
        let value = UIInterfaceOrientation.Portrait.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
        
        userNameTextField.attributedPlaceholder = NSAttributedString(string:"Username",
            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        passwordTextField.attributedPlaceholder = NSAttributedString(string:"Password",
            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        let reachability: Reachability
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
        } catch {
            print("Unable to create Reachability")
            return
        }
        
        
        reachability.whenReachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            dispatch_async(dispatch_get_main_queue()) {
                if reachability.isReachableViaWiFi() {
                    print("Reachable via WiFi")
                } else {
                    print("Reachable via Cellular")
                }
            }
        }
        reachability.whenUnreachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            dispatch_async(dispatch_get_main_queue()) {
                print("Not reachable")
            }
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        
        //check if there was a successful user login
        if NSUserDefaults.standardUserDefaults().objectForKey("username") != nil {
            print("there is a username stored")
            let userName = NSUserDefaults.standardUserDefaults().objectForKey("username") as! String
            let password = NSUserDefaults.standardUserDefaults().objectForKey("password") as! String
            autoLogin(userName, password: password)
        }
        else {
            print("no user yet")
        }

        
    }
    
    func autoLogin(username: String, password: String){
        var parameters: Dictionary<String, String> = [:]
        parameters["username"] = username
        parameters["password"] = password
        debugPrint(parameters)
        Alamofire.request(.POST, "http://ec2-52-91-171-36.compute-1.amazonaws.com/auth", parameters:parameters, encoding: .JSON)
            .validate()
            .responseJSON { response in
                var tempResult = response.result.value as! Dictionary<String, AnyObject>
                //check if temp result has key named token, if it doesn't then alert user of invalid login credentials.
                if let token = tempResult["token"]{
                    self.resultsDict["username"] = username
                    self.resultsDict["token"] = tempResult["token"] as! String
                    UserVariables.userName = username
                    self.performSegueWithIdentifier("segueToDashboard", sender: self)
                }
                else {
                    self.displayErrorMessage("Invalid Username or Password")
                    self.userNameTextField.text! = ""
                    self.passwordTextField.text! = ""
                }
                //                    var tempArray = tempResult["token"] as! String
                //                    debugPrint(response)
                
        }
    }
// functions for moving keyboard
    func keyboardWillHide(sender: NSNotification) {
        let userInfo: [NSObject : AnyObject] = sender.userInfo!
        let keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
        self.view.frame.origin.y += keyboardSize.height
    }
    
    func keyboardWillShow(sender: NSNotification) {
        let userInfo: [NSObject : AnyObject] = sender.userInfo!
        
        let keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
        let offset: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue.size
        
        if keyboardSize.height == offset.height {
            if self.view.frame.origin.y == 0 {
                UIView.animateWithDuration(0.1, animations: { () -> Void in
                    self.view.frame.origin.y -= keyboardSize.height
                })
            }
        } else {
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.view.frame.origin.y += keyboardSize.height - offset.height
            })
        }
        print(self.view.frame.origin.y)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//methods for sign in
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        signInButtonTapped()
        return true
    }
    
    @IBAction func signInButton(sender: UIButton) {
        signInButtonTapped()
    }
    //gets called by either keyboard or sign in button
   func signInButtonTapped() {
        let username = userNameTextField.text!
        let password = passwordTextField.text!
        
        //check if fields are blank
        if username.isEmpty || password.isEmpty {
            displayErrorMessage("Fields cannot be left blank")
        }
        else //connect aws and retrieve information for user.
        {
            var parameters: Dictionary<String, String> = [:]
            parameters["username"] = username
            parameters["password"] = password
            debugPrint(parameters)
            Alamofire.request(.POST, "http://ec2-52-91-171-36.compute-1.amazonaws.com/auth", parameters:parameters, encoding: .JSON)
                .validate()
                .responseJSON { response in
                    var tempResult = response.result.value as! Dictionary<String, AnyObject>
                    //check if temp result has key named token, if it doesn't then alert user of invalid login credentials.
                    if let token = tempResult["token"]{
                        self.resultsDict["username"] = username
                        self.resultsDict["token"] = tempResult["token"] as! String
                        NSUserDefaults.standardUserDefaults().setObject(username, forKey: "username")
                        NSUserDefaults.standardUserDefaults().setObject(password, forKey: "password")
                        UserVariables.userName = username
                        self.performSegueWithIdentifier("segueToDashboard", sender: self)  
                    }
                    else {
                        self.displayErrorMessage("Invalid Username or Password")
                        self.userNameTextField.text! = ""
                        self.passwordTextField.text! = ""
                    }
//                    var tempArray = tempResult["token"] as! String
//                    debugPrint(response)

            }


        }
    }
    
    //function for displaying error message if field is empty
    func displayErrorMessage(errorMessage: String) {
        let ac = UIAlertController(title: "Alert", message: errorMessage, preferredStyle: .Alert)
        let alert = UIAlertAction(title: "ok", style: .Default, handler: nil)
        ac.addAction(alert)
        self.presentViewController(ac, animated: true, completion: nil)
    }
    
    //prepare for segue function, this will pass user info as results dict to new view
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueToDashboard" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! DashboardViewController
            controller.currentUser = resultsDict
            resultsDict = [:]
            userNameTextField.text! = ""
            passwordTextField.text! = ""
        }
    }
    
    
//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
//        view.endEditing(true)
//        super.touchesBegan(touches, withEvent: event)
//    }
    
//    override func shouldAutorotate() -> Bool {
//        return false
//    }
    
//    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
//        return [UIInterfaceOrientationMask.LandscapeLeft,UIInterfaceOrientationMask.LandscapeRight]
//    }

// removes all files from documents to handle device storage management, called at logout.
    func removeAllFilesFromDocumentsDirectory(){
        var error: NSError?
        let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let fileManager = NSFileManager.defaultManager()
        do {
            let files = try fileManager.contentsOfDirectoryAtPath(path)
            
            for file in files {
                print("file: \(file)")
                let fullPath = path+"/"+file
                try fileManager.removeItemAtPath(fullPath)
            }
        } catch {
            print("\(error)")
        }
    }
    
    deinit {
       Alamofire.Request
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: self.view.window)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: self.view.window)
    }
    
    
    override func shouldAutorotate() -> Bool {
        return false
    }
}

