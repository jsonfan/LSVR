//
//  WifiWarningViewController.swift
//  lsvrOne
//
//  Created by Micah Chiang on 3/14/16.
//  Copyright © 2016 Micah Chiang. All rights reserved.
//

import UIKit

class WifiWarningViewController: UIViewController {

    @IBAction func backButtonTapped(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let value = UIInterfaceOrientation.Portrait.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }

}
