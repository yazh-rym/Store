//
//  ShopController.swift
//  Tryon
//
//  Created by Udayakumar N on 13/03/17.
//  Copyright © 2017 1000Lookz. All rights reserved.
//

import UIKit
import Alamofire
import NVActivityIndicatorView
import FaveButton
import AlamofireImage
import Alamofire
import TagListView
import PhoneNumberKit
import AWSS3
import NHRangeSlider
import Appsee
import RealmSwift


struct FilterTag {
    var category: CategoryIdentifiers
    var filterName: String
}


class ShopController: UIViewController, NVActivityIndicatorViewable, SomethingWentWrongDelegate {
    

    // MARK: - Class variables
    
    @IBOutlet weak var categoryTableView: UITableView!
    @IBOutlet weak var clearAllFiltersButton: UIButton!
    @IBOutlet weak var inventoryTableView: UITableView!
    @IBOutlet weak var inventoryTableViewHeaderLabel: UILabel!
    @IBOutlet weak var inventoryTableViewFooter: UIView!
    @IBOutlet weak var inventoryTableViewFooterAcitivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var inventoryTableViewFooterLabel: UILabel!
    @IBOutlet weak var frontImgView: UIImageView!
    @IBOutlet weak var glassImgView: UIImageView!
    @IBOutlet weak var tryon3DButton: UIButton!
    @IBOutlet weak var tryon3DLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var inventoryBigView: UIView!
    @IBOutlet weak var selectedInventoryName: UILabel!
    @IBOutlet weak var selectedInventoryDetail: UILabel!
    @IBOutlet weak var filterTagListView: TagListView!
    @IBOutlet weak var filterTagListTitleLabel: UILabel!
    @IBOutlet weak var shareUserImageButton: UIButton!
    @IBOutlet weak var shareUserImageLabel: UILabel!
    @IBOutlet weak var buyImageButton: UIButton!
    @IBOutlet weak var buyImageLabel: UILabel!
    
    @IBOutlet weak var imageScrollHandlerView: UIView!
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var tryonLogoImageView: UIImageView!
    
    @IBAction func myUnwindAction(unwindSegue: UIStoryboardSegue) {
        
    }
    
    @IBAction func clearAllFilters(_ sender: UIButton) {
        clearAllFilters(shouldGetInventoryFrames: true)
    }
    
    func clearAllFilters(shouldGetInventoryFrames: Bool) {
        //Configure Category Table view
        clearAllFiltersButton.isEnabled = false
        
        //Collapse all selected headers, if any
        for header in categoryHeaders {
            if header.isSelected {
                menuItemArray.collapse(header.row)
                header.isSelected = false
            }
        }
        
        //Unselect all items
        for items in categoryItems {
            for item in items.value {
                item.isSelected = false
            }
        }
        
        DispatchQueue.main.async {
            //Clear all filters
            self.allFilters.removeAll()
            self.selectedPriceRange = nil
            self.categoryTableView.reloadData()
            
            //Remove Filter tags
            self.filterTags.removeAll()
            self.filterTagListView.removeAllTags()
            self.filterTagListTitleLabel.isHidden = true
            
            if shouldGetInventoryFrames {
                //Filter the inventory
                self.filterInventory(resetPage: true)
            }
        }
    }
    
    @IBAction func didTapTryon3DButton(_ sender: UIButton) {
        let userLiked = UserLiked(frame: self.selectedFrame!)
        
        if tryon3D.isUserLiked(userLiked: userLiked) {
            //Already Liked. So Dislike it
            setTryon3DButtonText(isLiked: false)
            tryon3D.removeUserLiked(userLiked: userLiked)
        } else {
            //Newly Liked
            let addResult = tryon3D.addUserLiked(userLiked: userLiked)
            if addResult {
                setTryon3DButtonText(isLiked: true)
            } else {
                self.showAlertMessage(withTitle: "Sorry!", message: maxUserLikedCountReachedText)
            }
        }
        
        //Update Inventory Table
        self.inventoryTableView.reloadData()
        
        //Update TabBar
        let likedCount = tryon3D.countUserLiked()
        if let tabBarController = self.tabBarController as? MainTabBarController {
            tabBarController.updateLikedBadgeCount(withCount: likedCount)
        }
    }
    
    @IBAction func buyImageDidTap(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Buy", message: "Do you want to buy this glass? Please provide your mobile number", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Mobile Number"
            textField.keyboardType = UIKeyboardType.decimalPad
            if let mobileNumber = self.model.customer?.mobileNumber {
                textField.text = mobileNumber
            } else if let mobileNumber = self.model.sharedMobileNumber {
                textField.text = mobileNumber
            }
        }
        
