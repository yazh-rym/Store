//
//  SomethingWentWrongController.swift
//  Tryon
//
//  Created by Udayakumar N on 22/03/17.
//  Copyright © 2017 1000Lookz. All rights reserved.
//

import UIKit


protocol SomethingWentWrongDelegate: NSObjectProtocol {
    func tryAgainDidTap()
    func closeDidTap()
}


class SomethingWentWrongController: BaseViewController {
    
    // MARK: - Class variables
    let defaultMessageText = "Something failed. Please try again."
    var message: String?
    weak var somethingWentWrongDelegate: SomethingWentWrongDelegate?
    
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var tryAgainButtonLabel: UILabel!
    @IBOutlet weak var somethingWentWrongView: UIView!
    
    @IBAction func tryAgainDidTap(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {
            self.somethingWentWrongDelegate?.tryAgainDidTap()
        })
    }
    
    @IBAction func closeButtonDidTap(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        //self.somethingWentWrongDelegate?.closeDidTap()
    }
    
    
    // MARK: - Init functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let message = message {
            messageLabel.text = message
        } else {
            messageLabel.text = defaultMessageText
        }
        
        configureUI()
    }
    
    func configureUI() {
        somethingWentWrongView.addCornerRadius(20.0, inCorners: [.topLeft, .topRight, .bottomLeft, .bottomRight])
        somethingWentWrongView.backgroundColor = UIColor.white
        tryAgainButtonLabel.addCornerRadius(8.0, inCorners: [.topLeft, .topRight, .bottomLeft, .bottomRight])
        
        messageLabel.textColor = UIColor.primaryDarkColor
        tryAgainButtonLabel.textColor = UIColor.primaryDarkColor
        tryAgainButtonLabel.backgroundColor = UIColor.primaryLightColor
        
        shadowView.layer.shadowColor = UIColor.lightShadowColor.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 4, height: 60)
        shadowView.layer.shadowOpacity = 0.6
        shadowView.layer.shadowRadius = 6.0
        shadowView.clipsToBounds = false
        shadowView.layer.masksToBounds = false
        shadowView.layer.shouldRasterize = true
        shadowView.layer.rasterizationScale = UIScreen.main.scale
    }
}
