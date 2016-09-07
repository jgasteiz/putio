//
//  OfflineFilesController.swift
//  putio
//
//  Created by Javi Manzano on 04/09/2016.
//  Copyright © 2016 Javi Manzano. All rights reserved.
//

import Foundation

class OfflineFilesController {
    
    /*
     Return a list of offline files in the default documents directory.
    */
    func getOfflineFiles() -> [File] {
        var fileList: [File] = []
        let paths = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentsURL = paths[0]
        
        do {
            let fileManager = NSFileManager.defaultManager()
            let urlList = try fileManager.contentsOfDirectoryAtURL(documentsURL, includingPropertiesForKeys: nil, options: .SkipsPackageDescendants)
            for url in urlList {
                
                if url.path != nil {
                    let fileName = url.path!.characters.split{$0 == "/"}.map(String.init).last
                    
                    // Only support mp4 files for offline usage.
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
                                accessToken: ""
                            ))
                    }
                }
            }
        } catch {
            print("Couldn't get the list of local files")
        }
        
        return fileList
    }
    
    /*
     Delete a given file from the offline documents directory.
    */
    func deleteOfflineFile (file file: File) {
        do {
            try NSFileManager.defaultManager().removeItemAtURL(getFileOfflineURL(file: file))
            print("Deleted offline file")
        } catch {
            print("There was an error deleting \(file.getOfflineFileName())")
        }
    }
    
    /*
     Checks whether a file is offline or not.
    */
    func isFileOffline(file file: File) -> Bool {
        return NSFileManager.defaultManager().fileExistsAtPath(getFileOfflineURL(file: file).path!)
    }
    
    /*
     Gets a file playback url.
    */
    func getFilePlaybackURL(file file: File) -> NSURL {
        if isFileOffline(file: file) {
            return getFileOfflineURL(file: file)
        }
        return file.getDownloadURL()
    }
    
    /*
     Gets the path for an offline file
    */
    func getFileOfflineURL(file file: File) -> NSURL {
        let fileManager = NSFileManager.defaultManager()
        let documentsDirectory = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        return documentsDirectory.URLByAppendingPathComponent(file.getOfflineFileName())
    }
}
