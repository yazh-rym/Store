//
//  RootViewController.swift
//  Tryon
//
//  Created by Udayakumar N on 27/12/17.
//  Copyright © 2017 Adhyas. All rights reserved.
//

import UIKit
import AWSS3

class RootViewController: BaseViewController {
    
    // MARK: - Class variables
    let model = TryonModel.sharedInstance
    private var current: UIViewController

    
    // MARK: - Init functions
    init() {
        self.current = SplashViewController()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChildViewController(current)
        current.view.frame = view.bounds
        view.addSubview(current.view)
        current.didMove(toParentViewController: self)
    }
    
    // MARK: - Navigation functions
    func switchToHome() {
        activityIndicator?.startAnimating()
        
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let mainViewController = storyboard.instantiateViewController(withIdentifier: "mainAppWithTabBar") as UIViewController
        self.animateFadeTransition(to: mainViewController)
    }
    
    func switchToRegister() {
        self.model.accessToken.removeAll()
        let storyboard = UIStoryboard(name: "Register", bundle: nil)
        let registerViewController = storyboard.instantiateViewController(withIdentifier: "register") as UIViewController
        
        animateDismissTransition(to: registerViewController)
    }
    
    func switchToRegisterData() {
        let storyboard = UIStoryboard(name: "Register", bundle: nil)
        let registerDataController = storyboard.instantiateViewController(withIdentifier: "registerData") as UIViewController
        
        animateDismissTransition(to: registerDataController)
    }
    
    
    // MARK: - Transition functions
    private func animateFadeTransition(to new: UIViewController, completion: (() -> Void)? = nil) {
        current.willMove(toParentViewController: nil)
        addChildViewController(new)
        
        transition(from: current, to: new, duration: 0.3, options: [.transitionCrossDissolve, .curveEaseOut], animations: {
        }) { completed in
            self.current.removeFromParentViewController()
            new.didMove(toParentViewController: self)
            self.current = new
            completion?()
        }
    }
    
    private func animateDismissTransition(to new: UIViewController, completion: (() -> Void)? = nil) {
        //let initialFrame = CGRect(x: -view.bounds.width, y: 0, width: view.bounds.width, height: view.bounds.height)
        current.willMove(toParentViewController: nil)
        addChildViewController(new)
        
        transition(from: current, to: new, duration: 0.3, options: [], animations: {
            new.view.frame = self.view.bounds
        }) { completed in
            self.current.removeFromParentViewController()
            new.didMove(toParentViewController: self)
            self.current = new
            completion?()
        }
    }
}
