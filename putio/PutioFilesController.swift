//
//  PutioFilesController.swift
//  putio
//
//  Created by Javi Manzano on 31/10/2015.
//  Copyright © 2015 Javi Manzano. All rights reserved.
//

import Foundation
import Alamofire

class PutioFilesController {
    
    var downloads = [Int: Dictionary<String, AnyObject>]()
    
    static let sharedInstance = PutioFilesController()
    
    /*
     Fetch a directory of files from put.io.
    */
    func fetchDirectoryFiles(parent: File?, onTaskDone: ([File]) -> Void, onTaskError: () -> Void) {
        guard let accessToken = NSUserDefaults.standardUserDefaults().valueForKey("accessToken") as? String else {
            print("Access token is missing")
            return
        }
        
        // Get the files in the directory
        let downloadTask: NSURLSessionDownloadTask = NSURLSession.sharedSession().downloadTaskWithURL(
            getApiURL(parent, accessToken: accessToken),
            completionHandler:
            { (location: NSURL?, response: NSURLResponse?, error: NSError?) -> Void in
            
            if error != nil {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    onTaskError()
                })
                return
            }
            
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
                    fileExtension: fileDict["extension"] as? String,
                    accessToken: accessToken
                ))
            }
            
            // Perform the dispatch async with the fetched stories
            // and the boolean value of firstThirtyStories.
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                onTaskDone(files)
            })
        })
        
        // Perform the API call.
        downloadTask.resume()
    }
    
    /*
     Download a file from put.io to local storage.
    */
    func downloadFile(file file: File, downloadURL: NSURL) -> Void {
        
        downloads[file.getId()] = ["downloadProgress": 0.0, "taskRunning": true]
        
        let fileDestination = Alamofire.Request.suggestedDownloadDestination(directory: .DocumentDirectory, domain: .UserDomainMask)
        
        let download = Alamofire.download(
            Alamofire.Method.GET,
            downloadURL,
            destination: fileDestination
        )
        .progress({ bytesRead, totalBytesRead, totalBytesExpectedToRead in
            // This closure is NOT called on the main queue for performance
            // reasons. To update your ui, dispatch to the main queue.
            dispatch_async(dispatch_get_main_queue()) {
                let downloadProgress = Float(totalBytesRead) / Float(totalBytesExpectedToRead)
                self.downloads[file.getId()]!["downloadProgress"] = downloadProgress
            }
        })
        .response(completionHandler: { _, _, _, error in
            if let error = error {
                print("Failed with error: \(error)")
            } else {
                print("File downloaded successfully: \(file.getName())")
            }
            self.downloads[file.getId()] = ["downloadProgress": 0.0, "taskRunning": false]
        })
        
        
        downloads[file.getId()]!["request"] = download
    }
    
    /*
     Cancel an active request for downloading a file.
    */
    func cancelDownload(file: File) {
        if let download = downloads[file.getId()] {
            let request = download["request"] as! Alamofire.Request
            request.cancel()
            downloads[file.getId()] = ["taskRunning": false]
        }
    }
    
    /*
     Delete a remote put.io file or directory.
    */
    func deleteRemoteFile(file: File, onFileDeleted: () -> Void) {
        guard let accessToken = NSUserDefaults.standardUserDefaults().valueForKey("accessToken") as? String else {
            print("Access token is missing")
            return
        }
        
        Alamofire.request(
            Alamofire.Method.POST,
            getDeleteApiURL(accessToken),
            parameters: ["file_ids": String(file.getId())]
        )
        .response(completionHandler: { request, response, data, error in
            if response?.statusCode == 200 {
                print("File deleted successfully: \(file.getName())")
                onFileDeleted()
            } else {
                print("Failed with error: \(error)")
                print(data)
                print(String(response))
            }
        })
    }
    
    /*
     Add a new transfer to the put.io transfers.
     */
    func addTransfer(downloadURL: String, onTransferAdded: () -> Void) {
        guard let accessToken = NSUserDefaults.standardUserDefaults().valueForKey("accessToken") as? String else {
            print("Access token is missing")
            return
        }
        
        Alamofire.request(
            Alamofire.Method.POST,
            getAddApiURL(accessToken),
            parameters: [
                "url": downloadURL,
                "save_parent_id": 0,
                "extract": true
            ]
        )
            .response(completionHandler: { request, response, data, error in
                if response?.statusCode == 200 {
                    print("Transfer added successfully")
                    onTransferAdded()
                } else {
                    print("Failed with error: \(error)")
                    print(data)
                    print(String(response))
                }
            })
    }
    
    /*
     Return the download progress.
    */
    func getDownloadProgress(file: File) -> Float {
        if let download = downloads[file.getId()] {
            return download["downloadProgress"] as! Float
        }
        return 0.0
    }
    
    /*
     Return a boolean determining whether a download task for a given file
     is in progress or not.
    */
    func isTaskRunning(file: File) -> Bool {
        if let download = downloads[file.getId()] {
            if let isTaskRunning = download["taskRunning"] as? Bool {
                return isTaskRunning
            }
        }
        return false
    }

    /*
     Get the API url necessary for fetching a file/directory from put.io.
    */
    private func getApiURL (parent: File?, accessToken: String) -> NSURL {
        if parent != nil {
            return NSURL(string: "https://api.put.io/v2/files/list?oauth_token=\(accessToken)&parent_id=\(parent!.getId())")!
        } else {
            return NSURL(string: "https://api.put.io/v2/files/list?oauth_token=\(accessToken)")!
        }
    }
    
    /*
     Get the API url for deleting a file in put.io.
    */
    private func getDeleteApiURL (accessToken: String) -> NSURL {
        return NSURL(string: "https://api.put.io/v2/files/delete?oauth_token=\(accessToken)")!
    }
    
    /*
     Get the API url for adding a new transfer.
     */
    private func getAddApiURL (accessToken: String) -> NSURL {
        return NSURL(string: "https://api.put.io/v2/transfers/add?oauth_token=\(accessToken)")!
    }
}
