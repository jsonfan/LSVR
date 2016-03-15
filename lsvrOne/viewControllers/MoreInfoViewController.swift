//
//  MoreInfoViewController.swift
//  lsvrOne
//
//  Created by Micah Chiang on 3/14/16.
//  Copyright © 2016 Micah Chiang. All rights reserved.
//

import UIKit

class MoreInfoViewController: UIViewController {
    
        //use this if using navigation bar button
//    @IBAction func backButtonTapped(sender: UIBarButtonItem) {
//        dismissViewControllerAnimated(true, completion: nil)
//    }

    @IBAction func backButtonPressed(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
