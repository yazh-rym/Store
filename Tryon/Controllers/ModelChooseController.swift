//
//  ModelChooseController.swift
//  Tryon
//
//  Created by Udayakumar N on 31/01/18.
//  Copyright © 2018 Varun Raj. All rights reserved.
//

import UIKit
import ImageSlideshow
import RealmSwift
import Kingfisher

class ModelChooseController: BaseViewController {

    let model = TryonModel.sharedInstance
    let tryon3D = Tryon3D.sharedInstance
    
    var frame: InventoryFrame?
    var images: [InputSource] = []
    
    private let totalModels = 2
    private var selectedModelIndex = 0
    private var models: [ModelAvatar] = []
    
    @IBOutlet weak var imageSlideShowView: ImageSlideshow!
    
    @IBOutlet weak var rightArrowButton: UIButton!
    @IBOutlet weak var leftArrowButton: UIButton!
    @IBOutlet weak var model1Button: UIButton!
    @IBOutlet weak var model1ImageView: UIImageView!
    @IBOutlet weak var model2Button: UIButton!
    @IBOutlet weak var model2ImageView: UIImageView!
    
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var nextView: UIView!
    @IBOutlet weak var nextLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    @IBAction func backButtonDidTap(_ sender: UIButton) {
        
         NotificationCenter.default.post(name: NSNotification.Name(rawValue: "tabClose"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func rightArrowButtonDidTap(_ sender: UIButton) {
        let currentPage = imageSlideShowView.currentPage
        let nextPage = currentPage + 1
        
        if nextPage >= totalModels {
            //Ignore
        } else {
            imageSlideShowView.setCurrentPage(nextPage, animated: false)
            selectedModelIndex = nextPage
            updateUI()
        }
    }
    
    @IBAction func leftArrowButtonDidTap(_ sender: UIButton) {
        let currentPage = imageSlideShowView.currentPage
        let prevPage = currentPage - 1
        
        if prevPage < 0 {
            //Ignore
        } else {
            imageSlideShowView.setCurrentPage(prevPage, animated: false)
            selectedModelIndex = prevPage
            updateUI()
        }
    }
    
    @IBAction func model1ButtonDidTap(_ sender: UIButton) {
        if self.images.count > 0 {
            if imageSlideShowView.currentPage != 0 {
                imageSlideShowView.setCurrentPage(0, animated: false)
                selectedModelIndex = 0
                updateUI()
            }
        }
    }
    
    @IBAction func model2ButtonDidTap(_ sender: UIButton) {
        if self.images.count > 1 {
            if imageSlideShowView.currentPage != 1 {
                imageSlideShowView.setCurrentPage(1, animated: false)
                selectedModelIndex = 1
                updateUI()
            }
        }
    }
    
    @IBAction func nextButtonDidTap(_ sender: UIButton) {
        
        if Reachability.isConnectedToNetwork() != true {
            
            let alert = UIAlertController(title:"Oops" , message: "Please enable Internet Connection For Tryon", preferredStyle: UIAlertControllerStyle.alert);
            
            let alertAction = UIAlertAction(title: "ok", style: .cancel) { (alert) in
                self.dismiss(animated: true, completion: nil)
            }
            
            alert.addAction(alertAction)
            
            self.present(alert, animated: true, completion: nil)
            
        }else{
            let model = self.models[selectedModelIndex]
            
            let x = self.imageSlideShowView.frame.origin.x + (self.imageSlideShowView.frame.width / 2)
            let y = self.imageSlideShowView.frame.origin.y + self.imageSlideShowView.frame.height + 30
            self.setupActivityIndicator(atCenterPoint: CGPoint(x: x, y: y))
            self.activityIndicator?.startAnimating()
            
            ModelAvatarHelper().getUserFromModel(modelName: model.modelName, shouldRenderImages: false, jsonUrl: model.jsonUrl, serverVideoUrl: model.serverVideoUrl, frontFaceImgUrl: model.frontFaceImgUrl, completionHandler: { (newUser) in
                self.activityIndicator?.stopAnimating()
                self.tryon3D.user = newUser
                self.tryon3D.isUserSelectedByAppUser = true
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "tabClose"), object: nil)
                
                UserDefaults.standard.set(nil, forKey: "IDS")
                
                UserDefaults.standard.set(nil, forKey: "imageKey")
                
                UserDefaults.standard.set(nil, forKey: "UsersKey")
                self.performSegue(withIdentifier: "modelSelectionToModelDetailSegue", sender: self.frame)
            })
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.addCornerRadius(15.0, inCorners: [.topRight, .bottomRight])
        backButton.clipsToBounds = true
        backButton.masksToBounds = true
        
        KingfisherManager.shared.cache.pathExtension = "jpg"

        initData()
        configureUI()
        updateUI()
        
        imageSlideShowView.setImageInputs(images)
    }
    
    func initData() {
        let realm = try! Realm()
        let models = realm.objects(ModelAvatar.self).sorted(byKeyPath: "order")

        var i = 1
        for model in models {
            //Use only 2 models
            if i > 2 {
                break
            }
            
            if model.frontFaceImgUrl != "" {
                self.models.append(model)
                self.images.append(KingfisherSource(urlString: model.frontFaceImgUrl)!)
                i = i + 1
            }
        }
    }
    
    func configureUI() {
        imageSlideShowView.backgroundColor = UIColor.mainBackgroundColor
        imageSlideShowView.pageControlPosition = .hidden
        imageSlideShowView.slideshowInterval = 0
        imageSlideShowView.contentScaleMode = .scaleAspectFill
        imageSlideShowView.activityIndicator = DefaultActivityIndicator(style: .white, color: UIColor.primaryDarkColor)
        imageSlideShowView.draggingEnabled = false
        imageSlideShowView.circular = false
        
        imageSlideShowView.layer.shadowColor = UIColor.gray.cgColor
        imageSlideShowView.layer.shadowOffset = CGSize(width: 0, height: 10)
        imageSlideShowView.layer.shadowOpacity = 0.6
        imageSlideShowView.layer.shadowRadius = 6.0
        imageSlideShowView.clipsToBounds = false
        imageSlideShowView.layer.masksToBounds = false
        imageSlideShowView.layer.shouldRasterize = true
        imageSlideShowView.layer.rasterizationScale = UIScreen.main.scale
        
        imageSlideShowView.currentPageChanged = { page in            
            self.selectedModelIndex = page
            self.updateUI()
        }
        
        rightArrowButton.backgroundColor = UIColor.primaryLightColor
        leftArrowButton.backgroundColor = UIColor.primaryLightColor
        
        leftArrowButton.addCornerRadius(10.0, inCorners: [.topLeft, .bottomLeft])
        rightArrowButton.addCornerRadius(10.0, inCorners: [.topRight, .bottomRight])
        model1Button.addCornerRadius(10.0, inCorners: [.topLeft, .topRight])
        model2Button.addCornerRadius(10.0, inCorners: [.topLeft, .topRight])
        
        borderView.backgroundColor = UIColor.primaryLightColor
        nextLabel.textColor = UIColor.primaryDarkColor
        nextView.backgroundColor = UIColor.primaryLightColor
        nextView.addCornerRadius(10.0, inCorners: [.topLeft, .topRight])

        var i = 0
        for model in self.models {
            if let url = model.gender?.iconUrl {
                if i == 0 {
                    self.model1ImageView.kf.setImage(with: URL(string: url)!)
                } else {
                    self.model2ImageView.kf.setImage(with: URL(string: url)!)
                }
            }
            
            i = i + 1
        }
    }
    
    func updateUI() {
        if selectedModelIndex == 0 {
            model1Button.backgroundColor = UIColor.selectedViewColor
            model2Button.backgroundColor = UIColor.unSelectedViewColor
            model1ImageView.alpha = 1.0
            model2ImageView.alpha = 0.25
        } else {
            model1Button.backgroundColor = UIColor.unSelectedViewColor
            model2Button.backgroundColor = UIColor.selectedViewColor
            model1ImageView.alpha = 0.25
            model2ImageView.alpha = 1.0
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         NotificationCenter.default.post(name: NSNotification.Name(rawValue: "tabClose"), object: nil)
        if let detailModelController = segue.destination as? DetailModelController {
            if let frame = sender as? InventoryFrame {
                detailModelController.frame = frame
            }
        }
    }
}
