//
//  TrayController.swift
//  Tryon
//
//  Created by Udayakumar N on 24/01/18.
//  Copyright © 2018 Varun Raj. All rights reserved.
//

import UIKit
import RealmSwift
import DropDown
import EPSignature
import SearchTextField

class TrayController: BaseViewController , EPSignatureDelegate {
    
    let model = TryonModel.sharedInstance
    let realm = try! Realm()
    let accountDropDown = DropDown()
    let accountAddressDropDown = DropDown()
    let priceDropDown = DropDown()
    
    let numberFormatter = NumberFormatter()
    var accountIds:[Int] = []
    var accountNames:[String] = []
    var searchArray:[String] = []
    
    var price:[String] = []
    var itemAdded = [[String:String]]()
    var Val:[String:String] = [:]
    var invoices: [String: AnyObject]!
    var selectedInvoiceIndex: String!
    var invoiceNumber: Int?
    var nextNumberAsString: String!
    
    var location:Int?
    var selectedAddress: String?
    var selectedAccountId: Int?
    var selectedPrice: String?
    let nullAddressText = "- Null -"
    let defaultAddressText = "Select City"
    let defaultAccountText = "Select Account"
    let defaultPriceText = "PRICE"
    
    var userLookId : [String] = []

    @IBOutlet weak var contentHolderView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var accountSelectionView: UIView!
    @IBOutlet weak var accountAddressDropDownButton: UIButton!
    @IBOutlet weak var accountDropDownButton: UIButton!
    @IBOutlet weak var priceDropDownButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var exportButton: UIButton!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var clearBagButton: UIButton!
    @IBOutlet weak var dropIcon: UIImageView!
    @IBOutlet weak var totalQty: UILabel!
    
    @IBOutlet weak var signatureView: UIView!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var plainView: UIView!
    @IBOutlet weak var sucessLabel: UILabel!
    @IBOutlet weak var clearBtn: UIButton!
    @IBOutlet weak var clientClearBtn: UIButton!
    @IBOutlet weak var searchTextFields: SearchTextField!
    
    @IBOutlet weak var signatureImageView: UIImageView!
    @IBOutlet weak var clientSignatureImageView: UIImageView!
    @IBOutlet weak var salesManTabLabel: UILabel!
    @IBOutlet weak var clientTapLabel: UILabel!
    
    var prevPoint1: CGPoint!
    var prevPoint2: CGPoint!
    var lastPoint:CGPoint!
    var width: CGFloat!
    var salesIsTouch: Bool!
    var clientIsTouch: Bool!
    
    @IBAction func priceDropDownButtonDidTap(_ sender: UIButton) {
        priceDropDown.show()
        itemLoadArray()
    }
    @IBAction func accountAddressDropDownButtonDidTap(_ sender: UIButton) {
        accountAddressDropDown.show()
    }
    @IBAction func accountDropDownButtonDidTap(_ sender: UIButton) {
        accountDropDown.show()
    }
    
    @IBAction func subtmitButtonDidTap(_ sender: UIButton) {
        //Dismiss Keyboard
            if  self.searchTextFields.text != "" {
                if let string = self.searchTextFields.text {
                    let indexArray = self.searchArray.indices.filter { self.searchArray[$0].localizedCaseInsensitiveContains(string) }
                    
                    if self.accountIds.count != 0{
                        self.selectedAccountId = self.accountIds[indexArray[0]]
                        self.location = indexArray[0]
                        
                        self.plainView.isHidden = false
                    }
                }
            } else {
                self.plainView.isHidden = true
                self.showAlertMessage(withTitle: "Oops", message: "Select Location.")
            }
    }
    
