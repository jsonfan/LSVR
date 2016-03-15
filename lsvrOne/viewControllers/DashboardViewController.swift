//
//  DashboardViewController.swift
//  lsvrOne
//
//  Created by Micah Chiang on 3/7/16.
//  Copyright © 2016 Micah Chiang. All rights reserved.
//

import UIKit
import Foundation
import Alamofire

extension UIImageView {
    public func imageFromUrl(urlString: String) {
        if let url = NSURL(string: urlString) {
            let request = NSURLRequest(URL: url)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {
                (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
                self.image = UIImage(data: data!)
            }
        }
    }
}

class DashboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    
    //variables that hold user data and video data.
    var currentUser: Dictionary<String, String> = [:]
    var userName: String = ""
    var vidsAvailable: Array<Dictionary<String, AnyObject>> = []
    
    //these variables hold data for segueing to VideoInformationViewController
    var videoTitle: String!
    var videoDesc: String!
    var videoPic: UIImage!
    var videoID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //retrieves video list for logged in user.
        getAssets(currentUser["token"]!)
        userName = currentUser["username"]!
    }

    
    
    //table functions
    
    //returns number of rows (equal to number of videos client has access to.)
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vidsAvailable.count
    }
    
    //assigns video title and desc to each cell, then return. videoIdentification is used for downloading video later on.
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: VideoTableCell = tableView.dequeueReusableCellWithIdentifier("cell")! as! VideoTableCell

        let video: Dictionary<String, AnyObject>
        video = vidsAvailable[indexPath.row]
        let thumbnailBucket = video["thumbnailBucket"] as! String
        let thumbnailKey = video["thumbnailKey"] as! String
        let thumbnailURL = "https://s3.amazonaws.com/"+thumbnailBucket+"/"+thumbnailKey
        cell.videoTitle?.text = video["name"] as! String
        cell.videoDescription?.text = video["description"] as! String
        cell.videoIdentification = video["_id"] as! String
        ImageLoader.sharedLoader.imageForUrl(thumbnailURL, completionHandler: {(image: UIImage?, url: String) in
            cell.videoThumbNail?.image = image!
        })
        return cell
    }
    
    //function that selects a given video from thumbnail, gathers necessary information in preparation to send to VideoInformationViewController, then calls proper segue.
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("I LIKE TURTLES")
        let indexPath = tableView.indexPathForSelectedRow!
        let cell = tableView.cellForRowAtIndexPath(indexPath)! as! VideoTableCell
        videoTitle = cell.videoTitle.text!
        videoDesc = cell.videoDescription.text!
        videoPic = cell.videoThumbNail?.image!
        videoID = cell.videoIdentification
        print(videoTitle, videoDesc, videoPic, videoID)
        performSegueWithIdentifier("segueToVideoInfo", sender: self)
    }

    //function to request authorized assets for user
    func getAssets (token: String){
        Alamofire.request(.GET, "http://ec2-52-91-171-36.compute-1.amazonaws.com/assets", parameters: ["token": token])
            .responseJSON {response in
                debugPrint(response)
                var tempResult = response.result.value as! Dictionary<String, AnyObject>
                let tempArray = tempResult["_availableAssets"] as! Array<Dictionary<String, AnyObject>>
                for var i = 0; i < tempArray.count; i++ {
                    self.vidsAvailable.append(tempArray[i])
                }
                print(self.vidsAvailable[0]["_id"])
                self.tableView.reloadData()
        }

    }
    
    //function sends video information to VideoInformationViewController needed to download a video.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueToVideoInfo" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! VideoInformationViewController
            controller.thumbNail = videoPic
            controller.videoInformation = videoDesc
            controller.userToken = currentUser["token"]
            controller.vidID = videoID
            controller.userCompanyName = userName
            tableView.deselectRowAtIndexPath(tableView.indexPathForSelectedRow!, animated: true)
        }
        if segue.identifier == "segueToLogoutView" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! LogOutViewController
            controller.currentUserName = userName
        }
    }
}
