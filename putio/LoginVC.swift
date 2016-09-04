//
//  LoginVC.swift
//  putio
//
//  Created by Javi Manzano on 01/11/2015.
//  Copyright © 2015 Javi Manzano. All rights reserved.
//

import UIKit

class LoginVC: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    
    let fileListSegueId: String = "showFiles"
    let mainViewControllerId = "MainViewController"
    let offlineViewControllerId = "OfflineViewController"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        webView.delegate = self
        
        self.navigationItem.title = "Login put.io"
        
        if Reachability.isConnectedToNetwork() == true {
            let url : NSURL! = NSURL(string: "https://api.put.io/v2/oauth2/authenticate?client_id=2187&response_type=token&redirect_uri=https://putio-javiman.herokuapp.com/")
            webView.loadRequest(NSURLRequest(URL: url))
        } else {
            // Take user to downloads view
            let offlineViewController = self.storyboard?.instantiateViewControllerWithIdentifier(offlineViewControllerId) as! UINavigationController
            self.presentViewController(offlineViewController, animated: false, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if request.URL != nil {
            let url = String(request.URL!)
            if url.containsString("https://putio-javiman.herokuapp.com/#access_token=") {
                
                // Get the access token from the url.
                let accessToken = url.stringByReplacingOccurrencesOfString("https://putio-javiman.herokuapp.com/#access_token=", withString: "")
                
                // Store it in the standard preferences.
                NSUserDefaults.standardUserDefaults().setObject(accessToken, forKey: "accessToken")
                
                // Open the main navigation controller.
                let navigationController = self.storyboard?.instantiateViewControllerWithIdentifier(mainViewControllerId) as! UITabBarController
                self.presentViewController(navigationController, animated: false, completion: nil)
            }
        }
        return true
    }
    
}

