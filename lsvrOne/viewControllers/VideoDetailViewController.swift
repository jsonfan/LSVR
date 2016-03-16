//
//  VideoDetailViewController.swift
//  lsvrOne
//
//  Created by Micah Chiang on 3/7/16.
//  Copyright © 2016 Micah Chiang. All rights reserved.
//

import UIKit
import SceneKit
import CoreMotion
import SpriteKit
import AVFoundation
import Foundation
import Darwin
import CoreGraphics

class VideoDetailViewController: UIViewController {

    var vidName: String!
    var videoFormatFlag: Int!
    
    @IBAction func backButtonTapped(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func phoneButtonTapped(sender: UIButton) {
        videoFormatFlag = 1
        performSegueWithIdentifier("segueToWatchInstructions", sender: self)
    }
    @IBAction func headsetButtonTapped(sender: UIButton) {
        videoFormatFlag = 2
        performSegueWithIdentifier("segueToWatchInstructions", sender: self)
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
//        if segue.identifier == "stereoSegue" {
//            let controller = segue.destinationViewController as! StereocopicViewController
//            controller.videoFileURL = vidName
//        }
//        if segue.identifier == "monoSegue" {
//            let controller = segue.destinationViewController as!
//            MonoscopicViewController
//            controller.videoFileURL = vidName
//        }
        if segue.identifier == "segueToWatchInstructions" {
            let controller = segue.destinationViewController as! WatchInstructionsViewController
            controller.vidName = vidName
            controller.videoFormatIndicator = videoFormatFlag
        }
        if segue.identifier == "segueToUserLogoutFromPlayStyle" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! LogOutViewController
        }
    }

}
