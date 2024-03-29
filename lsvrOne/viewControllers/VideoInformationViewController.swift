//
//  VideoInformationViewController.swift
//  lsvrOne
//
//  Created by Micah Chiang on 3/9/16.
//  Copyright © 2016 Micah Chiang. All rights reserved.
//
import SystemConfiguration
import UIKit
import Alamofire



class VideoInformationViewController: UIViewController {

    @IBOutlet weak var videoThumbnail: UIImageView!
    @IBOutlet weak var videoDescription: UILabel!
    @IBOutlet weak var downloadProgress: UIProgressView!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    //for progress bar
    @IBOutlet weak var totalMegabytesLabel: UILabel!
    @IBOutlet weak var percentDoneLabel: UILabel!
    
    @IBAction func navBackButtonTapped(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func playButtonTapped(sender: UIButton) {
    }
    @IBAction func backButtonTapped(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func playButtonPressed(sender: UIButton) {
        performSegueWithIdentifier("segueToPlayStyle", sender: self)
    }
    
    var userCompanyName: String!
    var videoInformation: String!
    var thumbNail: UIImage!
    var userToken: String!
    var vidID: String!
    var vidURL: String!
    var vidName: String!
    var vidFileName: String!
    var reachability: Reachability?
    
    //used for updating progress bar after exiting and then returning to video info screen. NSTimer is fired once every second, and calls updateProgress
    var timer = NSTimer()
    func updateProgress() {
            dispatch_async(dispatch_get_main_queue()){
            self.percentDoneLabel.text! = "\(UserVariables.percentage)%"
            self.totalMegabytesLabel.text! = "\(UserVariables.fractionDone)MB / \(UserVariables.totalFraction)MB"
            self.downloadProgress.setProgress(Float(UserVariables.fractionDone)/Float(UserVariables.totalFraction), animated: true)
                
                if UserVariables.fractionDone == UserVariables.totalFraction {
                    self.downloadProgress.hidden = true
                    self.totalMegabytesLabel.hidden = true
                    self.percentDoneLabel.hidden = true
                    self.playButton.hidden = false
                }
        }

    }


    override func viewDidLoad() {
        super.viewDidLoad()
        let value = UIInterfaceOrientation.Portrait.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
//        UINavigationBar.appearance().setBackgroundImage(UIImage(named: "ls_logo"), forBarMetrics: .Default)
        checkIfFileExists(vidFileName)
        // Do any additional setup after loading the view.
        videoThumbnail.image = thumbNail
        videoDescription.text = videoInformation
        downloadProgress.transform = CGAffineTransformScale(downloadProgress.transform, 1, 30)
        downloadProgress.setProgress(0.0, animated: false)


        //sets progressbar attributes. if downloadDict key value is true, then download button is hidden, and update progress is called with nstimer
        if UserVariables.downloadDict["\(vidID)"] == true{
            downloadButton.hidden = false
            downloadProgress.hidden = false
            totalMegabytesLabel.hidden = false
            percentDoneLabel.hidden = false
            timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "updateProgress", userInfo: nil, repeats: true)
        }
        else {
        downloadProgress.hidden = true
        totalMegabytesLabel.text! = "0/0"
        percentDoneLabel.text! = "0%"
        totalMegabytesLabel.hidden = true
        percentDoneLabel.hidden = true
            print(UserVariables.downloadDict["\(vidID)"])
        }
        var nav = self.navigationController?.navigationBar
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        imageView.contentMode = .ScaleAspectFit
        let image = UIImage(named: "ls_logo")
        imageView.image = image
        navigationItem.titleView = imageView
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        //adjust alpha for transparency
        self.navigationController?.navigationBar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
        //hide play button
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func downloadButtonTapped(sender: AnyObject) {
        //reachability
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
        
        //if not connected to wifi do this:
        if reachability.isReachableViaWiFi() == false {
            print("connect to wifi please")
            performSegueWithIdentifier("segueToWifiWarning", sender: self)
        }
        //else, download:
        else {
            UserVariables.downloadDict["\(vidID)"] = true
            UserVariables.didFinishDownload = false
            downloadProgress.hidden = false
            percentDoneLabel.hidden = false
            totalMegabytesLabel.hidden = false
            downloadButton.hidden = true
            print("connected to wifi")
            Alamofire.request(.GET, "http://ec2-52-91-171-36.compute-1.amazonaws.com/assets/"+vidID+"?token="+userToken)
            .responseJSON {
                response in
                debugPrint(response)
                
                var tempResult = response.result.value as! Dictionary<String, AnyObject>
                //let destination = Alamofire.Request.suggestedDownloadDestination(directory: .DocumentDirectory, domain: .UserDomainMask)
                var fileName: String?
                var finalPath: NSURL?
                Alamofire.download(.GET,
                                    tempResult["url"] as! String,
                                    destination: { (temporaryURL, response) in
                                            if let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as? NSURL {
                                                    fileName = response.suggestedFilename!
                                                    finalPath = directoryURL.URLByAppendingPathComponent(fileName!)
                                                                        return finalPath!
                                            }
                                        print ("temporaryURL = \(temporaryURL)")
                                    return temporaryURL
                                   
                })
                    .progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
                        print(totalBytesRead)
                        
                        // This closure is NOT called on the main queue for performance
                        // reasons. To update your ui, dispatch to the main queue.
                        dispatch_async(dispatch_get_main_queue()) {
                            UserVariables.percentage = Int(floor((Float(totalBytesRead)/Float(totalBytesExpectedToRead))*100))
                            UserVariables.fractionDone = Int(floor((Float(totalBytesRead))/1000000))
                            UserVariables.totalFraction = Int((floor(Float(totalBytesExpectedToRead))/1000000))
                            print("Total bytes read on main queue: \(totalBytesRead)")
                            self.percentDoneLabel.text! = "\(UserVariables.percentage)%"
                            self.totalMegabytesLabel.text! = "\(UserVariables.fractionDone)MB / \(UserVariables.totalFraction)MB"
                            self.downloadProgress.setProgress(Float(totalBytesRead)/Float(totalBytesExpectedToRead), animated: true)
                        }
                    }
                    .response { _, _, _, error in
                        if let error = error {
                            print("Failed with error: \(error)")
                        } else {
//                            var filename: String? {
//                                return tempResult["url"]!.lastPathComponent
//                            }
                           
                            print("Downloaded file successfully")
//                            print(destination)
                             print ("downloaded file to = \(finalPath)")
                            UserVariables.downloadDict["\(self.vidID)"] = false;
                            UserVariables.didFinishDownload = true
                            self.vidName = finalPath?.lastPathComponent as String!
                            self.playButton.hidden = false
                            self.downloadProgress.hidden = true
                            self.totalMegabytesLabel.hidden = true
                            self.percentDoneLabel.hidden = true
                        }
                    }
                }
            }
        } //end of downLoadButtonTapped function
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueToPlayStyle" {
            let controller = segue.destinationViewController as! VideoDetailViewController
            controller.vidName = vidName
        }
        if segue.identifier == "segueToUserLogout" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! LogOutViewController
//            controller.currentUserName = userCompanyName
        }
    }
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    func checkIfFileExists (fileName: String)->Bool{
        let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let filePath = path+"/"+fileName+".mp4"
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(filePath) {
            self.playButton.hidden = false
            self.vidName = fileName+".mp4"
            print("file exists")
//            UserVariables.downloadDict["\(vidID)"] = false;
            return true
        }
        if UserVariables.didFinishDownload == true {
            self.playButton.hidden = false
            self.downloadProgress.hidden = true
            self.totalMegabytesLabel.hidden = true
            self.percentDoneLabel.hidden = true
        }
        self.playButton.hidden = true
//        UserVariables.downloadDict["\(vidID)"] = false;
        return false
    }
    
//    deinit {
//        checkIfFileExists(vidFileName)
//    }

}

