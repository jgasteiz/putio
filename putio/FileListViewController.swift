//
//  ViewController.swift
//  putio
//
//  Created by Javi Manzano on 31/10/2015.
//  Copyright © 2015 Javi Manzano. All rights reserved.
//

import UIKit

class FileListViewController: UITableViewController {
    
    // Ids
    let fileCellId = "FileCell"
    let viewControllerId = "FileListViewController"
    let fileDetailViewControllerId = "FileDetailViewController"
    
    // Fetch task
    var fetchPutioTask: FetchPutioTask = FetchPutioTask.sharedInstance
    
    // Access token for api access
    var accessToken: String?
    
    // This won't be null if we're not in the root.
    var parent: File?
    
    // List of files and directories
    var fileList: [File] = []
    
    // Define a spinner
    var activityIndicator: UIActivityIndicatorView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if parent != nil {
            self.navigationItem.title = parent!.getName()
        } else {
            self.navigationItem.title = "Put.io viewer"
        }
        
        // Plain back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        
        // Set table cells automatic height
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.estimatedRowHeight = 64
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Initialize spinner
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0,0, 16, 16))
        activityIndicator!.hidesWhenStopped = true
        activityIndicator!.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator!)
        
        // Get the access token from the preferences.
        accessToken = NSUserDefaults.standardUserDefaults().valueForKey("accessToken") as? String
        
        // Fetch the files and directories in the current directory.
        getDirectoryFiles()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getDirectoryFiles() {
        activityIndicator!.startAnimating()
        fetchPutioTask.fetchDirectoryFiles(parent, accessToken: accessToken!, onTaskDone: onFilesLoadSuccess, onTaskError: onStoriesLoadError)
    }

    func onFilesLoadSuccess(files: [File]) {
        activityIndicator!.stopAnimating()
        
        fileList = files
        
        tableView.reloadData()
    }
    
    func onStoriesLoadError() {
        activityIndicator!.stopAnimating()
        
        fileList = []
        tableView.reloadData()
        
        // Show error message
        let alertController = UIAlertController(title: "Ooops", message:
            "There was an error fetching the files. Please, try again later.", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        
        presentViewController(alertController, animated: true, completion: nil)
    }
}

extension FileListViewController {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileList.count;
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let indexPath = self.tableView.indexPathForSelectedRow as NSIndexPath! {
            
            let file = fileList[indexPath.row]

            // If it's a directory, open it.
            if file.getContentType() == "application/x-directory" {
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier(viewControllerId) as! FileListViewController
                vc.parent = file
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier(fileDetailViewControllerId) as! FileDetailViewController
                vc.file = file
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Get the table cell
        let cell = tableView.dequeueReusableCellWithIdentifier(fileCellId) as! FileCell
        
        // Retrieve the story with the cell index
        let file = fileList[indexPath.row]
        
        // Set the labels text with the story values
        cell.fileName.text = "\(file.getName())"
        
        cell.fileIconImageView.image = file.getIcon()
        
        return cell
    }
}


