//
//  ResultController.swift
//  Tryon
//
//  Created by Udayakumar N on 09/01/18.
//  Copyright © 2018 Varun Raj. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import Kingfisher
import ImageSlideshow
import Alamofire

enum ResultInputType {
    case frames
    case searchString
    case filterData
}

extension Notification.Name {
    static let notifyToScroll = Notification.Name("glassDescription")
}
let snapNotificationKey = "snapNotify"

class ResultController: BaseViewController, DeletableImageViewDelegate{
    
    let tryon3D = Tryon3D.sharedInstance
    let model = TryonModel.sharedInstance
    var user: User?
    let numberFormatter = NumberFormatter()
    var isAllDataLoaded = false
    var inventoryFrames: [InventoryFrame] = []
    var filterData: [FilterList: [Int]] = [:]
    var searchString: String?
    var resultInputType: ResultInputType = .frames
    var inventoryFramesForModelView: [InventoryFrame] = []
    var tryon3DImg: UIImage?
    var userImages: UIImage?
    var imageBool: Int?
    var imageUrls:[String] = []
    var userId:[String] = []
    
    @IBOutlet weak var tryonSegment: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionModelView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var emptyLabelModel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchLine: UIView!
    var imagesUserDict : NSDictionary!
    
    var finalImagesArray: [UIImage] = []
    
    var imageId : String!
    
