//
//  StereocopicViewController.swift
//  lsvrOne
//
//  Created by Micah Chiang on 3/8/16.
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

class StereocopicViewController: UIViewController, SCNSceneRendererDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var vidFinishedImage: UIImageView!
    @IBOutlet weak var vidPausedImage: UIImageView!
    
    @IBOutlet weak var rightSceneView: SCNView!
    @IBOutlet weak var leftSceneView: SCNView!
    var videoFileURL: String!
    //graph setup
    var scene : SCNScene?
    
    var videoNode : SCNNode?
    var videoSpriteKitNode : SKVideoNode?
    var player : AVPlayer!
    
    var camerasNode : SCNNode?
    var cameraRollNode : SCNNode?
    var cameraPitchNode : SCNNode?
    var cameraYawNode : SCNNode?
    
    var recognizer : UITapGestureRecognizer?
    var panRecognizer: UIPanGestureRecognizer?
    var motionManager : CMMotionManager?
    
    var playingVideo : Bool = false
    
    var currentAngleX : Float?
    var currentAngleY : Float?
    
    var progressObserver : AnyObject?
    
    //restarts video on tap at end of playing.
    func restartVideoFromBeginning() {
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let path = NSURL(fileURLWithPath: dirPaths)
        print(path)
        let fileURL = path.URLByAppendingPathComponent(videoFileURL)
        //        print(finishedVidImage.hidden)
        vidFinishedImage.hidden = true
        print("set" + "\(vidFinishedImage.hidden)")
        let seconds: Int64 = 0
        let preferredTimeScale: Int32 = 1
        let seekTime : CMTime = CMTimeMake(seconds, preferredTimeScale)
        player.seekToTime(seekTime)
        print("GO GRAB MY BELT")
        player = AVPlayer(URL: fileURL)
        player.play()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerDidFinishPlaying:", name: AVPlayerItemDidPlayToEndTimeNotification, object: player.currentItem)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().statusBarOrientation = UIInterfaceOrientation.LandscapeLeft
        let value = UIInterfaceOrientation.LandscapeLeft.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
        initInViewDidLoad()
        print("added Observer")
        play()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerDidFinishPlaying:", name: AVPlayerItemDidPlayToEndTimeNotification, object: player.currentItem)
    }
    
    //MARK: Camera Orientation methods
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        let camerasNodeAngles = getCamerasNodeAngle()
        camerasNode!.eulerAngles = SCNVector3Make(Float(camerasNodeAngles[0]), Float(camerasNodeAngles[1]), Float(camerasNodeAngles[2]))
    }
    
    func getCamerasNodeAngle() -> [Double] {
        var camerasNodeAngle1: Double! = 0.0
        var camerasNodeAngle2: Double! = 0.0
        let orientation = UIApplication.sharedApplication().statusBarOrientation.rawValue
        if orientation == 1 {
            camerasNodeAngle1 = -M_PI_2
        } else if orientation == 2 {
            camerasNodeAngle1 = M_PI_2
        } else if orientation == 3 {
            camerasNodeAngle1 = 0.0
            camerasNodeAngle2 = M_PI
        }
        
        return [ -M_PI_2, camerasNodeAngle1, camerasNodeAngle2 ]
    }
    
    //Mark: video player methods
    func play(){
        
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let path = NSURL(fileURLWithPath: dirPaths)
        print(path)
        
        let fileURL = path.URLByAppendingPathComponent(videoFileURL)
        if (fileURL == fileURL){
            
            player = AVPlayer(URL: fileURL)
            
            videoSpriteKitNode =  SKVideoNode(AVPlayer: player)
            videoNode = SCNNode()
            videoNode!.geometry = SCNSphere(radius: 30)
            
            let spriteKitScene = SKScene(size: CGSize(width: 2500, height: 2500))
            spriteKitScene.scaleMode = .AspectFit
            
            videoSpriteKitNode!.position = CGPoint(x: spriteKitScene.size.width / 2.0, y: spriteKitScene.size.height / 2.0)
            videoSpriteKitNode!.size = spriteKitScene.size
            
            spriteKitScene.addChild(videoSpriteKitNode!)
            
            videoNode!.geometry?.firstMaterial?.diffuse.contents = spriteKitScene
            videoNode!.geometry?.firstMaterial?.doubleSided = true
            
            // Flip video upside down, so that it's shown in the right position
            var transform = SCNMatrix4MakeRotation(Float(M_PI), 0.0, 0.0, 1.0)
            transform = SCNMatrix4Translate(transform, 1.0, 1.0, 0.0)
            
            videoNode!.pivot = SCNMatrix4MakeRotation(Float(M_PI_2), 0.0, -1.0, 0.0)
            videoNode!.geometry?.firstMaterial?.diffuse.contentsTransform = transform
            videoNode!.position = SCNVector3(x: 0, y: 0, z: 0)
            
            scene!.rootNode.addChildNode(videoNode!)
            
//            progressObserver = player.addPeriodicTimeObserverForInterval(CMTimeMakeWithSeconds(0.1, Int32(NSEC_PER_SEC)),
//                queue: nil,
//                usingBlock: { [unowned self] (time) -> Void in
//                    self.updateSliderProgression()
//                })
//            
//            playPausePlayer()
//            NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerDidFinishPlaying:", name: AVPlayerItemDidPlayToEndTimeNotification, object: player.currentItem)
        }
    }
    
    //function for end popup
    func playerDidFinishPlaying(note: NSNotification) {
        print("finished playing the video")
        vidFinishedImage.hidden = false
        NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
    }
    
    func stopPlay(){
        
        if (playingVideo){
            vidPausedImage.hidden = false
            videoSpriteKitNode!.pause()
        }else{
            vidPausedImage.hidden = true
            videoSpriteKitNode!.play()
        }
        
        playingVideo = !playingVideo
    }
    
    //Mark: action methods
    func tapTheScreen(){
        // Action when the screen is tapped
        //        stopPlay()
        let playerDuration = self.playerItemDuration()
        let duration = Float(CMTimeGetSeconds(playerDuration))
        let time = Float(CMTimeGetSeconds(player.currentTime()))
        if time >= duration {
            vidFinishedImage.hidden = true
            restartVideoFromBeginning()
        }
        else {
            print(time, duration)
            stopPlay()
        }
    }
    
    func panGesture(sender: UIPanGestureRecognizer){
        //getting the CGpoint at the end of the pan
        let translation = sender.translationInView(sender.view!)
        
        var newAngleX = Float(translation.x)
        
        //current angle is an instance variable so i am adding the newAngle to it
        newAngleX = newAngleX + currentAngleX!
        videoNode!.eulerAngles.y = -newAngleX/100
        
        //getting the end angle of the swipe put into the instance variable
        if(sender.state == UIGestureRecognizerState.Ended) {
            currentAngleX = newAngleX
        }
    }
    
    //Mark: Render the scenes
