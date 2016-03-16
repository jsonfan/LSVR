//
//  ViewController.swift
//  lsvrOne
//
//  Created by Micah Chiang on 3/7/16.
//  Copyright © 2016 Micah Chiang. All rights reserved.
//

import UIKit
import Alamofire

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    var resultsDict: Dictionary<String, String> = [:]
    
    //logout functionality
    @IBAction func unwindToVC(segue: UIStoryboardSegue){
        UserVariables.userName = nil
        
    //remove all files in documents directory
        removeAllFilesFromDocumentsDirectory()

        print("\(UserVariables.userName)")
        print("logout successful, bitches be trippin")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func signInButtonTapped(sender: UIButton) {
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
                .responseJSON { response in
                    var tempResult = response.result.value as! Dictionary<String, AnyObject>
//                    var tempArray = tempResult["token"] as! String
//                    debugPrint(response)
                    self.resultsDict["username"] = username
                    self.resultsDict["token"] = tempResult["token"] as! String
                    UserVariables.userName = username
                    self.performSegueWithIdentifier("segueToDashboard", sender: self)
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
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
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
}

