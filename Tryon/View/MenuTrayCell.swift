//
//  MenuTrayCell.swift
//  Tryon
//
//  Created by Udayakumar N on 01/03/18.
//  Copyright © 2018 Varun Raj. All rights reserved.
//

import UIKit

//Added this protocol, so that cell selection events can be captured, as Cell's didSelect is not being captured
protocol MenuTrayCellDelegate: NSObjectProtocol {
    func menuTrayCell(_ menuTrayCell: MenuTrayCell, cellDidTap: Bool)
}

class MenuTrayCell: UICollectionViewCell {
    
    // MARK: - Class variables
    weak var menuTrayCellDelegate: MenuTrayCellDelegate?
    
    @IBOutlet var cellContentView: UICollectionViewCell!
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var selectedView: UIView!
    
    @IBAction func buttonDidTap(_ sender: UIButton) {
        menuTrayCellDelegate?.menuTrayCell(self, cellDidTap: true)
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
        Bundle.main.loadNibNamed("MenuTrayCell", owner: self, options: nil)
        addSubview(cellContentView)
        cellContentView.frame = self.bounds
        cellContentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        titleLabel.textColor = UIColor.primaryDarkColor
        selectedView.backgroundColor = UIColor.primaryDarkColor
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        cellImageView.image = nil
    }
}
