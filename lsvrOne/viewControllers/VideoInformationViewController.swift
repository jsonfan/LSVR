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
    var reachability: Reachability?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        videoThumbnail.image = thumbNail
        videoDescription.text = videoInformation
        downloadProgress.transform = CGAffineTransformScale(downloadProgress.transform, 1, 20)
        
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
    
    
}

