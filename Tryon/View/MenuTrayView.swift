//
//  MenuTrayView.swift
//  Tryon
//
//  Created by Udayakumar N on 01/03/18.
//  Copyright © 2018 Varun Raj. All rights reserved.
//

import UIKit
import Kingfisher

enum MenuTrayList: String {
    case category = "CATEGORY"
    case shape = "SHAPE"
    case frameType = "TYPE"
    case frame = "FRAMES"
    case color = "COLOR"
    
    static let allValues = [category, shape, frameType, frame, color]
}

protocol MenuTrayViewDelegate: NSObjectProtocol {
    func menuTrayView(_ menuTrayView: MenuTrayView, didOpenTray: Bool)
    func menuTrayView(_ menuTrayView: MenuTrayView, didCloseTray: Bool)
    func menuTrayView(_ menuTrayView: MenuTrayView, didSelect id: Int?)
}


class MenuTrayView: UIView {
    
    // MARK: - Class variables
    var items: [[String: String?]] = [[:]]
    var selectedId: Int?
    weak var menuTrayViewDelegate: MenuTrayViewDelegate?
    
    var menuTrayType: MenuTrayList = .shape {
        didSet {
            mainButtonLabel.text = menuTrayType.rawValue
            headerLabel.text = menuTrayType.rawValue
        }
    }

    var totalItemsMaxWidth: CGFloat = 370.0//570.0
    var totalItemsMinWidth: CGFloat = 50.0//150.0
    private var isOpen = true
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var visibleView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var footerArrowView: UIView!
    
    @IBOutlet weak var mainButtonView: UIView!
    @IBOutlet weak var mainButton: UIButton!
    @IBOutlet weak var mainButtonImageView: UIImageView!
    @IBOutlet weak var mainButtonLabel: UILabel!
    @IBOutlet weak var mainButtonImageViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var headerWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var footerWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var visibleViewWidthConstraint: NSLayoutConstraint!
    
    @IBAction func mainButtonDidTap(_ sender: UIButton) {
        if isOpen == false {
            openTray()
        } else {
            closeTray()
        }
    }
    @IBAction func headerButtonDidTap(_ sender: UIButton) {
        closeTray()
    }
    @IBAction func footerButtonDidTap(_ sender: UIButton) {
        closeTray()
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
    
    deinit {
        mainButtonImageView.removeObserver(self, forKeyPath: "image")
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("MenuTrayView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.layer.shadowColor = UIColor.darkGray.cgColor
        contentView.layer.shadowOffset = CGSize(width: 4, height: 4)
        contentView.layer.shadowOpacity = 1.0
        contentView.layer.shadowRadius = 6.0
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.backgroundColor = UIColor.primaryLightColor
        headerLabel.textColor = UIColor.primaryDarkColor
        collectionView.register(MenuTrayCell.self, forCellWithReuseIdentifier: "menuTrayCell")
        collectionView.register(MenuTrayColorCell.self, forCellWithReuseIdentifier: "menuTrayColorCell")
        collectionView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.old, context: nil)
        footerArrowView.addCornerRadius(5.0, inCorners: [.topLeft, .bottomLeft])
        footerArrowView.backgroundColor = UIColor.primaryLightColor
        
        mainButtonImageView.addObserver(self, forKeyPath: "image", options: .new, context: nil)
        
        mainButtonView.addCornerRadius(10.0, inCorners: [.topLeft, .bottomLeft])
        mainButtonLabel.textColor = UIColor.primaryDarkColor
    }
    
    
    // MARK: - Tray functions
    func openTray(withDuration duration: TimeInterval = 0.5) {
        if isOpen == false {
            isOpen = true
            
            //Update depth, so that trays are displayed properly when they overlap
            self.layer.zPosition = 1

            //Call delegate
            self.menuTrayViewDelegate?.menuTrayView(self, didOpenTray: true)
            
            //Update collectionview size based on content size
            let contentSize = self.collectionView.collectionViewLayout.collectionViewContentSize
            if items.count == 0 {
                self.emptyLabel.isHidden = false
                self.collectionViewWidthConstraint.constant = totalItemsMinWidth
            } else if contentSize.width > self.totalItemsMaxWidth {
                self.emptyLabel.isHidden = true
                self.collectionViewWidthConstraint.constant = self.totalItemsMaxWidth
            } else {
                self.emptyLabel.isHidden = true
                self.collectionViewWidthConstraint.constant = contentSize.width
            }
            
            self.visibleViewWidthConstraint.constant = self.collectionViewWidthConstraint.constant + self.headerWidthConstraint.constant + self.footerWidthConstraint.constant
            
            //Update the frame
            let screenSize = UIScreen.main.bounds
            self.frame = CGRect(x: screenSize.width - self.visibleViewWidthConstraint.constant, y: self.frame.origin.y, width: self.visibleViewWidthConstraint.constant, height: self.frame.height)
            self.mainButtonView.frame.origin.x = self.contentView.width - self.mainButtonView.width
            self.layoutIfNeeded()
            
            //Initialize the visible view
            self.visibleView.frame.origin.x = self.contentView.width
            
            //Add corner radius again (it is required for every open(), as the width changes with every open)
            self.visibleView.addCornerRadius(10.0, inCorners: [.bottomLeft, .topLeft])
            
            //Move Main button
            UIView.animate(withDuration: duration, delay: duration / 2.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.6, options: .curveEaseInOut, animations: {
                self.mainButtonView.frame.origin.x = self.contentView.width
            }, completion: nil)
            
            //Move Visible view
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.6, options: .curveEaseInOut, animations: {
                self.visibleView.frame.origin.x = self.contentView.width - self.visibleViewWidthConstraint.constant
            }, completion: nil)
            
            self.layoutIfNeeded()
        } else {
            //Tray is already opened
            return
        }
    }
    
