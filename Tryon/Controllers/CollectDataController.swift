//
//  CollectDataController.swift
//  Tryon
//
//  Created by Udayakumar N on 22/03/17.
//  Copyright © 2017 1000Lookz. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import BetterSegmentedControl
import PhoneNumberKit
import Appsee


enum CustomerTypeIndex: UInt {
    case newToGlasses = 0
    case alreadyWearGlasses
}

protocol CollectDataDelegate: NSObjectProtocol {
    func collectDataSubmitDidTap()
    func collectDataSkipDidTap()
}

class CollectDataController: UIViewController, NVActivityIndicatorViewable {

    
    // MARK: - Class variables
    
    let model = TryonModel.sharedInstance
    weak var collectDataDelegate: CollectDataDelegate?
    
    let newCustomerTitleText = "Select your Driving type"
    let existingCustomerTitleText = "Select your existing Glass type"
    let mobileNumberEmptyText = "Mobile Number cannot be empty"
    let genderEmptyText = "Please select your gender"
    let ageGroupEmptyText = "Please select your age group"
    let drivingTypeEmptyText = "Please select your driving type"
    let frameTypeEmptyText = "Please select your existing frame type"
    let mobileNumberInvalidText = "Please enter valid phone number"
    
    let mobileNumberMaxLength = 10
    
    var selectedCustomerTypeIndex = CustomerTypeIndex.newToGlasses
    var selectedGender: Gender?
    var selectedAgeGroup: AgeGroup?
    var selectedFrameType: FrameType?
    var selectedDrivingType: DrivingType?
    var customerVideoType: String?
    
    @IBOutlet weak var customerTypeSegmentControl: BetterSegmentedControl!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var newCustomerVehicleView: UIView!
    @IBOutlet weak var existingCustomerGlassTypeView: UIView!
    @IBOutlet weak var mobileNumberTextField: UITextField!
    
    
    @IBAction func genderDidChange(_ sender: ISRadioButton) {
        if sender.titleLabel!.text == "Male" {
            selectedGender = .male
        } else if sender.titleLabel!.text == "Female" {
            selectedGender = .female
        }
    }
    
    @IBAction func ageGroupDidChange(_ sender: ISRadioButton) {
        if sender.titleLabel!.text == "<16" {
            selectedAgeGroup = .child
        } else if sender.titleLabel!.text == "16-25" {
            selectedAgeGroup = .young
        } else if sender.titleLabel!.text == "26-40" {
            selectedAgeGroup = .middle
        } else if sender.titleLabel!.text == "40+" {
            selectedAgeGroup = .old
        }
    }
    
    @IBAction func glassTypeDidChange(_ sender: ISRadioButton) {
        if sender.titleLabel!.text == "Full - rim" {
            selectedFrameType = .fullRim
        } else if sender.titleLabel!.text == "Half - rim" {
            selectedFrameType = .halfRim
        } else if sender.titleLabel!.text == "Rimless" {
            selectedFrameType = .rimLess
        }
        
        if mobileNumberTextField.text == "" {
            mobileNumberTextField.becomeFirstResponder()
        }
    }
    
    @IBAction func drivingTypeDidChange(_ sender: ISRadioButton) {
        if sender.titleLabel!.text == "Car" {
            selectedDrivingType = .car
        } else if sender.titleLabel!.text == "Bike" {
            selectedDrivingType = .bike
        } else if sender.titleLabel!.text == "Both" {
            selectedDrivingType = .both
        } else if sender.titleLabel!.text == "None" {
            selectedDrivingType = .noDriving
        }
        
        if mobileNumberTextField.text == "" {
            mobileNumberTextField.becomeFirstResponder()
        }
    }

