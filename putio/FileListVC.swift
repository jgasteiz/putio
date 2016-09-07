//
//  FileListVC.swift
//  putio
//
//  Created by Javi Manzano on 31/10/2015.
//  Copyright © 2015 Javi Manzano. All rights reserved.
//

import UIKit

class FileListVC: UITableViewController {
    
    // MARK: - Properties
    
    // Ids
    let fileCellId = "FileCell"
    let viewControllerId = "FileListViewController"
    let fileDetailViewControllerId = "FileDetailViewController"
    
    // Fetch task
    var putioFilesController = PutioFilesController.sharedInstance
    
    // This won't be null if we're not in the root.
    var parent: File?
    
    // List of files and directories
    var fileList: [File] = []
    
    // Define a spinner
    var activityIndicator: UIActivityIndicatorView?

    // MARK: - Override functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if parent != nil {
            navigationItem.title = parent!.getName()
        } else {
            navigationItem.title = "Put.io viewer"
        }
        
        // Plain back button
        navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        
        // Set table cells automatic height
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.estimatedRowHeight = 64
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Initialize spinner
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0,0, 16, 16))
        activityIndicator!.hidesWhenStopped = true
        activityIndicator!.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        navigationItem.rightBarButtonItems?.append(UIBarButtonItem(customView: activityIndicator!))
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        fetchDirectoryFiles()
    }
    
    // MARK: - IBActions
    @IBAction func addItem(sender: AnyObject) {
        let alertController = UIAlertController(
            title: "New link",
            message: "Paster the download link here", preferredStyle: UIAlertControllerStyle.Alert)
        
        var newLinkTextField = UITextField()
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Magnet link"
            newLinkTextField = textField
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) in
            if let downloadURL = newLinkTextField.text {
                self.putioFilesController.addTransfer(downloadURL, onTransferAdded: {
                    print("Success!")
                })
            }
        }))
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Functions
    func fetchDirectoryFiles () {
        // Fetch the files and directories in the current directory.
        activityIndicator!.startAnimating()
        putioFilesController.fetchDirectoryFiles(parent, onTaskDone: onFilesLoadSuccess, onTaskError: onStoriesLoadError)
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

// MARK: - Extensions

extension FileListVC {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileList.count;
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let indexPath = tableView.indexPathForSelectedRow as NSIndexPath! {
            
            let file = fileList[indexPath.row]

            // If it's a directory, open it.
            if file.getContentType() == "application/x-directory" {
                let vc = storyboard?.instantiateViewControllerWithIdentifier(viewControllerId) as! FileListVC
                vc.parent = file
                navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = storyboard?.instantiateViewControllerWithIdentifier(fileDetailViewControllerId) as! FileDetailVC
                vc.file = file
                navigationController?.pushViewController(vc, animated: true)
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
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let file = fileList[indexPath.row]
            
            // Delete the remote file.
            putioFilesController.deleteRemoteFile(file, onFileDeleted: {
                
                // Update the file list and tableview.
                self.fileList.removeAtIndex(indexPath.row)
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            })
        }
    }
}