    func closeTray(withDuration duration: TimeInterval = 0.5) {
        if isOpen == true {
            isOpen = false
            
            //Update depth, so that trays are displayed properly when they overlap
            self.layer.zPosition = 0.5
            
            //Call delegate
            self.menuTrayViewDelegate?.menuTrayView(self, didCloseTray: true)
            
            //Move Main button
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.6, options: .curveEaseInOut, animations: {
                self.mainButtonView.frame.origin.x = self.contentView.width - self.mainButtonView.width
            }, completion: nil)
            
            //Move Visible view
            UIView.animate(withDuration: duration - duration / 4.0, delay: duration / 4.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.6, options: .curveEaseInOut, animations: {
                self.visibleView.frame.origin.x = self.contentView.width
            }, completion: { (result) in
                //Update Frame, once all the animations are completed
                self.frame.origin = CGPoint(x: self.frame.origin.x + self.mainButtonView.frame.origin.x, y: self.frame.origin.y)
                self.mainButtonView.frame.origin = CGPoint(x: 0, y: self.mainButtonView.frame.origin.y)
                self.layoutIfNeeded()
                
                //Update depth, so that trays are displayed properly when they overlap
                self.layer.zPosition = 0
            })
            
            self.layoutIfNeeded()
        } else {
            //Tray is already closed
            return
        }
    }
}


