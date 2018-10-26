//
//  DetailFrameController.swift
//  Tryon
//
//  Created by Udayakumar N on 18/01/18.
//  Copyright © 2018 Varun Raj. All rights reserved.
//

import UIKit
import ImageSlideshow


class DetailFrameController: BaseViewController {
    
    var frame: InventoryFrame?
    @IBOutlet weak var backButton: UIButton!
    
    @IBAction func backButtonDidTap(_ sender: UIButton) {
         NotificationCenter.default.post(name: NSNotification.Name(rawValue: "tabClose"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }

    override func viewDidLoad() {
        backButton.addCornerRadius(15.0, inCorners: [.topRight, .bottomRight])
        backButton.clipsToBounds = true
        backButton.masksToBounds = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
         NotificationCenter.default.post(name: NSNotification.Name(rawValue: "tabClose"), object: nil)
        
        if let infoFrameController = segue.destination as? InfoFrameController {
            infoFrameController.frame = self.frame
            infoFrameController.infoFrameDelegate = self
        }
    }
}

extension DetailFrameController: InfoFrameDelegate {
    func frameDidChange(newFrame: InventoryFrame) {
        //Do nothing as of now
    }
    
    func frame(_ frame: InventoryFrame, isAddedToTray: Bool) {
        //Do nothing as of now
    }
    
    func frame(_ frame: InventoryFrame, isAddedTofTray: Bool) {
        //Do nothing as of now
    }
}
