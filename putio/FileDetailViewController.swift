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
    
    // Fetch task
    var fetchPutioTask: FetchPutioTask = FetchPutioTask.sharedInstance
    
    var file: File? = nil
    
    var statusCheckTimer: NSTimer?
    
    let webViewSegueId = "showWeb"
    let mediaSegueId = "showMedia"
    
    // Get an instance of the file manager
    let fileManager = NSFileManager.defaultManager()
    
    @IBOutlet weak var fileName: UILabel!
    @IBOutlet weak var fileSize: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var cancelDownload: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationItem.title = file!.getName()
        
        fileName.text = file!.getName()
        fileSize.text = file!.getSize()
        
        imageView.hidden = true
        if let thumbnailURL = NSURL(string: file!.getThumbnail()) {
            if let data = NSData(contentsOfURL: thumbnailURL){
                imageView.hidden = false
                imageView.contentMode = UIViewContentMode.ScaleAspectFit
                imageView.image = UIImage(data: data)
            }
        }
        
        // Set title for the play button.
        if file!.isVideo() {
            playButton.setTitle("Play Video", forState: UIControlState.Normal)
        } else if file!.isAudio() {
            playButton.setTitle("Play Audio", forState: UIControlState.Normal)
        } else {
            playButton.setTitle("View in WebView", forState: UIControlState.Normal)
        }
        
        // Try to create it if it doesn't exist.
        let documentsDirectory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        do {
            try fileManager.createDirectoryAtURL(documentsDirectory, withIntermediateDirectories: false, attributes: nil)
        } catch {
            print("Failed creating downloads directory")
        }
        
        // If the file is downloaded, remove the "Download" button.
        if file!.isFileOffline() {
            downloadButton.hidden = true
        }
        // Otherwise remove the "Delete download" button.
        else {
            deleteButton.hidden = true
        }
        
        if (fetchPutioTask.isTaskRunning) {
            animateActivityIndicator()
            // check status of the task every second
            self.statusCheckTimer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: Selector("checkDownloadStatus"), userInfo: nil, repeats: true)
        } else {
            cancelDownload.hidden = true
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
            
            secondViewController.player = AVPlayer(URL: file!.getPlaybackURL())
            
            self.presentViewController(secondViewController, animated: true, completion: nil)
        } else {
            self.performSegueWithIdentifier(webViewSegueId, sender: sender)
        }
    }
    
    @IBAction func downloadFile(sender: AnyObject) {
        // If the file is downloaded already, don't continue.
        if file!.isFileOffline() {
            notifyUser("This file has been downloaded already.")
            return
        }
        
        // Save file.
        animateActivityIndicator()
        fetchPutioTask.downloadFile(file!, onFileDownloadSuccess: onFileDownloadSuccess, onFileDownloadError: onFileDownloadError, onFileDownloadProgress: onFileDownloadProgress)
    }
    
    @IBAction func deleteFile(sender: AnyObject) {
        // If the file hasn't been downloaded yet, don't continue.
        if !file!.isFileOffline() {
            notifyUser("This file hasn't been downloaded yet.")
            return
        }
        
        do {
            try fileManager.removeItemAtURL(file!.getOfflineURL())
        } catch {
            print("There was an error deleting \(file!.getOfflineFileName())")
        }
        deleteButton.hidden = true
        downloadButton.hidden = false
    }
    
    @IBAction func cancelDownload(sender: AnyObject) {
        stopActivityIndicator()
        fetchPutioTask.isTaskRunning = false
        deleteFile(sender)
    }
    
    func onFileDownloadSuccess() {
        print("File downloaded successfully: \(self.file!.getName())")
        
        self.stopActivityIndicator()
    }
    
    func onFileDownloadError(error: NSError) {
        print("Failed with error: \(error)")
    }
    
    func onFileDownloadProgress(totalBytesRead: Float, totalBytesExpectedToRead: Float) {
        print("Total bytes read on main queue: \(totalBytesRead)/\(totalBytesExpectedToRead)")
        let progress = totalBytesRead / totalBytesExpectedToRead
        self.progressView.setProgress(progress, animated: true)
    }
    
    func animateActivityIndicator() {
        progressView.setProgress(0, animated: false)
        progressView.hidden = false
        cancelDownload.hidden = false
        downloadButton.hidden = true
        deleteButton.hidden = true
    }
    
    func stopActivityIndicator() {
        progressView.setProgress(0, animated: false)
        progressView.hidden = true
        downloadButton.hidden = true
        cancelDownload.hidden = true
        deleteButton.hidden = false
    }
    
    func notifyUser(message: String) -> Void {
        // Show error message
        let alertController = UIAlertController(title: "Ooops", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func checkDownloadStatus() -> Void {
        print("Checking download status")
        if (!fetchPutioTask.isTaskRunning) {
            stopActivityIndicator()
            self.statusCheckTimer!.invalidate()
        }
    }
}