// MARK: - Collection view functions
extension MenuTrayView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch menuTrayType {
        case .category, .shape, .frameType:
            return CGSize(width: 80.0, height: 60.0)
        case .frame:
            return CGSize(width: 150.0, height: 130.0)
        case .color:
            return CGSize(width: 40.0, height: 40.0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        switch menuTrayType {
        case .category, .shape, .frameType:
            return 20.0
        case .frame:
            return 20.0
        case .color:
            return 40.0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch menuTrayType {
        case .category, .shape, .frameType:
            return UIEdgeInsetsMake(0, 20, 0, 10)
        case .frame:
            return UIEdgeInsetsMake(0, 20, 0, 10)
        case .color:
            return UIEdgeInsetsMake(0, 40, 0, 30)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch menuTrayType {
        case .category, .shape, .frameType, .frame:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "menuTrayCell", for: indexPath) as? MenuTrayCell
            let item = items[indexPath.row]
            
            if let name = item["name"] {
                cell?.titleLabel.text = name?.uppercased()
            }
            
            if let url = item["iconUrl"] {
                cell?.cellImageView.kf.setImage(with: URL(string: url!)!)
            }
            
            if let id = item["id"] {
                if let selectedId = self.selectedId {
                    if id == String(selectedId) {
                        cell?.selectedView.isHidden = false
                    } else {
                        cell?.selectedView.isHidden = true
                    }
                } else {
                    cell?.selectedView.isHidden = true
                }
            }

            cell?.tag = indexPath.row
            cell?.menuTrayCellDelegate = self
            
            return cell!
        case .color:
            let colorCell = collectionView.dequeueReusableCell(withReuseIdentifier: "menuTrayColorCell", for: indexPath) as? MenuTrayColorCell
            let item = items[indexPath.row]
            
            if let r = item["colorR"], let g = item["colorG"], let b = item["colorB"] {
                if let colorR = NumberFormatter().number(from: r!), let colorG = NumberFormatter().number(from: g!), let colorB = NumberFormatter().number(from: b!) {
                    colorCell?.backgroundColor = UIColor(red: CGFloat(colorR)/255.0, green: CGFloat(colorG)/255.0, blue: CGFloat(colorB)/255.0, alpha: 1.0)
                }
            }
            
            if let id = item["id"] {
                if let selectedId = self.selectedId {
                    if id == String(selectedId) {
                        colorCell?.selectedImageView.isHidden = false
                    } else {
                        colorCell?.selectedImageView.isHidden = true
                    }
                } else {
                    colorCell?.selectedImageView.isHidden = true
                }
            }
            
            colorCell?.tag = indexPath.row
            colorCell?.menuTrayColorCellDelegate = self
            
            return colorCell!
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let observedObject = object as? UICollectionView, observedObject == collectionView {
            if self.collectionView.contentSize.width > self.totalItemsMaxWidth {
                self.collectionViewWidthConstraint.constant = self.totalItemsMaxWidth
            } else {
                self.collectionViewWidthConstraint.constant = self.collectionView.contentSize.width
            }
            if items.count == 0 {
                self.collectionViewWidthConstraint.constant = totalItemsMinWidth
            }
            
            self.visibleViewWidthConstraint.constant = self.collectionViewWidthConstraint.constant + self.headerWidthConstraint.constant + self.footerWidthConstraint.constant
            let screenSize = UIScreen.main.bounds
            self.frame = CGRect(x: screenSize.width - self.visibleViewWidthConstraint.constant, y: self.frame.origin.y, width: self.visibleViewWidthConstraint.constant, height: self.frame.height)
            self.layoutIfNeeded()

            self.visibleView.addCornerRadius(10.0, inCorners: [.bottomLeft, .topLeft])

            closeTray(withDuration: 0.0)
            collectionView.removeObserver(self, forKeyPath: "contentSize")
        } else if let observedObject = object as? UIImageView, observedObject == mainButtonImageView {
            if let _ = change?[.newKey] as? UIImage {
                //Image is set, so do nothing
                self.mainButtonImageViewHeightConstraint.constant = 25
            } else {
                //Image is set to nil, so change the height
                self.mainButtonImageViewHeightConstraint.constant = 10
            }
        }
    }
}

// MARK: - Data delegate functions
extension MenuTrayView: MenuTrayCellDelegate {
    func menuTrayCell(_ menuTrayCell: MenuTrayCell, cellDidTap: Bool) {
        var isAlreadySelected = false
        let item = items[menuTrayCell.tag]
        
        if let id = item["id"] {
            if let selectedId = self.selectedId {
                if id == String(selectedId) {
                    isAlreadySelected = true
                }
            }
            
            if isAlreadySelected {
                //Deselect it
                self.selectedId = nil
            } else {
                //Select it
                self.selectedId = Int(id!)
            }
            self.collectionView.reloadData()
            
            self.menuTrayViewDelegate?.menuTrayView(self, didSelect: self.selectedId)
        }
    }
}

extension MenuTrayView: MenuTrayColorCellDelegate {
    func menuTrayColorCell(_ menuTrayColorCell: MenuTrayColorCell, cellDidTap: Bool) {
        let item = items[menuTrayColorCell.tag]
        
        if let id = item["id"] {
            self.selectedId = Int(id!)
            
            self.collectionView.reloadData()
            
            self.menuTrayViewDelegate?.menuTrayView(self, didSelect: self.selectedId)
        }
    }
}
