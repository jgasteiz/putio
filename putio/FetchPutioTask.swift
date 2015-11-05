//
//  FetchFilesTask.swift
//  putio
//
//  Created by Javi Manzano on 31/10/2015.
//  Copyright © 2015 Javi Manzano. All rights reserved.
//

import Foundation
import Alamofire

class FetchPutioTask {
    
    let fetchFilesURL: String
    var isTaskRunning: Bool
    var isCancelled: Bool
    
    static let sharedInstance = FetchPutioTask()
    
    private init() {
        self.fetchFilesURL = "https://api.put.io/v2/files/list"
        self.isTaskRunning = false
        self.isCancelled = false
    }
    
    func getApiURL (parent: File?, accessToken: String) -> NSURL {
        if parent != nil {
            return NSURL(string: "\(fetchFilesURL)?oauth_token=\(accessToken)&parent_id=\(parent!.getId())")!
        } else {
            return NSURL(string: "\(fetchFilesURL)?oauth_token=\(accessToken)")!
        }
    }
    
    func fetchDirectoryFiles(parent: File?, accessToken: String, onTaskDone: ([File]) -> Void, onTaskError: () -> Void) {
        
        let apiURL = getApiURL(parent, accessToken: accessToken)

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
                        thumbnail: fileDict["screenshot"] as? String,
                        contentType: fileDict["content_type"] as? String,
                        createdAt: fileDict["created_at"] as? String,
                        hasMp4: fileDict["is_mp4_available"] as? Bool,
                        size: fileDict["size"] as? Int,
                        fileExtension: fileDict["extension"] as? String
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
    
    func downloadFile(file: File, onFileDownloadSuccess: () -> Void, onFileDownloadError: (NSError) -> Void, onFileDownloadProgress: (Float, Float) -> Void) {
        
        let destination = Alamofire.Request.suggestedDownloadDestination(directory: .DocumentDirectory, domain: .UserDomainMask)
        Alamofire.download(Alamofire.Method.GET, file.getDownloadURL(), destination: destination)
            .progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
                // This closure is NOT called on the main queue for performance
                // reasons. To update your ui, dispatch to the main queue.
                dispatch_async(dispatch_get_main_queue()) {
                    onFileDownloadProgress(Float(totalBytesRead), Float(totalBytesExpectedToRead))
                }
            }
            .response { _, _, _, error in
                if let error = error {
                    onFileDownloadError(error)
                } else {
                    onFileDownloadSuccess()
                }
        }
    }
}
