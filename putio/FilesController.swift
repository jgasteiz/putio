//
//  FilesController.swift
//  putio
//
//  Created by Javi Manzano on 04/09/2016.
//  Copyright © 2016 Javi Manzano. All rights reserved.
//

import Foundation

class FilesController {
    
    let fileManager = NSFileManager.defaultManager()
    
    func getOfflineFiles() -> [File] {
        var fileList: [File] = []
        let paths = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentsURL = paths[0]
        
        let accessToken = NSUserDefaults.standardUserDefaults().valueForKey("accessToken") as? String
        
        do {
            let urlList = try fileManager.contentsOfDirectoryAtURL(documentsURL, includingPropertiesForKeys: nil, options: .SkipsPackageDescendants)
            for url in urlList {
                let path = url.path
                if path != nil {
                    let pathComponents = path!.characters.split{$0 == "/"}.map(String.init)
                    let fileName = pathComponents.last
                    if (fileName!.containsString("mp4")) {
                        fileList.append(
                            File(
                                id: 0,
                                name: fileName,
                                parentId: -1,
                                thumbnail: nil,
                                contentType: "video",
                                createdAt: nil,
                                hasMp4: true,
                                size: -1,
                                fileExtension: "mp4",
                                accessToken: accessToken
                            ))
                    }
                }
            }
        } catch {
            return fileList
        }
        return fileList
    }
    
    func deleteFile (file file: File) {
        let fileManager = NSFileManager.defaultManager()
        do {
            try fileManager.removeItemAtURL(getFileOfflineURL(file: file))
        } catch {
            print("There was an error deleting \(file.getOfflineFileName())")
        }
    }
    
    func isFileOffline(file file: File) -> Bool {
        return fileManager.fileExistsAtPath(getFileOfflineURL(file: file).path!)
    }
    
    func getFilePlaybackURL(file file: File) -> NSURL {
        if self.isFileOffline(file: file) {
            return getFileOfflineURL(file: file)
        }
        return file.getDownloadURL()
    }
    
    func getFileOfflineURL(file file: File) -> NSURL {
        let documentsDirectory = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        return documentsDirectory.URLByAppendingPathComponent(file.getOfflineFileName())
    }
}