//
//  ImageLoader.swift
//  lsvrOne
//
//  Created by Micah Chiang on 3/9/16.
//  Copyright © 2016 Micah Chiang. All rights reserved.
//

import Foundation
import UIKit

class ImageLoader {
    
    var cache = NSCache()
    
    class var sharedLoader : ImageLoader {
        struct Static {
            static let instance : ImageLoader = ImageLoader()
        }
        return Static.instance
    }
    
    func imageForUrl(urlString: String, completionHandler:(image: UIImage?, url: String) -> ()) {
        /*
        let keyName = urlString.slice(urlString.lastIndexOf('/'));
        */
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {()in
            var data: NSData? = self.cache.objectForKey(urlString) as? NSData
            
            if let goodData = data {
                let image = UIImage(data: goodData)
                dispatch_async(dispatch_get_main_queue(), {() in
                    completionHandler(image: image, url: urlString)
                })
                return
            }
            
            var downloadTask: NSURLSessionDataTask = NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: urlString)!, completionHandler: {(data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                if (error != nil) {
                    completionHandler(image: nil, url: urlString)
                    return
                }
                
                if data != nil {
                    let image = UIImage(data: data!)
                    self.cache.setObject(data!, forKey: urlString)
                    dispatch_async(dispatch_get_main_queue(), {() in
                        completionHandler(image: image, url: urlString)
                    })
                    return
                }
                
            })
            downloadTask.resume()
        })
        
    }
    /*
    func loadImagesFromAssets(){
        Go through all files in thumbnails folder
        foreach:
            let fileURL: NSURL? = NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource("testvid1", ofType: "mp4")!)
    
            KeyName = "testvid1"
            data = ?
            self.cache.setObject(data!, forKey: KeyName)
    }
    */
}