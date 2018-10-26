//
//  SnapValidateController.swift
//  Tryon
//
//  Created by Udayakumar N on 13/02/18.
//  Copyright © 2018 Varun Raj. All rights reserved.
//

import UIKit
import YUCIHighPassSkinSmoothing
import RealmSwift


class SnapValidateController: BaseViewController {
    
    // MARK: - Class variables
    var frame: InventoryFrame?
    let model = TryonModel.sharedInstance
    let tryon3D = Tryon3D.sharedInstance
    var userImage: UIImage?
     let realm = try! Realm()
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var retakeButton: UIButton!
    
    var userImages: UIImage!
    
    @IBAction func continueDidTap(_ sender: UIButton) {
        
        let internalUserName = NSUUID().uuidString
        FileHelper().removeAllSnapJpgFilesCaches()
        
        //Change the image to Low Res
        UIGraphicsBeginImageContextWithOptions(self.model.serverImageSize, true, 1.0)
        self.userImage?.draw(in: CGRect(origin: .zero, size: self.model.serverImageSize))
        let lowResImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
       
        //Update Display Size, for further calculations
        self.model.displayImageSize = (userImage?.size)!
        
        //Is this required?
        //Process the image
//        let filter = YUCIHighPassSkinSmoothing()
//        filter.inputImage = CIImage(image: self.userImage!)
//        filter.inputAmount = 0.7
//        filter.inputRadius = 6.0
//        let ciOutputImage = filter.outputImage!
//        var uiOutputImage = UIImage(ciImage: ciOutputImage)
//        uiOutputImage = uiOutputImage.af_imageScaled(to: (self.userImage?.size)!)
//        uiOutputImage = uiOutputImage.withHorizontallyFlippedOrientation()
        
        let screenSize = UIScreen.main.bounds
        let x = screenSize.width / 2
        let y = screenSize.height / 4
        self.setupActivityIndicator(atCenterPoint: CGPoint(x: x, y: y))
        
        let frames = self.realm.objects(InventoryFrame.self).filter { $0.isTryonCreated == true }
        self.frame = frames.first
         NotificationCenter.default.post(name: NSNotification.Name(rawValue: "tabClose"), object: nil)
        
        self.performSegue(withIdentifier: "snapValidateToDetailModel", sender: self.frame)
       // self.activityIndicator?.startAnimating()
//        HPEHelper().extractFrameFromImage(internalUserName: internalUserName, image: self.userImage!, lowResImage: lowResImage!) { (newUser, error) in
//            if error == nil {
//                //self.tryon3D.user = newUser
//                self.activityIndicator?.stopAnimating()
//                self.performSegue(withIdentifier: "snapValidateToDetailModel", sender: nil)
//            } else {
//                self.activityIndicator?.stopAnimating()
//                self.showAlertMessage(withTitle: "Error", message: "Unable to process your face. Please try again.")
//            }
//        }
        
        
    }
    @IBAction func retakeDidTap(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
    
    // MARK: - Init functions
    override func viewDidLoad() {
        super.viewDidLoad()

        if let img = self.userImage {
            self.imageView.image = img
            
           // userImages.append(self.imageView.image!)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if let detailModelController = segue.destination as? DetailModelController {
       
            detailModelController.imageUser = self.imageView.image
            
            if let frame = sender as? InventoryFrame {
                detailModelController.frame = frame
            }
        }
        
    }

}

