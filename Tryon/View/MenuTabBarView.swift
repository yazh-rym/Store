//
//  MenuTabBarView.swift
//  Tryon
//
//  Created by Udayakumar N on 12/03/18.
//  Copyright © 2018 Varun Raj. All rights reserved.
//

import UIKit

enum MenuTabBarList: String {
    case shop = "SHOP"
    case filter = "FILTER"
    case shoot = "SHOOT"
    case cart = "CART"
    case orders = "FAVOURITES"
    case logout = "LOGOUT"
    
    static let allValues = [shop, filter, shoot, cart, orders, logout] // cart
}

protocol MenuTabBarViewDelegate: NSObjectProtocol {
    func menuTabBarView(_ menuTabBarView: MenuTabBarView, didSelect id: Int)
}

class MenuTabBarView: UIView {

    // MARK: - Class variables
    weak var menuTabBarDelegate: MenuTabBarViewDelegate?

    let items: [MenuTabBarList] = MenuTabBarList.allValues
    let itemImageNames: [String] = [
        "ShopMenuIcon",
        "FilterMenuIcon",
        "ShootMenuIcon",
        "CartMenuIcon",
        "ic_favorite_outline_violet",
        "ProfileMenuIcon"
    ]
    fileprivate var isOpen = true
    fileprivate var selectedId = 0
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var footerArrowView: UIView!
    @IBAction func headerButtonDidTap(_ sender: UIButton) {
        handleTray()
    }
    @IBAction func footerButtonDidTap(_ sender: UIButton) {
        handleTray()
    }
    
    // MARK: - Init functions
    override init(frame: CGRect) {
        super.init(frame: frame)
     NotificationCenter.default.addObserver(self, selector: #selector(self.closeTray(withDuration:)), name: NSNotification.Name(rawValue: "tabClose"), object: nil)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("MenuTabBarView", owner: self, options: nil)
        addSubview(contentView)

        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.layer.shadowColor = UIColor.darkGray.cgColor
        contentView.layer.shadowOffset = CGSize(width: 4, height: 4)
        contentView.layer.shadowOpacity = 1.0
        contentView.layer.shadowRadius = 6.0
        
        self.contentView.backgroundColor = UIColor.clear
        headerView.backgroundColor = UIColor.primaryDarkColor
        headerView.addCornerRadius(15.0, inCorners: [.topLeft, .bottomLeft])        
        
        collectionView.backgroundColor = UIColor.primaryLightColor
        collectionView.register(MenuTabBarCell.self, forCellWithReuseIdentifier: "menuTabBarCell")
        
        footerView.backgroundColor = UIColor.primaryLightColor
        footerArrowView.backgroundColor = UIColor.primaryDarkColor
        footerArrowView.addCornerRadius(5.0, inCorners: [.topLeft, .bottomLeft])
        
        //Initially, close the tray
        self.handleTray(withDuration: 0.0)
    }
    
    
    // MARK: - Tray functions
    func handleTray(withDuration duration: TimeInterval = 0.5) {
        if isOpen == true {
            closeTray(withDuration: duration)
        } else {
            openTray(withDuration: duration)
        }
    }
    
    func openTray(withDuration duration: TimeInterval = 0.5) {
        if isOpen == false {
            isOpen = true
            
            //Open the tray
            UIView.animate(withDuration: duration / 2.0, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.6, options: .curveEaseInOut, animations: {
                let screenSize = UIScreen.main.bounds
                self.frame.origin.x = screenSize.width - self.width
            }, completion: nil)
        }
    }
    
    func closeTray(withDuration duration: TimeInterval = 0.5) {
        if isOpen == true {
            isOpen = false
            
            //Close the tray
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.6, options: .curveEaseInOut, animations: {
                let screenSize = UIScreen.main.bounds
                self.frame.origin.x = screenSize.width - self.headerView.width
            }, completion: nil)
        }
    }
}


// MARK: - Collection view functions
extension MenuTabBarView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60.0, height: 60.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 15, 0, 15)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "menuTabBarCell", for: indexPath) as? MenuTabBarCell
        let item = items[indexPath.row]
        
        cell?.titleLabel.text = item.rawValue
        cell?.cellImageView.image = UIImage(named: itemImageNames[indexPath.row])
        
        if indexPath.row == self.selectedId  {
            cell?.selectedView.isHidden = false
        } else {
            cell?.selectedView.isHidden = true
        }
        
        cell?.tag = indexPath.row
        cell?.menuTabBarCellDelegate = self
        
        return cell!
    }
    
    func selectIndex(newIndex: Int) {
        self.closeTray()
        
        self.menuTabBarDelegate?.menuTabBarView(self, didSelect: newIndex)
        self.selectedId = newIndex
        
        self.collectionView.reloadData()
    }
}


// MARK: - Data delegate functions
extension MenuTabBarView: MenuTabBarCellDelegate {
    func menuTabBarCell(_ menuTabBarCell: MenuTabBarCell, cellDidTap: Bool) {
        self.selectIndex(newIndex: menuTabBarCell.tag)
    }
}
