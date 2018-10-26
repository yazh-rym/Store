//
//  MenuTrayColorCell.swift
//  Tryon
//
//  Created by Udayakumar N on 02/03/18.
//  Copyright © 2018 Varun Raj. All rights reserved.
//

import UIKit

//Added this protocol, so that cell selection events can be captured, as Cell's didSelect is not being captured
protocol MenuTrayColorCellDelegate: NSObjectProtocol {
    func menuTrayColorCell(_ menuTrayColorCell: MenuTrayColorCell, cellDidTap: Bool)
}

class MenuTrayColorCell: UICollectionViewCell {
    
    // MARK: - Class variables
    weak var menuTrayColorCellDelegate: MenuTrayColorCellDelegate?
    
    @IBOutlet var cellContentView: UICollectionViewCell!
    @IBOutlet weak var selectedImageView: UIImageView!
    
    @IBAction func buttonDidTap(_ sender: UIButton) {
        menuTrayColorCellDelegate?.menuTrayColorCell(self, cellDidTap: true)
    }
    
    
    // MARK: - Init functions
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("MenuTrayColorCell", owner: self, options: nil)
        addSubview(cellContentView)
        cellContentView.frame = self.bounds
        cellContentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        self.cornerRadius = 5.0
        self.borderWidth = 1.0
        self.borderColor = UIColor.lightGray
        self.cellContentView.cornerRadius = 5.0
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        selectedImageView.isHidden = true
    }
}
