//
//  File.swift
//  putio
//
//  Created by Javi Manzano on 31/10/2015.
//  Copyright © 2015 Javi Manzano. All rights reserved.
//

import Foundation
import UIKit

class File {

    var id: Int?
    var name: String?
    var parentId: Int?
    var thumbnail: String?
    var contentType: String?
    var createdAt: String?
    var hasMp4: Bool?
    var size: Int?
    var fileExtension: String?
    
    init(id: Int?, name: String?, parentId: Int?, thumbnail: String?, contentType: String?, createdAt: String?, hasMp4: Bool?, size: Int?, fileExtension: String?) {
        self.id = id
        self.name = name
        self.parentId = parentId
        self.thumbnail = thumbnail
        self.contentType = contentType
        self.createdAt = createdAt
        self.hasMp4 = hasMp4
        self.size = size
        self.fileExtension = fileExtension
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
    
    func getIcon() -> UIImage {
        if isAudio() {
            return UIImage(named: "Audio")!
        } else if isDirectory() {
            return UIImage(named: "Directory")!
        } else if isPdf() {
            return UIImage(named: "PDF")!
        } else if isPicture() {
            return UIImage(named: "Picture")!
        } else if isVideo() {
            return UIImage(named: "Video")!
        }
        return UIImage(named: "File")!
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
    
    func getDownloadURL() -> NSURL {
        if getHasMp4() {
            return NSURL(string: "https://api.put.io/v2/files/\(getId())/mp4/download?oauth_token=6HVUGYDO")!
        } else {
            return NSURL(string: "https://api.put.io/v2/files/\(getId())/download?oauth_token=6HVUGYDO")!
        }
    }
    
    func getFileExtension() -> String {
        return self.fileExtension != nil ? self.fileExtension! : ""
    }
    
    func getOfflineFileName() -> String {
        return self.getName()
    }
    
    func isDirectory() -> Bool {
        return self.getContentType().containsString("directory")
    }
    
    func isAudio() -> Bool {
        return self.getContentType().containsString("audio")
    }
    
    func isPdf() -> Bool {
        return self.getContentType().containsString("pdf")
    }
    
    func isPicture() -> Bool {
        return self.getContentType().containsString("image")
    }
    
    func isVideo() -> Bool {
        return self.getContentType().containsString("video")
    }
    
}