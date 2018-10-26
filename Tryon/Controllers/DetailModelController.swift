//
//  DetailModelController.swift
//  Tryon
//
//  Created by Udayakumar N on 09/01/18.
//  Copyright © 2018 Adhyas. All rights reserved.
//

import UIKit
import RealmSwift
import Kingfisher
import Alamofire

protocol DetailModelDelegate: NSObjectProtocol {
    func frameDidChange(newFrame: InventoryFrame)
    func frameInventoryUpdated(frame: InventoryFrame)
    
}

protocol VideoDelegates: NSObjectProtocol {
    
    func videoFrameChange(frame: InventoryFrame , ids: NSArray , valuesDicts : [NSDictionary])
    
}

class DetailModelController: BaseViewController {
    let model = TryonModel.sharedInstance
    let tryon3D = Tryon3D.sharedInstance
    let realm = try! Realm()
    
    var user: User? {
        didSet {
            self.isUserImagesAddedFor3D = false
        }
    }
    var frame: InventoryFrame?
    
    var videoImages: [UIImage] = []
    
    var usgImage : UIImage!
    
    var idValues: [String] = []
    
    var valuesDicts: [NSDictionary] = []
    
    var images: [NSDictionary] = []
    
    
    let Indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)

    weak var detailModelDelegate: DetailModelDelegate?
    
    weak var videoModelDelegate: VideoDelegates?
    
    
    var productDetailsTitle: [String] = []
    var productDetailsValue: [String] = []
    var is3DAlreadyRendered = false
    var numberOfFrames = 0
    var currentDisplayFrame = 0
    
    var isUserImagesAddedFor3D = false
    var is3DUserImageDidScroll = false
    
    var selectedCategory: CategoryProductType?
    var selectedShape: CategoryShape?
    var selectedFrameType: CategoryFrameType?
    var selectedFrame: InventoryFrame?
    var isFavourite: Bool?
    @IBOutlet weak var categoryMenuTrayView: MenuTrayView!
    @IBOutlet weak var shapeMenuTrayView: MenuTrayView!
    @IBOutlet weak var frameTypeMenuTrayView: MenuTrayView!
    @IBOutlet weak var frameMenuTrayView: MenuTrayView!
    @IBOutlet weak var colorMenuTrayView: MenuTrayView!
    
    @IBOutlet weak var bgScrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var imageScrollHandlerView: UIView!
    @IBOutlet weak var placeHolderImageView: UIImageView!
    @IBOutlet weak var imageScrollView: UIScrollView!
    
    @IBOutlet weak var cartImage: UIImageView!
    @IBOutlet weak var leftRotationImageView: UIImageView!
    @IBOutlet weak var rightRotationImageView: UIImageView!
    
    @IBOutlet weak var addToTrayButtonView: UIView!
    @IBOutlet weak var addToTrayButton: UIButton!
    @IBOutlet weak var infoButtonView: UIView!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tapGestureScrollUpDown: UIView!
    
    @IBOutlet weak var favImage: UIImageView!

    @IBOutlet weak var addToFavButtonView: UIView!
    @IBOutlet weak var addToFavButton: UIButton!
    
    var urlImage: [String] = []
    var userImages: [UIImage] = []
    var yprValues: [String] = []
    var userImagesCount : Int = 0
    var tempImage: [UIImage] = []
    var imageUser: UIImage!
    var imagesUserDict : NSDictionary!
    
    var valuesDict : [NSDictionary] = []
    var classDict : [NSDictionary] = []
    
    var imageArray: [UIImage] = []
    var finalImageArray: [UIImage] = []
    
    @IBAction func backButtonDidTap(_ sender: UIButton) {
        var shouldPopNormal = false
        removeImages()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "tabClose"), object: nil)
        let count = self.navigationController?.viewControllers.count ?? 0
        if count >= 3 {
            if let _ = self.navigationController?.viewControllers[count - 2] as? ModelChooseController {
                self.navigationController?.popToViewController((self.navigationController?.viewControllers[count - 3])!, animated: true)
            } else if let _ = self.navigationController?.viewControllers[count - 2] as? SnapValidateController {
                self.navigationController?.popToViewController((self.navigationController?.viewControllers[count - 3])!, animated: true)
            } else {
                shouldPopNormal = true
            }
        } else {
            shouldPopNormal = true
        }
        
        if shouldPopNormal {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func addToFavDidTap(_ sender: UIButton) {
        let isAdded = TrayHelper().addInventoryFrameTofav(self.frame!)
        updateUIForFrameTofTray(isAdded: isAdded)
        
        self.detailModelDelegate?.frameInventoryUpdated(frame: self.frame!)
    }
    
    @IBAction func addToCartButtonDidTap(_ sender: UIButton) {
        let isAdded = TrayHelper().addInventoryFrameToTray(self.frame!)
        updateUIForFrameToTray(isAdded: isAdded)
        
        let trayCount = TrayHelper().trayInventoryFramesCount()
        if let tabBarController = self.tabBarController as? MainTabBarController {
            tabBarController.updateTrayBadgeCount(withCount: trayCount)
            
            self.detailModelDelegate?.frameInventoryUpdated(frame: self.frame!)
        }
    }
    
    @IBAction func scrolToBottomButtonDidTap(_ sender: UIButton) {
        closeAllMenuTray()
        
        if bgScrollView.contentOffset.y > 200 {
            //Added -20 for Status bar
            bgScrollView.setContentOffset(CGPoint(x: 0, y: -20), animated: true)
            infoButton.setImage(UIImage(named: "DownIcon"), for: UIControlState.normal)
        } else {
            bgScrollView.setContentOffset(CGPoint(x: 0, y: bgScrollView.height - 180), animated: true)
            infoButton.setImage(UIImage(named: "UpIcon"), for: UIControlState.normal)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UserDefaults.standard.set(false, forKey: "info")
        isFavourite = UserDefaults.standard.bool(forKey: "isFav")

    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        Indicator.center = CGPoint(x: self.view.bounds.size.width/2, y: self.view.bounds.size.height/2)
        Indicator.color = UIColor.primaryDarkColor
        self.view.addSubview(Indicator)
        
        let screenSize = UIScreen.main.bounds
        let x = screenSize.width / 2
        let y = screenSize.height / 4
        self.setupActivityIndicator(atCenterPoint: CGPoint(x: x, y: y))
        
        if userImages.count != userImagesCount {
            
            //  updateVideo()
            
            setupButtons()
            
            self.activityIndicator?.startAnimating()
            
            var value = 0
            
            lastApi(lookzId: (self.frame?.lookzId)!, ids: self.idValues as NSArray)
            
            //self.Indicator.startAnimating()
            
        }else if imageUser != nil{
            
            self.activityIndicator?.startAnimating()
            
            self.usgImage = imageUser.rotate(radians: 2 * .pi)
            
            LastApiImage(image: self.usgImage )
            
            setupButtons()
            
        }else if let userKey = UserDefaults.standard.string(forKey: "UsersKey") {
            
            let idsArray: NSArray = UserDefaults.standard.array(forKey: "IDS")! as NSArray
            
//            print(idsArray.count)
            
            if idsArray.count == 1 {
                
                for id in idsArray{
                    
                    if let images = CacheHelper().image(withIdentifier: id as! String, in: "jpg"){
                        
                        self.activityIndicator?.startAnimating()
                        
                        
                        LastApiImage(image: images )
                        
                        self.usgImage = images
                        
                        imageUser = self.usgImage
                        
                    }
                    
                }
                setupButtons()
                
            }else{
                for id in idsArray{
                    
                    self.activityIndicator?.startAnimating()
                    
                    if let images = CacheHelper().image(withIdentifier: id as! String, in: "jpg"){
                        
                        self.userImages.append(images)
                        
                    }
                }
                lastApi(lookzId: (self.frame?.lookzId)!, ids: idsArray as NSArray)
                
                self.idValues = idsArray as! [String]
                
//                print(userKey)
                
                setupButtons()
            }
            
            
        }else{
            if let _ = self.frame {
                //Frame is already available, so do nothing
            } else {
                
                let frames = realm.objects(InventoryFrame.self).filter { $0.isTryonCreated == true }
                self.frame = frames.first
            }
            
            self.user = tryon3D.user
            
            setupButtons()
            self.activityIndicator?.startAnimating()
            
            updateImages()
            
            UserDefaults.standard.set(nil, forKey: "IDS")
            
            UserDefaults.standard.set(nil, forKey: "imageKey")
            
            UserDefaults.standard.set(nil, forKey: "UsersKey")
            
        }
        
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action:  #selector(handlePanGesture))
        panGestureRecognizer.cancelsTouchesInView = false
        imageScrollHandlerView.addGestureRecognizer(panGestureRecognizer)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        tapGestureRecognizer.cancelsTouchesInView = false
        imageScrollHandlerView.addGestureRecognizer(tapGestureRecognizer)
        
        let tapGestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(scrolToBottomButtonDidTap(_:)))
        tapGestureRecognizer1.cancelsTouchesInView = false
        tapGestureScrollUpDown.addGestureRecognizer(tapGestureRecognizer1)
        //
        //
    }
    
    func updateVideo(){
        //
        //        let frames = realm.objects(InventoryFrame.self).filter { $0.isTryonCreated == true }
        //        self.frame = frames.first
        
        // self.activityIndicator?.startAnimating()
        
        numberOfFrames = videoImages.count
        
        imageScrollView.contentSize = CGSize(width: CGFloat(videoImages.count) * imageScrollView.bounds.width, height: imageScrollView.bounds.height)
        
        var i: CGFloat = 0.0
        var counter: Int = 1
        
        for identifier in videoImages.reversed() {
            let tempImageView = UIImageView(frame: CGRect(x: i, y: 0, width: self.imageScrollView.bounds.width, height: self.imageScrollView.bounds.height))
            
            tempImageView.image = identifier
            tempImageView.clipsToBounds = true
            tempImageView.contentMode = .scaleAspectFill
            tempImageView.layer.cornerRadius = 5
            tempImageView.layer.masksToBounds = true
            
            DispatchQueue.main.async { [a = counter] in
                self.imageScrollView.addSubview(tempImageView)
                
                if a + 1 == self.videoImages.count {
                    //All images loaded
                    self.scrollToFrame(i: self.videoImages.count / 2, withDelay: 0.0)
                }
            }
            i += self.imageScrollView.bounds.width
            counter += 1
        }
        self.user = tryon3D.user
        
        scrollToFrame(i: 6, withDelay: 0.0)
        
        setupButtons()
    }
    
    func updateImages() {
        //Add Placeholder image
        
        if let front = self.user?.internalUserName{
            
            let frontFaceIdentifier = front + "-frontFace"
            
            placeHolderImageView.image = CacheHelper().image(withIdentifier: frontFaceIdentifier, in: "jpg")
            
            let image = CacheHelper().image(withIdentifier: frontFaceIdentifier, in: "jpg")
            
//            print(image!)
            
        }
        
        removeImages()
        
        if userImages.count != userImagesCount {
            
            self.activityIndicator?.startAnimating()
            
            lastApi(lookzId: (self.frame?.lookzId)!, ids: self.idValues as NSArray)
            
            //self.Indicator.startAnimating()
            
        }else if imageUser != nil{
            
            self.activityIndicator?.startAnimating()
            
            self.usgImage = imageUser.rotate(radians: 2 * .pi)
            
            LastApiImage(image: self.usgImage )
            
            
        }else{
            
            if is3DAlreadyRendered {
                //If already available, make use of it
                showImages()
                
            } else {
                //Render 3D and then add images
                
                //                if let idArray = UserDefaults.standard.array(forKey: "userId"){
                //
                //                    self.idValues = idArray as! [String]
                //
                //                    if let myLoadedImages = UserDefaults.standard.imageArray(forKey:"userImages") {
                //
                //                        self.userImages = myLoadedImages
                //                    }
                //
                //                    lastApi(lookzId : (self.frame?.lookzId)! ,ids:  self.idValues as NSArray)
                //
                //                }else{
                
                DispatchQueue.global(qos: .userInitiated).sync {
                    self.tryon3D.getRender3D(forUser: self.user!, shouldRenderWithUserImage: false, frame: self.frame!, inDirectory: .libraryDirectory, completionHandler: { (render3D) in
                        if render3D?.status == .isCompleted {
                            //Add User images
                            var userImageIdentifiers: [String] = []
                            for frameNumber in (self.user?.frameNumbers)! {
                                let id = (self.user?.internalUserName)! + "-user-\(frameNumber)"
                                userImageIdentifiers.append(id)
                            }
                            
                            //Add user images, only if it is not already added
                            if !self.isUserImagesAddedFor3D {
                                var index = 0
                                if !(self.is3DUserImageDidScroll) {
                                    //Since the image order is reversed, reversing the frontFrameIndex
                                    let totalIndexNumber = (self.user?.frameNumbers?.count)! - 1
                                    index = totalIndexNumber - (self.user?.frontFrameIndex)!
                                } else {
                                    index = self.currentDisplayFrame
                                }
                                
                                self.addUserImages(withIdentifiers: userImageIdentifiers, scrollTo: index)
                                self.isUserImagesAddedFor3D = true
                            }
                            
                            //Display 3D images
                            self.showImages()
                        } else {
                            //Error in rendering 3D images
                            log.error("Error in render 3D in Product Details screen for \(String(describing: self.frame?.id))")
                            self.updateUIForTryon3DFailed()
                        }
                    })
                }
                // }
            }
        }
        //  }
        
    }
    
    fileprivate func initDataFrameMenuTray() {
        //Filter the frames
        var filterData: [FilterList: [Int]] = [:]
        var additionalFilterString = "isTryonCreated == true"
        if let category = selectedCategory {
            filterData[.productType] = [category.id]
            additionalFilterString = " and isTryonCreated == true"
        }
        if let shape = selectedShape {
            filterData[.shape] = [shape.id]
            additionalFilterString = " and isTryonCreated == true"
        }
        if let type = selectedFrameType {
            filterData[.frameType] = [type.id]
            additionalFilterString = " and isTryonCreated == true"
        }
        InventoryFrameHelper().filterInventory(filterList: filterData, additionalFilterString: additionalFilterString) { (frames, error) in
            
            self.frameMenuTrayView.items.removeAll()
            if frames.count == 0 {
                self.frameMenuTrayView.selectedId = nil
                self.selectedFrame = nil
                self.frameMenuTrayView.mainButtonImageView.image = nil
            }
            
            var i = 0
            for frame in frames {
                self.frameMenuTrayView.items.append(["id": String(frame.id), "name": frame.modelNumber, "iconUrl": frame.thumbnailImageUrl])
                
                //Set the image of the first frame to the Main Button
                if i == 0 {
                    if let url = frame.thumbnailImageUrl {
                        if url != "" {
                            self.frameMenuTrayView.mainButtonImageView.kf.setImage(with: URL(string: url)!)
                        } else {
                            self.frameMenuTrayView.mainButtonImageView.image = nil
                        }
                    } else {
                        self.frameMenuTrayView.mainButtonImageView.image = nil
                    }
                }
                
                if frame.id == self.frame?.id {
                    self.frameMenuTrayView.selectedId = self.frame?.id
                    self.selectedFrame = self.frame
                    
                    //If the displayed frame is present in the list, set the image of this frame
                    if let url = frame.thumbnailImageUrl {
                        if url != "" {
                            self.frameMenuTrayView.mainButtonImageView.kf.setImage(with: URL(string: url)!)
                        } else {
                            self.frameMenuTrayView.mainButtonImageView.image = nil
                        }
                    } else {
                        self.frameMenuTrayView.mainButtonImageView.image = nil
                    }
                }
                i = i + 1
            }
            self.frameMenuTrayView.collectionView.reloadData()
        }
    }
    
    fileprivate func initDataColorMenuTray() -> Int {
        if let selectedFrame = self.selectedFrame {
            var childFrames: [InventoryFrame] = []
            if selectedFrame.childFrames.count > 0 {
                //It is a parent frame, with child(s)
                childFrames.append(selectedFrame)
                for child in selectedFrame.childFrames {
                    childFrames.append(child)
                }
            } else if let parent = selectedFrame.parentFrame.first {
                //It is a child frame, so make use of the parent
                if parent.childFrames.count > 0 {
                    childFrames.append(parent)
                    for child in parent.childFrames {
                        childFrames.append(child)
                    }
                }
            }
            
            self.colorMenuTrayView.items.removeAll()
            if childFrames.count == 0 {
                self.colorMenuTrayView.selectedId = nil
                self.colorMenuTrayView.mainButtonImageView.image = UIImage(named: "ColorIcon")
            } else {
                self.colorMenuTrayView.selectedId = self.selectedFrame?.id
                self.colorMenuTrayView.mainButtonImageView.image = UIImage(named: "ColorIcon")
            }
            
            for child in childFrames {
                
                if child.isTryonCreated == true{
                    
                    colorMenuTrayView.items.append(["id": "\(child.id)", "name": child.identifiedColor?.name, "colorR": "\(child.identifiedColor?.colorR.value ?? 255)", "colorG": "\(child.identifiedColor?.colorG.value ?? 255)", "colorB": "\(child.identifiedColor?.colorB.value ?? 255)"])
                    
                }
            }
            
            colorMenuTrayView.collectionView.reloadData()
            return childFrames.count
        }
        
        return 0
    }
    
    fileprivate func initDataFrameTypeMenuTray() {
        let frameTypes = realm.objects(CategoryFrameType.self).sorted(byKeyPath: "order")
        
        frameTypeMenuTrayView.items.removeAll()
        for frameType in frameTypes {
            frameTypeMenuTrayView.items.append(["id": String(frameType.id), "name": frameType.name, "iconUrl": frameType.iconUrl])
        }
        
        frameTypeMenuTrayView.selectedId = frame?.frameType?.id
        selectedFrameType = frame?.frameType
        
        if let url = frame?.frameType?.iconUrl {
            if url != "" {
                frameTypeMenuTrayView.mainButtonImageView.kf.setImage(with: URL(string: url)!)
            } else {
                frameTypeMenuTrayView.mainButtonImageView.image = nil
            }
        } else {
            frameTypeMenuTrayView.mainButtonImageView.image = nil
        }
    }
    
    fileprivate func initDataShapeMenuTray() {
        let shapes = realm.objects(CategoryShape.self).sorted(byKeyPath: "order")
        
        shapeMenuTrayView.items.removeAll()
        for shape in shapes {
            //Add the shape, only if it contains 3D objects
            let count = realm.objects(InventoryFrame.self).filter("shape.id == \(shape.id) and isTryonCreated == true").count
            if count > 0 {
                shapeMenuTrayView.items.append(["id": String(shape.id), "name": shape.name, "iconUrl": shape.iconUrl])
            }
        }
        
        shapeMenuTrayView.selectedId = frame?.shape?.id
        selectedShape = frame?.shape
        
        if let url = frame?.shape?.iconUrl {
            if url != "" {
                shapeMenuTrayView.mainButtonImageView.kf.setImage(with: URL(string: url)!)
            } else {
                shapeMenuTrayView.mainButtonImageView.image = nil
            }
        } else {
            shapeMenuTrayView.mainButtonImageView.image = nil
        }
    }
    
    fileprivate func initDataCategoryMenuTray() {
        let categories = realm.objects(CategoryProductType.self).sorted(byKeyPath: "order")
        
        categoryMenuTrayView.items.removeAll()
        for category in categories {
            categoryMenuTrayView.items.append(["id": String(category.id), "name": category.name, "iconUrl": category.iconUrl])
        }
        
        categoryMenuTrayView.selectedId = frame?.category?.id
        selectedCategory = frame?.category
        
        if let url = frame?.category?.iconUrl {
            if url != "" {
                categoryMenuTrayView.mainButtonImageView.kf.setImage(with: URL(string: url)!)
            } else {
                categoryMenuTrayView.mainButtonImageView.image = nil
            }
        } else {
            categoryMenuTrayView.mainButtonImageView.image = nil
        }
    }
    
    func setupButtons() {
        backButton.addCornerRadius(15.0, inCorners: [.topRight, .bottomRight])
        backButton.clipsToBounds = true
        backButton.masksToBounds = true
        
        let image = UIImage(named: "CartIcon")?.withRenderingMode(.alwaysTemplate)
        cartImage.tintColor = UIColor.primaryLightColor
        cartImage.image = image
        
        let image1 = UIImage(named: "ic_favorite_outline_violet")?.withRenderingMode(.alwaysTemplate)
        favImage.tintColor = UIColor.primaryLightColor
        favImage.image = image1
        
        infoButton.tintColor = UIColor.primaryDarkColor
        infoButton.addCornerRadius(15.0, inCorners: [.topLeft, .bottomLeft])
        infoButton.clipsToBounds = true
        infoButton.masksToBounds = true
        
        self.addToTrayButton.backgroundColor = UIColor.primaryDarkColor
        self.addToFavButton.backgroundColor = UIColor.primaryDarkColor

        let radius = self.addToTrayButtonView.bounds.size.height / 4
        addToTrayButton.addCornerRadius(radius, inCorners: [.topLeft, .bottomLeft])
        addToTrayButton.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        let radius1 = self.addToFavButtonView.bounds.size.height / 4
        addToFavButton.addCornerRadius(radius1, inCorners: [.topLeft, .bottomLeft])
        addToFavButton.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        addToTrayButtonView.shadowColor = UIColor.darkGray
        addToTrayButtonView.shadowOffset = CGSize(width: 4, height: 4)
        addToTrayButtonView.shadowOpacity = 0.5
        addToTrayButtonView.shadowRadius = 6.0
        
        addToFavButtonView.shadowColor = UIColor.darkGray
        addToFavButtonView.shadowOffset = CGSize(width: 4, height: 4)
        addToFavButtonView.shadowOpacity = 0.5
        addToFavButtonView.shadowRadius = 6.0
        
        infoButtonView.shadowColor = UIColor.darkGray
        infoButtonView.shadowOffset = CGSize(width: 4, height: 4)
        infoButtonView.shadowOpacity = 0.5
        infoButtonView.shadowRadius = 6.0
        
        //Configure Shape Menu Tray button
        categoryMenuTrayView.menuTrayViewDelegate = self
        categoryMenuTrayView.menuTrayType = .category
        categoryMenuTrayView.emptyLabel.text = "No category found"
        initDataCategoryMenuTray()
        
        //Configure Shape Menu Tray button
        shapeMenuTrayView.menuTrayViewDelegate = self
        shapeMenuTrayView.menuTrayType = .shape
        shapeMenuTrayView.emptyLabel.text = "No shapes found"
        initDataShapeMenuTray()
        
        //Configure FrameType Menu Tray button
        frameTypeMenuTrayView.menuTrayViewDelegate = self
        frameTypeMenuTrayView.menuTrayType = .frameType
        frameTypeMenuTrayView.emptyLabel.text = "No frame types found"
        initDataFrameTypeMenuTray()
        
        //Configure Frame Menu Tray button
        frameMenuTrayView.menuTrayViewDelegate = self
        frameMenuTrayView.menuTrayType = .frame
        frameMenuTrayView.emptyLabel.text = "No frames found"
        initDataFrameMenuTray()
        
        //Configure Color Menu Tray button
        colorMenuTrayView.menuTrayViewDelegate = self
        colorMenuTrayView.menuTrayType = .color
        colorMenuTrayView.emptyLabel.text = "No colors found"
        let _ = initDataColorMenuTray()
    }
    
    func updateUIForFrameToTray(isAdded: Bool) {
        if isAdded {
            self.addToTrayButton.backgroundColor = UIColor.primaryWarningColor
        } else {
            self.addToTrayButton.backgroundColor = UIColor.primaryDarkColor
        }
    }
    func updateUIForFrameTofTray(isAdded: Bool) {
        if isAdded {
            addToFavButton.backgroundColor = UIColor.primaryWarningColor
        } else {
            addToFavButton.backgroundColor = UIColor.primaryDarkColor
        }
    }
    func handlePanGesture(gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .changed {
            let translation = gestureRecognizer.location(in: self.view)
            handleGesture(x: translation.x, y: translation.y)
        }
    }
    
    func handleTapGesture(gestureRecognizer: UITapGestureRecognizer) {
        let translation = gestureRecognizer.location(in: self.view)
        handleGesture(x: translation.x, y: translation.y)
    }
    
    func handleGesture(x: CGFloat, y: CGFloat) {
        self.is3DUserImageDidScroll = true
        closeAllMenuTray()
        
        var x = x
        if y > (imageScrollView.center.y + imageScrollView.bounds.height/2) || y < (imageScrollView.center.y - imageScrollView.bounds.height/2){
            return
        }
        
        x = x - (self.view.bounds.width - imageScrollView.bounds.width)/2
        //Page going from 1 to numberOfFrames
        var page = Int((x/imageScrollView.bounds.width)*CGFloat(numberOfFrames)) + 1
        if page < 1 {
            page = 1
        }
        if page > numberOfFrames {
            page = numberOfFrames
        }
        currentDisplayFrame = page - 1
        imageScrollView.contentOffset = CGPoint(x: CGFloat(currentDisplayFrame)*imageScrollView.bounds.width, y: 0)
    }
    
    func updateUIForTryon3DStillLoading() {
        imageScrollHandlerView.isUserInteractionEnabled = false
        leftRotationImageView.isHidden = true
        rightRotationImageView.isHidden = true
        
        self.imageScrollView.isHidden = true
        self.activityIndicator?.startAnimating()
    }
    
    func updateUIForTryon3DCompleted() {
        imageScrollHandlerView.isUserInteractionEnabled = true
        
        //Display Left and Right rotation only if there are more number of images.
        if (self.user?.yprValues?.count ?? 0) > 1 {
            leftRotationImageView.isHidden = false
            rightRotationImageView.isHidden = false
        }
        self.imageScrollView.isHidden = false
        self.activityIndicator?.stopAnimating()
        
        
    }
    
    func updateUIForTryon3DFailed() {
        imageScrollHandlerView.isUserInteractionEnabled = false
        leftRotationImageView.isHidden = true
        rightRotationImageView.isHidden = true
        
        self.imageScrollView.isHidden = true
        self.activityIndicator?.stopAnimating()
    }
    
    // MARK: - Tryon3D functions
    
    func showImages() {
        //Add User with glass images
        var imageIdentifiers: [String] = []
        for frameNumber in (user?.frameNumbers)! {
            imageIdentifiers.append("\((frame?.id)!)-\(frameNumber)")
        }
        self.addImages(withIdentifiers: imageIdentifiers, in: "png")
        
        //Since the image order is reversed, reversing the frontFrameIndex
        let totalIndexNumber = (user?.frameNumbers?.count)! - 1
        let reversedFrontFrameIndex = totalIndexNumber - (user?.frontFrameIndex)!
        scrollToFrame(i: reversedFrontFrameIndex, withDelay: 0.0)
        
        updateUIForTryon3DCompleted()
    }
    
    func addUserImages(withIdentifiers identifiers: [String], scrollTo frame: Int) {
        
        numberOfFrames = identifiers.count
        imageScrollView.contentSize = CGSize(width: CGFloat(identifiers.count) * imageScrollView.bounds.width, height: imageScrollView.bounds.height)
        
        var i: CGFloat = 0.0
        var counter: Int = 1
        
        for identifier in identifiers.reversed() {
            let tempImageView = UIImageView(frame: CGRect(x: i, y: 0, width: self.imageScrollView.bounds.width, height: self.imageScrollView.bounds.height))
            
            if let img = CacheHelper().image(withIdentifier: identifier, in: "jpg") {
                tempImageView.image = img
            } else {
                log.error("Image not found for identifier: \(identifier)")
            }
            
            tempImageView.clipsToBounds = true
            tempImageView.contentMode = .scaleAspectFill
            tempImageView.layer.cornerRadius = 5
            tempImageView.layer.masksToBounds = true
            
            DispatchQueue.main.async { [a = counter] in
                self.imageScrollView.addSubview(tempImageView)
                
                if a + 1 == identifiers.count {
                    //All images loaded
                    self.scrollToFrame(i: frame, withDelay: 0.0)
                }
            }
            i += self.imageScrollView.bounds.width
            counter += 1
        }
        
    }
    
    func removeImages() {
        for view in self.imageScrollView.subviews {
            if view.tag > 0 {
                view.removeFromSuperview()
            }
        }
    }
    
    func addImages(withIdentifiers identifiers: [String], in representation: String) {
        
        
        numberOfFrames = identifiers.count
        imageScrollView.contentSize = CGSize(width: CGFloat(identifiers.count) * imageScrollView.bounds.width, height: imageScrollView.bounds.height)
        
        DispatchQueue.global(qos: .background).sync {
            var i: CGFloat = 0.0
            var counter: Int = 1
            for identifier in identifiers.reversed() {
                let tempImageView = UIImageView(frame: CGRect(x: i, y: 0, width: self.imageScrollView.bounds.width, height: self.imageScrollView.bounds.height))
                
                if let img = CacheHelper().image(withIdentifier: identifier, in: representation) {
                    tempImageView.image = img
                    tempImageView.tag = counter
                } else {
                    log.error("Image not found for identifier: \(identifier)")
                }
                
                tempImageView.clipsToBounds = true
                tempImageView.contentMode = .scaleAspectFill
                tempImageView.layer.cornerRadius = 5
                tempImageView.layer.masksToBounds = true
                
                //Add perspective angles to the existing angles
                let frameCount = self.user?.yprValues?.count
                let actualYPR = self.user?.actualYPRValues![frameCount! - counter]
                let actualYPRArray = actualYPR?.components(separatedBy: "_")
                let actualY = Double(actualYPRArray![0])!
                let actualP = Double(actualYPRArray![1])!
                let actualR = Double(actualYPRArray![2])!
                
                let ypr = self.user?.yprValues![frameCount! - counter]
                let yprArray = ypr?.components(separatedBy: "_")
                let y = Double(yprArray![0])!
                let p = Double(yprArray![1])!
                let r = Double(yprArray![2])!
                
                var actualSellionPoint = CGPoint.zero
                if self.user?.userInputType == .image {
                    let sellionPoint = self.user?.sellionPoints![frameCount! - counter]
                    let screenSize = UIScreen.main.bounds
                    let scalingFactorX = screenSize.width / self.model.serverImageSize.width
                    let scalingFactorY = screenSize.height / self.model.serverImageSize.height
                    actualSellionPoint = CGPoint(x: (sellionPoint?.x)! * scalingFactorX, y: (sellionPoint?.y)! * scalingFactorY)
                    
                } else {
                    let sellionPoint = self.user?.sellionPoints![frameCount! - counter]
                    let correctionFactorX = (self.model.serverVideoSize.width - self.model.displayImageSize.width) / 2
                    let correctionFactorY = (self.model.serverVideoSize.height - self.model.displayImageSize.height) / 2
                    
                    let screenSize = UIScreen.main.bounds
                    let scalingFactorX = screenSize.width / self.model.displayImageSize.width
                    let scalingFactorY = screenSize.height / self.model.displayImageSize.height
                    
                    actualSellionPoint = CGPoint(x: ((sellionPoint?.x)! - correctionFactorX) * scalingFactorX, y: ((sellionPoint?.y)! - correctionFactorY) * scalingFactorY)
                }
                
                let glassImageLayer = tempImageView.layer
                let newAnchorPointX = actualSellionPoint.x / glassImageLayer.frame.width
                let newAnchorPointY = actualSellionPoint.y / glassImageLayer.frame.height
                glassImageLayer.anchorPoint = CGPoint(x: newAnchorPointX, y: newAnchorPointY)
                glassImageLayer.position = CGPoint(x: glassImageLayer.position.x - glassImageLayer.frame.width/2 + actualSellionPoint.x, y: glassImageLayer.position.y - glassImageLayer.frame.height/2 + actualSellionPoint.y)
                
                var rotationAndPerspectiveTransform = CATransform3DIdentity
                rotationAndPerspectiveTransform.m34 = 1.0 / -200
                
                rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, CGFloat(((y - actualY) * Double.pi) / 180.0), 0, 1, 0)
                rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, CGFloat(((p - actualP) * Double.pi) / 180.0), 1, 0, 0)
                rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, CGFloat(((r - actualR) * Double.pi) / 180.0), 0, 0, 1)
                glassImageLayer.transform = rotationAndPerspectiveTransform
                glassImageLayer.zPosition = 100
                
                DispatchQueue.main.async {
                    self.imageScrollView.addSubview(tempImageView)
                }
                
                i += self.imageScrollView.bounds.width
                counter += 1
            }
        }
        
    }
    
    func scrollToFrame(i: Int, withDelay delay: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.currentDisplayFrame = i
            self.imageScrollView.contentOffset = CGPoint(x: CGFloat(self.currentDisplayFrame) * self.imageScrollView.bounds.width, y: 0)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "tabClose"), object: nil)
        
        if let infoFrameController = segue.destination as? InfoFrameController {
            infoFrameController.infoFrameDelegate = self
            self.detailModelDelegate = infoFrameController
            if let frame = self.frame {
                infoFrameController.frame = frame
            } else {
                //Take the first frame
                let frames = realm.objects(InventoryFrame.self).filter { $0.isTryonCreated == true }
                infoFrameController.frame = frames.first
            }
        }
    }
    
    // getFramesVideo
    
    func lastApi(lookzId : String ,ids: NSArray){
        
        let params: Parameters = [
            "_id": ids,
            "frameId": [lookzId]
            
        ]
        
        Alamofire.request("https://widget.oichub.com/v3/widget//getGlassFramesVideo", method: .post, parameters: params, encoding: URLEncoding.httpBody)
            .responseJSON(completionHandler:{ response in
                
                switch response.result {
                case .success:
                    
                    let dic :NSDictionary = response.result.value! as! NSDictionary
                    
                    let twDataArray = (dic.value(forKey:"data") as? NSArray) as Array?
                    
                    
                    if twDataArray != nil{
                        
                        self.valuesDict.removeAll()
                        
                        for value in twDataArray!{
                            
                            self.valuesDict.append(value as! NSDictionary)
                            
                        }
                        
                        self.loadingImage(ids: self.idValues)
                        
                    }else{
                        
                        let alert = UIAlertController(title:"No Model Preview Available" , message: "", preferredStyle: UIAlertControllerStyle.alert);
                        
                        let alertAction = UIAlertAction(title: "ok", style: .cancel) { (alert) in
                            self.dismiss(animated: true, completion: nil)
                        }
                        
                        alert.addAction(alertAction)
                        
                        self.present(alert, animated: true, completion: nil)
                        
//                        print(lookzId,"Not there")
                    }
                    
                    break
                    
                case .failure(let error):
                    print(error)
                    
                }
                
            })
    }
    
    // glass url to image
    func loadingImage(ids : [String]){
        
        print("Im loading images called ...")
        classDict.removeAll()
        
        for id in ids {
            for  i  in  0...11{
                if  valuesDict[i].object(forKey: "_id") as! String == id {
                    classDict.append(valuesDict[i])
                    
                }
            }
            
        }
        finalImageArray.removeAll()
        
        tempImage.removeAll()
        
        
        for dict in classDict{
            let url = URL.init(string:dict.object(forKey: "frameUrl")  as! String)
            
            KingfisherManager.shared.retrieveImage(with: url!, options: nil, progressBlock: nil, completionHandler: { image, error, cacheType, imageURL in
                ImageCache.default.store(image!, forKey: dict.object(forKey: "_id")  as! String)
                
//                print(dict.object(forKey: "_id")  as! String , "Storing ID")
                self.images.append(["url" : dict.object(forKey: "frameUrl")  as! String , "image" : image!])
                self.tempImage.append(image!)
                
                if self.tempImage.count == 12{
                    self.finalMethods(imgs: self.tempImage)
                    
                }
            })
            
        }
        
        
    }
    // Image Rendraing
    func finalMethods(imgs: [UIImage]){
        
        for  dict in classDict{
            
            let id = dict.object(forKey: "_id") as! String
            
//            print(id , "fetch before loop")
            
            ImageCache.default.retrieveImage(forKey: id , options: nil) {
                image, cacheType in
                if let image = image {
                    self.finalImageArray.append(image)
                    
                } else {
                    print("Not exist in cache.")
                }
            }
            
            
        }
        
        var a = 0
        
        imageArray.removeAll()
        
        for valueImages  in  classDict{
            
            let ima = userImages[a]
            
            
            
            CacheHelper().add(userImages[a], withIdentifier: self.idValues[a] , in: "jpg")
            
            UserDefaults.standard.set(self.idValues, forKey: "IDS")
            
            let image2 = ima.image(byDrawingImage: finalImageArray[a], inRect: CGRect.init(x: valueImages.value(forKey: "left") as! Int, y: valueImages.value(forKey: "top") as! Int, width: valueImages.value(forKey: "width") as! Int, height: valueImages.value(forKey: "height") as! Int))
            
            if a == 6 {
                
                UserDefaults.standard.set(nil, forKey: "UsersKey")
                
                UserDefaults.standard.set(nil, forKey: "imageKey")
                
                UserDefaults.standard.set(valueImages, forKey: "imageKey")
                
                UserDefaults.standard.set(valueImages.object(forKey: "frameUrl") as! String, forKey: "UsersKey")
                
                CacheHelper().add(userImages[6], withIdentifier: valueImages.object(forKey: "YPR") as! String , in: "jpg")
                
            }
            
            //            let url = URL.init(string:valueImages.object(forKey: "frameUrl")  as! String)
            //            let paramHeight = valueImages.object(forKey: "height")  as! Int
            //            let paramWidth = valueImages.object(forKey: "width")  as! Int
            //            let paramTop = valueImages.object(forKey: "top")  as! Int
            //            let paramLeft = valueImages.object(forKey: "left")  as! Int
            //            print(url,paramHeight , paramWidth , paramTop , paramLeft ,"[Vasan] Model Detail Page -- Frame meging")
            
            imageArray.append(image2!)
            
            
            
            a = a + 1
        }
        self.activityIndicator?.stopAnimating()
        
        self.Indicator.stopAnimating()
        //self.tryon3D.user = newUser
        self.videoImages = imageArray
        
        
        updateVideo()
        
        
    }
    
    
    func LastApiImage(image : UIImage){
        
        
        Alamofire.upload(multipartFormData:
            {
                (multipartFormData) in
                
                multipartFormData.append(UIImageJPEGRepresentation(image, 0.5)!, withName: "selfie", fileName: "file.jpeg", mimeType: "image/jpeg")
                
                
        }, to:"https://widget.oichub.com/v3/widget/uploadSelfie",headers:nil)
        { (result) in
            switch result {
            case .success(let upload,_,_ ):
                upload.uploadProgress(closure: { (progress) in
                    //Print progress
                })
                upload.responseJSON
                    { response in
                        //print response.result
                        if response.result.value != nil
                        {
                            let dic :NSDictionary = response.result.value! as! NSDictionary
                            
                            let dict : NSDictionary = dic.object(forKey: "data") as! NSDictionary
                            
                            
                            self.lastApi(id:dict.object(forKey: "id") as! String,lookzId: (self.frame?.lookzId)!)
                            
                        }
                }
            case .failure(let encodingError):
                
                print(encodingError)
                break
            }
            
        }
    }
    
    func lastApi(id :String , lookzId : String ){
        
        let params: Parameters = [
            "_id": [id],
            "frameId": [lookzId]
            
        ]
        
        Alamofire.request("https://widget.oichub.com/v3/widget//getGlassFrames", method: .post, parameters: params, encoding: URLEncoding.httpBody)
            .responseJSON{ response in
                
                switch response.result {
                case .success:
                    
                    let dic :NSDictionary = response.result.value! as! NSDictionary
                    
                    let twDataArray = (dic.value(forKey:"data") as? NSArray) as Array?
                    
                    
                    if twDataArray != nil{
                        
                        
                        for value in twDataArray!{
                            
                            
                            self.imagesUserDict = value as! NSDictionary
                            
                            //self.classDict.append(value as! NSDictionary)
                            
                            self.loadImage(urlStr: self.imagesUserDict.object(forKey: "frameUrl") as! String)
                            
                        }
                        
                        
                        
                    }else{
                        
                        let alert = UIAlertController(title:"No Model Preview Available" , message: "", preferredStyle: UIAlertControllerStyle.alert);
                        
                        let alertAction = UIAlertAction(title: "ok", style: .cancel) { (alert) in
                            self.dismiss(animated: true, completion: nil)
                        }
                        
                        alert.addAction(alertAction)
                        
                        self.present(alert, animated: true, completion: nil)
                        
                    }
             
                    break
                    
                case .failure(let error):
                    print(error)
                    
                    
                }
                
                
        }
    }
    
    
    func loadImage(urlStr: String){
        
        
        let url = URL.init(string: urlStr)
        
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            guard let data = data, error == nil else { return }
            
            DispatchQueue.main.async() {
                
                self.imagesFinal(ima: UIImage.init(data: data)!)
                self.activityIndicator?.stopAnimating()
            }
        }
        task.resume()
    }
    
    func imagesFinal(ima : UIImage){
        
        self.activityIndicator?.stopAnimating()
        
        
        let image2 = self.usgImage.image(byDrawingImage: ima, inRect: CGRect.init(x: self.imagesUserDict.value(forKey: "left") as! Int, y: self.imagesUserDict.value(forKey: "top") as! Int, width: self.imagesUserDict.value(forKey: "width") as! Int, height: self.imagesUserDict.value(forKey: "height") as! Int))
        
        UserDefaults.standard.set(nil, forKey: "IDS")
        
        UserDefaults.standard.set(nil, forKey: "imageKey")
        
        UserDefaults.standard.set(nil, forKey: "UsersKey")
        
        UserDefaults.standard.set(self.imagesUserDict, forKey: "imageKey")
        
        UserDefaults.standard.set(self.imagesUserDict.object(forKey: "frameUrl") as! String, forKey: "UsersKey")
        
        UserDefaults.standard.set([self.imagesUserDict.object(forKey: "YPR") as! String], forKey: "IDS")
        
        
        CacheHelper().add(self.usgImage, withIdentifier: self.imagesUserDict.object(forKey: "YPR") as! String , in: "jpg")
        
        let tempImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.imageScrollView.bounds.width, height: self.imageScrollView.bounds.height))
        
        tempImageView.image = image2
        tempImageView.clipsToBounds = true
        tempImageView.contentMode = .scaleAspectFill
        tempImageView.layer.cornerRadius = 5
        tempImageView.layer.masksToBounds = true
        
        self.imageScrollView.addSubview(tempImageView)
        
        imageScrollHandlerView.isUserInteractionEnabled = false
        leftRotationImageView.isHidden = true
        rightRotationImageView.isHidden = true
    }
}

