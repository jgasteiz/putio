//
//  WebViewVC.swift
//  putio
//
//  Created by Javi Manzano on 31/10/2015.
//  Copyright © 2015 Javi Manzano. All rights reserved.
//

import UIKit

class WebViewVC: UIViewController {
    
    var file: File? = nil
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let file = file {
            self.navigationItem.title = file.getName()
            
            let url : NSURL! = file.getDownloadURL()
            webView.loadRequest(NSURLRequest(URL: url))
        }
    }
}
