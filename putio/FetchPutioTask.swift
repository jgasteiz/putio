//
//  FetchFilesTask.swift
//  putio
//
//  Created by Javi Manzano on 31/10/2015.
//  Copyright © 2015 Javi Manzano. All rights reserved.
//

import Foundation

struct FetchPutioTask {
    
    let fetchFilesURL: String
    let accessToken: String
    
    init(accessToken: String) {
        self.fetchFilesURL = "https://api.put.io/v2/files/list"
        self.accessToken = accessToken
    }
    
    func getApiURL (parent: File?) -> NSURL {
        if parent != nil {
            return NSURL(string: "\(fetchFilesURL)?oauth_token=\(accessToken)&parent_id=\(parent!.getId())")!
        } else {
            return NSURL(string: "\(fetchFilesURL)?oauth_token=\(accessToken)")!
        }
    }
    
    func fetchDirectoryFiles(parent: File?, onTaskDone: ([File]) -> Void, onTaskError: () -> Void) {
        
        let apiURL = getApiURL(parent)

        // Get the top stories
        let sharedSession = NSURLSession.sharedSession()
        let downloadTask: NSURLSessionDownloadTask = sharedSession.downloadTaskWithURL(apiURL, completionHandler: { (location: NSURL?, response: NSURLResponse?, error: NSError?) -> Void in
            
            if error == nil {
                // Get the url content as NSData
                let dataObject = NSData(contentsOfURL: location!)
                
                // Get the files
                var files: [File] = []
                
                let responseJson: NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(dataObject!, options: [])) as! NSDictionary
                let filesArray: NSArray = responseJson["files"] as! NSArray
                
                // Add the fetched stories to the array
                for fileDict in filesArray {
                    files.append(File(
                        id: fileDict["id"] as? Int,
                        name: fileDict["name"] as? String,
                        parentId: fileDict["parent_id"] as? Int,
                        icon: fileDict["icon"] as? String,
                        thumbnail: fileDict["screenshot"] as? String,
                        contentType: fileDict["content_type"] as? String,
                        createdAt: fileDict["created_at"] as? String,
                        hasMp4: fileDict["is_mp4_available"] as? Bool,
                        size: fileDict["size"] as? Int
                    ))
                }
                
                // Perform the dispatch async with the fetched stories
                // and the boolean value of firstThirtyStories.
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    onTaskDone(files)
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    onTaskError()
                })
            }
        })
        
        // Perform the API call.
        downloadTask.resume()
    }
}
