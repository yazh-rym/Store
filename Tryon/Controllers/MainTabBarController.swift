//
//  MainTabBarController.swift
//  Tryon
//
//  Created by Udayakumar N on 13/03/17.
//  Copyright © 2017 1000Lookz. All rights reserved.
//

import UIKit
import AlamofireImage


enum TabBarList: Int {
    case shop = 0
    case searchAndFilter
    case shoot
    case tray
    case profile
}

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    // MARK: - Class variables
    let window = UIApplication.shared.keyWindow!
    var menuTabBarView: MenuTabBarView?
    
    
    // MARK: - Init functions
    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
        self.selectedIndex = TabBarList.shop.rawValue
        
        //Configure UI
        addLogoAtTheTop()
        
        self.tabBar.isHidden = true
        self.menuTabBarView = MenuTabBarView(frame: CGRect(x: window.frame.size.width - 420, y: window.frame.origin.y + 50, width: 555, height: 60))//555
        self.menuTabBarView?.tag = 2
        self.window.addSubview(menuTabBarView!)
        self.menuTabBarView?.menuTabBarDelegate = self
    }
    
    // MARK: - Tabbar functions
    func disableTabBarItem(item: Int) {
        let tabBarControllerItems = self.tabBar.items
        
        if let tab = tabBarControllerItems?[item] {
            tab.isEnabled = false
        }
    }
    
    func enableTabBarItem(item: Int) {
        let tabBarControllerItems = self.tabBar.items
        
        if let tab = tabBarControllerItems?[item] {
            tab.isEnabled = true
        }
    }
    
    func updateTrayBadgeCount(withCount count: Int) {
        if let navController = self.viewControllers?[TabBarList.tray.rawValue] as! UINavigationController? {
            if count > 0 {
                navController.tabBarItem.badgeValue = String(count)
            } else {
                navController.tabBarItem.badgeValue = nil
            }
        }
    }
    
    // MARK: - Window view functions
    func addLogoAtTheTop() {
        let window = UIApplication.shared.keyWindow!
        
        let backgroundView = UIView(frame: CGRect(x: window.frame.origin.x + 20, y: window.frame.origin.y + 20, width: 80, height: 40))
        backgroundView.backgroundColor = UIColor.clear
        backgroundView.layer.shadowColor = UIColor.darkGray.cgColor
        backgroundView.layer.shadowOffset = CGSize(width: 4, height: 4)
        backgroundView.layer.shadowOpacity = 0.5
        backgroundView.layer.shadowRadius = 6.0
        backgroundView.tag = 1
        
        let logoButton = UIButton(frame: CGRect(x:0, y:0, width: 80, height: 40))
        logoButton.backgroundColor = UIColor.primaryLightColor
        logoButton.setImage(UIImage(named: "OICLogo"), for: .normal)
        logoButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
        logoButton.addTarget(self, action: #selector(MainTabBarController.logoButtonPressed), for: .touchUpInside)
        logoButton.adjustsImageWhenHighlighted = false
        logoButton.addCornerRadius(15.0, inCorners: [.bottomLeft, .bottomRight])
        logoButton.clipsToBounds = true
        logoButton.masksToBounds = true
        logoButton.tag = 1

        let logoBgView1 = UIView(frame: CGRect(x: window.frame.origin.x + 120, y: window.frame.origin.y + 20, width: 149, height: 40))//143,59
        logoBgView1.backgroundColor = UIColor.clear
        logoBgView1.layer.shadowColor = UIColor.darkGray.cgColor
        logoBgView1.layer.shadowOffset = CGSize(width: 4, height: 4)
        logoBgView1.layer.shadowOpacity = 0.5
        logoBgView1.layer.shadowRadius = 6.0
        logoBgView1.tag = 1
        
        let logoBgView2 = UIView(frame: CGRect(x: 0, y:0, width: 143, height: 40))// height 59
        logoBgView2.backgroundColor = UIColor(red: 239/255.0, green: 239/255.0, blue:239/255.0, alpha: 1.0)
        logoBgView2.addCornerRadius(15.0, inCorners: [.bottomLeft, .bottomRight])
        logoBgView2.clipsToBounds = true
        logoBgView2.masksToBounds = true
        logoBgView2.tag = 1
        
        let logoImg = UIImageView.init(frame:CGRect(x:15, y:5, width:119, height:25))//))//15,5,119,25 last change for arcadio // x:4, y:0, width: 128, height: 54 // x:34, y:5, width:81, height:30
        
        let sales = UITapGestureRecognizer(target: self, action:  #selector(MainTabBarController.customButtonPressed))
        logoImg.addGestureRecognizer(sales)
        logoImg.isUserInteractionEnabled = true
        
        //        if UserDefaults.standard.value(forKey: "logoUrl") != nil {
        //            let image = String(describing: UserDefaults.standard.value(forKey: "logoUrl")!)
        //            let data = try? Data(contentsOf: URL(string:image)!)
        //            if data != nil {
        //                let img = UIImage(data: data!)
        //                if img != nil {
        if let image = CacheHelper().image(withIdentifier: "logoimg", in: "png") {
            logoImg.image = image
            window.addSubview(logoBgView1)
            logoBgView1.addSubview(logoBgView2)
            logoBgView1.addSubview(logoImg)
        }
        else{
            print("no image")
        }
        //            }
        //        }
        
        logoImg.backgroundColor = UIColor(red: 239/255.0, green: 239/255.0, blue:239/255.0, alpha: 1.0)
        logoImg.tag = 1

        let welcomeLabel = UILabel.init(frame: CGRect(x: window.frame.width - 310, y: 22, width: 300, height: 25))
        welcomeLabel.font = UIFont(name: "SFUIText-Regular", size: 14)
        welcomeLabel.textAlignment = .right
        let userName = String(describing: UserDefaults.standard.value(forKey: "UserName")!)//DBUser().username//
        welcomeLabel.text = "Welcome, " + userName + "!"
        welcomeLabel.tag = 1
        window.addSubview(welcomeLabel)
        
        window.addSubview(backgroundView)
        backgroundView.addSubview(logoButton)
    }
    
    func removeLogoFromWindow() {
        for view in self.window.subviews {
            if view.tag == 1 {
                //Remove Logo SubViews, if already added
                view.removeFromSuperview()
            }
        }
    }
    
    func removeMenuFromWindow() {
        for view in self.window.subviews {
            if view.tag == 2 {
                //Remove Menu SubViews, if already added
                view.removeFromSuperview()
            }
        }
    }
    
    func logoButtonPressed(sender: UIButton!) {
        self.menuTabBarView?.closeTray()
        self.menuTabBarView?.selectIndex(newIndex: TabBarList.shop.rawValue)
    }
    
    func customButtonPressed(sender: UIButton!) {
        self.menuTabBarView?.closeTray()
        self.menuTabBarView?.selectIndex(newIndex: TabBarList.shop.rawValue)
    }
}

// MARK: - Data delegate functions
extension MainTabBarController: MenuTabBarViewDelegate {
    func menuTabBarView(_ menuTabBarView: MenuTabBarView, didSelect id: Int) {
        selectIndex(newIndex: id)
    }
    
    func selectIndex(newIndex: Int) {
        if self.selectedIndex == newIndex {
            //Same tab is selected again
            if let vc = self.viewControllers?[self.selectedIndex] as? UINavigationController {
                vc.popToRootViewController(animated: true)
            }
        } else {
            //Some other tab is selected
            self.selectedIndex = newIndex
            if let vc = self.viewControllers?[self.selectedIndex] as? UINavigationController {
                vc.popToRootViewController(animated: false)
            }
        }
    }
}
