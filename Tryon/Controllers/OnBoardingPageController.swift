//
//  OnBoardingPageController.swift
//  Tryon
//
//  Created by Udayakumar N on 23/05/17.
//  Copyright © 2017 1000Lookz. All rights reserved.
//

import UIKit
import Appsee

enum ScrollDirection: Int {
    case left = 0
    case right
}

protocol OnBoardingPageDelegate: class {
    func onBoardingPageDidDisplay(_ viewController: OnBoardingPageController)
}

class OnBoardingPageController: UIViewController {
    //    var animationView: UIView?
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var deviceImageView: UIImageView!
    @IBOutlet weak var starImageView: UIImageView!
    
    var scrollDirection: ScrollDirection = .left
    var screenName: String?
    
    weak var onBoardingPageDelegate: OnBoardingPageDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        let animationViewFrame = CGRect(x: 398.5, y: 142.5, width: 40, height: 40)
        //        animationView = UIView(frame: animationViewFrame)
        //        animationView?.borderWidth = 3
        //        animationView?.borderColor = UIColor.primaryColor
        //        animationView?.cornerRadius = 20
        //
        //        self.view.addSubview(animationView!)
        //        self.view.bringSubview(toFront: animationView!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        onBoardingPageDelegate?.onBoardingPageDidDisplay(self)
        animateFrames()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let name = screenName {
            Appsee.startScreen(name)
        }
        
        super.viewDidAppear(animated)
    }
    
    func animateFrames() {
        var animationXForBackgroundImage: CGFloat?
        var animationXForDeviceImage: CGFloat?
        var animationXForStarImage: CGFloat?
        
        if scrollDirection == .left {
            animationXForBackgroundImage = -880
            animationXForDeviceImage = -800
            animationXForStarImage = -800
            
        } else if scrollDirection == .right {
            animationXForBackgroundImage = 880
            animationXForDeviceImage = 800
            animationXForStarImage = 800
            
        } else {
            animationXForBackgroundImage = 80
            animationXForDeviceImage = 0
            animationXForStarImage = 0
        }
        
        changeXPoisition(imageView: self.backgroundImageView, newX: animationXForBackgroundImage!)
        changeXPoisition(imageView: self.backgroundImageView, newX: 80, duration: 0.4, delay: 0.0)
        
        changeXPoisition(imageView: self.deviceImageView, newX: animationXForDeviceImage!)
        changeXPoisition(imageView: self.deviceImageView, newX: 0, duration: 0.3, delay: 0.2)
        
        changeXPoisition(imageView: self.starImageView, newX: animationXForStarImage!)
        changeXPoisition(imageView: self.starImageView, newX: 0, duration: 0.2, delay: 0.4)
    }
    
    func changeXPoisition(imageView: UIImageView, newX: CGFloat, duration: TimeInterval, delay: TimeInterval) {
        UIView.animate(withDuration: duration, delay: delay, options: [UIViewAnimationOptions.curveEaseIn], animations: {
            let newFrame = CGRect(x: newX, y: imageView.frame.origin.y, width: imageView.width, height: imageView.height)
            imageView.frame = newFrame
            
        }, completion: nil)
    }
    
    func changeXPoisition(imageView: UIImageView, newX: CGFloat) {
        let newFrame = CGRect(x: newX, y: imageView.frame.origin.y, width: imageView.width, height: imageView.height)
        imageView.frame = newFrame
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //        self.animationView!.transform = CGAffineTransform.identity
    }
    
    //    func animateView() {
    //        UIView.animate(withDuration: 0.6, animations: {
    //            self.animationView!.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
    //
    //        }, completion: { _ in
    //            UIView.animate(withDuration: 0.6, animations: {
    //                self.animationView!.transform = CGAffineTransform(scaleX: 1, y: 1)
    //            }, completion: { _ in
    //                self.animateView()
    //            })
    //        })
    //    }
}
