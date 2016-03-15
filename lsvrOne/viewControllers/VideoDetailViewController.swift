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
    
    @IBAction func phoneButtonTapped(sender: UIButton) {
        performSegueWithIdentifier("monoSegue", sender: self)
    }
    @IBAction func headsetButtonTapped(sender: UIButton) {
        performSegueWithIdentifier("stereoSegue", sender: self)
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
    }

}