        alertController.addAction(UIAlertAction(title: "Buy", style: UIAlertActionStyle.default, handler: { [weak self] (success) in
            //Get the mobile number
            let newMobileNumberTextField = alertController.textFields![0] as UITextField
            var phoneNumber: PhoneNumber?
            
            let phoneNumberKit = PhoneNumberKit()
            do {
                phoneNumber = try phoneNumberKit.parse(newMobileNumberTextField.text!)
                self?.model.sharedMobileNumber = phoneNumber?.numberString
                
                log.info("Valid New Phone Number: \(String(describing: phoneNumber?.numberString))")
            }
            catch {
                //Invalid phone number
                self?.showAlertMessage(withTitle: "Error", message: "Please enter valid mobile number")
                return
            }
            
            BuyHelper().sendSms(mobileNumber: (phoneNumber?.numberString)!, frame: (self?.selectedFrame)!, completionHandler: { (error) in
                if (error != nil) {
                    DispatchQueue.main.async {
                        log.error("BuySMS - Failed with error: \(String(describing: error))")
                        self?.showAlertMessage(withTitle: "Sorry", message: "We couldn't create the order. Please try again!")
                    }
                } else {
                    DispatchQueue.main.async {
                        log.info("BuySMS - Successful)")
                        self?.showAlertMessage(withTitle: "Thanks", message: "Your order has been sent to the Counter")
                    }
                }
            })
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func shareUserImageDidTap(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Share", message: "Do you want to share the image to your mobile number?", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Mobile Number"
            textField.keyboardType = UIKeyboardType.decimalPad
            if let mobileNumber = self.model.customer?.mobileNumber {
                textField.text = mobileNumber
            } else if let mobileNumber = self.model.sharedMobileNumber {
                textField.text = mobileNumber
            }
        }
        
        alertController.addAction(UIAlertAction(title: "Share", style: UIAlertActionStyle.default, handler: { [weak self] (success) in
            //Get the mobile number
            let newMobileNumberTextField = alertController.textFields![0] as UITextField
            var phoneNumber: PhoneNumber?
            
            let phoneNumberKit = PhoneNumberKit()
            do {
                phoneNumber = try phoneNumberKit.parse(newMobileNumberTextField.text!)
                self?.model.sharedMobileNumber = phoneNumber?.numberString
                
                log.info("Valid New Phone Number: \(String(describing: phoneNumber?.numberString))")
            }
            catch {
                //Invalid phone number
                self?.showAlertMessage(withTitle: "Error", message: "Please enter valid mobile number")
                return
            }
            
            //Create the image
            var frontImg: UIImage?
            var glassImg: UIImage?
            if (self?.is3DUserImageDidScroll)! {
                //Since the image order is reversed, reversing the frontFrameIndex
                let totalIndexNumber = (self?.user?.frameNumbers?.count)! - 1
                let reversedIndex = totalIndexNumber - (self?.currentDisplayFrame)!
                
                let userImageIidentifier = "user-" + String((self?.user?.frameNumbers?[reversedIndex])!)
                let glassImageIidentifier = String(describing: self?.selectedFrame?.id) + "-" + String((self?.user?.frameNumbers?[reversedIndex])!)
                
                if let img = self?.model.image(withIdentifier: userImageIidentifier, in: "jpg") {
                    frontImg = img
                } else {
                    self?.showAlertMessage(withTitle: "Sorry", message: "We couldn't share the image. Please try again!")
                }
                
                if let img = self?.model.imageFromCache(withIdentifier: glassImageIidentifier) {
                    glassImg = img
                } else {
                    self?.showAlertMessage(withTitle: "Sorry", message: "We couldn't share the image. Please try again!")
                }
            } else {
                frontImg = self?.frontImgView.image
                
                let identifier = String(describing: self?.selectedFrame?.id) + "-2D-" + String(describing: (self?.user?.frontFrameIndex)!)
                glassImg = self?.model.imageFromCache(withIdentifier: identifier)
            }
            
            let imgSize = CGSize(width: ((frontImg?.size.width)! / UIScreen.main.scale), height: ((frontImg?.size.height)! / UIScreen.main.scale))
            let bgRect = CGRect(x: 0, y: (imgSize.height - 45.0 - 5.0), width: imgSize.width, height: 45.0)
        
            UIGraphicsBeginImageContextWithOptions(imgSize, false, 0.0)
            frontImg?.draw(in: CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: imgSize))
            glassImg?.draw(in: CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: imgSize))
            
            if (self?.model.shouldAddCompanyLogoToShareImage)! {
                //Add Background to the image
                let bgImage = UIImage(named: "ShareBackground")
                bgImage?.draw(in: bgRect, blendMode: CGBlendMode.normal, alpha: 0.3)
            }
            
            //Add Logo to the image
            let logoImage = UIImage(named: "TryonLogoWithText")
            logoImage?.draw(in: CGRect(origin: CGPoint(x: imgSize.width - 105.0, y: imgSize.height - 45.0), size: CGSize(width: 80.0, height: 35.0)))
            
            if (self?.model.shouldAddCompanyLogoToShareImage)! {
                //Add Company Logo to the image
                let companyLogoImage = UIImage(named: "CompanyLogo")
                companyLogoImage?.draw(in: CGRect(origin: CGPoint(x: 25.0, y: imgSize.height - 42.0), size: CGSize(width: 80.0, height: 28.0)))
            }
            
            let userWithGlassImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            //Write the image to a file
            let imageName = NSUUID().uuidString + ".jpg"
            let imagePath = NSURL.fileURL(withPath: NSTemporaryDirectory() + imageName)
            
            if let data = UIImageJPEGRepresentation(userWithGlassImage!, 0.9) {
                do {
                    try data.write(to: imagePath, options: .atomic)
                } catch {
                    //Error in writing to the file
                    log.error(error)
                    self?.showAlertMessage(withTitle: "Sorry", message: "We couldn't share the image. Please try again!")
                    
                    return
                }
                log.info(imagePath)
            }
            
            //Upload the image
            let uploadCompletionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock = { (task, error) -> Void in
                if ((error) != nil){
                    DispatchQueue.main.async {
                        log.error("User Image Upload - Failed with error: \(String(describing: error))")
                        self?.showAlertMessage(withTitle: "Sorry", message: "We couldn't share the image. Please try again!")
                    }
                }
                else {
                    let userImageFilePath = EndPoints().s3UserShareFilePath + imageName
                    log.info("User Image - S3 image path: \(userImageFilePath)")
                    
                    ShareImageHelper().shareImage(mobileNumber: (phoneNumber?.numberString)!, sourceUrl: userImageFilePath, completionHandler: { (error) in
                        if (error != nil) {
                            DispatchQueue.main.async {
                                log.error("ShareImage - Failed with error: \(String(describing: error))")
                                self?.showAlertMessage(withTitle: "Sorry", message: "We couldn't share the image. Please try again!")
                            }
                        }
                    })
                }
            }
            
            AWSUploadHelper().uploadImage(fileURL: imagePath as NSURL, bucketName: EndPoints().s3BucketNameForUserShareUpload, fileS3UploadKeyName: imageName, completionHandler: uploadCompletionHandler, progressBlock: nil)

        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    let tryon3D = Tryon3D.sharedInstance
    let model = TryonModel.sharedInstance
    
    var categoryHeaders: [CategoryHeader] = []
    var categoryItems: [String: [CategoryItem]] = [:]
    let menuItemArray = SwiftyAccordionCells()
    
    var isAllCategoryDataLoadedInUI = false
    var isProductTypeLoaded = false
    var isBrandLoaded = false
    var isFrameTypeLoaded = false
    var isGenderLoaded = false
    
    //TODO: These are set to true for testing
    var isPriceLoaded = true
    var isShapeLoaded = true
    var isColorLoaded = true
    var isMaterialLoaded = true
    
    var inventoryFrames = [InventoryFrame]()
    var totalInventoryCount = 0
    var allFilters: [String: [String]] = [:]
    var isAllInventoryDataLoaded = false
    var nextInventoryPageNumber = 1
    var filterTags: [FilterTag] = []
    
    var operationQueueFor3D: OperationQueue = OperationQueue()
    var numberOfFrames = 0
    var currentDisplayFrame = 0
    
    let allGlassesLoadedText = "All Glasses loaded!"
    let noGlassesFoundText = "No Glasses found!"
    let errorInFetchingGlassesText = "Error in fetching Glasses!"
    let maxUserLikedCountReachedText = "You have already shortlisted 9 Glasses. Please remove some of them, before short-listing new glasses."
    
    weak var selectedFrame: InventoryFrame?
    
//    var allowedPriceRange = CategoryPrice(maxValue: -1.0, minValue: -1.0)
    var allowedPriceRange = CategoryPrice(value: [-1.0, -1.0])
    let minAllowedPrice = 0.0
    let maxAllowedPrice = 1000.0
    var selectedPriceRange: CategoryPrice?
    
    let imageDownloader = ImageDownloader(
        configuration: ImageDownloader.defaultURLSessionConfiguration(),
        downloadPrioritization: .fifo,
        maximumActiveDownloads: 4,
        imageCache: AutoPurgingImageCache()
    )
    
    let productDetailsFloatingController = UIStoryboard(name:"MainApp", bundle:nil).instantiateViewController(withIdentifier: "productDetailsFloating") as? ProductDetailsFloatingController
    let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.dark))
    
    var isUserImagesAddedFor3D = false
    var is3DUserImageDidScroll = false
    
    var user: User? {
        didSet {
            
            self.frontImgView.image = model.image(withIdentifier: "frontFace", in: "jpg")
            self.glassImgView.image = nil
            self.getUser2DRenderInProgress()
            
            self.isUserImagesAddedFor3D = false
            self.imageScrollView.isHidden = true
            self.imageScrollHandlerView.isUserInteractionEnabled = false
            self.tryonLogoImageView.isHidden = true
            self.is3DUserImageDidScroll = false
            DispatchQueue.main.async {
                self.removeAllUserImages()
            }
            
            tryon3D.removeUserLikedAll()
            let tabBarController = self.tabBarController as! MainTabBarController
            if let navController = tabBarController.viewControllers?[TabBarList.tray.rawValue] as! UINavigationController? {
                navController.tabBarItem.badgeValue = nil
                navController.popToRootViewController(animated: false)
                tabBarController.disableTabBarItem(item: TabBarList.tray.rawValue)
            }
            
            //Setup Operation Queue
            operationQueueFor3D.qualityOfService = .background
            operationQueueFor3D.maxConcurrentOperationCount = 1
            
            //Check Category data
            checkCategoryDataLoad()
            
            //Add Analytics
            model.customerReport?.customerVideoUrl = self.user?.serverVideoUrl
            if self.user?.userType == .model {
                model.customerReport?.customerFrontalFaceImgUrl = self.user?.frontFaceImgUrl
            } else {
//                //Upload front image
//                let frontFaceFilePath = model.imageFilePath(forIdentifier: "frontFace", in: "jpg")
//                let s3FileName = NSUUID().uuidString + ".jpg"
//                self.user?.frontFaceImgUrl = EndPoints().s3UserImageFilePath + s3FileName
//
//                let cutomerImageUploadCompletionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock? = { (task, error) -> Void in
//                    if (error == nil) {
//                        log.info("User Image Upload - Success - \(String(describing: self.user?.frontFaceImgUrl))")
//                        self.model.customerReport?.customerFrontalFaceImgUrl = self.user?.frontFaceImgUrl
//
//                    } else {
//                        log.info("User Image Upload - Failed with error - \(String(describing: error))")
//
//                    }
//                }
//
//                AWSUploadHelper().uploadFile(fileURL: NSURL(fileURLWithPath: frontFaceFilePath!), contentType: "", bucketName: EndPoints().s3BucketNameForUserImageUpload, fileS3UploadKeyName: s3FileName, completionHandler: cutomerImageUploadCompletionHandler, progressBlock: nil)
            }
            
        }
    }
    
    var isReadyForCustomerDetailsUpload = false {
        didSet {
            if isReadyForCustomerDetailsUpload {
                
                if self.user?.userType == .model {
                    self.model.customer?.imgUrl = self.user?.frontFaceImgUrl
                    
                    DispatchQueue.global(qos: .background).async {
                        CustomerHelper().updateCustomerDetails(completionHandler: { (error) -> () in
                            if error != nil {
                                log.error("Customer Details update - Failed with error: \(String(describing: error))")
                                self.isReadyForCustomerDetailsUpload = false
                            } else {
                                log.info("Customer Details updated - Successfully")
                            }
                        })
                    }
                    
                } else {
                    self.model.customer?.imgUrl = self.user?.frontFaceImgUrl
                    
                    DispatchQueue.global(qos: .background).async {
                        CustomerHelper().updateCustomerDetails(completionHandler: { (error) -> () in
                            if error != nil {
                                log.error("Customer Details update - Failed with error: \(String(describing: error))")
                                self.isReadyForCustomerDetailsUpload = false
                            } else {
                                log.info("Customer Details updated - Successfully")
                            }
                        })
                    }
                }
            }
        }
    }

    
    // MARK: - Init functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addCategoryHeaderData()
        self.getCategoryItemsData()
        
        self.categoryTableView.separatorStyle = .none
        self.inventoryTableView.separatorStyle = .none
                
        //Disable Clear button
        clearAllFiltersButton.isEnabled = false
        
        //Filter Tag List
        filterTagListView.alignment = .center
        filterTagListView.textFont = UIFont(name: "SFUIText-Regular", size: 14)!
        filterTagListView.delegate = self
        
        //Configure 3D in 2D
        imageScrollView.contentOffset = CGPoint(x: CGFloat(currentDisplayFrame) * imageScrollView.bounds.width, y: 0)
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture))
        longPressGestureRecognizer.minimumPressDuration = 0.5
        self.inventoryTableView.addGestureRecognizer(longPressGestureRecognizer)
        