//    func renderer(aRenderer: SCNSceneRenderer, updateAtTime time: NSTimeInterval){
//        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
//        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
//        // Render the scene
//        dispatch_async(backgroundQueue, { [weak self]() -> Void in
//            if let mm = self!.motionManager, let motion = mm.deviceMotion {
//                let currentAttitude = motion.attitude
//                
//                var roll : Double = currentAttitude.roll
//                if(UIApplication.sharedApplication().statusBarOrientation == UIInterfaceOrientation.LandscapeRight){ roll = -1.0 * (-M_PI - roll)}
//                
//                self!.cameraRollNode!.eulerAngles.x = Float(roll)
//                self!.cameraPitchNode!.eulerAngles.z = Float(currentAttitude.pitch)
//                self!.cameraYawNode!.eulerAngles.y = Float(currentAttitude.yaw)
//                
//            }
//        })
//    }
    func renderer(aRenderer: SCNSceneRenderer, updateAtTime time: NSTimeInterval){
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            // do some task
            dispatch_async(dispatch_get_main_queue()) { Void in
                // update some UI
                if let mm = self.motionManager, let motion = mm.deviceMotion {
                    let currentAttitude = motion.attitude
                    
                    var roll : Double = currentAttitude.roll
//                    if(UIApplication.sharedApplication().statusBarOrientation == UIInterfaceOrientation.LandscapeRight){ roll = -1.0 * (-M_PI - roll)}
//                    roll = -1.0 * (-M_PI - roll)
                    self.cameraRollNode!.eulerAngles.x = Float(roll)
                    self.cameraPitchNode!.eulerAngles.z = Float(currentAttitude.pitch)
                    self.cameraYawNode!.eulerAngles.y = Float(currentAttitude.yaw)
                    
                }
            }
        }
    }
    
    private func playerItemDuration() -> CMTime {
        let thePlayerItem = player.currentItem
        
        if AVPlayerItemStatus.ReadyToPlay == thePlayerItem?.status {
            return thePlayerItem?.duration ?? kCMTimeInvalid
        }
        
        return kCMTimeInvalid
    }
    
    //MARK: Clean Methods
    
    deinit {
        motionManager?.stopDeviceMotionUpdates()
        motionManager = nil
        
        if let observer = progressObserver {
            player.removeTimeObserver(observer)
        }
        
        playingVideo = false
        
        self.videoSpriteKitNode?.removeFromParent()
        
        for node in scene!.rootNode.childNodes {
            removeNode(node)
        }
    }
    
    func removeNode(node : SCNNode) {
        for node in node.childNodes {
            removeNode(node)
        }
        
        if 0 == node.childNodes.count {
            node.removeFromParentNode()
        }
    }
    
    func doubleTapped(){
        print("DOUBLE TAPPED!")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func initInViewDidLoad(){
        vidPausedImage.hidden = true
        vidFinishedImage.hidden = true
        
        // detect double tap gesture
        let tap = UITapGestureRecognizer(target: self, action: "doubleTapped")
        tap.numberOfTapsRequired = 2
        view.addGestureRecognizer(tap)
        
        //        print(videoPath)
        leftSceneView?.backgroundColor = UIColor.blackColor()
        rightSceneView?.backgroundColor = UIColor.whiteColor()
        
        // Create Scene
        scene = SCNScene()
        leftSceneView?.scene = scene
        rightSceneView?.scene = scene
        
        // Create cameras
        let camX = 0.0 as Float
        let camY = 0.0 as Float
        let camZ = 0.0 as Float
        let zFar = 50.0
        
        let leftCamera = SCNCamera()
        let rightCamera = SCNCamera()
        
        leftCamera.zFar = zFar
        rightCamera.zFar = zFar
        
        let leftCameraNode = SCNNode()
        leftCameraNode.camera = leftCamera
        leftCameraNode.position = SCNVector3(x: camX - 0.5, y: camY, z: camZ)
        
        let rightCameraNode = SCNNode()
        rightCameraNode.camera = rightCamera
        rightCameraNode.position = SCNVector3(x: camX + 0.5, y: camY, z: camZ)
        
        camerasNode = SCNNode()
        camerasNode!.position = SCNVector3(x: camX, y:camY, z:camZ)
        camerasNode!.addChildNode(leftCameraNode)
        camerasNode!.addChildNode(rightCameraNode)
        
        let camerasNodeAngles = getCamerasNodeAngle()
        camerasNode!.eulerAngles = SCNVector3Make(Float(camerasNodeAngles[0]), Float(camerasNodeAngles[1]), Float(camerasNodeAngles[2]))
        
        cameraRollNode =  SCNNode()
        cameraRollNode!.addChildNode(camerasNode!)
        
        cameraPitchNode = SCNNode()
        cameraPitchNode!.addChildNode(cameraRollNode!)
        
        cameraYawNode = SCNNode()
        cameraYawNode!.addChildNode(cameraPitchNode!)
        
        scene!.rootNode.addChildNode(cameraYawNode!)
        
        leftSceneView?.pointOfView = leftCameraNode
        rightSceneView?.pointOfView = rightCameraNode
        
        // Respond to user head movement. Refreshes the position of the camera 60 times per second.
        motionManager = CMMotionManager()
        motionManager?.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager?.startDeviceMotionUpdatesUsingReferenceFrame(CMAttitudeReferenceFrame.XArbitraryZVertical)
        
        leftSceneView?.delegate = self
        
        leftSceneView?.playing = true
        rightSceneView?.playing = true
        
        // Add gestures on screen
        recognizer = UITapGestureRecognizer(target: self, action:Selector("tapTheScreen"))
        recognizer!.delegate = self
        view.addGestureRecognizer(recognizer!)
        
        panRecognizer = UIPanGestureRecognizer(target: self, action: "panGesture:")
        view.addGestureRecognizer(panRecognizer!)
        currentAngleX = 0
        currentAngleY = 0
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [UIInterfaceOrientationMask.LandscapeLeft,UIInterfaceOrientationMask.LandscapeRight]
    }
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