    @IBAction func clearAllButtonDidTap(_ sender: UIButton) {
        TrayHelper().removeAllInventoryFrameFromTray()
        
        let trayCount = TrayHelper().trayInventoryFramesCount()
        if let tabBarController = self.tabBarController as? MainTabBarController {
            tabBarController.updateTrayBadgeCount(withCount: trayCount)
        }
        updateUI(forCount: trayCount)
        
        self.tableView.reloadData()
        invoiceNumber = nil
        
        UserDefaults.standard.set(nil, forKey: "userLookId")

        self.priceDropDownButton.setTitle(defaultPriceText, for: .normal)
        self.accountAddressDropDownButton.setTitle(defaultAddressText, for: .normal)

        self.searchTextFields.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        configureUI()
        
            searchTextFields.isHidden = false
            searchTextFields.isUserInteractionEnabled = true
            accountDropDownButton.isHidden = true
            accountDropDownButton.isUserInteractionEnabled = false
            searchTextFields.font = UIFont(name: "SFUIText-Regular ", size: 18)
            searchTextFields.textColor = UIColor.primaryDarkColor
            self.searchTextFields.placeholder = "Select Account"

        clientTapLabel.isHidden = false
        salesManTabLabel.isHidden = false
        
        let stencilImage = UIImage.init(named: "CloseIcon")
        let stencil = stencilImage?.withRenderingMode(.alwaysTemplate) // use your UIImage here
        cancelButton.setImage(stencil, for: .normal) // assign it to your UIButton
        cancelButton.tintColor = UIColor.primaryDarkColor
        
        clientTapLabel.isHidden = false
        salesManTabLabel.isHidden = false
        
        width = 3.0
        
        let image = UIImage(named: "DownArrowIcon")?.withRenderingMode(.alwaysTemplate)
        dropIcon.tintColor = UIColor(red: 178/255.0, green: 178/255, blue: 178/255, alpha: 1.0) // Change to custom green color
        dropIcon.image = image
        priceDropDown.borderColor = UIColor.clear
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.maximumFractionDigits = 2
        
        plainView.isHidden = true
        signatureView.layer.cornerRadius = 10.0
        signatureView.addShadowView()
        signatureView.masksToBounds = true
        
        let sales = UITapGestureRecognizer(target: self, action: #selector(self.salesTouchHappen(_:)))
        signatureImageView.addGestureRecognizer(sales)
        signatureImageView.isUserInteractionEnabled = true
        
        let Client = UITapGestureRecognizer(target: self, action: #selector(self.clientTouchHappen(_:)))
        clientSignatureImageView.addGestureRecognizer(Client)
        clientSignatureImageView.isUserInteractionEnabled = true
        
        commentTextView.layer.borderColor = UIColor.primaryDarkColor.cgColor
        commentTextView.layer.borderWidth = 2.0
        commentTextView.masksToBounds = true
        commentTextView.delegate = self
        commentTextView.text = "Enter your comments here"
        commentTextView.textColor = UIColor.lightGray
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        itemAdded.removeAll()
        
        if signatureImageView.image == nil {
            clearBtn.isHidden = true
            salesManTabLabel.isHidden = false
        }
        
        if clientSignatureImageView.image == nil {
            clientClearBtn.isHidden = true
            clientTapLabel.isHidden = false
        }
        let trayCount = TrayHelper().trayInventoryFramesCount()
        updateUI(forCount: trayCount)
        
        //Update Total
        var total = 0.0
        var totalQty = 0
        
        var qun : String!
        
        for frame in TrayHelper().trayInventoryFrames() {
            
            if UserDefaults.standard.array(forKey: "userLookId") != nil  {
                
                userLookId = UserDefaults.standard.array(forKey: "userLookId") as! [String]
                if let lookId = frame.lookzId {
                    
                    let indexArray = userLookId.indices.filter({ userLookId[$0].localizedCaseInsensitiveContains(lookId) })
                    print(userLookId,"Set Quantity")
                    
                    if indexArray.count != 0{
                        let quan = userLookId[indexArray[0]] as String
                        let str = quan.strstr(needle: "|")
                        
                        if str == nil{
                            qun  = "1"
                        }else{
                            qun = str!
                        }
                    }else{
                        qun = String(frame.orderQuantityCount)
                    }
                }
            }else{
                qun = String(frame.orderQuantityCount)
            }
            
            if self.priceDropDownButton.titleLabel?.text == "DP"{
                if let price = frame.priceDistributor.value {
                    total = total + (price * Double(qun)!)//(price * Double(frame.orderQuantityCount))
                }
            } else {
                if let price = frame.price.value {
                    total = total + (price * Double(qun)!)//Double(frame.orderQuantityCount))
                }
            }
//            if let price = frame.price.value {
//                total = total + (price * Double(frame.orderQuantityCount))
//            }
            if let qty:Int = Int(qun) {//frame.orderQuantityCount {
                totalQty = totalQty + qty
            }
        }
        self.totalLabel.text = numberFormatter.string(from: NSNumber(value: total))
        self.totalQty.text = String(totalQty)
        self.tableView.reloadData()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first  {
            prevPoint1 = touch.previousLocation(in:self.view)
            prevPoint2 = touch.previousLocation(in:self.view)
            lastPoint = touch.location(in:self.view)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if salesIsTouch == true{
            if let touch = touches.first {
                let currentPoint = touch.location(in: signatureImageView)
                prevPoint2 = prevPoint1
                prevPoint1 = touch.previousLocation(in: signatureImageView)
                
                UIGraphicsBeginImageContext(signatureImageView.frame.size)
                guard let context = UIGraphicsGetCurrentContext() else {
                    return
                }
                context.move(to:prevPoint2)
                context.addQuadCurve(to: prevPoint1, control: prevPoint2)
                context.setLineCap(.butt)
                context.setLineWidth(width)
                context.setStrokeColor(UIColor.black.cgColor)
                context.setBlendMode(.normal)
                context.strokePath()
                
                signatureImageView.image?.draw(in: CGRect(x: 0, y: 0, width: signatureImageView.frame.size.width, height: signatureImageView.frame.size.height), blendMode: .overlay, alpha: 1.0)
                signatureImageView.image = UIGraphicsGetImageFromCurrentImageContext()
                
                UIGraphicsEndImageContext()
                lastPoint = currentPoint
            }
            
        } else if (clientIsTouch == true) {
            
            if let touch = touches.first {
                let currentPoint = touch.location(in: clientSignatureImageView)
                prevPoint2 = prevPoint1
                prevPoint1 = touch.previousLocation(in: clientSignatureImageView)
                
                UIGraphicsBeginImageContext(clientSignatureImageView.frame.size)
                guard let context = UIGraphicsGetCurrentContext() else {
                    return
                }
                
                context.move(to:prevPoint2)
                context.addQuadCurve(to: prevPoint1, control: prevPoint2)
                context.setLineCap(.butt)
                context.setLineWidth(width)
                context.setStrokeColor(UIColor.black.cgColor)
                context.setBlendMode(.normal)
                context.strokePath()
                
                clientSignatureImageView.image?.draw(in: CGRect(x: 0, y: 0, width: clientSignatureImageView.frame.size.width, height: clientSignatureImageView.frame.size.height), blendMode: .overlay, alpha: 1.0)
                clientSignatureImageView.image = UIGraphicsGetImageFromCurrentImageContext()
                
                UIGraphicsEndImageContext()
                lastPoint = currentPoint
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    func initData() {
        var qun : String!
        var districtDict: [String: String] = [:]
        for dbUser in self.model.relatedDBUsers {
            accountIds.append(dbUser.id)
            accountNames.append(dbUser.name)
            
            if let district = dbUser.district {
                districtDict.updateValue(district, forKey: district)
            } else {
                districtDict.updateValue(nullAddressText, forKey: "Null")
            }
        }
        var districtArray: [String] = []
        for district in districtDict.values {
            districtArray.append(district)
        }
        
        accountAddressDropDownButton.setTitle(defaultAddressText, for: .normal)
        accountAddressDropDown.dataSource = districtArray.sorted()
        accountAddressDropDown.selectionAction = { [weak self] (index, item) in
            self?.accountAddressDropDownButton.setTitle(item, for: .normal)
            self?.selectedAddress = item
            
            self?.accountIds = []
            self?.accountNames = []
            
            let correctedItem: String?
            if item == self?.nullAddressText {
                correctedItem = nil
            } else {
                correctedItem = item
            }
            let filteredAccounts = self?.model.relatedDBUsers.filter { $0.district == correctedItem }
            
            for dbUser in filteredAccounts! {
                self?.accountIds.append(dbUser.id)
                self?.accountNames.append(dbUser.name)
            }
            self?.accountDropDown.dataSource = (self?.accountNames)!
        
                self?.searchTextFields.filterStrings((self?.accountNames.sorted())!)
                self?.searchArray = (self?.accountNames)!
                self?.searchTextFields.placeholder = "Select Account"
                self?.searchTextFields.becomeFirstResponder()
            
           self?.searchTextFields.text = ""
        }
        
        accountDropDownButton.setTitle(defaultAccountText, for: .normal)
        accountDropDown.dataSource = accountNames
        accountDropDown.selectionAction = { [weak self] (index, item1) in
            self?.location = index
            self?.accountDropDownButton.setTitle(item1, for: .normal)
            self?.selectedAccountId = self?.accountIds[index]
        }
        price = ["DP", "SP"]
        priceDropDownButton.setTitle(defaultPriceText, for: .normal)
        priceDropDown.dataSource = price
        priceDropDown.selectionAction = { [weak self] (index, item2) in
            self?.priceDropDownButton.setTitle(item2, for: .normal)
            self?.selectedPrice = self?.price[index]
            
            //pricelabel and multiple qty price
            let frame = TrayHelper().trayInventoryFrames()
            
            self?.tableView.reloadData()
            
            var total:Int = 0
            for i in 0..<TrayHelper().trayInventoryFramesCount() {
                //Calculate Price x Quantity
                if UserDefaults.standard.array(forKey: "userLookId") != nil  {
                    
                    let userLookId = UserDefaults.standard.array(forKey: "userLookId") as! [String]
                    if let lookId = frame[i].lookzId {
                        
                        let indexArray = userLookId.indices.filter({ userLookId[$0].localizedCaseInsensitiveContains(lookId) })
                        print(userLookId,"Set Quantity")
                        
                        if indexArray.count != 0{
                            let quan = userLookId[indexArray[0]] as String
                            let str = quan.strstr(needle: "|")
                            
                            if str == nil{
                                qun  = "1"
                            }else{
                                qun = str!
                            }
                        }else{
                            qun = String(frame[i].orderQuantityCount)
                        }
                    }
                }else{
                    qun = String(frame[i].orderQuantityCount)
                }
                var calcPriceText: String?
                if self?.selectedPrice == "DP"{
                    if let price = frame[i].priceDistributor.value {
                        calcPriceText = self?.numberFormatter.string(from: NSNumber(value: price * Double(qun)!))//Double(frame[i].orderQuantityCount)))
                        if calcPriceText == nil {
                            calcPriceText = "0"
                            //cell.priceMultiByQuantityLabel.text = calcPriceText
                        } else {
                            //cell.priceMultiByQuantityLabel.text = calcPriceText
                        }
                    }
                } else {
                    if let price = frame[i].price.value {
                        calcPriceText = self?.numberFormatter.string(from: NSNumber(value: price * Double(qun)!))//Double(frame[i].orderQuantityCount)))
                        if calcPriceText == nil {
                            calcPriceText = "0"
                            //cell.priceMultiByQuantityLabel.text = calcPriceText
                        } else {
                            //cell.priceMultiByQuantityLabel.text = calcPriceText
                        }
                    }
                }
                
                if calcPriceText == nil {
                    calcPriceText = "0"
                    //cell.priceMultiByQuantityLabel.text = calcPriceText
                }
                
                var dat = self?.itemAdded[i]
                dat?.updateValue(calcPriceText!, forKey: "Subtotal")
                self?.itemAdded[i] = dat!
            }
            for j in 0..<TrayHelper().trayInventoryFramesCount() {
                var dat = self?.itemAdded[j]
                total = total + Int(dat!["Subtotal"]!)!
            }
            DispatchQueue.global(qos: .background).sync {
                self?.totalLabel.text = String(describing: total)
            }
        }
    }
    
    func configureUI() {
        self.tableView.backgroundColor = UIColor.white
        self.headerView.backgroundColor = UIColor.white
        self.footerView.backgroundColor = UIColor.white
        self.clearBagButton.setTitleColor(UIColor.primaryDarkColor, for: .normal)
        
        self.headerView.addCornerRadius(20.0, inCorners: [.topLeft, .topRight])
        self.footerView.addCornerRadius(20.0, inCorners: [.bottomLeft, .bottomRight])
        
        self.contentHolderView.layer.shadowColor = UIColor.lightGray.cgColor
        self.contentHolderView.layer.shadowOffset = CGSize(width: 4, height: 4)
        self.contentHolderView.layer.shadowOpacity = 0.6
        self.contentHolderView.layer.shadowRadius = 6.0
        self.contentHolderView.clipsToBounds = false
        self.contentHolderView.layer.masksToBounds = false
        self.contentHolderView.layer.shouldRasterize = true
        self.contentHolderView.layer.rasterizationScale = UIScreen.main.scale
        
        accountDropDown.anchorView = accountDropDownButton
        accountDropDown.bottomOffset = CGPoint(x: 0, y:(accountDropDown.anchorView?.plainView.bounds.height)!)
        accountDropDown.backgroundColor = UIColor.white
        accountDropDown.selectionBackgroundColor = UIColor.mainBackgroundColor
        accountDropDown.cellHeight = 50
        
        accountAddressDropDown.anchorView = accountAddressDropDownButton
        accountAddressDropDown.bottomOffset = CGPoint(x: 0, y:(accountAddressDropDown.anchorView?.plainView.bounds.height)!)
        accountAddressDropDown.backgroundColor = UIColor.white
        accountAddressDropDown.selectionBackgroundColor = UIColor.mainBackgroundColor
        accountAddressDropDown.cellHeight = 50
        
        priceDropDown.anchorView = priceDropDownButton
        priceDropDown.bottomOffset = CGPoint(x: 0, y:(priceDropDown.anchorView?.plainView.bounds.height)!)
        priceDropDown.backgroundColor = UIColor.white
        priceDropDown.selectionBackgroundColor = UIColor.mainBackgroundColor
        priceDropDown.cellHeight = 50
        
    }
    
    func updateUI(forCount count: Int) {
        if count > 0 {
            self.emptyLabel.isHidden = true
            self.tableView.isHidden = false
            self.accountSelectionView.isHidden = false
            self.footerView.isHidden = false
        } else {
            self.emptyLabel.isHidden = false
            self.tableView.isHidden = true
            self.accountSelectionView.isHidden = true
            self.footerView.isHidden = true
        }
    }
    
    func salesTouchHappen(_ sender: UITapGestureRecognizer) {
        salesManTabLabel.isHidden = true
        clearBtn.isHidden = false
        commentTextView.resignFirstResponder()
        signatureImageView.image = nil
        
        let signatureVC = EPSignatureViewController(signatureDelegate: self, showsDate: true, showsSaveSignatureOption: true)
        signatureVC.subtitleText = "I agree to the terms and conditions"
        signatureVC.title = "SalesMan"
        let nav = UINavigationController(rootViewController: signatureVC)
        present(nav, animated: true, completion: nil)
    }
    
    func clientTouchHappen(_ sender: UITapGestureRecognizer) {
        clientTapLabel.isHidden = true
        clientClearBtn.isHidden = false
        commentTextView.resignFirstResponder()
        clientSignatureImageView.image = nil
        
        let signatureVC = EPSignatureViewController(signatureDelegate: self, showsDate: true, showsSaveSignatureOption: true)
        signatureVC.subtitleText = "I agree to the terms and conditions"
        signatureVC.title = "CLIENT"
        let nav = UINavigationController(rootViewController: signatureVC)
        present(nav, animated: true, completion: nil)
    }
    
    @IBAction func clearBtnAction(_ sender: Any) {
        signatureImageView.image = nil
        salesManTabLabel.isHidden = false
        clearBtn.isHidden = true
    }
    
    @IBAction func clientClearBtnAction(_ sender: Any) {
        clientSignatureImageView.image = nil
        clientTapLabel.isHidden = false
        clientClearBtn.isHidden = true
    }
    
    @IBAction func cancelBtnAction(_ sender: Any) {
        self.plainView.isHidden = true
        signatureImageView.image = nil
        clientSignatureImageView.image = nil
        clientTapLabel.isHidden = false
        salesManTabLabel.isHidden = false
        clientClearBtn.isHidden = true
        clearBtn.isHidden = true
        commentTextView.text = "Enter your comments here"
        commentTextView.textColor = UIColor.lightGray
    }
    
    func itemLoadArray() {

        for i in 0..<TrayHelper().trayInventoryFramesCount(){
            let frame = TrayHelper().trayInventoryFrames()[i]

            //Set Price
            var priceText: String? = "0"
            if self.selectedPrice == "DP"{
                if let price = frame.priceDistributor.value {
                    if price > 0 {
                        priceText = numberFormatter.string(from: NSNumber(value: price))
                    }
                }
            } else {
                if let price = frame.price.value {
                    if price > 0 {
                        priceText = numberFormatter.string(from: NSNumber(value: price))
                    }
                    else {
                        priceText = "0"
                    }
                }
            }
            
            //Calculate Price x Quantity
            var qunStr : String!
            if UserDefaults.standard.array(forKey: "userLookId") != nil  {
                userLookId = UserDefaults.standard.array(forKey: "userLookId") as! [String]
                if let lookId = frame.lookzId {
                    let indexArray = userLookId.indices.filter({ userLookId[$0].localizedCaseInsensitiveContains(lookId) })
                    if indexArray.count != 0{
                        let quan = userLookId[indexArray[0]] as String
                        print(quan)
                        let str = quan.strstr(needle: "|")
                        if str == nil{
                            qunStr = "1"
                            //   frame.orderQuantityCount = Int(cell.quantityTextField.text!)!
                         }else{
                            print(str!)
                            qunStr = str!
                            //  frame.orderQuantityCount = Int(cell.quantityTextField.text!)!
                        }
                        
                    }else{
                        qunStr = String(frame.orderQuantityCount)
                        //  frame.orderQuantityCount = Int(cell.quantityTextField.text!)!
                    }
                }
            }else{
                qunStr = String(frame.orderQuantityCount)
                // frame.orderQuantityCount = Int(cell.quantityTextField.text!)!
            }
            var calcPriceText: String?
            if self.selectedPrice == "DP"{
                if let price = frame.priceDistributor.value {
                    calcPriceText = numberFormatter.string(from: NSNumber(value: price * Double(Int(qunStr)!)))
                }
            } else {
                if let price = frame.price.value {
                    calcPriceText = numberFormatter.string(from: NSNumber(value: price * Double(Int(qunStr)!)))
                }
            }
            let modelItem: String = frame.productName! + " " + frame.modelNumber!
            let index = String(i+1)
            let quantity = String(Int(qunStr)!)
            
            if  calcPriceText == nil {
                calcPriceText = "0"
            }
            if  priceText == nil {
                priceText = "0"
            }
            
            Val = ["S.No":index,
                     "Item":modelItem,
                     "Price":priceText,
                     "Quantity":quantity,
                     "Subtotal":calcPriceText] as! [String:String]
           
            itemAdded.append(Val)
        }
    }
    
    @IBAction func SaveToPdf(_ sender: Any) {
        
        itemLoadArray()
        if signatureImageView.image != nil  && clientSignatureImageView.image != nil {
            self.plainView.isHidden = true
            if location != nil  {
                
                let senderinfo = self.model.relatedDBUsers.filter { $0.district == selectedAddress }[location!]
                let arr = senderinfo.name + ",<br>" + senderinfo.address1! + ",<br>" + senderinfo.district! + ",<br>" + senderinfo.pincode!
                
                let array = ["invoiceNumber":  "ORD-"  as AnyObject, "invoiceDate": self.formatAndGetCurrentDate() as AnyObject, "recipientInfo": arr as AnyObject, "totalAmount": totalLabel.text as AnyObject, "items": itemAdded as AnyObject, "totalQty": self.totalQty.text as AnyObject]
                
                invoices = array
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "tabClose"), object: nil)
                performSegue(withIdentifier: "exportPdf", sender: self)
                clearAllButtonDidTap(self.clearBagButton)
                
                self.searchTextFields.text = ""
            }
            else {
                self.showAlertMessage(withTitle: "Oops", message: "Select Location.")
            }
        } else {
            if signatureImageView.image == nil && clientSignatureImageView.image == nil {
                let alert = UIAlertController(title: "Oops",
                                              message: "Client & Salesman Signature is Empty",
                                              preferredStyle: UIAlertControllerStyle.alert)
                let cancelAction = UIAlertAction(title: "OK",
                                                 style: .cancel, handler: nil)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            } else {
                if signatureImageView.image == nil {
                    let alert = UIAlertController(title: "Oops",
                                                  message: "Salesman Signature is Empty",
                                                  preferredStyle: UIAlertControllerStyle.alert)
                    let cancelAction = UIAlertAction(title: "OK",
                                                     style: .cancel, handler: nil)
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true, completion: nil)
                }
                
                if clientSignatureImageView.image == nil {
                    
                    let alert = UIAlertController(title: "Oops",
                                                  message: "Client Signature is Empty",
                                                  preferredStyle: UIAlertControllerStyle.alert)
                    let cancelAction = UIAlertAction(title: "OK",
                                                     style: .cancel, handler: nil)
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func exportButtonDidTap(_ sender: UIButton) {
        
        var address1: String = ""
        
        if signatureImageView.image != nil  && clientSignatureImageView.image != nil {
            if let accountId = self.selectedAccountId {
                if TrayHelper().trayInventoryFramesCount() > 0 {
                    
                    var frameIds: [Int] = []
                    var quantity: [Int] = []
                    for frame in TrayHelper().trayInventoryFrames() {
                        frameIds.append(frame.id)
                        quantity.append(frame.orderQuantityCount)
                    }
                    let date:String = self.formatAndGetCurrentDate()
                    let timestamp = NSDate().timeIntervalSince1970
                    let myTimeInterval = TimeInterval(timestamp)
                    let time = NSDate(timeIntervalSince1970: TimeInterval(myTimeInterval))
                    
                    self.activityIndicator?.startAnimating()
                    TrayHelper().addItemsToCart(orderbyId: self.model.userId, accountId: accountId, frameIds: frameIds, quantity: quantity, orderDatetime: time as Date, orderStatusId: 1, completionHandler: { (orderDetails, error) in
                        if error == nil {
                            TrayHelper().placeOrder(orderbyId: self.model.userId, accountId: accountId, itemDetails: orderDetails, orderDatetime: Date(), orderStatusId: 2, comment: self.commentTextView.text , completionHandler: { (result, error) in

                                self.invoiceNumber = result[0].value(forKey: "account_order_id") as? Int
                                
                                self.activityIndicator?.stopAnimating()
                                if error == nil {
                                    self.itemLoadArray()

                                    self.plainView.isHidden = true
                                    if self.location != nil && self.invoiceNumber != nil {
                                        
                                        let senderinfo = self.model.relatedDBUsers.filter { $0.district == self.selectedAddress }[self.location!]
                                        let arr = senderinfo.name + ",<br>" + senderinfo.address1! + ",<br>" + senderinfo.district! + ",<br>" + senderinfo.pincode!
                                        
                                        if self.self.invoiceNumber! < 10 {
                                            self.nextNumberAsString = "000000\(String(describing: self.invoiceNumber!))"
                                        }
                                        else if self.self.invoiceNumber! < 100 {
                                            self.nextNumberAsString = "00000\(String(describing: self.invoiceNumber!))"
                                        }
                                        else if self.invoiceNumber! < 1000 {
                                            self.nextNumberAsString = "0000\(String(describing: self.self.invoiceNumber!))"
                                        }
                                        else if self.invoiceNumber! < 10000 {
                                            self.nextNumberAsString = "000\(String(describing: self.invoiceNumber!))"
                                        }
                                        else if self.invoiceNumber! < 100000 {
                                            self.nextNumberAsString = "00\(String(describing: self.invoiceNumber!))"
                                        }
                                        else if self.invoiceNumber! < 1000000 {
                                            self.nextNumberAsString = "0\(String(describing: self.invoiceNumber!))"
                                        }
                                        else {
                                            self.nextNumberAsString = "\(String(describing: self.invoiceNumber!))"
                                        }
                                        
                                        let array = ["invoiceNumber":  "ORD-" + self.nextNumberAsString as AnyObject, "invoiceDate": self.formatAndGetCurrentDate() as AnyObject, "recipientInfo": arr as AnyObject, "totalAmount": self.totalLabel.text as AnyObject, "items": self.itemAdded as AnyObject, "totalQty": self.totalQty.text as AnyObject]
                                        self.invoices = array
                                        
                                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "tabClose"), object: nil)
                                        self.performSegue(withIdentifier: "exportPdf", sender: self)
                                        self.clearAllButtonDidTap(sender)
                                        
                                    }
                                    else {
                                        self.showAlertMessage(withTitle: "Oops", message: "Select Location.")
                                    }
                                    
                                } else {
                                    self.showAlertMessage(withTitle: "Error", message: "Error in add the items to cart. Please try after sometime.")
                                }
                            })
                        } else {
                            self.activityIndicator?.stopAnimating()
                            self.showAlertMessage(withTitle: "Error", message: "Error in Placing Order. Please try after sometime.")
                        }
                    })
                } else {
                    self.showAlertMessage(withTitle: "Error", message: "Add frames to the Cart before submission")
                }
            } else {
                self.showAlertMessage(withTitle: "Error", message: "Choose the account before submission")
            }
            
            
        } else {
            
            if signatureImageView.image == nil && clientSignatureImageView.image == nil {
                let alert = UIAlertController(title: "Oops",
                                              message: "Client & Salesman Signature is Empty",
                                              preferredStyle: UIAlertControllerStyle.alert)
                let cancelAction = UIAlertAction(title: "OK",
                                                 style: .cancel, handler: nil)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            } else {
                if signatureImageView.image == nil {
                    let alert = UIAlertController(title: "Oops",
                                                  message: "Salesman Signature is Empty",
                                                  preferredStyle: UIAlertControllerStyle.alert)
                    let cancelAction = UIAlertAction(title: "OK",
                                                     style: .cancel, handler: nil)
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true, completion: nil)
                }
                
                if clientSignatureImageView.image == nil {
                    
                    let alert = UIAlertController(title: "Oops",
                                                  message: "Client Signature is Empty",
                                                  preferredStyle: UIAlertControllerStyle.alert)
                    let cancelAction = UIAlertAction(title: "OK",
                                                     style: .cancel, handler: nil)
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func epSignature(_: EPSignature.EPSignatureViewController, didCancel error: NSError) {
        
        if signatureImageView.image == nil  {
            salesManTabLabel.isHidden = false
            clearBtn.isHidden = true
        }
        if clientSignatureImageView.image == nil {
            clientTapLabel.isHidden  = false
            clientClearBtn.isHidden = true
        }
    }
    
    func epSignature(_: EPSignature.EPSignatureViewController, didSign signatureImage: UIImage, boundingRect: CGRect) {
        if signatureImageView.image == nil && salesManTabLabel.isHidden == true {
            signatureImageView.image = signatureImage
        } else if clientSignatureImageView.image == nil && clientTapLabel.isHidden == true {
            clientSignatureImageView.image = signatureImage
        }
    }
}

extension TrayController: UITableViewDataSource, UITableViewDelegate ,UITextViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TrayHelper().trayInventoryFramesCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let frame = TrayHelper().trayInventoryFrames()[indexPath.row]
        
        let cellIdentifier = "trayCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! TrayCell
        
        //Set Serial number
        cell.serialNumberLabel.text = String(indexPath.row + 1)
        
        //Set Image
        cell.thumbnailImageView.af_setImage(withURL: URL(string: frame.thumbnailImageUrl!)!)
        
        //Set Details
        let formattedString = NSMutableAttributedString()
        formattedString
            .normal((frame.brand?.name)!.uppercased(), size: 15, color: UIColor.black)
            .normal("\n" + (frame.modelNumber)!.uppercased(), size: 14, color: UIColor.darkGray)
        cell.detailsLabel.attributedText = formattedString
        
        //Set Price
        var priceText: String? = "0"
        if self.selectedPrice == "DP"{
            if let price = frame.priceDistributor.value {
                if price > 0 {
                    priceText = numberFormatter.string(from: NSNumber(value: price))
                }
            }
        } else {
            if let price = frame.price.value {
                if price > 0 {
                    priceText = numberFormatter.string(from: NSNumber(value: price))
                }
                else {
                    priceText = "0"
                }
            }
        }
        cell.priceLabel.text = priceText
        
        //Set Quantity
        if UserDefaults.standard.array(forKey: "userLookId") != nil  {
            
            userLookId = UserDefaults.standard.array(forKey: "userLookId") as! [String]
            if let lookId = frame.lookzId {
                
                let indexArray = userLookId.indices.filter({ userLookId[$0].localizedCaseInsensitiveContains(lookId) })
                print(userLookId,"Set Quantity")
                
                if indexArray.count != 0{
                    let quan = userLookId[indexArray[0]] as String
                    let str = quan.strstr(needle: "|")
                    if str == nil{
                        cell.quantityTextField.text = "1"
                    }else{
                        print(str!)
                        cell.quantityTextField.text = str!
                    }
                }else{
                    cell.quantityTextField.text = String(frame.orderQuantityCount)
                    //  frame.orderQuantityCount = Int(cell.quantityTextField.text!)!
                }
            }
        }else{
            cell.quantityTextField.text = String(frame.orderQuantityCount)
            // frame.orderQuantityCount = Int(cell.quantityTextField.text!)!
        }
        
        //Calculate Price x Quantity
        var calcPriceText: String?
        if self.selectedPrice == "DP"{
            if let price = frame.priceDistributor.value {
                calcPriceText = numberFormatter.string(from: NSNumber(value: price * Double(Int(cell.quantityTextField.text!)!)))
                if calcPriceText == nil {
                    calcPriceText = "0"
                    cell.priceMultiByQuantityLabel.text = calcPriceText
                } else {
                    cell.priceMultiByQuantityLabel.text = calcPriceText
                }
            }
        } else {
            if let price = frame.price.value {
                calcPriceText = numberFormatter.string(from: NSNumber(value: price * Double(Int(cell.quantityTextField.text!)!)))
                if calcPriceText == nil {
                    calcPriceText = "0"
                    cell.priceMultiByQuantityLabel.text = calcPriceText
                } else {
                    cell.priceMultiByQuantityLabel.text = calcPriceText
                }
            }
        }
        
        cell.trayDelegate = self
        if UserDefaults.standard.array(forKey: "userLookId") != nil{
            
            userLookId = UserDefaults.standard.array(forKey: "userLookId") as! [String]
            if let lookId = frame.lookzId {
                let indexArray = userLookId.indices.filter({ userLookId[$0].localizedCaseInsensitiveContains(lookId) })
            
                if indexArray.count != 0{
                    let quan = userLookId [indexArray[0]]
                   // print("Cell Did load",quan)
                    cell.quantityTextField.tag = 10
                }else{
                    cell.quantityTextField.tag = indexPath.row
                }
            }
        }
        cell.quantityTextField.tag = indexPath.row

        return cell
    }
    
    func formatAndGetCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        return dateFormatter.string(from: NSDate() as Date)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let frame = TrayHelper().trayInventoryFrames()[indexPath.row]
        self.performSegue(withIdentifier: "trayToFrameDetailSegue", sender: frame)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "tabClose"), object: nil)
        if let detailFrameController = segue.destination as? DetailFrameController {
            let frame = sender as! InventoryFrame
            detailFrameController.frame = frame
        }
        
        if let identifier = segue.identifier {
            if identifier == "exportPdf" {
                let previewViewController = segue.destination as! PreviewViewController
                previewViewController.invoiceInfo = invoices
                previewViewController.salesSignImage = signatureImageView.image
                previewViewController.clientSignImage = clientSignatureImageView.image
                previewViewController.descriptions = commentTextView.text
                signatureImageView.image = nil
                commentTextView.text = "Enter your comments here"
                commentTextView.textColor = UIColor.lightGray
                clientSignatureImageView.image = nil
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if !commentTextView.text!.isEmpty && commentTextView.text! == "Enter your comments here" {
            commentTextView.text = ""
            commentTextView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if commentTextView.text.isEmpty {
            commentTextView.text = "Enter your comments here"
            commentTextView.textColor = UIColor.lightGray
        }
    }
}

extension TrayController: TrayDelegate {
    func removeDidTap(trayCell: TrayCell) {
        
        var qunti : String!
        itemLoadArray()
        var quntis : String!
        
        let indexPath = self.tableView.indexPath(for: trayCell)
        itemAdded.remove(at: (indexPath?.row)!)
        
        let frameToBeRemove = TrayHelper().trayInventoryFrames()[(indexPath?.row)!]
        let _ = TrayHelper().addInventoryFrameToTray(frameToBeRemove)
        
        
        let trayCount = TrayHelper().trayInventoryFramesCount()
        if let tabBarController = self.tabBarController as? MainTabBarController {
            tabBarController.updateTrayBadgeCount(withCount: trayCount)
        }
        updateUI(forCount: trayCount)
        var totalQty = 0
        
        var total = 0.0
        for frame in TrayHelper().trayInventoryFrames() {
            
            if UserDefaults.standard.array(forKey: "userLookId") != nil  {
                
                userLookId = UserDefaults.standard.array(forKey: "userLookId") as! [String]
                if let lookId = frame.lookzId {
                    
                    let indexArray = userLookId.indices.filter({ userLookId[$0].localizedCaseInsensitiveContains(lookId) })
                    
                    //                    print(userLookId,"Set Quantity")
                    
                    if indexArray.count != 0{
                        
                        let quan = userLookId[indexArray[0]] as String
                        
                        let str = quan.strstr(needle: "|")
                        
                        if str == nil{
                            quntis = "1"
                        }else{
                            quntis = str!
                        }
                    }else{
                        quntis = String(frame.orderQuantityCount)
                    }
                }
            }else{
                quntis = String(frame.orderQuantityCount)
            }
            if self.selectedPrice == "DP"{
                if let price = frame.priceDistributor.value {
                    total = total + (price * Double(Int(quntis)!))
                }
            } else {
                if let price = frame.price.value {
                    total = total + (price * Double(Int(quntis)!))
                }
            }
        }
        self.totalLabel.text = numberFormatter.string(from: NSNumber(value: total))
        
        for i in 0..<TrayHelper().trayInventoryFrames().count {
            var dat = itemAdded[i]
            dat.updateValue(String(describing:i+1), forKey: "S.No")
            itemAdded[i] = dat
        }
        
        if UserDefaults.standard.array(forKey: "userLookId") != nil{
            
            userLookId = UserDefaults.standard.array(forKey: "userLookId") as! [String]
            if let lookId = frameToBeRemove.lookzId {
                
                let indexArray = userLookId.indices.filter({ userLookId[$0].localizedCaseInsensitiveContains(lookId) })
                
                if indexArray.count != 0{
                    userLookId.remove(at: indexArray[0])
                }
            }
            UserDefaults.standard.set(userLookId , forKey: "userLookId")
            
        }
        
        for frame in TrayHelper().trayInventoryFrames() {
            
            if UserDefaults.standard.array(forKey: "userLookId") != nil  {
                
                userLookId = UserDefaults.standard.array(forKey: "userLookId") as! [String]
                if let lookId = frame.lookzId {
                    
                    let indexArray = userLookId.indices.filter({ userLookId[$0].localizedCaseInsensitiveContains(lookId) })
                    
                    //                    print(userLookId,"Set Quantity")
                    
                    if indexArray.count != 0{
                        
                        let quan = userLookId[indexArray[0]] as String
                        
                        let str = quan.strstr(needle: "|")
                        if str == nil{
                            qunti  = "1"
                        }else{
                            qunti = str!
                        }
                    }else{
                        qunti = String(frame.orderQuantityCount)
                    }
                }
                
            }else{
                qunti = String(frame.orderQuantityCount)
            }
            if let qty:Int = Int(qunti)  {
                totalQty = totalQty + qty
            }
        }
        self.totalQty.text = String(totalQty)
        
        self.tableView.reloadData()
    }
}

extension TrayController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let pointInTable:CGPoint = textField.superview!.convert(textField.frame.origin, to:tableView)
        var contentOffset:CGPoint = tableView.contentOffset
        contentOffset.y  = pointInTable.y
        if let accessoryView = textField.inputAccessoryView {
            contentOffset.y -= accessoryView.frame.size.height
        }
        tableView.contentOffset = contentOffset
        textField.borderColor = UIColor.primaryLightColor
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        
        return string == numberFiltered
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        tableView.reloadData()
        self.view.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.updatePrice(textField)
        var qunti : String!
        var quntis : String!
        
        textField.borderColor = UIColor.mainBackgroundColor
        
        var total = 0.0
        for frame in TrayHelper().trayInventoryFrames() {
            
            if UserDefaults.standard.array(forKey: "userLookId") != nil  {
                
                userLookId = UserDefaults.standard.array(forKey: "userLookId") as! [String]
                if let lookId = frame.lookzId {
                    let indexArray = userLookId.indices.filter({ userLookId[$0].localizedCaseInsensitiveContains(lookId) })
                    print(userLookId,"Set Quantity")
                    
                    if indexArray.count != 0{
                        let quan = userLookId[indexArray[0]] as String
                        let str = quan.strstr(needle: "|")
                        
                        if str == nil{
                            quntis = "1"
                        }else{
                            quntis = str!
                        }
                    }else{
                        quntis = String(frame.orderQuantityCount)
                    }
                }
            }else{
                quntis = String(frame.orderQuantityCount)
            }
            
            if self.selectedPrice == "DP"{
                if let price = frame.priceDistributor.value {
                    total = total + (price * Double(Int(quntis)!))
                }
            } else {
                if let price = frame.price.value {
                    if let price = frame.price.value {
                        total = total + (price * Double(Int(quntis)!))
                    }
                }
            }
        }
        self.totalLabel.text = numberFormatter.string(from: NSNumber(value: total))
        
        var totalQty = 0
        
        for frame in TrayHelper().trayInventoryFrames() {
            
            if UserDefaults.standard.array(forKey: "userLookId") != nil  {
                
                userLookId = UserDefaults.standard.array(forKey: "userLookId") as! [String]
                if let lookId = frame.lookzId {
                    
                    let indexArray = userLookId.indices.filter({ userLookId[$0].localizedCaseInsensitiveContains(lookId) })
                    
                    print(userLookId,"Set Quantity")
                    
                    if indexArray.count != 0{
                        let quan = userLookId[indexArray[0]] as String
                        let str = quan.strstr(needle: "|")
                        
                        if str == nil{
                            qunti = "1"
                        }else{
                            qunti = str!
                        }
                    }else{
                        qunti = String(frame.orderQuantityCount)
                    }
                }
            }else{
                qunti = String(frame.orderQuantityCount)
            }
            
            if let qty:Int = Int(qunti) {
                totalQty = totalQty + qty
            }
        }
        self.totalQty.text = String(totalQty)
        self.tableView.reloadData()
         return true
    }
    
    func updatePrice(_ textField: UITextField) {
        var quantity: Int?
        if textField.text != "" {
            quantity = Int(textField.text!)!
        } else {
            quantity = 1
            textField.text = String(1)
        }
        
        let indexPath = IndexPath(row: textField.tag, section: 0)
        let frame = TrayHelper().trayInventoryFrames()[indexPath.row]
        try! realm.write {
            frame.orderQuantityCount = quantity!
        }
        if UserDefaults.standard.array(forKey: "userLookId") != nil{
            
            userLookId = UserDefaults.standard.array(forKey: "userLookId") as! [String]
            if let lookId = frame.lookzId {
                let indexArray = userLookId.indices.filter({ userLookId[$0].localizedCaseInsensitiveContains(lookId) })
                
                if indexArray.count != 0{
                    for userIndex in indexArray{
                        if userIndex != 0{
                            userLookId.remove(at: userIndex)
                        }else{
                            userLookId.remove(at: userIndex)
                        }
                    }
                    print("remove",userLookId)
                    
                    if let qun = quantity {
                        
                        userLookId.append(lookId + "|" + String(qun))
                    }
                    UserDefaults.standard.set(userLookId , forKey: "userLookId")
                }
            }
        }
        let cell = self.tableView.cellForRow(at: indexPath) as? TrayCell
        if let cell = cell {
            var calcPriceText: String?
            
            if self.selectedPrice == "DP"{
                if let price = frame.priceDistributor.value {
                    calcPriceText = numberFormatter.string(from: NSNumber(value: price * Double(quantity!)))//Double(frame.orderQuantityCount)))
                }
            } else {
                if let price = frame.price.value {
                    calcPriceText = numberFormatter.string(from: NSNumber(value: price * Double(quantity!)))//Double(frame.orderQuantityCount)))
                }
            }
            if calcPriceText == nil {
                calcPriceText = "0"
                cell.priceMultiByQuantityLabel.text = calcPriceText
            } else {
                cell.priceMultiByQuantityLabel.text = calcPriceText
            }
        }
        
        itemLoadArray()

        //Update Total
        var total = 0.0
        for frame in TrayHelper().trayInventoryFrames() {
            if let price = frame.price.value {
                total = total + (price * Double(quantity!))//Double(frame.orderQuantityCount))
            }
        }
        self.totalLabel.text = numberFormatter.string(from: NSNumber(value: total))
        var dat = itemAdded[indexPath.row]
        dat.updateValue((cell?.quantityTextField.text)!, forKey: "Quantity")
        dat.updateValue((cell?.priceMultiByQuantityLabel.text)!, forKey: "Subtotal")
        itemAdded[indexPath.row] = dat
    }
}

extension UIView {
    func addShadowView() {
        //Remove previous shadow views
        superview?.viewWithTag(119900)?.removeFromSuperview()
        
        //Create new shadow view with frame
        let shadowView = UIView(frame: frame)
        shadowView.tag = 119900
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 2, height: 3)
        shadowView.layer.masksToBounds = false
        
        shadowView.layer.shadowOpacity = 0.5
        shadowView.layer.shadowRadius = 7
        shadowView.layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        shadowView.layer.rasterizationScale = UIScreen.main.scale
        shadowView.layer.shouldRasterize = true
        
        superview?.insertSubview(shadowView, belowSubview: self)
    }
}

extension UIView {
    func addShadowViews() {
        //Remove previous shadow views
        superview?.viewWithTag(119900)?.removeFromSuperview()
        
        //Create new shadow view with frame
        let shadowView = UIView(frame: frame)
        shadowView.tag = 119900
        shadowView.layer.shadowColor = UIColor.lightGray.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 4, height: 4)
        shadowView.layer.masksToBounds = false
        
        shadowView.layer.shadowOpacity = 0.5
        shadowView.layer.shadowRadius = 6.0
        shadowView.layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        shadowView.layer.rasterizationScale = UIScreen.main.scale
        shadowView.layer.shouldRasterize = true
        
        superview?.insertSubview(shadowView, belowSubview: self)
    }
}

extension String {
    
    func strstr(needle: String, beforeNeedle: Bool = false) -> String? {
        guard let range = self.range(of: needle) else { return nil }
        
        if beforeNeedle {
            return self.substring(to: range.lowerBound)
        }
        
        return self.substring(from: range.upperBound)
    }
    
}
