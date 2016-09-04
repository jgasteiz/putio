//
//  FilesController.swift
//  putio
//
//  Created by Javi Manzano on 04/09/2016.
//  Copyright © 2016 Javi Manzano. All rights reserved.
//

import Foundation

class FilesController {
    
    func getOfflineFiles() -> [File] {
        var fileList: [File] = []
        let fileManager = NSFileManager.defaultManager()
        let paths = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentsURL = paths[0]
        do {
            let urlList = try fileManager.contentsOfDirectoryAtURL(documentsURL, includingPropertiesForKeys: nil, options: .SkipsPackageDescendants)
            for url in urlList {
                let path = url.path
                if path != nil {
                    let pathComponents = path!.characters.split{$0 == "/"}.map(String.init)
                    let fileName = pathComponents.last
                    if (fileName!.containsString("mp4")) {
                        fileList.append(File(id: 0, name: fileName, parentId: -1, thumbnail: nil, contentType: "video", createdAt: nil, hasMp4: true, size: -1, fileExtension: "mp4"))
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
            try fileManager.removeItemAtURL(file.getOfflineURL())
        } catch {
            print("There was an error deleting \(file.getOfflineFileName())")
        }
    }
}