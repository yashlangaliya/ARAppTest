//
//  VideoModel.swift
//  ARApp
//
//  Created by yash-mac on 19/10/23.
//

import Foundation
import RealmSwift

class VideoModel: Object {
    @objc dynamic var videoURLString = ""
    @objc dynamic var tag = ""
    @objc dynamic var duration = ""
}

