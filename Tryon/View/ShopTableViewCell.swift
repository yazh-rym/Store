//
//  ShopTableViewCell.swift
//  Tryon
//
//  Created by Udayakumar N on 10/01/18.
//  Copyright © 2018 Varun Raj. All rights reserved.
//

import UIKit


class ShopTableViewCell: UITableViewCell {

    @IBOutlet fileprivate weak var collectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor.mainBackgroundColor
        self.contentView.backgroundColor = UIColor.mainBackgroundColor
        
        self.collectionView.backgroundColor = UIColor.mainBackgroundColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}

extension ShopTableViewCell {
    func setFilterCollectionViewDataSourceDelegate<D: UICollectionViewDataSource & UICollectionViewDelegate>(_ dataSourceDelegate: D, forRow row: Int) {
        
        collectionView.delegate = dataSourceDelegate
        collectionView.dataSource = dataSourceDelegate
        collectionView.tag = row
        collectionView.setContentOffset(collectionView.contentOffset, animated:false) // Stops collection view if it was scrolling.
        collectionView.reloadData()
    }
    
    var collectionViewOffset: CGFloat {
        set { collectionView.contentOffset.x = newValue }
        get { return collectionView.contentOffset.x }
    }
}
