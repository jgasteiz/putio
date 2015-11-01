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
    
    @IBOutlet weak var fileName: UILabel!
    @IBOutlet weak var fileSize: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationItem.title = self.file!.getName()
        
        fileName.text = self.file!.getName()
        fileSize.text = self.file!.getSize()
        
        if let thumbnailURL = NSURL(string: self.file!.getThumbnail()) {
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
    
}