    var alert = UIAlertController()
    
    
    @IBAction func searchButtonDidTap(_ sender: UIButton) {
        if searchTextField.text == "" {
            searchTextField.becomeFirstResponder()
        } else {
            processSearchString(searchTextField.text)
        }
    }
    @IBAction func backButtonDidTap(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "tabClose"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        let attr = NSDictionary(object: UIFont(name: "SFUIText-Regular", size: 14.0)!, forKey: NSFontAttributeName as NSCopying)
        tryonSegment.setTitleTextAttributes(attr as [NSObject : AnyObject] , for: .normal)
        
        if #available(iOS 11.0, *) {
            tryonSegment.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            // Fallback on earlier versions
            tryonSegment.addCornerRadius(13.0, inCorners:[.topLeft, .topRight, .bottomLeft, .bottomRight])
        }
        tryonSegment.layer.cornerRadius = 13.0
        tryonSegment.borderWidth = 1.0
        tryonSegment.layer.borderColor = UIColor.primaryDarkColor.cgColor
        tryonSegment.clipsToBounds = true
        tryonSegment.masksToBounds = true
    }
    
    @IBAction func tryOnSelection(_ sender: Any) {
        
        if tryonSegment.selectedSegmentIndex == 1 {
            tryonSegment.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.primaryLightColor], for: UIControlState.selected)
            searchLine.isHidden = false
            searchButton.isHidden = false
            searchTextField.isHidden = false
            collectionModelView.isHidden = true
            
            collectionView.isHidden = false
            
            
            collectionView.reloadData()
            if let title = self.title {
                self.titleLabel.text =  "RESULTS" + " - \(self.inventoryFrames.count)" + "  Items"
            }
        }
        else if tryonSegment.selectedSegmentIndex == 0 {
            tryonSegment.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.primaryLightColor], for: UIControlState.selected)
            searchLine.isHidden = true
            searchButton.isHidden = true
            searchTextField.isHidden = true
            
            collectionView.isHidden = true
            collectionModelView.isHidden = false
            
            self.titleLabel.text =  "RESULTS" + " - \(self.inventoryFramesForModelView.count)" + "  Items"
            
        }
        else {
            tryonSegment.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.primaryLightColor], for: UIControlState.selected)
            searchLine.isHidden = false
            searchButton.isHidden = false
            searchTextField.isHidden = false
            
            tryonSegment.selectedSegmentIndex = 1
            
            self.collectionModelView.isHidden = true
            self.collectionView.isHidden = false
            
            let ProductVC = ProductViewController()
            ProductVC.modalPresentationStyle = .overCurrentContext
            
            ProductVC.inventoryFrames = self.inventoryFrames
            
            ProductVC.titleString = "RESULTS" + " - \(self.inventoryFrames.count)" + "  ITEMS"
            
            ProductVC.delegate = self
            present(ProductVC, animated: false, completion: nil)
            
            if let title = self.title {
                self.titleLabel.text =  "RESULTS" + " - \(self.inventoryFrames.count)" + "  ITEMS"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton.addCornerRadius(15.0, inCorners: [.topRight, .bottomRight])
        backButton.clipsToBounds = true
        backButton.masksToBounds = true
        
        tryonSegment.selectedSegmentIndex = 1
        collectionView.isHidden = false
        collectionModelView.isHidden = true
        
        
        //        self.inventoryFramesForModelView = self.inventoryFrames.filter { $0.isTryonCreated == true }
        DispatchQueue.global(qos: .background).sync {
            self.inventoryFramesForModelView = self.inventoryFrames.filter { $0.isTryonCreated == true }
            
            for inventoryFrame in inventoryFrames {
                if (inventoryFrame.childFrames.count) > 0 {
                    for child in (inventoryFrame.childFrames) {
                        if child.isTryonCreated == true {
                            inventoryFramesForModelView.append(child)
                            //                            print("count:")
                            //                            print(inventoryFramesForModelView.count)
                        }
                    }
                }
            }
            //            print(inventoryFramesForModelView.count)
            //            print(inventoryFramesForModelView)
        }
        
        self.user = self.tryon3D.user
        tryonSegment.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.primaryLightColor], for: UIControlState.selected)
        updateUI()
        
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.maximumFractionDigits = 2
        
        switch resultInputType {
        case .frames:
            if inventoryFrames.count == 0 {
                self.emptyLabel.isHidden = false
                self.emptyLabelModel.isHidden = false
            } else {
                self.emptyLabel.isHidden = true
                self.emptyLabelModel.isHidden = true
            }
        case .filterData:
            getFrameDataUsingFilter()
        case .searchString:
            getFrameDataUsingSearchString()
        }
        if let userKey = UserDefaults.standard.string(forKey: "UsersKey") {
            // print(userKey)
            let idenfi = UserDefaults.standard.dictionary(forKey: "imageKey")! as NSDictionary
            let ypr = idenfi.object(forKey: "YPR") as! String
            if let images = CacheHelper().image(withIdentifier: ypr, in: "jpg"){
                self.userImages = images
                if self.inventoryFramesForModelView.count != 0{
                    let inventory  =  self.inventoryFramesForModelView[0]
                    if let image = CacheHelper().image(withIdentifier: inventory.lookzId! + ypr, in: "jpg"){
                        //  print(image)
                        collectionModelView.reloadData()
                    }else{
                        LastApiImage(image: images, lookId: inventory.lookzId!)
                    }
                }
            }
        }else{
            let realm = try! Realm()
            let models = realm.objects(ModelAvatar.self).sorted(byKeyPath: "order")
            var i = 1
            for model in models {
                //Use only 2 models
                if i > 2 {
                    break
                }
                if model.frontFaceImgUrl != "" {
                    if let image = CacheHelper().image(withIdentifier: "ModelStack" , in: "jpg"){
                        //   print("already in cache method addImages sunglasses",image)
                        if self.inventoryFramesForModelView.count != 0{
                            let LastInventory  =  self.inventoryFramesForModelView.last
                            if let image = CacheHelper().image(withIdentifier: (LastInventory?.lookzId!)! + "Models", in: "jpg"){
                                //   print(image)
                            }else{
                                self.userImages = image
                                let inventory  =  self.inventoryFramesForModelView[0]
                                LastApiImage(image: self.userImages!, lookId: inventory.lookzId!)
                            }
                            collectionModelView.reloadData()
                        }
                    }else{
                        do{
                            let url = URL(string:model.frontFaceImgUrl)
                            let data = try Data(contentsOf: url!)
                            
                            self.userImages = UIImage.init(data: data)
                            
                            if self.userImages != nil{
                                if self.inventoryFramesForModelView.count != 0{
                                    let inventory  =  self.inventoryFramesForModelView[0]
                                    
                                    LastApiImage(image: self.userImages!, lookId: inventory.lookzId!)
                                    
                                    CacheHelper().add( UIImage(data: data)!, withIdentifier: "ModelStack", in: "jpg")
                                }
                            }
                        }catch{
                            print("error")
                        }
                    }
                    i = i + 1
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView.reloadData()
        
        if self.user?.internalUserName == self.tryon3D.user?.internalUserName {
            //Do nothing
        } else {
            self.user = self.tryon3D.user
            if tryonSegment.selectedSegmentIndex == 0 {
                self.collectionModelView.reloadData()
            }
        }
    }
    
    func updateUI() {
        if let title = self.title {
            self.titleLabel.text = title + " - \(self.inventoryFrames.count)" + "  Items"
        } else {
            self.titleLabel.text = "RESULTS" + " - \(self.inventoryFrames.count)"
        }
        
        if inventoryFrames.count == 0 {
            self.emptyLabel.isHidden = false
            self.emptyLabelModel.isHidden = false
        } else {
            self.emptyLabel.isHidden = true
            self.emptyLabelModel.isHidden = true
        }
    }
    
    func getFrameDataUsingSearchString() {
        
        activityIndicator?.startAnimating()
        
        if let searchString = self.searchString {
            InventoryFrameHelper().searchInventory(searchString: searchString, completionHandler: { (inventoryFrames, error) in
                self.activityIndicator?.stopAnimating()
                
                self.isAllDataLoaded = true
                
                self.inventoryFrames = inventoryFrames
                DispatchQueue.global(qos: .background).sync {
                    self.inventoryFramesForModelView = self.inventoryFrames.filter { $0.isTryonCreated == true }
                    
                    for inventoryFrame in inventoryFrames {
                        if (inventoryFrame.childFrames.count) > 0 {
                            for child in (inventoryFrame.childFrames) {
                                if child.isTryonCreated == true {
                                    self.inventoryFramesForModelView.append(child)
                                    //                            print("count:")
                                    //                            print(inventoryFramesForModelView.count)
                                }
                            }
                        }
                    }
                    //            print(inventoryFramesForModelView.count)
                    //            print(inventoryFramesForModelView)
                }
                self.updateUI()
                
                self.collectionView.reloadData()
                self.collectionModelView.reloadData()
            })
        }
    }
    
    func getFrameDataUsingFilter() {
        activityIndicator?.startAnimating()
        
        InventoryFrameHelper().filterInventory(filterList: filterData, additionalFilterString: nil) { (inventoryFrames, error) in
            self.activityIndicator?.stopAnimating()
            
            self.isAllDataLoaded = true
            
            self.inventoryFrames = inventoryFrames
            DispatchQueue.global(qos: .background).sync {
                self.inventoryFramesForModelView = self.inventoryFrames.filter { $0.isTryonCreated == true }
                
                for inventoryFrame in inventoryFrames {
                    if (inventoryFrame.childFrames.count) > 0 {
                        for child in (inventoryFrame.childFrames) {
                            if child.isTryonCreated == true {
                                self.inventoryFramesForModelView.append(child)
                            }
                        }
                    }
                }
            }
            self.updateUI()
            
            self.collectionView.reloadData()
            self.collectionModelView.reloadData()
        }
    }
    
    func preSegues(indexpaths: IndexPath){
        var frame: InventoryFrame?
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "tabClose"), object: nil)
        
        frame = self.inventoryFrames[indexpaths.row]
        if (frame?.isTryonCreated)! {
            if self.tryon3D.isUserSelectedByAppUser {
                self.performSegue(withIdentifier: "resultToModelDetailSegue", sender: indexpaths)
            } else {
                self.performSegue(withIdentifier: "resultToModelSelectionSegue", sender: indexpaths)
            }
        } else {
            self.performSegue(withIdentifier: "resultToFrameDetailSegue", sender: indexpaths)
        }
    }
    
    
    func LastApiImage(image : UIImage , lookId: String){
        
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
                        if response.result.value != nil {
                            let dic :NSDictionary = response.result.value! as! NSDictionary
                            let dict : NSDictionary = dic.object(forKey: "data") as! NSDictionary
                            
                            self.imageId = dict.object(forKey: "id") as! String
                            self.lastApi(id:dict.object(forKey: "id") as! String,lookzId: lookId)
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
                            self.imagesUserDict = nil
                            //                            print(value)
                            self.imagesUserDict = value as! NSDictionary
                            self.loadingImage(urlImage : self.imagesUserDict.value(forKey: "frameUrl") as! String)
                            //                            self.collectionModelView.reloadData()
                            //self.classDict.append(value as! NSDictionary)
                        }
                    }else{
                        self.loadingImage(urlImage : "")
                    }
                    break
                    
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    func loadingImage(urlImage : String){
        
        if urlImage == "" {
            self.finalImagesArray.append(userImages!)
            if self.finalImagesArray.count == self.inventoryFramesForModelView.count{
                self.collectionModelView.reloadData()
                //                print("completed")
            }else{
                self.apiCallMethod(index: self.finalImagesArray.count)
            }
        }else{
            let url = URL.init(string: urlImage)
            let task = URLSession.shared.dataTask(with: url!) { data, response, error in
                guard let data = data, error == nil else { return }
                
                DispatchQueue.main.async() {    // execute on main thread
                    if let img = UIImage.init(data: data) {
                        let image2 = self.userImages?.image(byDrawingImage: img , inRect: CGRect.init(x: self.imagesUserDict.value(forKey: "left") as! Int, y: self.imagesUserDict.value(forKey: "top") as! Int, width: self.imagesUserDict.value(forKey: "width") as! Int, height: self.imagesUserDict.value(forKey: "height") as! Int))
                        
                        self.finalImagesArray.append(image2!)
                        
                        if self.finalImagesArray.count == self.inventoryFramesForModelView.count{
                            self.alert.dismiss(animated: true, completion: nil)
                            self.collectionModelView.reloadData()
                        }else{
                            self.apiCallMethod(index: self.finalImagesArray.count)
                        }
                    }
                }
            }
            task.resume()
        }
    }
    
    func apiCallMethod(index: Int){
        
        let inventory  =  self.inventoryFramesForModelView[index]
        if finalImagesArray.count == 9 {
            self.lastApi(id:imageId,lookzId: inventory.lookzId!)
            collectionModelView.reloadData()
        }else{
            self.lastApi(id:imageId,lookzId: inventory.lookzId!)
            collectionModelView.reloadData()
        }
    }
}

