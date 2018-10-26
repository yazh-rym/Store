//
//  TrayCell.swift
//  Tryon
//
//  Created by Udayakumar N on 24/01/18.
//  Copyright © 2018 Varun Raj. All rights reserved.
//

import UIKit


protocol TrayDelegate: NSObjectProtocol {
    func removeDidTap(trayCell: TrayCell)
}

class TrayCell: UITableViewCell {
    
    weak var trayDelegate: TrayDelegate?
    
    @IBOutlet weak var serialNumberLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var priceMultiByQuantityLabel: UILabel!
    
    @IBAction func removeButtonDidTap(_ sender: UIButton) {
        self.trayDelegate?.removeDidTap(trayCell: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        quantityTextField.layer.cornerRadius = 5.0
        quantityTextField.borderWidth = 1.0
        quantityTextField.borderColor = UIColor.mainBackgroundColor
    }
}
