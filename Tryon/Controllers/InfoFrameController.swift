
//
//  InfoFrameController.swift
//  Tryon
//
//  Created by Udayakumar N on 24/01/18.
//  Copyright © 2018 Varun Raj. All rights reserved.
//

import UIKit
import ImageSlideshow
import TagListView
import RealmSwift
import Kingfisher

protocol InfoFrameDelegate: NSObjectProtocol {
    func frameDidChange(newFrame: InventoryFrame)
    func frame(_ frame: InventoryFrame, isAddedToTray: Bool)
    func frame(_ frame: InventoryFrame, isAddedTofTray: Bool)
}

class InfoFrameController: BaseViewController {
    let model = TryonModel.sharedInstance
    let realm = try! Realm()
    var userLookId : [String] = []
    var userId : [String] = []
    weak var infoFrameDelegate: InfoFrameDelegate?
    
    let numberFormatter = NumberFormatter()
    var frame: InventoryFrame?
    var images: [InputSource] = []
    var childFrames: [InventoryFrame] = []
    
    @IBOutlet weak var contntView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var headerDividerView: UIView!
    @IBOutlet weak var imageSlideShowView: ImageSlideshow!
    @IBOutlet weak var imageSlideShowSlider: UISlider!
    @IBOutlet weak var control3DView: UIView!
    @IBOutlet weak var tagListView: TagListView!
    @IBOutlet weak var colorTitleLabel: UILabel!
    
    @IBOutlet weak var heightConstraint3DView: NSLayoutConstraint!
    @IBOutlet weak var heightConstraintColorView: NSLayoutConstraint!
    
    @IBOutlet weak var quantityTextField: UITextField!
    
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var addToCartButton: UIButton!
    @IBOutlet weak var addToFavButton: UIButton!
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let currentValue = sender.value * 100
        let pageRange = 100.0 / Float(images.count)
        var page = Int(currentValue / pageRange)
        
        if page >= images.count {
            page = images.count - 1
        }
        
