//
//  BaseViewController.swift
//  Tryon
//
//  Created by Udayakumar N on 27/12/17.
//  Copyright © 2017 Adhyas. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Alamofire
import RealmSwift

class BaseViewController: UIViewController {
    // MARK: - Class variables
    var activityIndicator: NVActivityIndicatorView?
    
    // MARK: - Init functions
    override func viewDidLoad() {
        super.viewDidLoad()
        //Configure
        setupUI()
        setupActivityIndicator()
    }
    
    // MARK: - Setup functions
    func setupActivityIndicator() {
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 30, height: 30), type: .ballRotateChase, color: UIColor.primaryDarkColor, padding: 0)
        
        view.addSubview(activityIndicator!)
        activityIndicator?.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: activityIndicator!, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: activityIndicator!, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))
    }
    
    func setupActivityIndicator(atCenterPoint centerPoint: CGPoint) {
        let x = centerPoint.x - (30 / 2)
        let y = centerPoint.y - (30 / 2)
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: x, y: y, width: 30, height: 30), type: .ballRotateChase, color: UIColor.primaryDarkColor, padding: 0)
        
        view.addSubview(activityIndicator!)
    }
    
    func setupUI() {
        self.view.backgroundColor = UIColor.mainBackgroundColor
        
        let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
        statusBarView.backgroundColor = UIColor.white
        view.addSubview(statusBarView)
    }
}

extension CALayer {
    
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        
        let border = CALayer()
        
        switch edge {
        case UIRectEdge.top:
            border.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: thickness)
            break
        case UIRectEdge.bottom:
            border.frame = CGRect(x: 0, y: self.frame.height - thickness, width: self.frame.width, height: thickness)
            break
        case UIRectEdge.left:
            border.frame = CGRect(x: 0, y: 0, width: thickness, height: self.frame.height)
            break
        case UIRectEdge.right:
            border.frame = CGRect(x: self.frame.width - thickness, y: 0, width: thickness, height: self.frame.height)
            break
        default:
            break
        }
        
        border.backgroundColor = color.cgColor;
        
        self.addSublayer(border)
    }
    
}