    @IBAction func submitButtonDidTap(_ sender: UIButton) {
        if !(selectedGender != nil) {
            showAlertMessage(withTitle: "Error", message: genderEmptyText)
            
        } else if !(selectedAgeGroup != nil) {
            showAlertMessage(withTitle: "Error", message: ageGroupEmptyText)
            
        } else if mobileNumberTextField.text == "" {
            showAlertMessage(withTitle: "Error", message: mobileNumberEmptyText)
            
        } else if selectedCustomerTypeIndex == .newToGlasses && !(selectedDrivingType != nil) {
            showAlertMessage(withTitle: "Error", message: drivingTypeEmptyText)
            
        } else if selectedCustomerTypeIndex == .alreadyWearGlasses && !(selectedFrameType != nil) {
            showAlertMessage(withTitle: "Error", message: frameTypeEmptyText)
            
        } else {
            let phoneNumberKit = PhoneNumberKit()
            do {
                let phoneNumber = try phoneNumberKit.parse(mobileNumberTextField.text!)
                log.info("Valid Phone Number: \(phoneNumber)")
            }
            catch {
                //Invalid phone number
                showAlertMessage(withTitle: "Error", message: mobileNumberInvalidText)
                mobileNumberTextField.text = ""
                return
            }
            
            //Valid phone number
            var customerType: CustomerType?
            var frameType: FrameType?
            var drivingType: DrivingType?
            
            if selectedCustomerTypeIndex == .newToGlasses {
                customerType = .newToGlasses
                drivingType = self.selectedDrivingType
                
            } else if selectedCustomerTypeIndex == .alreadyWearGlasses {
                customerType = .alreadyWearGlasses
                frameType = self.selectedFrameType
            }
            
            if model.customer != nil {
                model.customer?.mobileNumber = mobileNumberTextField.text
                model.customer?.customerType = customerType
                model.customer?.frameType = frameType
                model.customer?.drivingType = drivingType
            } else {
                model.customer = Customer(imgUrl: "", mobileNumber: mobileNumberTextField.text, customerType: customerType, frameType: frameType, drivingType: drivingType)
            }
            
            if model.customerReport != nil {
                model.customerReport?.customerMobileNumber = mobileNumberTextField.text
                model.customerReport?.customerType = customerType?.rawValue
                model.customerReport?.customerVideoType = customerVideoType
                model.customerReport?.customerGender = selectedGender?.rawValue
                model.customerReport?.customerAge = selectedAgeGroup?.rawValue
            } else {
                let newCustomerReport = CustomerReport(deviceID: model.deviceId)
                newCustomerReport.customerMobileNumber = mobileNumberTextField.text
                newCustomerReport.customerType = customerType?.rawValue
                newCustomerReport.customerVideoType = customerVideoType
                newCustomerReport.customerGender = selectedGender?.rawValue
                newCustomerReport.customerAge = selectedAgeGroup?.rawValue
                model.customerReport = newCustomerReport
            }
            
            self.view.endEditing(true)
            self.collectDataDelegate?.collectDataSubmitDidTap()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func customerTypeDidChange(_ sender: BetterSegmentedControl) {
        if (sender as BetterSegmentedControl).index == CustomerTypeIndex.newToGlasses.rawValue {
            //New Customer
            selectedCustomerTypeIndex = .newToGlasses
        } else if (sender as BetterSegmentedControl).index == CustomerTypeIndex.alreadyWearGlasses.rawValue {
            // Existing Customer
            selectedCustomerTypeIndex = .alreadyWearGlasses
        } else {
            log.error("Incorrect Customer Type Segment")
        }
        
        updateUIForSelectedSegment()
    }
    
    @IBAction func skipButtonDidTap(_ sender: UIButton) {
        //Create an empty Customer Report
        if model.customerReport == nil {
            let newCustomerReport = CustomerReport(deviceID: model.deviceId)
            newCustomerReport.customerVideoType = customerVideoType
            model.customerReport = newCustomerReport
        }
        
        self.view.endEditing(true)
        self.collectDataDelegate?.collectDataSkipDidTap()
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Init functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customerTypeSegmentControl.titles = ["New to Glasses", "Already wear Glasses"]
        customerTypeSegmentControl.titleFont = UIFont(name: "SFUIText-Regular", size: 18)!
        customerTypeSegmentControl.selectedTitleFont = UIFont(name: "SFUIText-Regular", size: 18)!
        
        updateUIForSelectedSegment()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        Appsee.startScreen("CollectData")
        
        super.viewDidAppear(animated)
    }
    
    
    // MARK: - Helper functions
    
    func updateUIForSelectedSegment() {
        if selectedCustomerTypeIndex == .newToGlasses {
            titleLabel.text = newCustomerTitleText
            
            newCustomerVehicleView.alpha = 0
            newCustomerVehicleView.isHidden = false
            UIView.animate(withDuration: 0.2, animations: {
                self.existingCustomerGlassTypeView.alpha = 0
            }) { (finished) in
                self.existingCustomerGlassTypeView.isHidden = true
                UIView.animate(withDuration: 0.2, animations: {
                    self.newCustomerVehicleView.alpha = 1
                }) { (finished) in
                    // DO nothing
                }
            }
        } else {
            titleLabel.text = existingCustomerTitleText
            
            existingCustomerGlassTypeView.alpha = 0
            existingCustomerGlassTypeView.isHidden = false
            UIView.animate(withDuration: 0.2, animations: {
                self.newCustomerVehicleView.alpha = 0
            }) { (finished) in
                self.newCustomerVehicleView.isHidden = true
                UIView.animate(withDuration: 0.2, animations: {
                    self.existingCustomerGlassTypeView.alpha = 1
                }) { (finished) in
                    // DO nothing
                }
            }
        }
    }
    
    //Function to print all available fonts
    func printFonts() {
        let fontFamilyNames = UIFont.familyNames
        for familyName in fontFamilyNames {
            print("------------------------------")
            print("Font Family Name = [\(familyName)]")
            
            let names = UIFont.fontNames(forFamilyName: familyName)
            print("Font Names = [\(names)]")
        }
    }
}

// MARK: - TextField delegate

extension CollectDataController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        
        let newLength = text.utf16.count + string.utf16.count - range.length
        return newLength <= mobileNumberMaxLength
    }
    
}
