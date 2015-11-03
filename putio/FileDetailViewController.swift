//
//  FileViewController.swift
//  putio
//
//  Created by Javi Manzano on 01/11/2015.
//  Copyright © 2015 Javi Manzano. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class FileDetailViewController: UIViewController {
    
    var file: File? = nil
    
    let webViewSegueId = "showWeb"
    let mediaSegueId = "showMedia"
    
    // Get an instance of the file manager
    let fileManager = NSFileManager.defaultManager()
    let documentsDirectory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
    var offlineFileURL: NSURL?
    
    @IBOutlet weak var fileName: UILabel!
    @IBOutlet weak var fileSize: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationItem.title = file!.getName()
        
        fileName.text = file!.getName()
        fileSize.text = file!.getSize()
        
        if let thumbnailURL = NSURL(string: file!.getThumbnail()) {
            if let data = NSData(contentsOfURL: thumbnailURL){
                imageView.contentMode = UIViewContentMode.ScaleAspectFit
                imageView.image = UIImage(data: data)
            }
        }
        
        if file!.isVideo() {
            playButton.setTitle("Play Video", forState: UIControlState.Normal)
        } else if file!.isAudio() {
            playButton.setTitle("Play Audio", forState: UIControlState.Normal)
        } else {
            playButton.setTitle("View in WebView", forState: UIControlState.Normal)
        }
        
        // Initialise the `offline file url`
        let offlineMediaDirectory = documentsDirectory.URLByAppendingPathComponent("Offline", isDirectory: true)
        // Try to create it if it doesn't exist.
        do {
            try fileManager.createDirectoryAtURL(offlineMediaDirectory, withIntermediateDirectories: false, attributes: nil)
        } catch {
            print("Failed creating downloads directory")
        }
        offlineFileURL = offlineMediaDirectory.URLByAppendingPathComponent(file!.getOfflineFileName())
        
        // If the file is downloaded, remove the "Download" button.
        if isFileDownloaded() {
            downloadButton.hidden = true
        }
        // Otherwise remove the "Delete download" button.
        else {
            deleteButton.hidden = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == webViewSegueId {
            let controller = segue.destinationViewController as! WebViewViewController
            controller.file = file
        }
    }
    
    @IBAction func viewFile(sender: AnyObject) {
        if file!.isVideo() || file!.isAudio() {
            let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MediaViewController") as! AVPlayerViewController
            secondViewController.player = AVPlayer(URL: file!.getDownloadURL())
            self.presentViewController(secondViewController, animated: true, completion: nil)
        } else {
            self.performSegueWithIdentifier(webViewSegueId, sender: sender)
        }
    }
    
    @IBAction func downloadFile(sender: AnyObject) {
        // If the file is downloaded already, don't continue.
        if isFileDownloaded() {
            notifyUser("This file has been downloaded already.")
            return
        }
        
        // Save file.
        // TODO: save the file using an async task.
        let fileData = NSData(contentsOfURL: file!.getDownloadURL())!
        fileData.writeToURL(offlineFileURL!, atomically: true)
        downloadButton.hidden = true
        deleteButton.hidden = false
    }
    
    @IBAction func deleteFile(sender: AnyObject) {
        // If the file hasn't been downloaded yet, don't continue.
        if !isFileDownloaded() {
            notifyUser("This file hasn't been downloaded yet.")
            return
        }
        
        do {
            try fileManager.removeItemAtURL(offlineFileURL!)
        } catch {
            print("There was an error deleting \(file!.getOfflineFileName())")
        }
        deleteButton.hidden = true
        downloadButton.hidden = false
    }
    
    func isFileDownloaded() -> Bool {
        return fileManager.fileExistsAtPath(offlineFileURL!.path!)
    }
    
    func notifyUser(message: String) -> Void {
        // Show error message
        let alertController = UIAlertController(title: "Ooops", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        presentViewController(alertController, animated: true, completion: nil)
    }
}