        //Configure tryon3D button
        tryon3DButton.titleLabel?.minimumScaleFactor = 0.5
        tryon3DButton.titleLabel?.numberOfLines = 1
        tryon3DButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        //Configure for 3D in 2D
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action:  #selector(handlePanGesture))
        imageScrollHandlerView.addGestureRecognizer(panGestureRecognizer)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        imageScrollHandlerView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.inventoryTableView.reloadData()
        
        //Update Button text
        if let frame = self.selectedFrame {
            let userLiked = UserLiked(frame: frame)
            if tryon3D.isUserLiked(userLiked: userLiked) {
                setTryon3DButtonText(isLiked: true)
            } else {
                setTryon3DButtonText(isLiked: false)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        Appsee.startScreen("Shop")
        
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        //TODO: Handle this
        log.error("MEMORY WARNING in ShopController")
        filterInventory(resetPage: true)
    }

    
    // MARK: - Select First functions
    
    func selectFirstCategory() {
        clearAllFilters(shouldGetInventoryFrames: true)
        
        let indexPath = IndexPath(row: 0, section: 0);
        self.categoryTableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.none)
        tableView(self.categoryTableView, didSelectRowAt: indexPath)
    }
    
    func selectFirstInventory() {
        let indexPath = IndexPath(row: 0, section: 0);
        self.inventoryTableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.none)
        tableView(self.inventoryTableView, didSelectRowAt: indexPath)
    }
    
    
    // MARK: Product Details Floating
    
    func handleLongPressGesture(gestureReconizer: UILongPressGestureRecognizer) {
        switch gestureReconizer.state {
        case .began:
            let longPressPoint = gestureReconizer.location(in: self.inventoryTableView)
            if let indexPath = self.inventoryTableView.indexPathForRow(at: longPressPoint) {
                let frame = inventoryFrames[indexPath.row]
                
                //Added -1 to display the border
                blurEffectView.frame = CGRect(x: 0, y: 0, width: view.bounds.width - self.inventoryTableView.width - 1, height: view.bounds.height)
                blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                blurEffectView.alpha = 0
                view.addSubview(blurEffectView)
                
                tableView(self.inventoryTableView, didSelectRowAt: indexPath)
                self.addChildViewController(productDetailsFloatingController!)
                inventoryBigView.addSubview((productDetailsFloatingController?.view)!)
                view.bringSubview(toFront: inventoryBigView)
                inventoryBigView.clipsToBounds = true
                constrainViewEqual(holderView: inventoryBigView, view: (productDetailsFloatingController?.view)!)
                productDetailsFloatingController?.frame = frame
                productDetailsFloatingController?.updateProductDetails()
                
                //Display View
                inventoryBigView.alpha = 0
                inventoryBigView.isHidden = false
                UIView.animate(withDuration: 0.2, animations: {
                    self.inventoryBigView.alpha = 1
                    self.blurEffectView.alpha = 1
                }) { (finished) in
                    //Do nothing
                }
            }
            
        case .cancelled, .ended, .failed:
            //Hide View
            UIView.animate(withDuration: 0.2, animations: {
                self.inventoryBigView.alpha = 0
                self.blurEffectView.alpha = 0
            }) { (finished) in
                self.inventoryBigView.isHidden = true
                self.hideContentController(content: self.productDetailsFloatingController!)
                self.blurEffectView.removeFromSuperview()
            }
            
        default:
            break
        }
    }
    
    func hideContentController(content: UIViewController) {
        content.willMove(toParentViewController: nil)
        content.view.removeFromSuperview()
        content.removeFromParentViewController()
    }
    
    func constrainViewEqual(holderView: UIView, view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let pinTop = NSLayoutConstraint(item: view,
                                        attribute: .top,
                                        relatedBy: .equal,
                                        toItem: holderView,
                                        attribute: .top,
                                        multiplier: 1.0,
                                        constant: 0)
        
        let pinBottom = NSLayoutConstraint(item: view,
                                           attribute: .bottom,
                                           relatedBy: .equal,
                                           toItem: holderView,
                                           attribute: .bottom,
                                           multiplier: 1.0,
                                           constant: 0)
        
        let pinLeft = NSLayoutConstraint(item: view,
                                         attribute: .left,
                                         relatedBy: .equal,
                                         toItem: holderView,
                                         attribute: .left,
                                         multiplier: 1.0,
                                         constant: 0)
        
        let pinRight = NSLayoutConstraint(item: view,
                                          attribute: .right,
                                          relatedBy: .equal,
                                          toItem: holderView,
                                          attribute: .right,
                                          multiplier: 1.0,
                                          constant: 0)
        
        holderView.addConstraints([pinTop, pinBottom, pinLeft, pinRight])
    }
    
    
    // MARK: - Category Data
    
    func addCategoryHeaderData() {
        categoryHeaders.append(CategoryHeader(name: CategoryList.productType.rawValue, identifier: CategoryIdentifiers.productType, row: 0))
        categoryHeaders.append(CategoryHeader(name: CategoryList.frameType.rawValue, identifier: CategoryIdentifiers.frameType, row: 1))
        categoryHeaders.append(CategoryHeader(name: CategoryList.brand.rawValue, identifier: CategoryIdentifiers.brand, row: 2))
        categoryHeaders.append(CategoryHeader(name: CategoryList.gender.rawValue, identifier: CategoryIdentifiers.gender, row: 3))
        
        //TODO: These are not required for now
        //categoryHeaders.append(CategoryHeader(name: CategoryList.price.rawValue, identifier: CategoryIdentifiers.price, row: 4))
        //categoryHeaders.append(CategoryHeader(name: CategoryList.shape.rawValue, identifier: CategoryIdentifiers.shape, row: 2))
        //categoryHeaders.append(CategoryHeader(name: CategoryList.color.rawValue, identifier: CategoryIdentifiers.color, row: 6))
        //categoryHeaders.append(CategoryHeader(name: CategoryList.material.rawValue, identifier: CategoryIdentifiers.material, row: 7))
        
        //Add Headers to UI
        for header in categoryHeaders {
            menuItemArray.append(SwiftyAccordionCells.HeaderItem(value: header.name, category: header.identifier))
        }
    }
    
    func getCategoryItemsData() {
        startAnimating(loaderConfig().size, message: loaderConfig().message, type: loaderConfig().type)
        getCategoryProductType()
        getCategoryFrameType()
        getCategoryBrand()
        getCategoryGender()
        
        //TODO: These are not required for now
        //getCategoryPrice()
        //getCategoryShape()
        //getCategoryColor()
        //getCategoryMaterial()
    }
    
    func getCategoryProductType() {
        CategoryHelper().getCategoryProductType(completionHandler: { (dataArray) -> () in
            let header = CategoryHeader(name: CategoryList.productType.rawValue, identifier: CategoryIdentifiers.productType)
            var allItems: [CategoryItem] = []
            for data in dataArray {
                let item = CategoryItem(name: data.name, header: header, type: .textOnly, minValue: nil, maxValue: nil, iconUrl: nil, iconImage: nil, iconTintedImage: nil, iconTintedSelectedImage: nil, row: 0)
                allItems.append(item)
            }
            self.categoryItems[CategoryList.productType.rawValue] = allItems
            
            self.isProductTypeLoaded = true
            log.info("getCategoryProductType - Completed")
            self.checkCategoryDataLoad()
        })
    }
    
    func getCategoryBrand() {
        CategoryHelper().getCategoryBrand(completionHandler: { (dataArray) -> () in
            let header = CategoryHeader(name: CategoryList.brand.rawValue, identifier: CategoryIdentifiers.brand)
            var allItems: [CategoryItem] = []
            for data in dataArray {
                let item = CategoryItem(name: data.name, header: header, type: .textOnly, minValue: nil, maxValue: nil, iconUrl: data.iconUrl, iconImage: nil, iconTintedImage: nil, iconTintedSelectedImage: nil, row: 0)
                allItems.append(item)
            }
            self.categoryItems[CategoryList.brand.rawValue] = allItems
            
            self.isBrandLoaded = true
            log.info("getCategoryBrand - Completed")
            self.checkCategoryDataLoad()
        })
    }
    
    func getCategoryShape() {
        CategoryHelper().getCategoryShape(completionHandler: { (dataArray) -> () in
            let header = CategoryHeader(name: CategoryList.shape.rawValue, identifier: CategoryIdentifiers.shape)
            var allItems: [CategoryItem] = []
            for data in dataArray {
                let item = CategoryItem(name: data.name, header: header, type: .textOnly, minValue: nil, maxValue: nil, iconUrl: data.iconUrl, iconImage: nil, iconTintedImage: nil, iconTintedSelectedImage: nil, row: 0)
                allItems.append(item)
            }
            self.categoryItems[CategoryList.shape.rawValue] = allItems
            
            self.isShapeLoaded = true
            log.info("getCategoryShape - Completed")
            self.checkCategoryDataLoad()
        })
    }
    
    func getCategoryFrameType() {
        CategoryHelper().getCategoryFrameType(completionHandler: { (dataArray) -> () in
            let header = CategoryHeader(name: CategoryList.frameType.rawValue, identifier: CategoryIdentifiers.frameType)
            var allItems: [CategoryItem] = []
            for data in dataArray {
                let item = CategoryItem(name: data.name, header: header, type: .textOnly, minValue: nil, maxValue: nil, iconUrl: nil, iconImage: nil, iconTintedImage: nil, iconTintedSelectedImage: nil, row: 0)
                allItems.append(item)
            }
            self.categoryItems[CategoryList.frameType.rawValue] = allItems

            self.isFrameTypeLoaded = true
            log.info("getCategoryFrameType - Completed")
            self.checkCategoryDataLoad()
        })
    }
    
    func getCategoryColor() {
        CategoryHelper().getCategoryColor(completionHandler: { (dataArray) -> () in
            let header = CategoryHeader(name: CategoryList.color.rawValue, identifier: CategoryIdentifiers.color)
            var allItems: [CategoryItem] = []
            for data in dataArray {
                let item = CategoryItem(name: data.name, header: header, type: .textOnly, minValue: nil, maxValue: nil, iconUrl: nil, iconImage: nil, iconTintedImage: nil, iconTintedSelectedImage: nil, row: 0)
                allItems.append(item)
            }
            self.categoryItems[CategoryList.color.rawValue] = allItems
            
            self.isColorLoaded = true
            log.info("getCategoryColor - Completed")
            self.checkCategoryDataLoad()
        })
    }
    
    func getCategoryMaterial() {
        CategoryHelper().getCategoryMaterial(completionHandler: { (dataArray) -> () in
            let header = CategoryHeader(name: CategoryList.material.rawValue, identifier: CategoryIdentifiers.material)
            var allItems: [CategoryItem] = []
            for data in dataArray {
                let item = CategoryItem(name: data.name, header: header, type: .textOnly, minValue: nil, maxValue: nil, iconUrl: nil, iconImage: nil, iconTintedImage: nil, iconTintedSelectedImage: nil, row: 0)
                allItems.append(item)
            }
            self.categoryItems[CategoryList.material.rawValue] = allItems
            
            self.isMaterialLoaded = true
            log.info("getCategoryMaterial - Completed")
            self.checkCategoryDataLoad()
        })
    }
    
    func getCategoryGender() {
        CategoryHelper().getCategoryGender(completionHandler: { (dataArray) -> () in
            let header = CategoryHeader(name: CategoryList.gender.rawValue, identifier: CategoryIdentifiers.gender)
            var allItems: [CategoryItem] = []
            for data in dataArray {
                let item = CategoryItem(name: data.name, header: header, type: .textOnly, minValue: nil, maxValue: nil, iconUrl: nil, iconImage: nil, iconTintedImage: nil, iconTintedSelectedImage: nil, row: 0)
                allItems.append(item)
            }
            self.categoryItems[CategoryList.gender.rawValue] = allItems
            
            self.isGenderLoaded = true
            log.info("getCategoryGender - Completed")
            self.checkCategoryDataLoad()
        })
    }
    
    func getCategoryPrice() {
        CategoryHelper().getCategoryPrice(completionHandler: { (dataArray) -> () in
            let header = CategoryHeader(name: CategoryList.price.rawValue, identifier: CategoryIdentifiers.price)
            var allItems: [CategoryItem] = []
            for data in dataArray {
                let item = CategoryItem(name: "Price", header: header, type: .range, minValue: data.minValue, maxValue: data.maxValue, iconUrl: nil, iconImage: nil, iconTintedImage: nil, iconTintedSelectedImage: nil, row: 0)
                allItems.append(item)
                self.allowedPriceRange.maxValue = data.maxValue
                self.allowedPriceRange.minValue = data.minValue
            }
            self.categoryItems[CategoryList.price.rawValue] = allItems
            
            self.isPriceLoaded = true
            log.info("getCategoryPrice - Completed")
            self.checkCategoryDataLoad()
        })
    }
    
    func checkCategoryDataLoad() {
        if isProductTypeLoaded && isBrandLoaded && isShapeLoaded && isFrameTypeLoaded && isColorLoaded && isMaterialLoaded && isGenderLoaded && isPriceLoaded {
            log.info("All Categories - Completed")
            self.stopAnimating()
            
            if isAllCategoryDataLoadedInUI == false {
                //Add Items to UI
                var index = 0
                var categoryCount = 0
                for category in CategoryList.allValues {
                    if let categoryIndex = self.menuItemArray.items.index(where: { $0.value == category.rawValue }) {
                        //Update Index of headers
                        self.categoryHeaders[categoryCount].row = index
                        categoryCount = categoryCount + 1
                        
                        if let items = self.categoryItems[category.rawValue] {
                            var itemCount = 0
                            for item in items {
                                self.menuItemArray.items.insert(SwiftyAccordionCells.Item(value: item.name, category: item.header.identifier), at: categoryIndex + 1)
                                
                                //Update Index of the items
                                index = index + 1
                                self.categoryItems[category.rawValue]?[itemCount].row = index
                                itemCount = itemCount + 1
                            }
                        }
                    }
                    index = index + 1
                }
                isAllCategoryDataLoadedInUI = true
            }
            
            self.categoryTableView.reloadData()
            self.selectFirstCategory()
        }
    }
    
    func categoryItem(atRow row:Int) -> CategoryItem? {
        for category in CategoryList.allValues {
            if let items = self.categoryItems[category.rawValue] {
                for item in items {
                    if item.row == row {
                        return item
                    }
                }
            }
        }
        
        return nil
    }
    
    func categoryHeader(atRow row:Int) -> CategoryHeader? {
        for category in self.categoryHeaders {
            if category.row == row {
                return category
            }
        }
        
        return nil
    }
    
    
    // MARK: - Filter Inventory
    
    func filterInventory(resetPage: Bool) {
        if resetPage {
            //Update Selected Inventory details
            self.selectedInventoryName.text = ""
            self.selectedInventoryDetail.text = ""
            
            nextInventoryPageNumber = 1
            isAllInventoryDataLoaded = false
            self.inventoryTableViewFooterAcitivityIndicator.startAnimating()
            self.inventoryTableViewFooterAcitivityIndicator.isHidden = false
            self.inventoryTableViewFooterLabel.text = ""
            self.inventoryTableViewHeaderLabel.text = ""
            
            self.operationQueueFor3D.cancelAllOperations()
            
            self.inventoryFrames.removeAll()
            self.user?.selectedFrameId = nil
            self.user?.selectedFrameUuid = nil
            self.inventoryTableView.reloadData()
            self.glassImgView.image = nil
            
            self.removeAll3DImages()
            self.imageScrollHandlerView.isUserInteractionEnabled = false
            self.tryonLogoImageView.isHidden = true
            
            self.getUser2DRenderInProgress()
        }
        
        //As of now, only price is a range fitler
        var rangeFilters: [String : Dictionary<String, Double?>] = [:]
        if (self.selectedPriceRange != nil) {
            rangeFilters = [CategoryIdentifiers.price.rawValue : ["from": self.selectedPriceRange?.minValue, "to": self.selectedPriceRange?.maxValue]]
        }
        
//        InventoryFrameHelper().filterInventory(allFilters: self.allFilters, rangeFilters: rangeFilters, page: self.nextInventoryPageNumber, completionHandler: {  [requestFilters = self.allFilters, requestRangeFilters = rangeFilters] (dataArray, page, inventoryCount, error) -> () in
//            self.inventoryFrames.append(dataArray)
//        }
        
        if self.nextInventoryPageNumber > 1 {
            log.info("All inventory data fetched")
            self.isAllInventoryDataLoaded = true
            self.inventoryTableViewFooterAcitivityIndicator.isHidden = true
            
            if self.inventoryFrames.count == 0 {
                self.inventoryTableViewFooterLabel.text = self.noGlassesFoundText
            } else {
                self.inventoryTableViewFooterLabel.text = self.allGlassesLoadedText
            }
            
            return
        }
        InventoryFrameHelper().filterInventory(allFilters: self.allFilters, rangeFilters: rangeFilters, page: self.nextInventoryPageNumber, completionHandler: { [requestFilters = self.allFilters, requestRangeFilters = rangeFilters] (frames, page, inventoryCount, error) in
            if let error = error {
                self.getInventoryFailed(withError: error)
                
            } else {
                var isSameFilter = true
                var i = 0
                
                for requestFilter in requestFilters {
                    if let currentFilter = self.allFilters[requestFilter.key] {
                        if currentFilter != requestFilter.value {
                            isSameFilter = false
                            i = i + 1
                            break
                        }
                    } else {
                        isSameFilter = false
                        i = i + 1
                        break
                    }
                    i = i + 1
                }
                if i == 0 {
                    //No filters were present in requestFilters
                    if self.allFilters.count != 0 {
                        //But currently there are some filters
                        isSameFilter = false
                    }
                }
                
                //If IsSameFilter, check for the remaining type of filters
                if isSameFilter {
                    i = 0
                    //Check for Price Filter
                    for requestFilter in requestRangeFilters {
                        if let priceRange = self.selectedPriceRange {
                            if (priceRange.minValue != (requestFilter.value["from"])!) || (priceRange.maxValue != (requestFilter.value["to"])!) {
                                isSameFilter = false
                                i = i + 1
                                break
                            }
                        } else {
                            isSameFilter = false
                            i = i + 1
                            break
                        }
                        i = i + 1
                    }
                }
                if i == 0 {
                    //No filters were present in requestRangeFilters
                    if (self.selectedPriceRange != nil) {
                        //But currently there are some filters
                        isSameFilter = false
                    }
                }
                
                //Display results only if the same filter is still applied
                if isSameFilter {
                    if resetPage {
                        self.inventoryFrames.removeAll()
                        self.inventoryTableView.reloadData()
                    }
                    
                    if frames.count > 0 {
                        if self.nextInventoryPageNumber == page {
                            //Data for the requested page number
                            self.isAllInventoryDataLoaded = false
                            self.nextInventoryPageNumber += 1
                            
                            for frame in frames {
                                self.inventoryFrames.append(frame)
                            }
                            self.inventoryTableView.reloadData()
                        } else {
                            //This data is currently not required
                            log.warning("Duplicate page requested in inventory for page: \(page)")
                        }
                    } else {
                        log.info("All inventory data fetched")
                        self.isAllInventoryDataLoaded = true
                        self.inventoryTableViewFooterAcitivityIndicator.isHidden = true
                        
                        if self.inventoryFrames.count == 0 {
                            self.inventoryTableViewFooterLabel.text = self.noGlassesFoundText
                        } else {
                            self.inventoryTableViewFooterLabel.text = self.allGlassesLoadedText
                        }
                    }
                    
                    //Update Total Inventory Count
                    if requestFilters.count == 0 && requestRangeFilters.count == 0 {
                        self.totalInventoryCount = inventoryCount
                    }
                    
                    if inventoryCount >= 0 && self.totalInventoryCount > 0 {
                        //self.inventoryTableViewHeaderLabel.text =  String(inventoryCount) + " / " + String(self.totalInventoryCount)
                    }
                }
            }
            
            //Select First Inventory
            if resetPage {
                if self.inventoryFrames.count > 0 {
                    self.selectFirstInventory()
                } else {
                    self.getUser2DRenderFailed()
                }
            }
        })
        
        /*
         InventoryFilterHelper().filterInventory(allFilters: self.allFilters, rangeFilters: rangeFilters, page: self.nextInventoryPageNumber, completionHandler: {  [requestFilters = self.allFilters, requestRangeFilters = rangeFilters] (dataArray, page, inventoryCount, error) -> () in
         if let error = error {
         self.getInventoryFailed(withError: error)
         
         } else {
         var isSameFilter = true
         var i = 0
         
         for requestFilter in requestFilters {
         if let currentFilter = self.allFilters[requestFilter.key] {
         if currentFilter != requestFilter.value {
         isSameFilter = false
         i = i + 1
         break
         }
         } else {
         isSameFilter = false
         i = i + 1
         break
         }
         i = i + 1
         }
         if i == 0 {
         //No filters were present in requestFilters
         if self.allFilters.count != 0 {
         //But currently there are some filters
         isSameFilter = false
         }
         }
         
         //If IsSameFilter, check for the remaining type of filters
         if isSameFilter {
         i = 0
         //Check for Price Filter
         for requestFilter in requestRangeFilters {
         if let priceRange = self.selectedPriceRange {
         if (priceRange.minValue != (requestFilter.value["from"])!) || (priceRange.maxValue != (requestFilter.value["to"])!) {
         isSameFilter = false
         i = i + 1
         break
         }
         } else {
         isSameFilter = false
         i = i + 1
         break
         }
         i = i + 1
         }
         }
         if i == 0 {
         //No filters were present in requestRangeFilters
         if (self.selectedPriceRange != nil) {
         //But currently there are some filters
         isSameFilter = false
         }
         }
         
         //Display results only if the same filter is still applied
         if isSameFilter {
         if resetPage {
         self.inventories.removeAll()
         self.inventoryTableView.reloadData()
         }
         
         if dataArray.count > 0 {
         if self.nextInventoryPageNumber == page {
         //Data for the requested page number
         self.isAllInventoryDataLoaded = false
         self.nextInventoryPageNumber += 1
         
         for data in dataArray {
         self.inventories.append(data)
         }
         self.inventoryTableView.reloadData()
         } else {
         //This data is currently not required
         log.warning("Duplicate page requested in inventory for page: \(page)")
         }
         } else {
         log.info("All inventory data fetched")
         self.isAllInventoryDataLoaded = true
         self.inventoryTableViewFooterAcitivityIndicator.isHidden = true
         
         if self.inventories.count == 0 {
         self.inventoryTableViewFooterLabel.text = self.noGlassesFoundText
         } else {
         self.inventoryTableViewFooterLabel.text = self.allGlassesLoadedText
         }
         }
         
         //Update Total Inventory Count
         if requestFilters.count == 0 && requestRangeFilters.count == 0 {
         self.totalInventoryCount = inventoryCount
         }
         
         if inventoryCount >= 0 && self.totalInventoryCount > 0 {
         self.inventoryTableViewHeaderLabel.text =  String(inventoryCount) + " / " + String(self.totalInventoryCount)
         }
         }
         }
         
         //Select First Inventory
         if resetPage {
         if self.inventories.count > 0 {
         self.selectFirstInventory()
         } else {
         self.getUser2DRenderFailed()
         }
         }
         })*/
    }
    
    func getInventoryFailed(withError error: NSError) {
        log.error(error)
        self.inventoryTableViewFooterAcitivityIndicator.isHidden = true
        self.inventoryTableViewFooterLabel.text = self.errorInFetchingGlassesText
        self.showSomethingWentWrongScreen(withMessage: error.localizedDescription)
    }
    
    func tryAgainDidTap() {
        self.isAllInventoryDataLoaded = false
        self.nextInventoryPageNumber = 1
        filterInventory(resetPage: true)
    }

    
    // MARK: - Model Inventory Prerender
    
    func getUser2DRender(forFrameId frameId: Int, frameNumber: Int) {
        //Add Analytics
//        model.customerReport?.addRender2DToCustomerReport(forLookzId: lookzId)
        let frame = self.selectedFrame

        if let img = self.model.imageFromCache(withIdentifier: String(frameId) + "-2D-" + String(frameNumber)) {
            if self.user?.selectedFrameId == frameId {
                //Image already available in cache
                self.glassImgView.image = img
                
                var isLiked = false
                let userLiked = UserLiked(frame: frame!)
                if self.tryon3D.isUserLiked(userLiked: userLiked) {
                    //Already Liked.
                    isLiked = true
                }
                
                self.getUser2DRenderSuccess(isLiked: isLiked)
            }
        } else {
            let yprValue = self.user?.yprValues?[frameNumber]
            let sellionPoint = self.user?.sellionPoints?[frameNumber]
            
            let glassUrlPath = (self.user?.glassUrl)! + (frame?.uuid)!
            let jsonUrlPath = (self.user?.jsonUrl)! + (frame?.uuid)!
            
            let glassUrl = glassUrlPath + "/Images/" + yprValue! + ".png"
            let jsonUrl = jsonUrlPath + "/jsons/" + yprValue! + ".json"
            let glassImageForScalingUrl = glassUrlPath + "/Images/0_0_0.png"
            
            UserRenderHelper().getGlassCenterJson(jsonUrl: jsonUrl, frameUuid: (self.user?.selectedFrameUuid)!, glassImageForScalingUrl: glassImageForScalingUrl, completionHandler: { (glassCenter, glassSizeForScaling, error) in
                if error == nil {
                    
                    UserRenderHelper().createGlassImage(forUser: self.user, glassUrl: glassUrl, glassSizeForScaling: glassSizeForScaling, glassCenter: glassCenter, sellionPoint: sellionPoint, faceSize: self.user?.serverFaceSize, withUserImage: nil, completionHandler: { (glassImage, error) in
                        
                        if error == nil {
                            //Check whether Glass Image is created or not
                            if let glassImage = glassImage {
                                //Update the glass
                                if self.user?.selectedFrameId == frameId {
                                    self.glassImgView.image = glassImage
                                    
                                    //Update Analytics
//                                    self.model.customerReport?.updateRender2DToCustomerReport(forLookzId: lookzId, withEndTime: Date())
                                    
                                    DispatchQueue.global(qos: .userInteractive).async {
                                        var isLiked = false
                                        let userLiked = UserLiked(frame: frame!)
                                        if self.tryon3D.isUserLiked(userLiked: userLiked) {
                                            //Already Liked.
                                            isLiked = true
                                        }
                                        
                                        DispatchQueue.main.async {
                                            if self.user?.selectedFrameId == frame?.id {
                                                self.getUser2DRenderSuccess(isLiked: isLiked)
                                            }
                                        }
                                        
                                        self.model.addToCache(glassImage, withIdentifier: String(describing: frame?.id) + "-2D-" + String(frameNumber))
                                    }
                                }
                            } else {
                                //Glass Image is not created
                                DispatchQueue.main.async {
                                    //Error in downloading the glass image
                                    self.glassImgView.image = nil
                                    self.getUser2DRenderFailed()
                                }
                                
                                log.error("Inventory - User Render 2D - Error in creating glass image from \(glassUrl)")
                            }
                        } else {
                            DispatchQueue.main.async {
                                //Error in downloading the glass image
                                self.glassImgView.image = nil
                                self.getUser2DRenderFailed()
                            }
                            
                            log.error("Inventory - User Render 2D - Error in downloading image from \(glassUrl)")
                        }
                    })
                } else {
                    DispatchQueue.main.async {
                        //Error in getting Glass Center json
                        self.glassImgView.image = nil
                        self.getUser2DRenderFailed()
                    }
                    
                    log.error("Inventory - User Render 2D - Error in getting glass center json from \(jsonUrl)")
                }
            })
        }
    }
    
    func getUser2DRenderInProgress() {
        self.tryon3DLoadingIndicator.startAnimating()
        self.tryon3DLoadingIndicator.isHidden = false
        self.tryon3DButton.isUserInteractionEnabled = false
        self.tryon3DButton.backgroundColor = UIColor.mainButtonDisableBackgroundColor
        
        self.shareUserImageButton.isUserInteractionEnabled = false
        if let image = UIImage(named: "UploadIconDisabled") {
            self.shareUserImageButton.setImage(image, for: .normal)
        }
        self.shareUserImageLabel.textColor = UIColor.mainButtonDisableBackgroundColor
        
        self.buyImageButton.isUserInteractionEnabled = false
        if let image = UIImage(named: "BuyIconDisabled") {
            self.buyImageButton.setImage(image, for: .normal)
        }
        self.buyImageLabel.textColor = UIColor.mainButtonDisableBackgroundColor
    }
    
    func getUser2DRenderSuccess(isLiked: Bool) {
        self.tryon3DLoadingIndicator.stopAnimating()
        self.tryon3DLoadingIndicator.isHidden = true
        self.tryon3DButton.isUserInteractionEnabled = true
        self.tryon3DButton.backgroundColor = UIColor.primaryColor
        self.setTryon3DButtonText(isLiked: isLiked)
        
        self.shareUserImageButton.isUserInteractionEnabled = true
        if let image = UIImage(named: "UploadIcon") {
            self.shareUserImageButton.setImage(image, for: .normal)
        }
        self.shareUserImageLabel.textColor = UIColor.primaryColor
        
        self.buyImageButton.isUserInteractionEnabled = true
        if let image = UIImage(named: "BuyIcon") {
            self.buyImageButton.setImage(image, for: .normal)
        }
        self.buyImageLabel.textColor = UIColor.primaryColor
    }
    
    func getUser2DRenderFailed() {
        self.tryon3DLoadingIndicator.stopAnimating()
        self.tryon3DLoadingIndicator.isHidden = true
        self.tryon3DButton.isUserInteractionEnabled = false
        self.tryon3DButton.backgroundColor = UIColor.mainButtonDisableBackgroundColor
        
        self.shareUserImageButton.isUserInteractionEnabled = false
        if let image = UIImage(named: "UploadIconDisabled") {
            self.shareUserImageButton.setImage(image, for: .normal)
        }
        self.shareUserImageLabel.textColor = UIColor.mainButtonDisableBackgroundColor
        
        self.buyImageButton.isUserInteractionEnabled = false
        if let image = UIImage(named: "BuyIconDisabled") {
            self.buyImageButton.setImage(image, for: .normal)
        }
        self.buyImageLabel.textColor = UIColor.mainButtonDisableBackgroundColor
    }
    
    func getUser3DRenderFailed() {
        self.tryon3DLoadingIndicator.stopAnimating()
        self.tryon3DLoadingIndicator.isHidden = true
        self.imageScrollHandlerView.isUserInteractionEnabled = false
    }
    
    func setTryon3DButtonText(isLiked: Bool) {
        if isLiked {
            tryon3DButton.setTitle("Remove from Shortlist", for: .normal)
        } else {
            tryon3DButton.setTitle("Shortlist", for: .normal)
        }
    }
}


