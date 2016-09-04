//
//  OfflineVC.swift
//  putio
//
//  Created by Javi Manzano on 31/10/2015.
//  Copyright © 2015 Javi Manzano. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class OfflineVC: UITableViewController {
    
    // Ids
    let cellId = "LabelCell"
    let viewControllerId = "FileListViewController"
    let fileDetailViewControllerId = "FileDetailViewController"
    
    // Fetch task
    var fetchPutioTask: FetchPutioTask = FetchPutioTask.sharedInstance
    
    // List of files and directories
    var fileList: [File] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Downloaded items"
        
        // Plain back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        
        // Set table cells automatic height
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "LabelCell")
        tableView.estimatedRowHeight = 64
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Fetch the files and directories in the current directory.
        fileList = fetchPutioTask.getOfflineFiles()
        tableView.reloadData()
    }
}

extension OfflineVC {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileList.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let indexPath = self.tableView.indexPathForSelectedRow as NSIndexPath! {
            
            let file = fileList[indexPath.row]
            
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("MediaViewController") as! AVPlayerViewController
            vc.player = AVPlayer(URL: file.getPlaybackURL())
            self.presentViewController(vc, animated: true, completion: nil)
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath)
        
        // Retrieve the story with the cell index
        let file = fileList[indexPath.row]
        cell.textLabel?.text = "\(file.getName())"
        
        return cell
    }
}