extension ResultController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView == self.collectionView) {
            return self.inventoryFrames.count
        }
        else {
            if UserDefaults.standard.string(forKey: "UsersKey") != nil{
                if finalImagesArray.count == 0 {
                    return inventoryFramesForModelView.count
                } else {
                    return self.finalImagesArray.count
                }
            }else{
                if finalImagesArray.count == 0 {
                    return inventoryFramesForModelView.count
                } else {
                    return self.finalImagesArray.count
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if (collectionView == self.collectionView)  {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "resultCell", for: indexPath) as? ResultCell
            let inventoryFrame = self.inventoryFrames[indexPath.row]
            
            var titleText = inventoryFrame.brand?.name.uppercased()
            if let modelNumber = inventoryFrame.modelNumber {
                titleText = titleText! + " - " + modelNumber
            }
            cell?.titleLabel.text = titleText
            
            if inventoryFrame.is3DCreated {
                cell?.tryon3DImageView.isHidden = false
            } else {
                cell?.tryon3DImageView.isHidden = true
            }
            let image: UIImage? = UIImage(named:"tryOn")?.withRenderingMode(.alwaysTemplate)
            cell?.tryOnImageView.tintColor = UIColor(red: 161/255.0, green: 161/255.0, blue: 161/255.0, alpha: 1.0)
            cell?.tryOnImageView.image = image
            
            if inventoryFrame.isTryonCreated {
                cell?.tryOnImageView.isHidden = false
            } else {
                cell?.tryOnImageView.isHidden = true
            }
            
            if TrayHelper().isAlreadyAvailbleInTray(inventoryFrame) {
                cell?.cartImageView.isHidden = false
            } else {
                cell?.cartImageView.isHidden = true
            }
            
            if TrayHelper().isAlreadyAvailbleInfav(inventoryFrame) {
                cell?.favButton.setImage(UIImage(named: "ic_favorite_violet"), for: .normal)
            } else {
                cell?.favButton.setImage(UIImage(named: "ic_favorite_outline_violet"), for: .normal)
            }
            cell?.favButton.addTarget(self, action: #selector(addFav(_:)), for: .touchUpInside)
            
            var colorName = (inventoryFrame.frameColor?.name)! + " - "
            if let _ = inventoryFrame.identifiedColor?.name {
                colorName = ""
            }
            var displayText = colorName + (inventoryFrame.shape?.name)!
            if let size = inventoryFrame.sizeText {
                displayText = displayText + " - " + size
            }
            displayText = displayText.uppercased()
            
            cell?.subTitleLabel.text = displayText.lowercased().capitalizingFirstLetter()
            
            KingfisherManager.shared.cache.pathExtension = "jpg"
            
            cell?.imageView.kf.setImage(with: URL(string: inventoryFrame.thumbnailImageUrl!))
            if inventoryFrame.childFrames.count >= 1 {
                //Added +1 to include the parent frame
                cell?.colorLabel.text = String(inventoryFrame.childFrames.count + 1) + "  COLORS"
            } else {
                cell?.colorLabel.text = ""
            }
            
            var priceText: String? = ""
            if let price = inventoryFrame.price.value {
                if price > 0 {
                    if let priceUnit = inventoryFrame.priceUnit {
                        priceText = priceUnit + " "
                    }
                    priceText = priceText! + numberFormatter.string(from: NSNumber(value: price))!
                }
            }
            cell?.highlightedLabel.text = priceText
            
            return cell!
        }
        else {
            let inventoryFrame = self.inventoryFramesForModelView[indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "modelCell", for: indexPath) as? ModelCell
            
            //            let i = self.user!.frontFrameIndex!
            //
            //            let identifier = String(describing: inventoryFrame.id) + "-\(String(describing: self.user!.frameNumbers![i]))"
            
            if let userKey = UserDefaults.standard.string(forKey: "UsersKey") {
                //                print(userKey)
                let idenfi = UserDefaults.standard.dictionary(forKey: "imageKey")! as NSDictionary
                let ypr = idenfi.object(forKey: "YPR") as! String
                if let image = CacheHelper().image(withIdentifier: inventoryFrame.lookzId! + ypr, in: "jpg"){
                    cell?.imageView.image = image
                }else{
                    if self.imagesUserDict != nil{
                        //  let ypr = self.imagesUserDict.value(forKey: "YPR") as! String
                        let urlStr =  EndPoints().s3PreRenderedUrl + inventoryFrame.lookzId! + "/Images/" + ypr + ".png"
                        let url = URL.init(string:urlStr)
                        //                    print(url!)
                        cell?.imageView.image = finalImagesArray[indexPath.row]
                        
                        CacheHelper().add(finalImagesArray[indexPath.row], withIdentifier:  inventoryFrame.lookzId! + ypr, in: "jpg")
                    }
                }
                cell?.imageView.contentMode = .scaleAspectFill
                
                var titleText = inventoryFrame.brand?.name.uppercased()
                if let modelNumber = inventoryFrame.modelNumber {
                    titleText = titleText! + " - " + modelNumber
                }
                cell?.titleLabel.text = titleText
                
                //TODO: Should we display Product Name here?
                var colorName = (inventoryFrame.frameColor?.name)! + " - "
                if let _ = inventoryFrame.identifiedColor?.name {
                    colorName = ""
                }
                var displayText = colorName + (inventoryFrame.shape?.name)!
                if let size = inventoryFrame.sizeText {
                    displayText = displayText + " - " + size
                }
                displayText = displayText.uppercased()
                cell?.subTitleLabel.text = displayText.lowercased().capitalizingFirstLetter()
                
                if TrayHelper().isAlreadyAvailbleInfav(inventoryFrame) {
                    cell?.favButton.setImage(UIImage(named: "ic_favorite_violet"), for: UIControlState.normal)
                } else {
                    cell?.favButton.setImage(UIImage(named: "ic_favorite_outline_violet"), for: UIControlState.normal)
                }
                cell?.favButton.addTarget(self, action: #selector(addFav1(_:)), for: .touchUpInside)
                
            }
            else{
                
                if let image = CacheHelper().image(withIdentifier: inventoryFrame.lookzId! + "Models", in: "jpg") {
                    cell?.imageView.image = image
                }
                else {
                    if self.imagesUserDict != nil{
                        cell?.imageView.image = finalImagesArray[indexPath.row]
                        CacheHelper().add(finalImagesArray[indexPath.row], withIdentifier:  inventoryFrame.lookzId! + "Models", in: "jpg")
                    }
                }
                cell?.imageView.contentMode = .scaleAspectFill
                
                var titleText = inventoryFrame.brand?.name.uppercased()
                if let modelNumber = inventoryFrame.modelNumber {
                    titleText = titleText! + " - " + modelNumber
                }
                cell?.titleLabel.text = titleText
                
                //TODO: Should we display Product Name here?
                var colorName = (inventoryFrame.frameColor?.name)! + " - "
                if let _ = inventoryFrame.identifiedColor?.name {
                    colorName = ""
                }
                var displayText = colorName + (inventoryFrame.shape?.name)!
                if let size = inventoryFrame.sizeText {
                    displayText = displayText + " - " + size
                }
                displayText = displayText.uppercased()
                cell?.subTitleLabel.text = displayText.lowercased().capitalizingFirstLetter()
                
                if TrayHelper().isAlreadyAvailbleInfav(inventoryFrame) {
                    cell?.favButton.setImage(UIImage(named: "ic_favorite_violet"), for: UIControlState.normal)
                } else {
                    cell?.favButton.setImage(UIImage(named: "ic_favorite_outline_violet"), for: UIControlState.normal)
                }
                cell?.favButton.addTarget(self, action: #selector(addFav1(_:)), for: .touchUpInside)
            }
            //                else{
            //
            //                if let image = CacheHelper().image(withIdentifier: identifier, in: "jpg") {
            //                    cell?.imageView.image = image
            //                }
            //                else {
            //                    let uuid = inventoryFrame.uuid
            //                    let jsonPath = (self.user?.jsonUrl)! + uuid + "/jsons/"
            //                    let glassPath = (self.user?.glassUrl)! + uuid + "/Images/"
            //                    let glassImageForScalingUrl = glassPath + "0_0_0.png"
            //                    let jsonUrl = jsonPath + self.user!.yprValues![i] + ".json"
            //
            //                    let blockOperation2: BlockOperation = BlockOperation.init (
            //                        block: {
            //                            UserRenderHelper().getGlassCenterJson(jsonUrl: jsonUrl, frameUuid: uuid, glassImageForScalingUrl: glassImageForScalingUrl, completionHandler: { (glassCenter, glassSizeForScaling, error) in
            //
            //                                let blockOperation: BlockOperation = BlockOperation.init(
            //                                    block: {
            //                                        let glassUrl = glassPath + (self.user!.yprValues![i]) + ".png"
            //                                        let userIdentifier = (self.user?.internalUserName)! + "-user-\(String(describing: self.user!.frameNumbers![i]))"
            //                                        let userImage = CacheHelper().image(withIdentifier: userIdentifier, in: "jpg")!
            //
            //                                        UserRenderHelper().createGlassImage(forUser: self.user!, glassUrl: glassUrl, glassSizeForScaling: glassSizeForScaling, glassCenter: glassCenter, sellionPoint: self.user!.sellionPoints![i], faceSize: self.user!.serverFaceSize, withUserImage: userImage, completionHandler: { [identifier = identifier] (glassImage, error) in
            //                                            DispatchQueue.main.async {
            //                                                if error != nil {
            //                                                    cell?.imageView.image = userImage
            //                                                }
            //                                                else {
            //                                                    cell?.imageView.image = glassImage
            //                                                }
            //                                            }
            //                                            //Check whether glass Image is created or not
            //                                            if let glassImge = glassImage {
            //                                                CacheHelper().add(glassImge, withIdentifier: identifier, in: "jpg")
            //                                            }
            //                                        })
            //                                })
            //                                blockOperation.queuePriority = .normal
            //                                self.user?.operationQueue.maxConcurrentOperationCount = 4
            //                                self.user?.operationQueue.qualityOfService = .userInitiated
            //                                self.user?.operationQueue.addOperation(blockOperation)
            //                            })
            //                    })
            //                    blockOperation2.queuePriority = .normal
            //                    self.user?.operationQueue.maxConcurrentOperationCount = 4
            //                    self.user?.operationQueue.qualityOfService = .userInitiated
            //                    self.user?.operationQueue.addOperation(blockOperation2)
            //                }
            //                cell?.imageView.contentMode = .scaleAspectFill
            //
            //                var titleText = inventoryFrame.brand?.name.uppercased()
            //                if let modelNumber = inventoryFrame.modelNumber {
            //                    titleText = titleText! + " - " + modelNumber
            //                }
            //                cell?.titleLabel.text = titleText
            //
            //                //TODO: Should we display Product Name here?
            //                var colorName = (inventoryFrame.frameColor?.name)! + " - "
            //                if let _ = inventoryFrame.identifiedColor?.name {
            //                    colorName = ""
            //                }
            //                var displayText = colorName + (inventoryFrame.shape?.name)!
            //                if let size = inventoryFrame.sizeText {
            //                    displayText = displayText + " - " + size
            //                }
            //                displayText = displayText.uppercased()
            //                cell?.subTitleLabel.text = displayText.lowercased().capitalizingFirstLetter()
            //                if TrayHelper().isAlreadyAvailbleInfav(inventoryFrame) {
            //                    cell?.favButton.setImage(UIImage(named: "ic_favorite_violet"), for: UIControlState.normal)
            //                } else {
            //                    cell?.favButton.setImage(UIImage(named: "ic_favorite_outline_violet"), for: UIControlState.normal)
            //                }
            //                cell?.favButton.addTarget(self, action: #selector(addFav1(_:)), for: .touchUpInside)
            //            }
            return cell!
        }
    }
    
    @objc func addFav(_ sender: UIButton) {
        let hitPoint = sender.convert(CGPoint.zero, to: collectionView)
        if let indexPath = collectionView.indexPathForItem(at: hitPoint) {
            let frame = self.inventoryFrames[indexPath.item]
            let added = TrayHelper().addInventoryFrameTofav(frame)
            let selectedCell = collectionView.cellForItem(at: indexPath) as! ResultCell
            if added {
                if UserDefaults.standard.array(forKey: "favorites") != nil{
                    userId = UserDefaults.standard.array(forKey: "favorites") as! [String]
                    if let uuid:String = frame.lookzId{
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
                    userId.append(frame.lookzId!)
                    UserDefaults.standard.set(userId, forKey: "favorites")
                } else {
                    userId.append(frame.lookzId!)
                    UserDefaults.standard.set(userId, forKey: "favorites")
                }
                selectedCell.favButton.setImage(UIImage(named: "ic_favorite_violet"), for: UIControlState.normal)
            } else {
                if UserDefaults.standard.array(forKey: "favorites") != nil{
                    userId = UserDefaults.standard.array(forKey: "favorites") as! [String]
                    if let uuid:String = frame.lookzId{
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
                selectedCell.favButton.setImage(UIImage(named: "ic_favorite_outline_violet"), for: UIControlState.normal)
            }
        }
    }
    
    @objc func addFav1(_ sender: UIButton) {
        let hitPoint = sender.convert(CGPoint.zero, to: collectionModelView)
        if let indexPath = collectionModelView.indexPathForItem(at: hitPoint) {
            let frame = inventoryFramesForModelView[indexPath.item]
            let added = TrayHelper().addInventoryFrameTofav(frame)
            let selectedCell = collectionModelView.cellForItem(at: indexPath) as! ModelCell
            if added {
                if UserDefaults.standard.array(forKey: "favorites") != nil{
                    userId = UserDefaults.standard.array(forKey: "favorites") as! [String]
                    if let uuid:String = frame.lookzId {
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
                    userId.append(frame.lookzId!)
                    UserDefaults.standard.set(userId, forKey: "favorites")
                } else {
                    userId.append(frame.lookzId!)
                    UserDefaults.standard.set(userId, forKey: "favorites")
                }
                selectedCell.favButton.setImage(UIImage(named: "ic_favorite_violet"), for: UIControlState.normal)
            } else {
                if UserDefaults.standard.array(forKey: "favorites") != nil{
                    userId = UserDefaults.standard.array(forKey: "favorites") as! [String]
                    if let uuid:String = frame.lookzId {
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
                selectedCell.favButton.setImage(UIImage(named: "ic_favorite_outline_violet"), for: UIControlState.normal)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.collectionView{
            return CGSize(width: 220, height: 220)
        } else {
            return CGSize(width: 220, height: 330)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var frame: InventoryFrame?
        var imageView: UIImageView?
        
        if tryonSegment.selectedSegmentIndex == 0 {
            frame = self.inventoryFramesForModelView.filter({$0.isTryonCreated == true})[indexPath.row]
        } else {
            frame = self.inventoryFrames[indexPath.row]
        }
        ImageCache.default.maxMemoryCost = 1024 * 1024 * 100
        var arr : [String] = []
        var images: [UIImage] = []
        arr = ["thumbnail_high.jpg", "PD_Center.jpg", "PD_Back.jpg", "PD_Right.jpg", "PD_Right45.jpg", "PD_Left.jpg", "PD_Left45.jpg"]
        if let imagePath = frame?.imagePath {
            
            DispatchQueue.global(qos: .background).sync {
                for name in arr  {
                    let imageUrlString = imagePath + (frame?.uuid)! + "/" + name
                    var childFrames: [InventoryFrame]?
                    
                    if (frame?.childFrames.count)! > 0 {
                        for child in (frame?.childFrames)! {
                            let imageurls = imagePath + (child.uuid) + "/" + name
                            imageUrls.append(imageurls)
                            
                            imageView?.kf.setImage(with: URL(string: imageurls), placeholder: nil, options: [KingfisherOptionsInfoItem.cacheOriginalImage], progressBlock: { (receivedSize, totalSize) -> () in
                                print("Download Progress: \(receivedSize)/\(totalSize)")
                            }, completionHandler:  { (_, error, cacheType, imageURL) -> () in
                                print("Downloaded and set!")
                            })
                        }
                    }
                    imageUrls.append(imageUrlString)
                    let urls = imageUrls.map { URL(string: $0)! }
                    ////                    imageUrls.forEach({
                    //                        ImageDownloader.default.downloadImage(with:(URL(string: imageUrlString)!), options: [], progressBlock: nil) {
                    //                            (image, error, url, data) in
                    //                            images.append(image!)
                    //                            if images.count == self.imageUrls.count {
                    //                               // callback()
                    //                            }
                    //                        }
                    ////                    })
                    let prefetcher = ImagePrefetcher(urls: urls) {
                        skippedResources, failedResources, completedResources in
                        //                        print("These completed resources are prefetched: \(completedResources)")
                    }
                    prefetcher.start()
                    //                    ImageCache.default.clearMemoryCache()
                    //                    if let result = ImageCache.default.imageCachedType(forKey: imageUrlString) {
                    //                        print(result.cached)
                    //                        print(result.cacheType)
                    //                    }
                }
            }
        }
        if (UserDefaults.standard.string(forKey: "UsersKey") != nil) && (frame?.isTryonCreated)!{
            self.performSegue(withIdentifier: "resultToModelDetailSegue", sender: indexPath)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "tabClose"), object: nil)
        }else{
            
            if (frame?.isTryonCreated)! {
                if self.tryon3D.isUserSelectedByAppUser {
                    self.performSegue(withIdentifier: "resultToModelDetailSegue", sender: indexPath)
                } else {
                    if Reachability.isConnectedToNetwork() == true {
                        self.performSegue(withIdentifier: "resultToModelSelectionSegue", sender: indexPath)
                    } else {
                        self.performSegue(withIdentifier: "resultToFrameDetailSegue", sender: indexPath)
                    }
                }
            } else {
                self.performSegue(withIdentifier: "resultToFrameDetailSegue", sender: indexPath)
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "tabClose"), object: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "tabClose"), object: nil)
        
        let indexPath = sender as! IndexPath
        let frame: InventoryFrame?
        
        if tryonSegment.selectedSegmentIndex == 0 {
            frame = self.inventoryFramesForModelView.filter({$0.isTryonCreated == true})[indexPath.row]
        } else {
            frame = self.inventoryFrames[indexPath.row]
        }
        
        if let detailModelController = segue.destination as? DetailModelController {            
            detailModelController.frame = frame
        } else if let modelChooseController = segue.destination as? ModelChooseController {
            modelChooseController.frame = frame
        } else if let detailFrameController = segue.destination as? DetailFrameController {
            detailFrameController.frame = frame
        }
    }
}

extension ResultController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        processSearchString(textField.text)
    }
    
    fileprivate func processSearchString(_ searchString: String?) {
        if let searchString = searchString?.trimmingCharacters(in: .whitespacesAndNewlines) {
            if !(searchString.isEmpty) {
                activityIndicator?.startAnimating()
                
                InventoryFrameHelper().searchInventory(searchString: searchString, completionHandler: { (inventoryFrames, error) in
                    self.activityIndicator?.stopAnimating()
                    
                    self.isAllDataLoaded = true
                    
                    self.inventoryFrames = inventoryFrames
                    
                    self.updateUI()
                    
                    self.collectionView.reloadData()
                    self.searchTextField.text = ""
                })
            }
        }
    }
}
