//
//  CustomWebController.swift
//  Tryon
//
//  Created by Udayakumar N on 18/05/17.
//  Copyright © 2017 1000Lookz. All rights reserved.
//

import UIKit
import Appsee


class CustomWebController: UIViewController {

    var urlString: String?
    var screenName: String?
    
    @IBOutlet weak var webView: UIWebView!
    @IBAction func backButtonDidTap(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {})
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: urlString!)
        let requestObj = URLRequest(url: url!)
        webView.loadRequest(requestObj)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let name = screenName {
            Appsee.startScreen(name)
        }
        
        super.viewDidAppear(animated)
    }
}