extension DetailModelController: InfoFrameDelegate {
    func frameDidChange(newFrame: InventoryFrame) {
        self.frame = newFrame
        updateImages()
    }
    
    func frame(_ frame: InventoryFrame, isAddedToTray: Bool) {
        //Update UI
        updateUIForFrameToTray(isAdded: isAddedToTray)
    }
    
    func frame(_ frame: InventoryFrame, isAddedTofTray: Bool) {
        updateUIForFrameTofTray(isAdded: isAddedTofTray)
    }
}

extension DetailModelController: MenuTrayViewDelegate {
    func menuTrayView(_ menuTrayView: MenuTrayView, didOpenTray: Bool) {
        switch menuTrayView {
        case categoryMenuTrayView:
            shapeMenuTrayView.closeTray()
            frameTypeMenuTrayView.closeTray()
            frameMenuTrayView.closeTray()
            colorMenuTrayView.closeTray()
            
        case shapeMenuTrayView:
            categoryMenuTrayView.closeTray()
            frameTypeMenuTrayView.closeTray()
            frameMenuTrayView.closeTray()
            colorMenuTrayView.closeTray()
            
        case frameTypeMenuTrayView:
            categoryMenuTrayView.closeTray()
            shapeMenuTrayView.closeTray()
            frameMenuTrayView.closeTray()
            colorMenuTrayView.closeTray()
            
        case frameMenuTrayView:
            categoryMenuTrayView.closeTray()
            shapeMenuTrayView.closeTray()
            frameTypeMenuTrayView.closeTray()
            colorMenuTrayView.closeTray()
            
        case colorMenuTrayView:
            categoryMenuTrayView.closeTray()
            shapeMenuTrayView.closeTray()
            frameTypeMenuTrayView.closeTray()
            frameMenuTrayView.closeTray()
            
        default:
            break
        }
    }
    
