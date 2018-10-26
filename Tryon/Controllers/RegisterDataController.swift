//
//  RegisterDataController.swift
//  Tryon
//
//  Created by Udayakumar N on 30/01/18.
//  Copyright © 2018 Varun Raj. All rights reserved.
//

import UIKit
import RealmSwift

class RegisterDataController: BaseViewController {

    // MARK: - Class variables
    let model = TryonModel.sharedInstance

    private var isModelDataLoaded = false
    private var isInventoryFrameDataLoaded = false
    private var isUserDataLoaded = false
    
    // MARK: - Init functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Reachability.isConnectedToNetwork() != true {
            let realm = try! Realm()
            let dbUsers: Results<DBUser> = realm.objects(DBUser.self)
            //  print("realm",dbUsers)
            
            var dpUsersArray: [DBUser] = []
            for user in dbUsers {
                let name = user.name
                let id = user.id
                let address1 = user.address1
                let address2 = user.address2
                let district = user.district
                let state = user.state
                let pincode = user.pincode
                
                let dbUser = DBUser(value: ["id": id as Any, "name": name as Any, "address1": address1 as Any, "address2": address2 as Any, "district": district as Any, "state": state as Any, "pincode": pincode as Any])
                dpUsersArray.append(dbUser)
            }
            self.model.relatedDBUsers = dpUsersArray
            
            AppDelegate.shared.rootViewController.switchToHome()
            
        }else{
            
            self.activityIndicator?.startAnimating()
            
            //Get Category details
            CategoryHelper().getAllCategories { (status) in
                if status {
                    //Get Model details
                    ModelAvatarHelper().getModelDetails { (modelAvatars, error) in
                        
                        if Reachability.isConnectedToNetwork() == true {
                            print("Internet connection OK")
                        } else {
                            let ProductVC = AlertViewController()
                            self.present(ProductVC, animated: false, completion: nil)
                        }
                        let realm = try! Realm()
                        try! realm.write {
                            realm.delete(realm.objects(ModelAvatar.self))
                            for model in modelAvatars {
                                realm.add(model)
                            }
                        }
                        self.isModelDataLoaded = true
                        
                        if self.isModelDataLoaded && self.isInventoryFrameDataLoaded && self.isUserDataLoaded {
                            self.activityIndicator?.stopAnimating()
                            AppDelegate.shared.rootViewController.switchToHome()
                        }
                    }
                    
                    //Get Inventory details
                    InventoryFrameHelper().getAllInventories() { (inventoryFrames, error) in
                        
                        if Reachability.isConnectedToNetwork() == true {
                            print("Internet connection OK")
                        } else {
                            let ProductVC = AlertViewController()
                            self.present(ProductVC, animated: false, completion: nil)
                        }
                        let realm = try! Realm()
                        try! realm.write {
                            realm.delete(realm.objects(InventoryFrame.self))
                            for frame in inventoryFrames {
                                realm.add(frame)
                            }
                        }
                        self.isInventoryFrameDataLoaded = true
                        
                        if self.isModelDataLoaded && self.isInventoryFrameDataLoaded && self.isUserDataLoaded {
                            self.activityIndicator?.stopAnimating()
                            AppDelegate.shared.rootViewController.switchToHome()
                        }
                    }
                } else {
                    //TODO: Handle this
                }
            }
            
            //Get User details
            DBUserHelper().getUserDetails { (dbUsers, error) in
                
                if Reachability.isConnectedToNetwork() == true {
                    print("Internet connection OK")
                } else {
                    let ProductVC = AlertViewController()
                    self.present(ProductVC, animated: false, completion: nil)
                }
                
                let realm = try! Realm()
                try! realm.write {
                    realm.delete(realm.objects(DBUser.self))
                    for user in dbUsers {
                        realm.add(user)
                    }
                }
                self.model.relatedDBUsers = dbUsers
                self.isUserDataLoaded = true
                
                if self.isModelDataLoaded && self.isInventoryFrameDataLoaded && self.isUserDataLoaded {
                    self.activityIndicator?.stopAnimating()
                    AppDelegate.shared.rootViewController.switchToHome()
                }
            }
        }
    }
}
