//
//  AlertViewController.swift
//  Tryon
//
//  Created by look z on 02/08/18.
//  Copyright © 2018 Varun Raj. All rights reserved.
//

import UIKit

class AlertViewController: UIViewController {
    
    
    @IBOutlet weak var centerView: UIView!
    
    @IBOutlet weak var iconView: UIImageView!
    
    @IBOutlet weak var closeBtn: UIButton!
    
    @IBOutlet weak var alertTextLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        iconView.image = iconView.image?.maskWithColor(color: UIColor.primaryDarkColor)
        
        alertTextLabel.textColor = UIColor.primaryDarkColor
        
        self.view.backgroundColor = UIColor.mainBackgroundColor
        centerView.addCornerRadius(20.0, inCorners: [.topLeft, .topRight, .bottomLeft, .bottomRight])
        centerView.backgroundColor = UIColor.white
        closeBtn.addCornerRadius(8.0, inCorners: [.topLeft, .topRight, .bottomLeft, .bottomRight])
        
        closeBtn.setTitleColor(UIColor.primaryDarkColor, for: .normal)
        closeBtn.backgroundColor = UIColor.primaryLightColor
        
        
        centerView.layer.shadowColor = UIColor.lightShadowColor.cgColor
        centerView.layer.shadowOffset = CGSize(width: 4, height: 60)
        centerView.layer.shadowOpacity = 0.6
        centerView.layer.shadowRadius = 6.0
        centerView.clipsToBounds = false
        centerView.layer.masksToBounds = false
        centerView.layer.shouldRasterize = true
        centerView.layer.rasterizationScale = UIScreen.main.scale
        centerView.addShadowView()

      
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func closeBtnAction(_ sender: Any) {
        
        exit(-1)
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UIImage {
    
    func maskWithColor( color:UIColor) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()!
        
        color.setFill()
        
        context.translateBy(x: 0, y: self.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        let rect = CGRect(x: 0.0, y: 0.0, width: self.size.width, height: self.size.height)
        context.draw(self.cgImage!, in: rect)
        
        context.setBlendMode(CGBlendMode.sourceIn)
        context.addRect(rect)
        context.drawPath(using: CGPathDrawingMode.fill)
        
        let coloredImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return coloredImage!
    }
}
