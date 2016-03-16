//
//  WatchInstructionsViewController.swift
//  lsvrOne
//
//  Created by Micah Chiang on 3/16/16.
//  Copyright © 2016 Micah Chiang. All rights reserved.
//

import UIKit

class WatchInstructionsViewController: UIViewController {

    var vidName: String!
    var videoFormatIndicator: Int!
    
    @IBAction func backButtonTapped(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func buttonToPlayVideoTapped(sender: UIButton) {
        if videoFormatIndicator == 1 {
            performSegueWithIdentifier("monoSegue", sender: self)
        }
        if videoFormatIndicator == 2 {
            performSegueWithIdentifier("stereoSegue", sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "stereoSegue" {
            let controller = segue.destinationViewController as! StereocopicViewController
            controller.videoFileURL = vidName
        }
        if segue.identifier == "monoSegue" {
            let controller = segue.destinationViewController as!
            MonoscopicViewController
            controller.videoFileURL = vidName
        }
        if segue.identifier == "segueToLogoutFromInstructions" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! LogOutViewController
        }
    }
}
