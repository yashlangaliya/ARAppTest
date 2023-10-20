//
//  VideoDB.swift
//  ARApp
//
//  Created by yash-mac on 19/10/23.
//

import Foundation
import RealmSwift

class VideoDB {
    
    var realm: Realm = try! Realm()
    public func saveVideo(_ video: VideoModel)
    {
        try! realm.write {
            realm.add(video)
        }
    }
    
    public func getVideos() -> Results<VideoModel>
    {
        let results = realm.objects(VideoModel.self)
        return results
    }
}
