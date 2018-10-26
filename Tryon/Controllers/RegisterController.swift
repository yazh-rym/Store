//
//  RegisterController.swift
//  Tryon
//
//  Created by Udayakumar N on 14/03/17.
//  Copyright © 2017 1000Lookz. All rights reserved.
//

import UIKit


class RegisterController: BaseViewController {

    // MARK: - Class variables
    let model = TryonModel.sharedInstance
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var holderView: UIView!
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTxtField: UITextField!
    
    @IBAction func registerBtnTapped(_ sender: Any) {
        //Dismiss Keyboard
        self.view.endEditing(true)
        
        if !(usernameTextField.text?.isEmpty)! {
            if !(passwordTxtField.text?.isEmpty)! {
                registerEvent(forUserName: usernameTextField.text!, password: passwordTxtField.text!)
                UserDefaults.standard.set(usernameTextField.text!, forKey: "UserName")
            } else {
                self.showAlertMessage(withTitle: "Invalid", message: "Password cannot be Empty")
            }
        } else {
            self.showAlertMessage(withTitle: "Invalid", message: "Username cannot be Empty")
        }
    }
    
    
    // MARK: - Init functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bgView.backgroundColor = UIColor.primaryLightColor
        self.view.backgroundColor = UIColor.primaryLightColor
        
        holderView.layer.shadowColor = UIColor.lightGray.cgColor
        holderView.layer.shadowOffset = CGSize(width: 4, height: 4)
        holderView.layer.shadowOpacity = 0.6
        holderView.layer.shadowRadius = 6.0
        holderView.clipsToBounds = false
        holderView.layer.masksToBounds = false
        holderView.layer.shouldRasterize = true
        holderView.layer.rasterizationScale = UIScreen.main.scale
    }
    
    override func viewDidAppear(_ animated: Bool) {        
        super.viewDidAppear(animated)
        usernameTextField.becomeFirstResponder()
    }
    
    // MARK: - Register functions
    func registerEvent(forUserName username: String, password: String) {
        self.activityIndicator?.startAnimating()
        
        RegisterHelper().registerUser(username: username, password: password) { (accessToken, userId, error) in
            if Reachability.isConnectedToNetwork() == true {
                    print("Internet connection OK")
            } else {
                let ProductVC = AlertViewController()
               
                self.present(ProductVC, animated: false, completion: nil)
            }
            if error != nil {
                self.clearData()
                if error?.code == 401 {
                    self.activityIndicator?.stopAnimating()
                    self.showAlertMessage(withTitle: "Login failed", message: "Please enter valid username / password")
                } else {
                    self.activityIndicator?.stopAnimating()
                    self.showAlertMessage(withTitle: "Login failed", message: "Please try again")
                }
            } else {
                if let accessToken = accessToken {
                    self.model.accessToken = accessToken
                    self.model.userId = userId!
                    RegisterHelper().registerUserLogo(accessToken: accessToken, userIdentity: userId!, completionHandler: { (userName, logoUrl, error) in
                        if Reachability.isConnectedToNetwork() == true {
                            print("Internet connection OK")
                        } else {
                            let ProductVC = AlertViewController()
                            self.present(ProductVC, animated: false, completion: nil)
                        }
                        self.activityIndicator?.stopAnimating()

                        if error == nil {
                            UserDefaults.standard.set(userName!,forKey: "UserName")
                            if logoUrl != nil {
                                UserDefaults.standard.set(logoUrl!, forKey: "logoUrl")
                                let image = String(describing: UserDefaults.standard.value(forKey: "logoUrl")!)
                                let data = try? Data(contentsOf: URL(string:image)!)
                                if data != nil {
                                    
                                    let img = UIImage(data: data!)
                                    if img != nil {
                                        CacheHelper().add(img!, withIdentifier: "logoimg", in: "png")
                                        UserDefaults.standard.set(data?.base64EncodedString(), forKey: "logoimagedata")
                                    }
                                }
                            }
                        }
                        else {
                            if error?.code == 401 {
                                self.showAlertMessage(withTitle: String(describing: error?.code), message: "Authorization Required")
                            } else {
                                self.showAlertMessage(withTitle: String(describing: error?.code), message: "Authorization Required")
                            }
                        }
                        self.performSegue(withIdentifier: "registerToFetchData", sender: nil)
                    })
                }
            }
        }
    }
    
    func clearData() {
        self.passwordTxtField.text = ""
    }
}
