//
//  ProductViewController.swift
//  Tryon
//
//  Created by 1000Lookz on 02/07/18.
//  Copyright © 2018 Varun Raj. All rights reserved.
//

import UIKit
import Kingfisher

protocol DeletableImageViewDelegate {
    func preSegues(indexpaths : IndexPath)
}

class ProductViewController: UIViewController ,UITableViewDelegate , UITableViewDataSource {
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    var inventoryFrames :[InventoryFrame]  = []
    
    @IBOutlet weak var fulModeltableView: UITableView!
    
    var delegate: DeletableImageViewDelegate?
    
    var titleString: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fulModeltableView.separatorStyle = UITableViewCellSeparatorStyle.none

        titleLabel.text  = titleString
        
        fulModeltableView.register(ModelTableViewCell.nib, forCellReuseIdentifier: ModelTableViewCell.identifier)
        
        fulModeltableView.dataSource = self
        fulModeltableView.delegate = self
        
        backBtn.addCornerRadius(15.0, inCorners: [.topRight, .bottomRight])
        backBtn.clipsToBounds = true
        backBtn.masksToBounds = true
        backBtn.addShadowView()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return  self.inventoryFrames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ModelTableViewCell.identifier, for: indexPath) as! ModelTableViewCell
        let inventoryFrame = self.inventoryFrames[indexPath.row]
        
        KingfisherManager.shared.cache.pathExtension = "jpg"
        
        
        cell.glassImage.kf.setImage(with: URL(string: inventoryFrame.thumbnailImageUrl!))
        
        var titleText = inventoryFrame.brand?.name.uppercased()
        if let modelNumber = inventoryFrame.modelNumber {
            titleText = titleText! + " - " + modelNumber
        }
        cell.titleLabel.text = titleText
        
        var displayText = (inventoryFrame.shape?.name)!
        
        if let size = inventoryFrame.sizeText {
            
            displayText = displayText + " - " + size
            
        }
        displayText = displayText.uppercased()
        
        cell.productLabel.text = displayText.lowercased().capitalizingFirstLetter()
        
        if let price = inventoryFrame.price.value {
            
            cell.amountLabel.text = "RS \(String(describing: Int(price)))"
            
        } else {
            cell.amountLabel.text = ""
        }
        cell.amountLabel.textColor = UIColor.red
        
        if inventoryFrame.childFrames.count >= 1 {
            //Added +1 to include the parent frame
            cell.colorLabel.text = String(inventoryFrame.childFrames.count + 1) + "  COLORS"
        } else {
            cell.colorLabel.text = ""
        }
        cell.tryOnImageView.image = UIImage.init(named: "tryOn")
        
        if inventoryFrame.isTryonCreated {
            cell.tryOnImageView.isHidden = false
        } else {
            cell.tryOnImageView.isHidden = true
        }
        cell.textLabel?.numberOfLines = 0
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.preSegues(indexpaths: indexPath)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backBtnAction(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "tabClose"), object: nil)
        dismiss(animated: true, completion: nil)
    }
}