// MARK: - TableView functions

extension ShopController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.categoryTableView {
            return menuItemArray.items.count
        } else if tableView == self.inventoryTableView {
            return inventoryFrames.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.categoryTableView {
            let menuItem = menuItemArray.items[(indexPath as NSIndexPath).row]
            if menuItem is SwiftyAccordionCells.HeaderItem {
                let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! FilterCategoryCell
                
                let header = categoryHeader(atRow: (indexPath as NSIndexPath).row)
                cell.categoryName.text = header?.name
                cell.selectionStyle = .none
                
                if (header?.isSelected)! {
                    updateSelectedHeaderCell(cell: cell)
                } else {
                    updateDeselectedHeaderCell(cell: cell)
                }
                
                return cell
            } else {
                var cell: FilterCategorySubTypeCell?
                
                let item = categoryItem(atRow: (indexPath as NSIndexPath).row)
                var cellIdentifier = "categorySubTypeCell"
                if let type = item?.type {
                    switch type {
                    case .imageOnly:
                        cellIdentifier = "categorySubTypeImageCell"
                        
                    case .textOnly:
                        cellIdentifier = "categorySubTypeTextCell"
                        
                    case .textAndImage:
                        cellIdentifier = "categorySubTypeCell"
                        
                    case .range:
                        cellIdentifier = "categorySubTypeRangeCell"
                    }
                }

                cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? FilterCategorySubTypeCell
                cell?.selectionStyle = .none
                
                if let type = item?.type {
                    if type == .textOnly || type == .textAndImage {
                        //Handle text
                        cell?.categorySubTypeName.text = item?.name.lowercased().capitalizingFirstLetter()
                        
                        if let label = cell?.categorySubTypeName {
                            if (item?.isSelected)! {
                                label.textColor = UIColor.filterSelectedTextColor
                            } else {
                                label.textColor = UIColor.filterTextColor
                            }
                        }
                    }
                    
                    if type == .imageOnly || type == .textAndImage {
                        //Handle Image
                        if item?.iconTintedImage == nil {
                            //Image needs to be downloaded
                            if let iconUrl = item?.iconUrl {
                                if iconUrl != "" {
                                    let urlRequest = URLRequest(url: URL(string: iconUrl)!)
                                    imageDownloader.download(urlRequest) { response in
                                        if let img = response.result.value {
                                            item?.iconTintedImage = img.tint(with: UIColor.filterImageTintColor)
                                            item?.iconTintedSelectedImage = img.tint(with: UIColor.primaryColor)
                                            
                                            if (item?.isSelected)! {
                                                cell?.categorySubTypeImage.image = item?.iconTintedSelectedImage
                                            } else {
                                                cell?.categorySubTypeImage.image = item?.iconTintedImage
                                            }
                                        }
                                    }
                                }
                            }
                        } else {
                            if (item?.isSelected)! {
                                cell?.categorySubTypeImage.image = item?.iconTintedSelectedImage
                            } else {
                                cell?.categorySubTypeImage.image = item?.iconTintedImage
                            }
                        }
                    }
                    
                    if type == .range {
                        cell?.sliderView?.delegate = self
                        
                        if selectedPriceRange != nil {
                            //Filtered
                            cell?.addRangeSlider(withMinValue: (selectedPriceRange?.minValue)!, maxValue: (selectedPriceRange?.maxValue)!)
                        } else {
                            if allowedPriceRange.minValue == 0 {
                                allowedPriceRange.minValue = minAllowedPrice
                            }
                            if allowedPriceRange.maxValue == 0 {
                                allowedPriceRange.maxValue = maxAllowedPrice
                            }
                                
                            cell?.addRangeSlider(withMinValue: allowedPriceRange.minValue, maxValue: allowedPriceRange.maxValue)
                        }
                        
                        
                    }
                }
                
                return cell!
            }
        } else if tableView == self.inventoryTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "inventoryCell", for: indexPath) as! FilterInventoryCell
            let frame = inventoryFrames[indexPath.row]
            
            cell.inventoryName.text = frame.brand?.name.lowercased().capitalizingFirstLetter() ?? ""
            cell.inventorySubName.text = frame.productName?.lowercased().capitalizingFirstLetter()
            if let size = frame.size {
                if let letter = size.lowercased().capitalizingFirstLetter().characters.first {
                    cell.sizeLabel.text = String(letter)
                }
            }
            
            if let thumbNailImageUrl = frame.thumbNailImageUrl {
                if thumbNailImageUrl != "" {                    
                    cell.inventoryImage.af_setImage(withURL: URL(string: thumbNailImageUrl)!)
                } else {
                    log.warning("Image not found for Inventory: \(String(describing: frame.id))")
                }
            }
            
            if (tryon3D.isUserLiked(frameId: frame.id)) {
                cell.inventoryLikeButton.isHidden = false
                cell.inventoryLikeButton.isSelected = true
            } else {
                cell.inventoryLikeButton.isHidden = true
            }
            
            cell.selectionStyle = .none
            
            if frame.isSelected {
                updateSelectedInventoryCell(cell: cell)
            } else {
                updateDeselectedInventoryCell(cell: cell)
            }
            
            //Fetch next page
            if indexPath.row == inventoryFrames.count - 1 {
                //Fetch next page
                if !isAllInventoryDataLoaded {
                    filterInventory(resetPage: false)
                }
            }
            
            return cell
        }
        
        return UITableViewCell.init()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.categoryTableView {
            let item = menuItemArray.items[(indexPath as NSIndexPath).row]
            
            if item is SwiftyAccordionCells.HeaderItem {
                return 60
            } else if (item.isHidden) {
                return 0
            } else {
                switch item.category {
                case .brand:
                    //Display only image - return 90
                    //Display only Text
                    return 50
                    
                case .shape:
                    //Display both image and text - return 110
                    //Display only Text
                    return 50
                    
                case .productType, .frameType, .color, .material, .gender:
                    //Display only Text
                    return 50
                    
                case .price:
                    //Display Price Range
                    return 100
                }
            }
        } else if tableView == self.inventoryTableView {
            return 170
        }
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if tableView == self.categoryTableView {
            let menuItem = menuItemArray.items[(indexPath as NSIndexPath).row]
            if !(menuItem is SwiftyAccordionCells.HeaderItem) {
                let item = categoryItem(atRow: (indexPath as NSIndexPath).row)
                if item?.type == .range {
                    return nil
                }
            }
        }
        
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.categoryTableView {
            
            let menuItem = menuItemArray.items[(indexPath as NSIndexPath).row]
            if menuItem is SwiftyAccordionCells.HeaderItem {
                let header = categoryHeader(atRow: (indexPath as NSIndexPath).row)
                
                if (header?.isSelected)! {
                    menuItemArray.collapse((header?.row)!)
                    if let cell = self.categoryTableView.cellForRow(at: indexPath) as! FilterCategoryCell? {
                        updateDeselectedHeaderCell(cell: cell)
                    }
                } else {
                    menuItemArray.expand((header?.row)!)
                    if let cell = self.categoryTableView.cellForRow(at: indexPath) as! FilterCategoryCell? {
                        updateSelectedHeaderCell(cell: cell)
                    }
                    
                    //Collapse previously selected headers, if any
                    for otherHeader in categoryHeaders {
                        if otherHeader.isSelected {
                            menuItemArray.collapse(otherHeader.row)
                            otherHeader.isSelected = false
                            
                            if let cell = self.categoryTableView.cellForRow(at: IndexPath(row: otherHeader.row, section: 0)) as! FilterCategoryCell? {
                                updateDeselectedHeaderCell(cell: cell)
                            }
                        }
                    }
                }
                header?.isSelected = !(header?.isSelected)!
                
                categoryTableView.beginUpdates()
                categoryTableView.endUpdates()
            
            } else {
                let item = categoryItem(atRow: (indexPath as NSIndexPath).row)
                
                if (item?.isSelected)! {
                    //Remove selection
                    removeFilter(category: (item?.header.identifier)!, value: (item?.name)!)
                    removeFilterTag(category: (item?.header.identifier)!, filterName: (item?.name)!)
                    
                } else {
                    addFilter(category: (item?.header.identifier)!, value: (item?.name)!)
                    addFilterTag(category: (item?.header.identifier)!, filterName: (item?.name)!)
                }
                item?.isSelected = !(item?.isSelected)!
                
                categoryTableView.reloadData()
            }

        } else if tableView == self.inventoryTableView {
            //Update previous cell
            if (self.selectedFrame != nil) {
                self.selectedFrame?.isSelected = false
            }
            
            //Update current cell
            let frame = inventoryFrames[indexPath.row]
            frame.isSelected = true
            self.selectedFrame = frame
            self.user?.selectedFrameId = frame.id
            self.user?.selectedFrameUuid = frame.uuid
            
            //Update UI
            let isLiked = tryon3D.isUserLiked(frameId: frame.id)
            setTryon3DButtonText(isLiked: isLiked)
            
            //Update 3D
            self.tryonLogoImageView.isHidden = true
            removeAll3DImages()
            
            self.imageScrollView.isHidden = true

            //Since the image order is reversed, reversing the frontFrameIndex
            let totalIndexNumber = (self.user?.frameNumbers?.count)! - 1
            let reversedIndex = totalIndexNumber - self.currentDisplayFrame
            var frameNumber: Int = 0
            
            if self.is3DUserImageDidScroll {
                frameNumber = reversedIndex
                
                let identifier = "user-" + String((self.user?.frameNumbers?[reversedIndex])!)
                self.frontImgView.image = self.model.image(withIdentifier: identifier, in: "jpg")
                
            } else {
                frameNumber = (self.user?.frontFrameIndex)!
            }
            getUser2DRender(forFrameId: (self.user?.selectedFrameId)!, frameNumber: frameNumber)
            
            //Update Selected Inventory details
            selectedInventoryName.text = frame.productName?.lowercased().capitalizingFirstLetter()
            let appendString = "  |  "
            
            var detailText = frame.brand?.name.lowercased().capitalizingFirstLetter()
            if let color = frame.frameColor {
                detailText = detailText! + appendString + color.name.lowercased().capitalizingFirstLetter()
            }
            if let size = frame.size {
                detailText = detailText! + appendString + size.lowercased().capitalizingFirstLetter()
            }
//            if let price = frame.price {
//                detailText = detailText! + appendString + "₹" + String(price)
//            }
            selectedInventoryDetail.text = detailText
            
            DispatchQueue.global(qos: .userInitiated).sync {
                self.tryon3D.getRender3D(forUser: self.user!, shouldRenderWithUserImage: false, frame: frame, inDirectory: .cachesDirectory, completionHandler: { (render3D) in
                    if render3D?.status == .isCompleted {
                        //Display 3D images
                        self.displayImages(forFrame: frame, withRender3D: render3D!)
                    } else {
                        //Error in rendering 3D images
                        log.error("Error in render 3D from Shop screen for \(String(describing: frame.id))")
                        self.getUser3DRenderFailed()
                    }
                })
            }
            
            self.inventoryTableView.reloadData()
        }
    }
    
    
    // MARK: - Display 3D in 2D
    
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
        is3DUserImageDidScroll = true
        
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
    
    func displayImages(forFrame frame: InventoryFrame, withRender3D render3D: Render3D) {
        if render3D.status == Render3DStatus.isCompleted {
            //Update UI, if it is still selected
            if selectedFrame?.id == frame.id {
                let blockOperation: BlockOperation = BlockOperation.init(
                    block: {
                        log.info("displayImages(forInventory: ) - Started")
                        var imageIdentifiers: [String] = []
                        var userImageIdentifiers: [String] = []
                        for frameNumber in (self.user?.frameNumbers)! {
                            imageIdentifiers.append("\(frame.id)-\(frameNumber)")
                            userImageIdentifiers.append("user-\(frameNumber)")
                        }
                        
                        var index = 0
                        if !(self.is3DUserImageDidScroll) {
                            //Since the image order is reversed, reversing the frontFrameIndex
                            let totalIndexNumber = (self.user?.frameNumbers?.count)! - 1
                            index = totalIndexNumber - (self.user?.frontFrameIndex)!
                        } else {
                            index = self.currentDisplayFrame
                        }
                        
                        if !self.isUserImagesAddedFor3D {
                            self.addUserImages(withIdentifiers: userImageIdentifiers, scrollTo: index)
                            self.isUserImagesAddedFor3D = true
                        }
                        self.addImages(forFrame: frame, withIdentifiers: imageIdentifiers, scrollTo: index)
                })
                
                //Add Operation to Queue
                if self.operationQueueFor3D.operationCount > 0 {
                    blockOperation.queuePriority = .high
                } else {
                    blockOperation.queuePriority = .normal
                }
                self.operationQueueFor3D.addOperation(blockOperation)
            }
        } else {
            log.warning("Cannot Display 3D from Shop screen for \(String(describing: frame.id))")
        }
    }
    
    func removeAll3DImages() {
        log.info("removeAll3DImages() - Started")
        for view in imageScrollView.subviews {
            if view.tag > 0 {
                if view is UIImageView {
                    let imgView = view as! UIImageView
                    imgView.image = nil
                }
                view.removeFromSuperview()
            }
        }
        log.info("removeAll3DImages() - Completed")
    }
    
    func removeAllUserImages() {
        log.info("removeAllUserImages() - Started")
        for view in imageScrollView.subviews {
            view.removeFromSuperview()
        }
        log.info("removeAllUserImages() - Completed")
    }
    
    func addUserImages(withIdentifiers identifiers: [String], scrollTo frame: Int) {
        numberOfFrames = identifiers.count
        imageScrollView.contentSize = CGSize(width: CGFloat(identifiers.count) * imageScrollView.bounds.width, height: imageScrollView.bounds.height)
        
        self.imageScrollView.isHidden = true
        
        var i: CGFloat = 0.0
        var counter: Int = 1
        
        for identifier in identifiers.reversed() {
            let tempImageView = UIImageView(frame: CGRect(x: i, y: 0, width: self.imageScrollView.bounds.width, height: self.imageScrollView.bounds.height))
            
            if let img = self.model.image(withIdentifier: identifier, in: "jpg") {
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
                    self.scrollToFrame(i: frame)
                }
            }
            
            i += self.imageScrollView.bounds.width
            counter += 1
        }
    }
    
    func addImages(forFrame frame: InventoryFrame, withIdentifiers identifiers: [String], scrollTo frameNumber: Int) {
        numberOfFrames = identifiers.count
        imageScrollView.contentSize = CGSize(width: CGFloat(identifiers.count) * imageScrollView.bounds.width, height: imageScrollView.bounds.height)
        
        imageScrollView.isHidden = true
        
        var i: CGFloat = 0.0
        var counter: Int = 1
        
        for identifier in identifiers.reversed() {
            let tempImageView = UIImageView(frame: CGRect(x: i, y: 0, width: self.imageScrollView.bounds.width, height: self.imageScrollView.bounds.height))
            
            if let img = self.model.imageFromCache(withIdentifier: identifier) {
                tempImageView.image = img
                tempImageView.tag = counter
            } else {
                log.error("Image not found for identifier: \(identifier)")
            }
            
            tempImageView.clipsToBounds = true
            tempImageView.contentMode = .scaleAspectFill
            tempImageView.layer.cornerRadius = 5
            tempImageView.layer.masksToBounds = true
            
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
            
            let sellionPoint = self.user?.sellionPoints![frameCount! - counter]
            let correctionFactorX = (UserRenderHelper.model.serverVideoSize.width - UserRenderHelper.model.displayImageSize.width) / 2
            let correctionFactorY = (UserRenderHelper.model.serverVideoSize.height - UserRenderHelper.model.displayImageSize.height) / 2
            let actualSellionPoint = CGPoint(x: (sellionPoint?.x)! - correctionFactorX, y: (sellionPoint?.y)! - correctionFactorY)
            
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
            
            DispatchQueue.main.sync { [a = counter] in
                if self.selectedFrame?.id == frame.id {
                    self.imageScrollView.addSubview(tempImageView)
                    
                    if a == identifiers.count {
                        //All images loaded
                        self.scrollToFrame(i: frameNumber)
                        self.imageScrollView.isHidden = false
                        self.imageScrollHandlerView.isUserInteractionEnabled = true
                        
                        //Remove 2D glass
                        self.glassImgView.image = nil
                        
                        self.tryonLogoImageView.alpha = 0
                        self.tryonLogoImageView.isHidden = false
                        UIView.animate(withDuration: 0.2, animations: {
                            self.tryonLogoImageView.alpha = 1
                        })
                    }
                }
            }
            
            i += self.imageScrollView.bounds.width
            counter += 1
        }
    }
    
    func scrollToFrame(i: Int) {
        DispatchQueue.main.async {
            self.currentDisplayFrame = i
            self.imageScrollView.contentOffset = CGPoint(x: CGFloat(self.currentDisplayFrame) * self.imageScrollView.bounds.width, y: 0)
        }
    }
    
    // MARK: - Filter functions
    
    func addFilter(category: CategoryIdentifiers, value: String) {
        //Add filter
        var filter = allFilters[category.rawValue]
        if filter != nil {
            filter?.append(value)
            allFilters[category.rawValue] = filter
        } else {
            allFilters[category.rawValue] = [value]
        }
        
        //Enable Clear button
        clearAllFiltersButton.isEnabled = true
        
        //Filter the inventory
        filterInventory(resetPage: true)
    }
    
    func addPriceFilter(category: CategoryIdentifiers, minValue: Double, maxValue: Double) {
        //Add price filter
//        selectedPriceRange = CategoryPrice(maxValue: maxValue, minValue: minValue)
        
        selectedPriceRange = CategoryPrice(value: [maxValue, minValue])
        
        //Enable Clear button
        clearAllFiltersButton.isEnabled = true
        
        //Filter the inventory
        filterInventory(resetPage: true)
    }
    
    func removeFilter(category: CategoryIdentifiers, value: String) {
        //Remove filter
        var filter = allFilters[category.rawValue]
        if filter != nil {
            if let index = filter?.index(of: value) {
                filter?.remove(at: index)
                if filter?.count == 0 {
                    allFilters.removeValue(forKey: category.rawValue)
                } else {
                    allFilters[category.rawValue] = filter
                }
            }
        }
        
        //Disable Clear button
        if (allFilters.count == 0) && (selectedPriceRange == nil) {
            clearAllFiltersButton.isEnabled = false
        }
        
        //Filter the inventory
        filterInventory(resetPage: true)
    }
    
    func removePriceFilter(category: CategoryIdentifiers, value: String) {
        //Remove filter
        selectedPriceRange = nil
        
        //Disable Clear button
        if (allFilters.count == 0) && (selectedPriceRange == nil) {
            clearAllFiltersButton.isEnabled = false
        }
        
        //Filter the inventory
        filterInventory(resetPage: true)
    }
    
    func addFilterTag(category: CategoryIdentifiers, filterName: String) {
        if category == CategoryIdentifiers.price {
            //Remove if previous price is present
            var index = 0;
            for tag in filterTags {
                if tag.category == CategoryIdentifiers.price {
                    filterTagListView.removeTag(tag.filterName)
                    filterTags.remove(at: index)
                    break
                }
                index = index + 1
            }
            
        }
        filterTags.append(FilterTag(category: category, filterName: filterName))
        filterTagListView.addTag(filterName.lowercased().capitalizingFirstLetter())
        
        filterTagListTitleLabel.isHidden = false
    }
    
    func removeFilterTag(category: CategoryIdentifiers, filterName: String) {
        //Remove Tag from UI
        filterTagListView.removeTag(filterName.lowercased().capitalizingFirstLetter())

        //Remove Tag's data
        var index = 0;
        for tag in filterTags {
            if tag.category == category {
                //For Price Category, simpy remove the tag irrespective of Filter Value
                if tag.category == CategoryIdentifiers.price {
                    filterTags.remove(at: index)
                    
                } else if tag.filterName == filterName {
                    // For other categories, check the filter name
                    filterTags.remove(at: index)
                    break
                }
            }
            index = index + 1
        }
        
        //Remove Tag's Header
        if (self.allFilters.count == 0) && (self.selectedPriceRange == nil) {
            filterTagListTitleLabel.isHidden = true
        }
    }

    
    // MARK: - Update UI functions
    
    func updateSelectedHeaderCell(cell: FilterCategoryCell) {
        cell.categoryName.textColor = UIColor.filterSelectedTextColor
        cell.categoryImage.image = UIImage(named: "PlusButtonWhiteIcon")
        
        UIView.animate(withDuration: 0.2, animations: {
            cell.backgroundColor = UIColor.filterSelectedCategoryBackgroundColor
        })
    }
    
    func updateDeselectedHeaderCell(cell: FilterCategoryCell) {
        cell.categoryName.textColor = UIColor.filterTextColor
        cell.categoryImage.image = UIImage(named: "PlusButtonIcon")
        
        UIView.animate(withDuration: 0.2, animations: {
            cell.backgroundColor = UIColor.filterCategoryBackgroundColor
        })
    }
    
    func updateSelectedInventoryCell(cell: FilterInventoryCell) {
        cell.borderView.layer.borderColor = UIColor.filterSelectedTextColor.cgColor
        cell.inventoryName.textColor = UIColor.filterSelectedTextColor
        cell.inventorySubName.textColor = UIColor.filterSelectedTextColor
    }
    
    func updateDeselectedInventoryCell(cell: FilterInventoryCell) {
        cell.borderView.layer.borderColor = UIColor.filterImageBorderColor.cgColor
        cell.inventoryName.textColor = UIColor.filterTextColor
        cell.inventorySubName.textColor = UIColor.filterTextColor
    }
}


