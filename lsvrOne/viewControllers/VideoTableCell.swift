//
//  VideoTableCell.swift
//  lsvrOne
//
//  Created by Micah Chiang on 3/7/16.
//  Copyright © 2016 Micah Chiang. All rights reserved.
//
import UIKit
import Foundation

class VideoTableCell: UITableViewCell {
    
    @IBOutlet weak var videoTitle: UILabel!
    @IBOutlet weak var videoDescription: UILabel!
    @IBOutlet weak var videoThumbNail: UIImageView!
    var videoIdentification: String!
    //store video key for checking if file exists
    var videoName: String!
    
    private var _model: Video? = nil
    
    var model: Video? {
        get {
            return self._model
        }
        set {
            self.videoTitle!.text = self._model!.name
            self.videoDescription!.text = self._model!.desc
            //ASYNC REQUEST FOR THUMBNAIL ----
            // alamofire......
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}