//
//  File.swift
//  putio
//
//  Created by Javi Manzano on 31/10/2015.
//  Copyright © 2015 Javi Manzano. All rights reserved.
//

import Foundation

class File {

    var id: Int?
    var name: String?
    var parentId: Int?
    var thumbnail: String?
    var contentType: String?
    var createdAt: String?
    var hasMp4: Bool?
    var size: Int?
    
    init(id: Int?, name: String?, parentId: Int?, thumbnail: String?, contentType: String?, createdAt: String?, hasMp4: Bool?, size: Int?) {
        self.id = id
        self.name = name
        self.parentId = parentId
        self.thumbnail = thumbnail
        self.contentType = contentType
        self.createdAt = createdAt
        self.hasMp4 = hasMp4
        self.size = size
    }
    
    ////////////////////////////
    // Getters
    ////////////////////////////
    func getId() -> Int {
        return self.id != nil ? self.id! : -1
    }
    
    func getName() -> String {
        return self.name != nil ? self.name! : ""
    }
    
    func getParentId() -> Int {
        return self.parentId != nil ? self.parentId! : -1
    }
    
    func getThumbnail() -> String {
        return self.thumbnail != nil ? self.thumbnail! : ""
    }
    
    func getContentType() -> String {
        return self.contentType != nil ? self.contentType! : ""
    }
    
    func getCreatedAt() -> String {
        return self.createdAt != nil ? self.createdAt! : ""
    }
    
    func getHasMp4() -> Bool {
        return self.hasMp4 != nil ? self.hasMp4! : false
    }
    
    func getSize() -> String {
        let bytes: Int = self.size != nil ? self.size! : 0
        if bytes > 1000000000 {
            return "\(bytes / 1024 / 1024 / 1024)GB"
        } else if bytes > 1000000 {
            return "\(bytes / 1024 / 1024)MB"
        } else if bytes > 1000 {
            return "\(bytes / 1024)KB"
        } else {
            return "\(bytes)B"
        }
    }
    
    func isVideo() -> Bool {
        return self.getContentType().containsString("video")
    }
    
    func isAudio() -> Bool {
        return self.getContentType().containsString("audio")
    }
    
    func getDownloadURL() -> NSURL {
        if self.getHasMp4() {
            return NSURL(string: "https://api.put.io/v2/files/\(self.getId())/mp4/download?oauth_token=6HVUGYDO")!
        } else {
            return NSURL(string: "https://api.put.io/v2/files/\(self.getId())/download?oauth_token=6HVUGYDO")!
        }
    }
    
}