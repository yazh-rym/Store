//
//  ProductDetailsController.swift
//  Tryon
//
//  Created by Udayakumar N on 29/03/17.
//  Copyright © 2017 1000Lookz. All rights reserved.
//

import UIKit
import ImageSlideshow
import AlamofireImage
import PhoneNumberKit
import AWSS3
import Appsee


enum ProductDetails: String {
    case name = "Name"
    case brandName = "Brand Name"
    case frameCategory = "Product Type"
    case frameType = "Frame Type"
    case frameShape = "Frame Shape"
    case material = "Material"
    case size = "Size"
    case color = "Colour"
}

class ProductDetailsController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var bgScrollView: UIScrollView!
    @IBOutlet weak var imageScrollHandlerView: UIView!
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productDetailsLabel: UILabel!
    @IBOutlet weak var imageSlideshowView: ImageSlideshow!
    @IBOutlet weak var scrollToBottomButton: UIButton!
    @IBOutlet weak var productDetailsTableView: UITableView!
    @IBOutlet weak var placeHolderImageView: UIImageView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var shareUserImageLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var buyLabel: UILabel!
    
    @IBAction func likeButtonDidTap(_ sender: UIButton) {
        if let frameId = self.frame?.id {
            if tryon3D.isUserLiked(frameId: frameId) {
                tryon3D.removeUserLiked(frameId: frameId)
            } else {
                let userLiked = UserLiked(frame: self.frame!)
                let addResult = tryon3D.addUserLiked(userLiked: userLiked)
                if addResult {
                    //Do Nothing
                } else {
                    self.showAlertMessage(withTitle: "Sorry!", message: maxUserLikedCountReachedText)
                }
            }
            
            //Update UI
            updateLikeButton()
            
            //Update TabBar
            let likedCount = tryon3D.countUserLiked()
            if let tabBarController = self.tabBarController as? MainTabBarController {
                tabBarController.updateLikedBadgeCount(withCount: likedCount)
            } else if let delegate = likeDelegate {
                delegate.updateLikeCount!()
            }
        }
    }
    
    @IBAction func scrolToBottomButtonDidTap(_ sender: UIButton) {
        if bgScrollView.contentOffset.y > 200 {
            bgScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            scrollToBottomButton.setImage(UIImage(named: "DownWhiteIcon"), for: UIControlState.normal)
        } else {
            bgScrollView.setContentOffset(CGPoint(x: 0, y: scrollToBottomButton.frame.size.height + imageSlideshowView.frame.size.height + productDetailsTableView.frame.size.height), animated: true)
            scrollToBottomButton.setImage(UIImage(named: "UpWhiteIcon"), for: UIControlState.normal)
        }
    }
    
    @IBAction func buyButtonDidTap(_ sender: UIButton) {
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
            
            BuyHelper().sendSms(mobileNumber: (phoneNumber?.numberString)!, frame: (self?.frame)!, completionHandler: { (error) in
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
    
    @IBAction func shareButtonDidTap(_ sender: UIButton) {
        //TODO: Remove this whole code and place it to a function, so that it can be shared with all Share operations
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
        
        alertController.addAction(UIAlertAction(title: "Share", style: UIAlertActionStyle.default, handler: { (success) in
            //Get the mobile number
            let newMobileNumberTextField = alertController.textFields![0] as UITextField
            var phoneNumber: PhoneNumber?
            
            let phoneNumberKit = PhoneNumberKit()
            do {
                phoneNumber = try phoneNumberKit.parse(newMobileNumberTextField.text!)
                self.model.sharedMobileNumber = phoneNumber?.numberString
                
                log.info("Valid New Phone Number: \(String(describing: phoneNumber?.numberString))")
            }
            catch {
                //Invalid phone number
                self.showAlertMessage(withTitle: "Error", message: "Please enter valid mobile number")
                return
            }

            //Added +1, as tags have 0 as default
            let imgView = self.view.viewWithTag(self.currentDisplayFrame + 1) as! UIImageView
            
            //Create the image
            let imgSize = imgView.image?.size
            let bgRect = CGRect(x: 0, y: ((imgSize?.height)! - 90.0 - 10.0), width: (imgSize?.width)!, height: 90.0)
            
            UIGraphicsBeginImageContextWithOptions(imgSize!, false, 1.0)
            imgView.image?.draw(in: CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: imgSize!))
            
            if self.model.shouldAddCompanyLogoToShareImage {
                //Add Background to the image
                let bgImage = UIImage(named: "ShareBackground")
                bgImage?.draw(in: bgRect, blendMode: CGBlendMode.normal, alpha: 0.3)
            }
            
            //Add Logo to the image
            let logoImage = UIImage(named: "TryonLogoWithText")
            logoImage?.draw(in: CGRect(origin: CGPoint(x: (imgSize?.width)! - 210.0, y: (imgSize?.height)! - 90.0), size: CGSize(width: 160.0, height: 70.0)))
            
            if self.model.shouldAddCompanyLogoToShareImage {
                //Add Company Logo to the image
                let companyLogoImage = UIImage(named: "CompanyLogo")
                companyLogoImage?.draw(in: CGRect(origin: CGPoint(x: 50.0, y: (imgSize?.height)! - 83.0), size: CGSize(width: 160.0, height: 56.0)))
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
                    self.showAlertMessage(withTitle: "Sorry", message: "We couldn't share the image. Please try again!")
                    
                    return
                }
                log.info(imagePath)
            }
            
            //Upload the image
            let uploadCompletionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock = { (task, error) -> Void in
                if ((error) != nil){
                    DispatchQueue.main.async {
                        log.error("User Image Upload - Failed with error: \(String(describing: error))")
                        self.showAlertMessage(withTitle: "Sorry", message: "We couldn't share the image. Please try again!")
                    }
                }
                else {
                    let userImageFilePath = EndPoints().s3UserShareFilePath + imageName
                    log.info("User Image - S3 image path: \(userImageFilePath)")
                    
                    ShareImageHelper().shareImage(mobileNumber: (phoneNumber?.numberString)!, sourceUrl: userImageFilePath, completionHandler: { (error) in
                        if (error != nil) {
                            DispatchQueue.main.async {
                                log.error("ShareImage - Failed with error: \(String(describing: error))")
                                self.showAlertMessage(withTitle: "Sorry", message: "We couldn't share the image. Please try again!")
                            }
                        }
                    })
                }
            }
            
            AWSUploadHelper().uploadImage(fileURL: imagePath as NSURL, bucketName: EndPoints().s3BucketNameForUserShareUpload, fileS3UploadKeyName: imageName, completionHandler: uploadCompletionHandler, progressBlock: nil)
            
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    let imageSlideshowInterval = 3.0 //secs

    let model = TryonModel.sharedInstance
    let tryon3D = Tryon3D.sharedInstance
    
    var numberOfFrames = 0
    var currentDisplayFrame = 0
    var user: User?
    var frame: InventoryFrame?
    var productDetailsTitle: [String] = []
    var productDetailsValue: [String] = []
    var is3DAlreadyRendered = true
    
    var scrollToFaceTask: [DispatchWorkItem] = []
    
    let maxUserLikedCountReachedText = "You have already shortlisted 9 Glasses. Please remove some of them, before short-listing new glasses."
    
    weak var likeDelegate: LikeDelegate?
    
    // MARK: - Init functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bgScrollView.delegate = self
        
        imageScrollView.contentOffset = CGPoint(x: CGFloat(currentDisplayFrame) * imageScrollView.bounds.width, y: 0)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action:  #selector(handlePanGesture))
        imageScrollHandlerView.addGestureRecognizer(panGestureRecognizer)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        imageScrollHandlerView.addGestureRecognizer(tapGestureRecognizer)
        
        //Add Placeholder image
        placeHolderImageView.image = model.image(withIdentifier: "frontFace", in: "jpg")
        
        //Add Like button
        updateLikeButton()
        
        //Add 3D images
        updateUIForTryon3DStillLoading()
        if is3DAlreadyRendered {
            showImages()
        } else {
            //Render 3D and then add images
            DispatchQueue.global(qos: .userInitiated).sync {
                self.tryon3D.getRender3D(forUser: self.user!, shouldRenderWithUserImage: true, frame: frame!, inDirectory: .documentDirectory, completionHandler: { (render3D) in
                    if render3D?.status == .isCompleted {
                        //Display 3D images
                        self.showImages()
                    } else {
                        //Error in rendering 3D images
                        log.error("Error in render 3D in Product Details screen for \(String(describing: self.frame?.id))")
                        self.updateUIForTryon3DFailed()
                    }
                })
            }
        }
        
        //Add Product Name and Details
        productNameLabel.text = frame?.productName?.lowercased().capitalizingFirstLetter()
        
        let appendString = "  |  "
        var detailText = frame?.brand?.name.lowercased().capitalizingFirstLetter()
        if let color = frame?.frameColor {
            detailText = detailText! + appendString + color.name.lowercased().capitalizingFirstLetter()
        }
        if let size = frame?.size {
            detailText = detailText! + appendString + size.lowercased().capitalizingFirstLetter()
        }
//        if let price = frame?.price {
//            detailText = detailText! + appendString + "₹" + String(price)
//        }
        productDetailsLabel.text = detailText
        addProductDetails()
        
        //Configure Image Slide show
        imageSlideshowView.pageControlPosition = .insideScrollView
        imageSlideshowView.pageControl.pageIndicatorTintColor = UIColor.productDetailsImageBorderColor
        imageSlideshowView.pageControl.currentPageIndicatorTintColor = UIColor.primaryColor
        imageSlideshowView.slideshowInterval = imageSlideshowInterval
        addProductImages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        //Since the image order is reversed, reversing the frontFrameIndex
        let totalIndexNumber = (user?.frameNumbers?.count)! - 1
        let reversedFrontFrameIndex = totalIndexNumber - (user?.frontFrameIndex)!
        scrollToFrame(i: reversedFrontFrameIndex, withDelay: 0.0)
        
        //TODO: Is this required?
        //currentDisplayFrame = 0
        //scrollToFace()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        Appsee.startScreen("ProductDetails")
        
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        removeAllImages()
        placeHolderImageView.image = nil
        
        if let slideView = imageSlideshowView {
            for view in slideView.scrollView.subviews {
                if view is ImageSlideshowItem {
                    let item = view as! ImageSlideshowItem
                    item.imageView.image = nil
                }
                view.removeFromSuperview()
            }
            imageSlideshowView.slideshowInterval = 0.0
            imageSlideshowView.removeFromSuperview()
            imageSlideshowView = nil
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        //TODO: Handle this
        log.error("MEMORY WARNING in ProductDetailsController")
    }
    
    
    // MARK: - Tryon3D functions
    
    func showImages() {
        //Add User with glass images
        var imageIdentifiers: [String] = []
        for frameNumber in (user?.frameNumbers)! {
            imageIdentifiers.append("\((frame?.id)!)-\(frameNumber)")
        }
        self.addImages(withIdentifiers: imageIdentifiers, in: "jpg")
        updateUIForTryon3DCompleted()
    }
    
    func updateLikeButton() {
        if let frameId = self.frame?.id {
            if tryon3D.isUserLiked(frameId: frameId) {
                if let image = UIImage(named: "HeartIcon") {
                    likeButton.setImage(image, for: .normal)
                }
            } else {
                if let image = UIImage(named: "HeartIconDisabled") {
                    likeButton.setImage(image, for: .normal)
                }
            }
        }
    }
    
    func updateUIForTryon3DStillLoading() {
        imageScrollHandlerView.isUserInteractionEnabled = false
        shareUserImageLabel.textColor = UIColor.mainButtonDisableBackgroundColor
        
        if let image = UIImage(named: "UploadIconDisabled") {
            self.shareButton.setImage(image, for: .normal)
        }
        self.shareButton.isUserInteractionEnabled = false
        
        buyLabel.textColor = UIColor.mainButtonDisableBackgroundColor
        if let image = UIImage(named: "BuyIconDisabled") {
            self.buyButton.setImage(image, for: .normal)
        }
        self.buyButton.isUserInteractionEnabled = false
    }
    
    func updateUIForTryon3DCompleted() {
        imageScrollHandlerView.isUserInteractionEnabled = true
        shareUserImageLabel.textColor = UIColor.primaryColor
        
        if let image = UIImage(named: "UploadIcon") {
            self.shareButton.setImage(image, for: .normal)
        }
        self.shareButton.isUserInteractionEnabled = true
        
        buyLabel.textColor = UIColor.primaryColor
        if let image = UIImage(named: "BuyIcon") {
            self.buyButton.setImage(image, for: .normal)
        }
        self.buyButton.isUserInteractionEnabled = true
    }
    
    func updateUIForTryon3DFailed() {
        imageScrollHandlerView.isUserInteractionEnabled = false
        shareUserImageLabel.textColor = UIColor.mainButtonDisableBackgroundColor
        
        if let image = UIImage(named: "UploadIconDisabled") {
            self.shareButton.setImage(image, for: .normal)
        }
        self.shareButton.isUserInteractionEnabled = false
        
        buyLabel.textColor = UIColor.mainButtonDisableBackgroundColor
        if let image = UIImage(named: "BuyIconDisabled") {
            self.buyButton.setImage(image, for: .normal)
        }
        self.buyButton.isUserInteractionEnabled = false
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
        //Cancel previous tasks, if any
        cancelAllScrollToFaceTasks()
        
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
    
    func scrollToFace() {
        var delay = 0.0
        
        //Cancel previous tasks, if any
        cancelAllScrollToFaceTasks()
        
        // Scroll to the left end
        for i in 0..<numberOfFrames {
            delay += 0.08
            scrollToFaceFrame(i: i, withDelay: delay)
        }

        // Scroll back to center
        for i in stride(from: numberOfFrames-1, to: (numberOfFrames/2)-1, by: -1) {
            delay += 0.08
            scrollToFaceFrame(i: i, withDelay: delay)
        }
    }
    
    func scrollToFrame(i: Int, withDelay delay: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.currentDisplayFrame = i
            self.imageScrollView.contentOffset = CGPoint(x: CGFloat(self.currentDisplayFrame) * self.imageScrollView.bounds.width, y: 0)
        }
    }
    
    func scrollToFaceFrame(i: Int, withDelay delay: Double) {
        let task = DispatchWorkItem {
            //Reduce frame number by 1, to compensate scrolling
            var frame = i - 1
            if frame < 0 {
                frame = 0
            }
            
            self.currentDisplayFrame = frame
            self.imageScrollView.contentOffset = CGPoint(x: CGFloat(self.currentDisplayFrame) * self.imageScrollView.bounds.width, y: 0)
        }
        self.scrollToFaceTask.append(task)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: task)
    }
    
    func cancelAllScrollToFaceTasks() {
        for task in scrollToFaceTask {
            task.cancel()
        }
        self.scrollToFaceTask.removeAll()
    }
    
    func removeAllImages() {
        for view in imageScrollView.subviews {
            if view is UIImageView {
                let imgView = view as! UIImageView
                imgView.image = nil
            }
            view.removeFromSuperview()
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
                
                if let img = self.model.image(withIdentifier: identifier, in: representation) {
                    tempImageView.image = img
                    tempImageView.tag = counter
                } else {
                    log.error("Image not found for identifier: \(identifier)")
                }
                
                DispatchQueue.main.async {
                    tempImageView.clipsToBounds = true
                    tempImageView.contentMode = .scaleAspectFill
                    tempImageView.layer.cornerRadius = 5
                    tempImageView.layer.masksToBounds = true
                    
                    self.imageScrollView.addSubview(tempImageView)
                }
                
                i += self.imageScrollView.bounds.width
                counter += 1
            }
            
            //Bring button to the front
            self.view.bringSubview(toFront: self.shareButton)
            self.view.bringSubview(toFront: self.buyButton)
        }
    }
    
    
    // MARK: - Product Details functions
    
    func addProductImages() {
//        if let imgs = frame?.imgUrls {
//            
//            var imgsData: [Any] = []
//            for img in imgs {
//                if img != "" {
//                    imgsData.append(AlamofireSource(urlString: img)!)
//                }
//            }
//            
//            //TODO: For testing
//            imageSlideshowView.setImageInputs(imgsData as! [InputSource])
//        }
    }
    
    func addProductDetails() {
        if let name = frame?.productName {
            if name != "" {
                productDetailsTitle.append(ProductDetails.name.rawValue)
                productDetailsValue.append(name.lowercased().capitalizingFirstLetter())
            }
        }
        if let brand = frame?.brand {
            if brand.name != "" {
                productDetailsTitle.append(ProductDetails.brandName.rawValue)
                productDetailsValue.append(brand.name.lowercased().capitalizingFirstLetter())
            }
        }
        if let category = frame?.category {
            if category.name != "" {
                productDetailsTitle.append(ProductDetails.frameCategory.rawValue)
                productDetailsValue.append(category.name.lowercased().capitalizingFirstLetter())
            }
        }
        if let frameType = frame?.frameType {
            if frameType.name != "" {
                productDetailsTitle.append(ProductDetails.frameType.rawValue)
                productDetailsValue.append(frameType.name.lowercased().capitalizingFirstLetter())
            }
        }
        if let shape = frame?.shape {
            if shape.name != "" {
                productDetailsTitle.append(ProductDetails.frameShape.rawValue)
                productDetailsValue.append(shape.name.lowercased().capitalizingFirstLetter())
            }
        }
        if let material = frame?.frameMaterial {
            if material.name != "" {
                productDetailsTitle.append(ProductDetails.material.rawValue)
                productDetailsValue.append(material.name.lowercased().capitalizingFirstLetter())
            }
        }
        if let size = frame?.size {
            if size != "" {
                productDetailsTitle.append(ProductDetails.size.rawValue)
                productDetailsValue.append(size.lowercased().capitalizingFirstLetter())
            }
        }
        if let color = frame?.frameColor {
            if color.name != "" {
                productDetailsTitle.append(ProductDetails.color.rawValue)
                productDetailsValue.append(color.name.lowercased().capitalizingFirstLetter())
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.bgScrollView {
            if bgScrollView.contentOffset.y > 200 {
                //Up icon
                scrollToBottomButton.setImage(UIImage(named: "UpWhiteIcon"), for: UIControlState.normal)
            } else {
                scrollToBottomButton.setImage(UIImage(named: "DownWhiteIcon"), for: UIControlState.normal)
            }
        }
    }
}

extension ProductDetailsController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productDetailsTitle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productDetailsCell", for: indexPath) as! ProductDetailsCell
        cell.productDetailsTitleLabel.text = productDetailsTitle[indexPath.row]
        cell.productDetailsValueLabel.text = productDetailsValue[indexPath.row]
        cell.selectionStyle = .none
        
        return cell
    }
}
