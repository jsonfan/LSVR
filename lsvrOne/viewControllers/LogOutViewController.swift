//
//  LogOutViewController.swift
//  lsvrOne
//
//  Created by Micah Chiang on 3/14/16.
//  Copyright © 2016 Micah Chiang. All rights reserved.
//

import UIKit

class LogOutViewController: UIViewController {

    @IBOutlet weak var loggedInLabel: UILabel!
    
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var companyNameLabel: UILabel!
    var currentUserName: String!
    
    @IBAction func logoutButtonTapped(sender: UIButton) {
    }
    
    @IBAction func cancelButtonTapped(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let value = UIInterfaceOrientation.Portrait.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
        // Do any additional setup after loading the view.
        companyNameLabel.text! = UserVariables.userName
        loggedInLabel.font = UIFont(name:"Gotham Light Thin", size: 18.0)
        logoutButton.titleLabel!.font = UIFont.boldSystemFontOfSize(15)
        }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }

}
