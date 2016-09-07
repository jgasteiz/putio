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

class FileDetailVC: UIViewController {
    
    // MARK: - Properties
    
    var file: File? = nil
    
    // Controllers
    var putioFilesController = PutioFilesController.sharedInstance
    let offlineFilesController = OfflineFilesController()
    
    var statusCheckTimer: NSTimer?
    
    let webViewSegueId = "ShowWebView"
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var fileName: UILabel!
    @IBOutlet weak var fileSize: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var cancelDownload: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    
    // MARK: - Override functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let file = file else {
            print("There's no file to load.")
            return
        }
        
        // Set the navigation title to the file name.
        navigationItem.title = file.getName()
        
        // Set the file name and size in the view labels.
        fileName.text = file.getName()
        fileSize.text = file.getSize()
  
        // Load a file image if it's a video and it has a thumbnail.
        imageView.hidden = true
        if let thumbnailURL = NSURL(string: file.getThumbnail()) {
            if let data = NSData(contentsOfURL: thumbnailURL){
                imageView.hidden = false
                imageView.contentMode = UIViewContentMode.ScaleAspectFit
                imageView.image = UIImage(data: data)
            }
        }
        
        // Set title for the play button.
        if file.isVideo() {
            playButton.setTitle("Play Video", forState: UIControlState.Normal)
        } else if file.isAudio() {
            playButton.setTitle("Play Audio", forState: UIControlState.Normal)
        } else {
            playButton.setTitle("View File", forState: UIControlState.Normal)
        }
        
        // Check if there's a task running in the background.
        checkDownloadStatus()
    }
    
    override func viewDidAppear(animated: Bool) {
        // Check if there's a task running in the background.
        checkDownloadStatus()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == webViewSegueId {
            let destination = segue.destinationViewController as! WebViewVC
            destination.file = file
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func viewFile(sender: AnyObject) {
        if file!.isVideo() || file!.isAudio() {
            let secondViewController = storyboard?.instantiateViewControllerWithIdentifier("MediaViewController") as! AVPlayerViewController
            
            if let file = file {
                secondViewController.player = AVPlayer(URL: offlineFilesController.getFilePlaybackURL(file: file))
                presentViewController(secondViewController, animated: true, completion: nil)
            }
        } else {
            performSegueWithIdentifier(webViewSegueId, sender: sender)
        }
    }
    
    @IBAction func downloadFile(sender: AnyObject) {
        startFileDownload()
    }
    
    @IBAction func deleteFile(sender: AnyObject) {
        deleteLocalFile()
    }
    
    @IBAction func cancelDownload(sender: AnyObject) {
        cancelFileDownload()
    }
    
    // MARK: - General functions
    
    /*
     Start storing an offline version of the file.
    */
    func startFileDownload () {
        // If the file is downloaded already, don't continue.
        if let file = file {
            if offlineFilesController.isFileOffline(file: file) {
                notifyUser("This file has been downloaded already.")
                
                // Check the download status again and exit.
                checkDownloadStatus()
                return
            }
            
            // Save the file for offline use.
            putioFilesController.downloadFile(
                file: file,
                downloadURL: file.getDownloadURL()
            )
            checkDownloadStatus()
        }
    }
    
    /*
     Delete the offline version of the file.
    */
    func deleteLocalFile () {
        // If the file hasn't been downloaded yet, don't continue.
        if let file = file {
            if !offlineFilesController.isFileOffline(file: file) {
                notifyUser("This file hasn't been downloaded yet.")
                
                // Check the download status again and exit.
                checkDownloadStatus()
                return
            }
            
            // Delete the file.
            offlineFilesController.deleteOfflineFile(file: file)
            deleteButton.hidden = true
            downloadButton.hidden = false
        }
    }
    
    /*
     Cancel an active file download.
     */
    func cancelFileDownload () {
        if let file = file {
            putioFilesController.cancelDownload(file)
            statusCheckTimer!.invalidate()
            checkDownloadStatus()
        }
    }
    
    /*
     Check a file download status and starts a timer to check it every 250ms.
     */
    func checkDownloadStatus() {
        updateDownloadControlsVisibility()
        
        statusCheckTimer = NSTimer.scheduledTimerWithTimeInterval(
            0.25,
            target: self,
            selector: #selector(FileDetailVC.updateProgressView),
            userInfo: nil,
            repeats: true
        )
        statusCheckTimer?.fire()
    }
    
    /*
     Show or hide the download controls for a file depending on its status.
    */
    func updateDownloadControlsVisibility() {
        // If the file is downloaded, remove the "Download" button.
        if let file = file {
            if offlineFilesController.isFileOffline(file: file) {
                downloadButton.hidden = true
                deleteButton.hidden = false
            } else {
                deleteButton.hidden = true
                downloadButton.hidden = false
            }
        }
    }
    
    /*
     Update the progress view status with the download progress.
    */
    func updateProgressView() {
        if putioFilesController.isTaskRunning(file!) {
            if progressView.hidden == true {
                showProgressView()
            }
            let downloadProgress = putioFilesController.getDownloadProgress(file!)
            print("Download status at \(downloadProgress * 100)%")
            progressView.setProgress(downloadProgress, animated: true)
        } else {
            hideProgressView()
            statusCheckTimer!.invalidate()
        }
    }
    
    /*
     Show the file download progress view.
    */
    func showProgressView() {
        progressView.setProgress(0, animated: false)
        progressView.hidden = false
        cancelDownload.hidden = false
        downloadButton.hidden = true
        deleteButton.hidden = true
    }
    
    /*
     Hide the file download progress view.
    */
    func hideProgressView() {
        progressView.setProgress(0, animated: false)
        progressView.hidden = true
        cancelDownload.hidden = true
        
        updateDownloadControlsVisibility()
    }
    
    /*
     Shows the given message in a notification.
     */
    func notifyUser(message: String) {
        let alertController = UIAlertController(title: "Ooops", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        presentViewController(alertController, animated: true, completion: nil)
    }
}
