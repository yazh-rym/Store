//
//  UIViewController+TryonConfig.swift
//  Tryon
//
//  Created by Udayakumar N on 14/03/17.
//  Copyright © 2017 1000Lookz. All rights reserved.
//

import Foundation
import UIKit
import NVActivityIndicatorView

extension UIViewController {
    
    // MARK: - NVActivityIndicatorView loader config
    func loaderConfig() -> (size : CGSize, message : String , type : NVActivityIndicatorType) {
        return (CGSize(width: 60, height: 60), message: "", type: NVActivityIndicatorType.ballScaleRippleMultiple)
    }
    
    
    // MARK: - Alert config
    func showAlertMessage(withTitle title: String, message: String) {
        let myAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert);
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil );
        myAlert.addAction(okAction)
        
        self.present(myAlert, animated: true, completion : nil);
    }
    
    
    // MARK: - Something went wrong
    func showSomethingWentWrongScreen(withMessage message: String) {
        DispatchQueue.main.async {
            let vc: SomethingWentWrongController = UIStoryboard(name: "Others", bundle: nil).instantiateViewController(withIdentifier: "wentWrong") as! SomethingWentWrongController
            vc.somethingWentWrongDelegate = self as? SomethingWentWrongDelegate
            vc.message = message
            
            if let modalVC = self.presentedViewController {
                modalVC.present(vc, animated: true, completion: nil)
            } else {
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    func showSomethingWentWrongScreen() {
        let vc: SomethingWentWrongController = UIStoryboard(name: "Others", bundle: nil).instantiateViewController(withIdentifier: "wentWrong") as! SomethingWentWrongController
        vc.somethingWentWrongDelegate = self as? SomethingWentWrongDelegate
        
        self.present(vc, animated: true, completion: nil)
    }
    
    //Set and Hide views with animation
    func setView(_ view: UIView, inDuration duration: TimeInterval) {
        view.alpha = 0
        view.isHidden = false
        
        UIView.animate(withDuration: duration, animations: {
            view.alpha = 1
        }, completion: { finished in
            view.isHidden = false
        })
    }
    
    func hideView(_ view: UIView, inDuration duration: TimeInterval) {
        view.alpha = 1
        view.isHidden = false
        
        UIView.animate(withDuration: duration, animations: {
            view.alpha = 0
        }, completion: { finished in
            view.isHidden = true
            view.alpha = 1
        })
    }
}
