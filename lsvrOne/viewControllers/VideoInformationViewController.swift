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
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
//        let url = NSURL(fileURLWithPath: path)
//        let filePath = url.URLByAppendingPathComponent(vidFileName+".mp4").absoluteString
//        let fileManager = NSFileManager.defaultManager()
//        if fileManager.fileExistsAtPath(filePath) {
//            self.playButton.hidden = false
//            self.vidName = vidFileName
//            print("file exists")
//        }

//        UINavigationBar.appearance().setBackgroundImage(UIImage(named: "ls_logo"), forBarMetrics: .Default)
        checkIfFileExists(vidFileName)
        // Do any additional setup after loading the view.
        videoThumbnail.image = thumbNail
        videoDescription.text = videoInformation
        
        //sets progressbar attributes.
        downloadProgress.transform = CGAffineTransformScale(downloadProgress.transform, 1, 30)
        downloadProgress.setProgress(0.0, animated: false)
        downloadProgress.hidden = true
        
        var nav = self.navigationController?.navigationBar
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        imageView.contentMode = .ScaleAspectFit
        let image = UIImage(named: "ls_logo")
        imageView.image = image
        navigationItem.titleView = imageView
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.view.backgroundColor = UIColor.clearColor()
        //hide play button
        
        //check if file exists

        
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
            downloadProgress.hidden = false
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
                            print("Total bytes read on main queue: \(totalBytesRead)")
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
                            self.vidName = finalPath?.lastPathComponent as String!
                            self.playButton.hidden = false
                            self.downloadProgress.hidden = true
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
    
    func checkIfFileExists (fileName: String)->Bool{
        let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let filePath = path+"/"+fileName+".mp4"
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(filePath) {
            self.playButton.hidden = false
            self.vidName = fileName+".mp4"
            print("file exists")
            return true
        }
        self.playButton.hidden = true
        return false
    }
    
    
}

