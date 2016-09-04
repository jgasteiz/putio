//
//  FileDetailVC.swift
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
        
        // Check if there's a task running in the background.
        checkDownloadStatus()
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
        fetchPutioTask.downloadFile(file!)
        checkDownloadStatus()
    }
    
    @IBAction func deleteFile(sender: AnyObject) {
        // If the file hasn't been downloaded yet, don't continue.
        if !file!.isFileOffline() {
            notifyUser("This file hasn't been downloaded yet.")
            return
        }
        
        let fileManager = NSFileManager.defaultManager()
        do {
            try fileManager.removeItemAtURL(file!.getOfflineURL())
        } catch {
            print("There was an error deleting \(file!.getOfflineFileName())")
        }
        deleteButton.hidden = true
        downloadButton.hidden = false
    }
    
    @IBAction func cancelDownload(sender: AnyObject) {
        fetchPutioTask.cancelDownload(self.file!)
        self.statusCheckTimer!.invalidate()
        checkDownloadStatus()
    }
    
    func showProgressView() -> Void {
        progressView.setProgress(0, animated: false)
        progressView.hidden = false
        cancelDownload.hidden = false
        downloadButton.hidden = true
        deleteButton.hidden = true
    }
    
    func hideProgressView() -> Void {
        progressView.setProgress(0, animated: false)
        progressView.hidden = true
        cancelDownload.hidden = true
        
        // Depending on the file status, show/hide download controls.
        showDownloadControls()
    }
    
    func showDownloadControls() -> Void {
        // If the file is downloaded, remove the "Download" button.
        if file!.isFileOffline() {
            downloadButton.hidden = true
            deleteButton.hidden = false
        }
        // Otherwise remove the "Delete download" button.
        else {
            deleteButton.hidden = true
            downloadButton.hidden = false
        }
    }
    
    func notifyUser(message: String) -> Void {
        // Show error message
        let alertController = UIAlertController(title: "Ooops", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func checkDownloadStatus() -> Void {
        // Depending on the file status, show/hide download controls.
        showDownloadControls()
        
        // check status of the task every second
        self.statusCheckTimer = NSTimer.scheduledTimerWithTimeInterval(0.25, target:self, selector: Selector("updateProgressView"), userInfo: nil, repeats: true)
        self.statusCheckTimer?.fire()
    }
    
    func updateProgressView() -> Void {
        if fetchPutioTask.isTaskRunning(file!) {
            if progressView.hidden == true {
                showProgressView()
            }
            let downloadProgress = fetchPutioTask.getDownloadProgress(file!)
            print("Download status at \(downloadProgress * 100)%")
            self.progressView.setProgress(downloadProgress, animated: true)
        } else {
            hideProgressView()
            self.statusCheckTimer!.invalidate()
        }
    }
}
