//
//  User.swift
//  lsvrOne
//
//  Created by Micah Chiang on 3/14/16.
//  Copyright © 2016 Micah Chiang. All rights reserved.
//

import Foundation

struct UserVariables {
    static var userName: String!
    static var downloadDict: Dictionary<String,Bool>! = [:]
    static var percentage: Int!
    static var fractionDone: Int!
    static var totalFraction: Int!
    static var didFinishDownload: Bool = false
}