        imageSlideShowView.setCurrentPage(page, animated: false)
    }
    
    @IBAction func addToCartButtonDidTap(_ sender: UIButton) {
        
        let isAdded = TrayHelper().addInventoryFrameToTray(self.frame!)
        
        if isAdded {
            addToCartButton.setTitle("REMOVE", for: .normal)
            addToCartButton.backgroundColor = UIColor.primaryWarningColor
            addToCartButton.setTitleColor(UIColor.white, for: .normal)
            infoFrameDelegate?.frame(self.frame!, isAddedToTray: true)
            
            if UserDefaults.standard.array(forKey: "userLookId") != nil{
                userLookId = UserDefaults.standard.array(forKey: "userLookId") as! [String]
                
                if quantityTextField.text == "1"{
                    userLookId.append((self.frame?.lookzId)!)
                }else{
                    if let lookId = frame?.lookzId {
                        let indexArray = userLookId.indices.filter({ userLookId[$0].localizedCaseInsensitiveContains(lookId) })
                        
                        if indexArray.count != 0{
                            for userIndex in indexArray{
                                if userIndex != 0{
                                    userLookId.remove(at: userIndex)
                                }else{
                                    userLookId.remove(at: userIndex)
                                }
                            }
                        }
                        userLookId.append(lookId + "|" + String(quantityTextField.text!))
                    }
                }
//                print("Add Items",userLookId)
                UserDefaults.standard.set(userLookId , forKey: "userLookId")
            }else{
                userLookId.append((self.frame?.lookzId)! + "|" + String(quantityTextField.text!))
                //  userLookId.append((self.frame?.lookzId)!)
//                print("Add Items",userLookId)
                UserDefaults.standard.set(userLookId , forKey: "userLookId")
            }
        } else {
            addToCartButton.setTitle("ADD TO CART", for: .normal)
            addToCartButton.backgroundColor = UIColor.primaryDarkColor
            addToCartButton.setTitleColor(UIColor.primaryLightColor, for: .normal)
            infoFrameDelegate?.frame(self.frame!, isAddedToTray: false)
            
            if UserDefaults.standard.array(forKey: "userLookId") != nil{
                userLookId = UserDefaults.standard.array(forKey: "userLookId") as! [String]
                if let lookId = self.frame?.lookzId {
                    let indexArray = userLookId.indices.filter({ userLookId[$0].localizedCaseInsensitiveContains(lookId) })
                    
                    if indexArray.count != 0{
                        for userIndex in indexArray{
                            if userIndex != 0{
                                userLookId.remove(at: userIndex)
                            }else{
                                userLookId.remove(at: userIndex)
                            }
                        }
                        quantityTextField.text = "1"
                    }
                }
                UserDefaults.standard.set(userLookId , forKey: "userLookId")
            }
        }
        
        let trayCount = TrayHelper().trayInventoryFramesCount()
        if let tabBarController = self.tabBarController as? MainTabBarController {
            tabBarController.updateTrayBadgeCount(withCount: trayCount)
        }
    }
    
    @IBAction func addToFavDidTap(_ sender: Any) {
        let isfav = TrayHelper().addInventoryFrameTofav(self.frame!)
        if isfav {
            if UserDefaults.standard.array(forKey: "favorites") != nil{
                userId = UserDefaults.standard.array(forKey: "favorites") as! [String]
                if let uuid = self.frame?.lookzId {
                let indexArr = userId.indices.filter({userId[$0].localizedCaseInsensitiveContains(uuid)})
                    if indexArr.count != 0{
                        for userIndex in indexArr{
                            if userIndex != 0{
                                userId.remove(at: userIndex)
                            }else{
                                userId.remove(at: userIndex)
                            }
                        }
                    }
                }
                userId.append(self.frame!.lookzId!)
                UserDefaults.standard.set(userId, forKey: "favorites")
            } else {
                userId.append(self.frame!.lookzId!)
                UserDefaults.standard.set(userId, forKey: "favorites")
            }
            addToFavButton.setImage(UIImage(named: "ic_favorite_violet"), for: UIControlState.normal)
            infoFrameDelegate?.frame(self.frame!, isAddedTofTray: true)
        } else {
            if UserDefaults.standard.array(forKey: "favorites") != nil{
                userId = UserDefaults.standard.array(forKey: "favorites") as! [String]
                if let uuid = self.frame?.lookzId {
                    let indexArr = userId.indices.filter({userId[$0].localizedCaseInsensitiveContains(uuid)})
                    if indexArr.count != 0{
                        for userIndex in indexArr{
                            if userIndex != 0{
                                userId.remove(at: userIndex)
                            }else{
                                userId.remove(at: userIndex)
                            }
                        }
                    }
                }
                UserDefaults.standard.set(userId, forKey: "favorites")
            }
            addToFavButton.setImage(UIImage(named: "ic_favorite_outline_violet"), for: UIControlState.normal)
            infoFrameDelegate?.frame(self.frame!, isAddedTofTray: false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        log.info("InfoFrameController: \(String(describing: self.frame?.uuid))")
        
        initData()
        configureUI()
        
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.maximumFractionDigits = 2
        
        tagListView.delegate = self
        quantityTextField.delegate = self
        
        imageSlideShowView.isUserInteractionEnabled = true
        
        updateTrayButton()
        updatefTrayButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTrayButton()
        updatefTrayButton()
    }
    
    func didTap() {
        imageSlideShowView.presentFullScreenController(from: self)
    }
    
    func initData() {
        let formattedString = NSMutableAttributedString()
        formattedString.normal((frame?.brand?.name)!.uppercased(), size: 24, color: UIColor.black).light("  " + (frame?.modelNumber)!.uppercased(), size: 16, color: UIColor.black)
        self.headerLabel.attributedText = formattedString
        KingfisherManager.shared.cache.pathExtension = "jpg"

        self.images.removeAll()
        if let imagePath = self.frame?.imagePath {
            if (self.frame?.is3DCreated)! {
                DispatchQueue.global(qos: .background).sync {
                    for i in 1...20 {
                        let imageName = "Full360degree_" + String(i) + ".jpg"
                        let imageUrlString = imagePath + (self.frame?.uuid)! + "/360degree/High/" + imageName
                        self.images.append(KingfisherSource(urlString: imageUrlString)!)
                    }
                    
                    //Added the first image again for a smooth display
                    let imageName = "Full360degree_" + String(1) + ".jpg"
                    let imageUrlString = imagePath + (self.frame?.uuid)! + "/360degree/High/" + imageName
                    self.images.append(KingfisherSource(urlString: imageUrlString)!)
                }
                self.control3DView.isHidden = false
            } else {
                var arr : [String] = []
                let string = String(describing: UserDefaults.standard.value(forKey: "UserName")!)
                if string == "Arcadio_f" {
                 arr = ["thumbnail_high.jpg", "PD_Center.jpg", "PD_Back.jpg", "PD_Right.jpg", "PD_Right45.jpg", "PD_Left.jpg", "PD_Left45.jpg"]
                } else if string == "augustinogold" {
                    arr = ["PD_Center.jpg", "PD_Left.jpg", "PD_Right.jpg", "thumbnail.jpg"]
                } else if string == "chhajer" {
                    arr = ["PD_Center.jpg", "PD_Left.jpg", "PD_Right.jpg", "thumbnail.jpg"]
                } else {
                    arr = ["PD_Center.jpg", "PD_Right.jpg", "thumbnail.jpg"]
                }
                
                DispatchQueue.global(qos: .background).sync {
                    for name in arr  {
                        //  let imageName = arr[i]
                        let imageUrlString = imagePath + (self.frame?.uuid)! + "/" + name
                        self.images.append(KingfisherSource(urlString: imageUrlString)!)
                    }
                }
                self.control3DView.isHidden = true
            }
            imageSlideShowView.setImageInputs(images)
            imageSlideShowView.setCurrentPage(0, animated: false)
            imageSlideShowView.zoomEnabled = true
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
            gestureRecognizer.numberOfTouchesRequired = 1
            imageSlideShowView.addGestureRecognizer(gestureRecognizer)
        }
        
        self.childFrames.removeAll()
        if (self.frame?.childFrames.count)! > 0 {
            //It is a parent frame
            self.childFrames.append(self.frame!)
            for child in (self.frame?.childFrames)! {
                self.childFrames.append(child)
            }
        } else if let parent = self.frame?.parentFrame.first {
            //It is a child frame, so make use of the parent
            if parent.childFrames.count > 0 {
                self.childFrames.append(parent)
                for child in parent.childFrames {
                    self.childFrames.append(child)
                }
            }
        }
        var i = 0
        tagListView.removeAllTags()
        tagListView.layer.cornerRadius = tagListView.frame.height/2
        
       /* for child in childFrames {
            let Val = child.modelNumber?.components(separatedBy: " ")
            if Val?.count == 2 {
                tagListView.addTag(Val![1])
            }
            
            tagListView.tagViews[i].tag = i
            
            if child.id == self.frame?.id {
                let image = UIImage(named: "square-icon.png")?.withRenderingMode(.alwaysTemplate)//TickIcon
                tagListView.tagViews[i].setBackgroundImage(image?.tint(with: UIColor.primaryLightColor), for: .normal)
                if Val?.count == 2 {
                    tagListView.tagViews[i].setTitle(Val![1], for: UIControlState(rawValue: UIControlState.RawValue(i)))
                }
            } else {
                tagListView.tagViews[i].setImage(nil, for: .normal)
            }*/
 ///////////Base
        for child in childFrames {
            tagListView.addTag("  ")
            
            if let r = child.identifiedColor?.colorR.value, let g = child.identifiedColor?.colorG.value, let b = child.identifiedColor?.colorB.value {
                
                let color = UIColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: 1.0)
                
                
                tagListView.tagViews[i].backgroundColor = color
            } else {
                tagListView.tagViews[i].backgroundColor = UIColor.clear
            }
            tagListView.tagViews[i].tag = i
            
            if child.id == self.frame?.id {
                tagListView.tagViews[i].setBackgroundImage(UIImage(named: "TickIcon"), for: .normal)
            } else {
                tagListView.tagViews[i].setBackgroundImage(nil, for: .normal)
            }

            i = i + 1
        }
        
        var displayText1 = (frame?.frameColor?.name)! + "  |  " + (frame?.shape?.name)!
        if let size = frame?.sizeText {
            displayText1 = displayText1 + "  |  " + size
        }
        let displayText2 = (frame?.category?.name)!.lowercased().capitalizingFirstLetter()
        
        self.detailLabel.text = displayText1.uppercased() + "\n" + displayText2.uppercased()
        
        self.priceLabel.textColor = UIColor.primaryDarkColor
        if let price = self.frame?.price.value {
            if let priceUnit = self.frame?.priceUnit {
                self.priceLabel.text = priceUnit + " " + numberFormatter.string(from: NSNumber(value: price))!
            } else {
                self.priceLabel.text = numberFormatter.string(from: NSNumber(value: price))
            }
        }        

        //Set Quantity
        if UserDefaults.standard.array(forKey: "userLookId") != nil  {
            userLookId = UserDefaults.standard.array(forKey: "userLookId") as! [String]
            if let lookId = frame?.lookzId {
                let indexArray = userLookId.indices.filter({ userLookId[$0].localizedCaseInsensitiveContains(lookId) })
                
                if indexArray.count != 0{
                    let quan = userLookId[indexArray[0]] as String
                    print(quan)
                    let str = quan.strstr(needle: "|")
                    
                    if str == nil{
                        quantityTextField.text = "1"
                    }else{
                        print(str!)
                        quantityTextField.text = str!
                    }
                }else{
                    quantityTextField.text = "1"
                }
            }
        }else{
            quantityTextField.text = "1"
        }
    }
    
    func configureUI() {
        headerDividerView.backgroundColor = UIColor.primaryLightColor
        
        imageSlideShowView.contentScaleMode = .scaleAspectFill
        imageSlideShowView.activityIndicator = DefaultActivityIndicator(style: .white, color: UIColor.primaryDarkColor)
        
        ////////////Base
        tagListView.backgroundColor = UIColor.clear
        tagListView.textFont = UIFont.systemFont(ofSize: 24, weight: UIFontWeightMedium)
        tagListView.alignment = .center
        tagListView.marginX = 5.0
        tagListView.marginY = 5.0
        
//        tagListView.backgroundColor = UIColor.clear
//        tagListView.textFont = UIFont.systemFont(ofSize: 12, weight: UIFontWeightMedium)
//        tagListView.textColor = UIColor.primaryDarkColor
//        tagListView.alignment = .center
//        tagListView.marginX = 5.0
//        tagListView.marginY = 5.0
//        tagListView.paddingX = 10.0
//        tagListView.paddingY = 10.0
        
        if (self.frame?.is3DCreated)! {
            imageSlideShowView.pageControlPosition = .hidden
            imageSlideShowView.slideshowInterval = 0
            imageSlideShowView.draggingEnabled = false
            
            heightConstraint3DView.constant = 75
            self.view.layoutIfNeeded()
        } else {
            imageSlideShowView.pageControlPosition = .underScrollView
            imageSlideShowView.pageControl.pageIndicatorTintColor = UIColor.primaryDarkColor
            imageSlideShowView.pageControl.currentPageIndicatorTintColor = UIColor.primaryLightColor
            imageSlideShowView.slideshowInterval = 3.0 //secs
            imageSlideShowView.draggingEnabled = true
            
            heightConstraint3DView.constant = 25
            self.view.layoutIfNeeded()
        }
        imageSlideShowSlider.value = 0.0
        
        if self.childFrames.count > 0 {
            heightConstraintColorView.constant = tagListView.intrinsicContentSize.height + 10
            self.view.layoutIfNeeded()
            
            self.tagListView.isHidden = false
            self.colorTitleLabel.isHidden = false
        } else {
            heightConstraintColorView.constant = 10
            self.view.layoutIfNeeded()
            
            self.tagListView.isHidden = true
            self.colorTitleLabel.isHidden = true
        }
    }
    
    func updateTrayButton() {
        let isAlreadyAvailable = TrayHelper().isAlreadyAvailbleInTray(self.frame!)
        if isAlreadyAvailable {
            addToCartButton.setTitle("REMOVE", for: .normal)
            addToCartButton.backgroundColor = UIColor.primaryWarningColor
            addToCartButton.setTitleColor(UIColor.white, for: .normal)
            infoFrameDelegate?.frame(self.frame!, isAddedToTray: true)
        } else {
            addToCartButton.setTitle("ADD TO CART", for: .normal)
            addToCartButton.backgroundColor = UIColor.primaryDarkColor
            addToCartButton.setTitleColor(UIColor.primaryLightColor, for: .normal)
            infoFrameDelegate?.frame(self.frame!, isAddedToTray: false)
        }
    }
    
    func updatefTrayButton() {
        let isfAlreadyAvailable = TrayHelper().isAlreadyAvailbleInfav(self.frame!)
        if isfAlreadyAvailable {
            addToFavButton.setImage(UIImage(named: "ic_favorite_violet"), for: UIControlState.normal)
            infoFrameDelegate?.frame(self.frame!, isAddedTofTray: true)
        } else {
            addToFavButton.setImage(UIImage(named: "ic_favorite_outline_violet"), for: UIControlState.normal)
            infoFrameDelegate?.frame(self.frame!, isAddedTofTray: false)
        }
    }
}

extension InfoFrameController: TagListViewDelegate {
    
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        self.frame = self.childFrames[tagView.tag]
        infoFrameDelegate?.frameDidChange(newFrame: self.frame!)
        
        initData()
        configureUI()
        
        updateTrayButton()
        updatefTrayButton()
    }
}

extension InfoFrameController: DetailModelDelegate {
    func frameDidChange(newFrame: InventoryFrame) {
        self.frame = newFrame
        
        initData()
        configureUI()
        
        updateTrayButton()
        updatefTrayButton()
    }
    
    func frameInventoryUpdated(frame: InventoryFrame) {
        self.updateTrayButton()
        self.updatefTrayButton()
    }
}

extension InfoFrameController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        
        return string == numberFiltered
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        var quantity: Int?
        if textField.text != "" {
            quantity = Int(textField.text!)!
        } else {
            quantity = 1
            textField.text = String(1)
        }
        try! realm.write {
            self.frame?.orderQuantityCount = quantity!
        }
        
        return true
    }
}