// MARK: - TagList delegate functions

extension ShopController: TagListViewDelegate {
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        tagRemoveHandler(title, tagView: tagView, sender: sender)
    }
    
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        tagRemoveHandler(title, tagView: tagView, sender: sender)
    }
    
    func tagRemoveHandler(_ title: String, tagView: TagView, sender: TagListView) {
        for tag in filterTags {
            if tag.filterName.lowercased().capitalizingFirstLetter() == title {
                
                if tag.category == CategoryIdentifiers.price {
                    removePriceFilter(category: tag.category, value: tag.filterName)
                    removeFilterTag(category: tag.category, filterName: tag.filterName)
                } else {
                    removeFilter(category: tag.category, value: tag.filterName)
                    removeFilterTag(category: tag.category, filterName: tag.filterName)
                    
                    //Update Data
                    for items in categoryItems {
                        for item in items.value {
                            if item.header.identifier == tag.category {
                                if item.header.identifier == CategoryIdentifiers.price {
                                    item.isSelected = false
                                } else if item.name == tag.filterName {
                                    item.isSelected = false
                                }
                            }
                        }
                    }
                }
                
                self.categoryTableView.reloadData()
                break
            }
        }
    }
}


// MARK: - Range Slider delegate functions

extension ShopController: NHRangeSliderViewDelegate {
    func sliderValueChanged(slider: NHRangeSlider?) {
        if allowedPriceRange.maxValue == slider?.upperValue && allowedPriceRange.minValue == slider?.lowerValue {
            //No Filter, so remove filter
            for tag in filterTags {
                if tag.category == CategoryIdentifiers.price {
                    removePriceFilter(category: CategoryIdentifiers.price, value: tag.filterName)
                    removeFilterTag(category: CategoryIdentifiers.price, filterName: tag.filterName)
                    
                    break
                }
            }
        } else {
            //Filter is applied
            let filterName = "₹\(Int((slider?.lowerValue)!)) - \(Int((slider?.upperValue)!))"
            addPriceFilter(category: CategoryIdentifiers.price, minValue: (slider?.lowerValue)!, maxValue: (slider?.upperValue)!)
            addFilterTag(category: CategoryIdentifiers.price, filterName: filterName)
        }
        
        self.categoryTableView.reloadData()
    }
}


// MARK: - Navigation

extension ShopController: LikeDelegate {
    
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        if identifier == "ProductDetails" {
            if let _ = self.selectedFrame {
                return true
            } else {
                return false
            }
        }
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let productDetailsController = segue.destination as? ProductDetailsController {
            productDetailsController.user = self.user
            productDetailsController.frame = self.selectedFrame
            productDetailsController.is3DAlreadyRendered = false
            productDetailsController.likeDelegate = self
            
            Appsee.addEvent("MaxButtonFromShop", withProperties: ["ID" : self.selectedFrame?.id,
                                                                  "FrameType" : self.selectedFrame?.frameType,
                                                                  "Price" : self.selectedFrame?.price ?? 0])
        }
    }
    
    func updateLikeCount() {
        let likedCount = tryon3D.countUserLiked()
        if let tabBarController = self.tabBarController as? MainTabBarController {
            tabBarController.updateLikedBadgeCount(withCount: likedCount)
        }
    }
}