    func menuTrayView(_ menuTrayView: MenuTrayView, didCloseTray: Bool) {
        //Do Nothing
        return
    }
    
    func menuTrayView(_ menuTrayView: MenuTrayView, didSelect id: Int?) {
        switch menuTrayView {
        case categoryMenuTrayView:
            if let id = id {
                self.selectedCategory = realm.objects(CategoryProductType.self).filter("id == \(id)").first
                if let url = self.selectedCategory?.iconUrl {
                    if url != "" {
                        self.categoryMenuTrayView.mainButtonImageView.kf.setImage(with: URL(string: url)!)
                    } else {
                        self.categoryMenuTrayView.mainButtonImageView.image = nil
                    }
                } else {
                    self.categoryMenuTrayView.mainButtonImageView.image = nil
                }
            } else {
                self.selectedCategory = nil
                self.categoryMenuTrayView.mainButtonImageView.image = nil
            }
            
            initDataFrameMenuTray()
            let _ = initDataColorMenuTray()
            
            //Open the tray, if the user selected something
            if let _ = id {
                shapeMenuTrayView.openTray()
            }
            
        case shapeMenuTrayView:
            if let id = id {
                self.selectedShape = realm.objects(CategoryShape.self).filter("id == \(id)").first
                if let url = self.selectedShape?.iconUrl {
                    if url != "" {
                        self.shapeMenuTrayView.mainButtonImageView.kf.setImage(with: URL(string: url)!)
                    } else {
                        self.shapeMenuTrayView.mainButtonImageView.image = nil
                    }
                } else {
                    self.shapeMenuTrayView.mainButtonImageView.image = nil
                }
            } else {
                self.selectedShape = nil
                self.shapeMenuTrayView.mainButtonImageView.image = nil
            }
            
            initDataFrameMenuTray()
            let _ = initDataColorMenuTray()
            
            //Open the tray, if the user selected something
            if let _ = id {
                frameTypeMenuTrayView.openTray()
            }
            
        case frameTypeMenuTrayView:
            if let id = id {
                self.selectedFrameType = realm.objects(CategoryFrameType.self).filter("id == \(id)").first
                if let url = self.selectedFrameType?.iconUrl {
                    if url != "" {
                        self.frameTypeMenuTrayView.mainButtonImageView.kf.setImage(with: URL(string: url)!)
                    } else {
                        self.frameTypeMenuTrayView.mainButtonImageView.image = nil
                    }
                } else {
                    self.frameTypeMenuTrayView.mainButtonImageView.image = nil
                }
            } else {
                self.selectedFrameType = nil
                self.frameTypeMenuTrayView.mainButtonImageView.image = nil
            }
            
            initDataFrameMenuTray()
            let _ = initDataColorMenuTray()
            
            //Open the tray, if the user selected something
            if let _ = id {
                frameMenuTrayView.openTray()
            }
            
        case frameMenuTrayView, colorMenuTrayView:
            if let id = id {
                self.selectedFrame = realm.objects(InventoryFrame.self).filter("id == \(id)").first
                self.frame = self.selectedFrame
                
                self.detailModelDelegate?.frameDidChange(newFrame: self.frame!)
                
                if self.videoImages.count != 0{
                    
                    //  self.videoModelDelegate?.videoFrameChange(frame: self.frame!, ids: as NSArray, valuesDicts: self.valuesDicts)
                    
                    if self.frame?.isTryonCreated as! Bool == true{
                        
                        classDict.removeAll()
                        valuesDict.removeAll()
                        
                        lastApi(lookzId : (self.frame?.lookzId)! ,ids:  self.idValues as NSArray)
                        self.activityIndicator?.startAnimating()
                        
                    }else{
                        
                        print("not creates glass")
                    }
                    
                    
                }else if imageUser != nil{
                    
                    setupButtons()
                    removeImages()
                    
                    LastApiImage(image: self.usgImage)
                    self.activityIndicator?.startAnimating()
                    
                    
                }else{
                    self.activityIndicator?.startAnimating()
                    updateImages()
                    
                    
                    
                }
                
                if let url = self.selectedFrame?.thumbnailImageUrl {
                    if url != "" {
                        self.frameMenuTrayView.mainButtonImageView.kf.setImage(with: URL(string: url)!)
                    }
                }
            }
            
            let colorCount = initDataColorMenuTray()
            if colorCount > 0 {
                colorMenuTrayView.openTray()
            }
            
        default:
            break
        }
    }
    
    func closeAllMenuTray() {
        categoryMenuTrayView.closeTray()
        shapeMenuTrayView.closeTray()
        frameTypeMenuTrayView.closeTray()
        frameMenuTrayView.closeTray()
        colorMenuTrayView.closeTray()
    }
}

extension UIImage {
    func rotate(radians: CGFloat) -> UIImage {
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0,
                                 y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.x, y: -origin.y,
                            width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return rotatedImage ?? self
        }
        
        return self
    }
}
