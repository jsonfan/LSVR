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

    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navBarItem: UINavigationItem!
    var vidName: String!
    var videoFormatFlag: Int!
    
    @IBAction func navBackButtonTapped(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
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
        
        // SET NAV IMAGE TO LOGO
//        var nav = self.navigationController?.navigationBar
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        imageView.contentMode = .ScaleAspectFit
        let image = UIImage(named: "ls_logo")
        imageView.image = image
        navBarItem.titleView = imageView
        //adjust alpha for transparency
        navBar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
        
        navBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navBar.shadowImage = UIImage()
        navBar.translucent = true
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.view.backgroundColor = UIColor.clearColor()

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
