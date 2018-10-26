//
//  FavouriteController.swift
//  Tryon
//
//  Created by Yazh Mozhi on 12/08/18.
//  Copyright © 2018 Varun Raj. All rights reserved.
//

import UIKit
import Kingfisher
import Alamofire

class FavouriteController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    var inventoryFrames :[InventoryFrame]  = []
    let tryon3D = Tryon3D.sharedInstance
    let model = TryonModel.sharedInstance
    var user: User?
    var imagesUserDict : NSDictionary!
    var finalImagesArray: [UIImage] = []
    var imageId : String!
    var userImages: UIImage?
    var userId:[String] = []
    var userLookId:[String] = []

    var alert = UIAlertController()
    
    @IBOutlet weak var tableFavView: UITableView!
    @IBOutlet weak var clearAll: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator?.stopAnimating()
        inventoryFrames = TrayHelper().favInventoryFrames()
        self.user = self.tryon3D.user
        
        clearAll.addCornerRadius(8, inCorners: [.topRight, .bottomRight])
        clearAll.clipsToBounds = true
        clearAll.masksToBounds = true
    }
    override func viewWillAppear(_ animated: Bool) {
        inventoryFrames = TrayHelper().favInventoryFrames()
         for frame in TrayHelper().favInventoryFrames() {
            if UserDefaults.standard.array(forKey: "favorites") != nil  {
                userId = UserDefaults.standard.array(forKey: "favorites") as! [String]
                if let uuid = frame.lookzId {
                    let indexArray = userId.indices.filter({ userId[$0].localizedCaseInsensitiveContains(uuid) })
                }
            }
        }
        tableFavView.reloadData()
        if TrayHelper().favInventoryFramesCount() != 0 {
            clearAll.isHidden = false
        } else {
            clearAll.isHidden = true
        }
        self.user = self.tryon3D.user
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func clearBag(_ sender: Any) {
        TrayHelper().removeAllInventoryFrameFromfav()
        tableFavView.reloadData()
        clearAll.isHidden = true
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
                        if response.result.value != nil
                        {
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
                        //                        let alert = UIAlertController(title:"lookzId NOT WORK" , message: lookzId, preferredStyle: UIAlertControllerStyle.alert);
                        //
                        //                        let alertAction = UIAlertAction(title: "ok", style: .cancel) { (alert) in
                        //                            self.dismiss(animated: true, completion: nil)
                        //                        }
                        //
                        //                        alert.addAction(alertAction)
                        //
                        //                        self.present(alert, animated: true, completion: nil)
                        //
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
            
            if self.finalImagesArray.count == self.inventoryFrames.count{
                
                tableFavView.reloadData()
                
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
                        
                        if self.finalImagesArray.count == self.inventoryFrames.count{
                            
                            self.alert.dismiss(animated: true, completion: nil)
                            
                            self.tableFavView.reloadData()
                            
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
        
        let inventory  =  self.inventoryFrames[index]
        
        if finalImagesArray.count == 9 {
            
            self.lastApi(id:imageId,lookzId: inventory.lookzId!)
            
            tableFavView.reloadData()
        } /*else if finalImagesArray.count == 18 {
             
             self.lastApi(id:imageId,lookzId: inventory.lookzId!)
             
             collectionModelView.reloadData()
             } else if finalImagesArray.count == 27 {
             
             self.lastApi(id:imageId,lookzId: inventory.lookzId!)
             
             collectionModelView.reloadData()
         }*/else{
            
            self.lastApi(id:imageId,lookzId: inventory.lookzId!)
            
            tableFavView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TrayHelper().favInventoryFramesCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let inventoryFrame = TrayHelper().favInventoryFrames()[indexPath.row]//self.inventoryFrames[indexPath.row]

        let cellIdentifier = "favCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! FavouriteCell
        cell.frameImg.kf.setImage(with: URL(string: inventoryFrame.thumbnailImageUrl!))
        cell.productName.text = inventoryFrame.productName
        cell.modelFrame.text = (inventoryFrame.modelNumber)! + " / " + (inventoryFrame.templeColor?.name)!
        cell.rimType.text = inventoryFrame.frameType?.name
        cell.frameSize.text = inventoryFrame.sizeActual
        cell.frameType.text = inventoryFrame.templeColor?.name
        cell.frameColor.text = inventoryFrame.frameColor?.name

        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.clear
        cell.selectedBackgroundView = backgroundView
        
        cell.cartBtn.addTarget(self, action: #selector(addCart(_:)), for: .touchUpInside)
        cell.favBtn.addTarget(self, action: #selector(addFav(_:)), for: .touchUpInside)
        
        if TrayHelper().isAlreadyAvailbleInTray(inventoryFrame) {
            cell.addCart.backgroundColor = UIColor.primaryWarningColor
        } else {
            cell.addCart.backgroundColor = UIColor.primaryDarkColor
        }
        
//                let i = self.user!.frontFrameIndex!
//                let identifier = String(describing: inventoryFrame.id) + "-\(String(describing: self.user!.frameNumbers![i]))"
//                if let userKey = UserDefaults.standard.string(forKey: "UsersKey") {
//                    //                print(userKey)
//                    let idenfi = UserDefaults.standard.dictionary(forKey: "imageKey")! as NSDictionary
//                    let ypr = idenfi.object(forKey: "YPR") as! String
//
//                    if let image = CacheHelper().image(withIdentifier: inventoryFrame.lookzId! + ypr, in: "jpg"){
//                        cell.modelImg.image = image
//                    }else{
//                        if self.imagesUserDict != nil{
//                            //  let ypr = self.imagesUserDict.value(forKey: "YPR") as! String
//                            let urlStr =  EndPoints().s3PreRenderedUrl + inventoryFrame.lookzId! + "/Images/" + ypr + ".png"
//                            let url = URL.init(string:urlStr)
//                            //  print(url!)
//                            if finalImagesArray.count >= 9 {
//                                cell.modelImg.image = finalImagesArray[indexPath.row]
//                                CacheHelper().add(finalImagesArray[indexPath.row], withIdentifier:  inventoryFrame.lookzId! + ypr, in: "jpg")
//                            }
//                        }
//                    }
//                }
//                    else{
//                    if let image = CacheHelper().image(withIdentifier: identifier, in: "jpg") {
//                        cell.modelImg.image = image
//                    }
//                    else {
//                        let uuid = inventoryFrame.uuid
//                        let jsonPath = (self.user?.jsonUrl)! + uuid + "/jsons/"
//                        let glassPath = (self.user?.glassUrl)! + uuid + "/Images/"
//                        let glassImageForScalingUrl = glassPath + "0_0_0.png"
//                        let jsonUrl = jsonPath + self.user!.yprValues![i] + ".json"
//
//                        let blockOperation2: BlockOperation = BlockOperation.init (
//                            block: {
//                                UserRenderHelper().getGlassCenterJson(jsonUrl: jsonUrl, frameUuid: uuid, glassImageForScalingUrl: glassImageForScalingUrl, completionHandler: { (glassCenter, glassSizeForScaling, error) in
//
//                                    let blockOperation: BlockOperation = BlockOperation.init(
//                                        block: {
//                                            let glassUrl = glassPath + (self.user!.yprValues![i]) + ".png"
//                                            let userIdentifier = (self.user?.internalUserName)! + "-user-\(String(describing: self.user!.frameNumbers![i]))"
//                                            let userImage = CacheHelper().image(withIdentifier: userIdentifier, in: "jpg")!
//
//                                            UserRenderHelper().createGlassImage(forUser: self.user!, glassUrl: glassUrl, glassSizeForScaling: glassSizeForScaling, glassCenter: glassCenter, sellionPoint: self.user!.sellionPoints![i], faceSize: self.user!.serverFaceSize, withUserImage: userImage, completionHandler: { [identifier = identifier] (glassImage, error) in
//                                                DispatchQueue.main.async {
//                                                    if error != nil {
//                                                        cell.modelImg.image = userImage
//                                                    }
//                                                    else {
//                                                        cell.modelImg.image = glassImage
//                                                    }
//                                                }
//                                                //Check whether glass Image is created or not
//                                                if let glassImge = glassImage {
//                                                    CacheHelper().add(glassImge, withIdentifier: identifier, in: "jpg")
//                                                }
//                                            })
//                                    })
//                                    blockOperation.queuePriority = .normal
//                                    self.user?.operationQueue.maxConcurrentOperationCount = 4
//                                    self.user?.operationQueue.qualityOfService = .userInitiated
//                                    self.user?.operationQueue.addOperation(blockOperation)
//                                })
//                        })
//                        blockOperation2.queuePriority = .normal
//                        self.user?.operationQueue.maxConcurrentOperationCount = 4
//                        self.user?.operationQueue.qualityOfService = .userInitiated
//                        self.user?.operationQueue.addOperation(blockOperation2)
//                    }
//                }
        return cell
    }
    
    @objc func addFav(_ sender: UIButton) {
        let hitPoint = sender.convert(CGPoint.zero, to: tableFavView)
        if let indexPath = tableFavView.indexPathForRow(at: hitPoint) {
            let added = TrayHelper().isAlreadyAvailbleInfav(inventoryFrames[indexPath.row])
          
            if added {
                if UserDefaults.standard.array(forKey: "favorites") != nil{
                    userId = UserDefaults.standard.array(forKey: "favorites") as! [String]
                    if let uuid: String = inventoryFrames[indexPath.row].lookzId {
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
                inventoryFrames.remove(at: indexPath.row)
                TrayHelper().removeAllInventoryFrameFromfav()
                for i in 0..<inventoryFrames.count{
                    TrayHelper().addInventoryFrameTofav(inventoryFrames[i])
                }
                tableFavView.reloadData()
            }
        }
    }
    
    @objc func addCart(_ sender: UIButton) {
        let hitPoint = sender.convert(CGPoint.zero, to: tableFavView)
        if let indexPath = tableFavView.indexPathForRow(at: hitPoint) {
            let added = TrayHelper().addInventoryFrameToTray(inventoryFrames[indexPath.row])
            let selectedCell = tableFavView.cellForRow(at: indexPath) as! FavouriteCell
            if added {
                selectedCell.addCart.backgroundColor = UIColor.primaryWarningColor
                if UserDefaults.standard.array(forKey: "userLookId") != nil{
                    userLookId = UserDefaults.standard.array(forKey: "userLookId") as! [String]
                    
//                    if let quantityTextField.text == "1"{
//                        userLookId.append((inventoryFrames[indexPath.row].lookzId)!)
//                    }else{
                        if let lookId = inventoryFrames[indexPath.row].lookzId {
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
                            userLookId.append(lookId + "|1")
                        }
//                    }
                    //                print("Add Items",userLookId)
                    UserDefaults.standard.set(userLookId , forKey: "userLookId")
                }else{
                    userLookId.append((inventoryFrames[indexPath.row].lookzId)! + "|1")
                    //  userLookId.append((self.frame?.lookzId)!)
                    //                print("Add Items",userLookId)
                    UserDefaults.standard.set(userLookId , forKey: "userLookId")
                }
            }
            else {
                selectedCell.addCart.backgroundColor = UIColor.primaryDarkColor
                if UserDefaults.standard.array(forKey: "userLookId") != nil{
                    userLookId = UserDefaults.standard.array(forKey: "userLookId") as! [String]
                    if let lookId = inventoryFrames[indexPath.row].lookzId {
                        let indexArray = userLookId.indices.filter({ userLookId[$0].localizedCaseInsensitiveContains(lookId) })
                        
                        if indexArray.count != 0{
                            for userIndex in indexArray{
                                if userIndex != 0{
                                    userLookId.remove(at: userIndex)
                                }else{
                                    userLookId.remove(at: userIndex)
                                }
                            }
//                            quantityTextField.text = "1"
                        }
                    }
                    UserDefaults.standard.set(userLookId , forKey: "userLookId")
                }
            }
            tableFavView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let frame = TrayHelper().favInventoryFrames()[indexPath.row]
        self.performSegue(withIdentifier: "resultToInfoSegue", sender: frame)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 315
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailFrameController = segue.destination as? DetailFrameController {
            let frame = sender as! InventoryFrame
            detailFrameController.frame = frame
        }
    }
}
