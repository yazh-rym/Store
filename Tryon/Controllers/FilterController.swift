//
//  FilterController.swift
//  Tryon
//
//  Created by Udayakumar N on 08/01/18.
//  Copyright © 2018 Adhyas. All rights reserved.
//

import Foundation
import RealmSwift
import Kingfisher

enum FilterList: Int {
    case productType = 0
    case gender
    case frameType
    case shape
    case brand
    case color
    
    static let allValues = [productType, gender, frameType, shape, brand, color]
}

class FilterController: BaseViewController {

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var shadowMaskView: UIView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBAction func resetButtonDidTap(_ sender: UIButton) {
        self.selectedFilterIndexPath.removeAll()
        self.selectedFilterData.removeAll()
        
        self.tableView.reloadData()
    }
    @IBAction func submitButtonDidTap(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "tabClose"), object: nil)
        self.performSegue(withIdentifier: "filterToResultSegue", sender: nil)
    }
    @IBAction func searchButtonDidTap(_ sender: UIButton) {
        if searchTextField.text == "" {
            searchTextField.becomeFirstResponder()
        } else {
            processSearchString(searchTextField.text)
        }
    }
    
    let realm = try! Realm()
    
    var filterTitleData: [FilterList: String] = [:]
    var selectedFilterIndexPath: [FilterList: [Int]] = [:]
    var selectedFilterData: [FilterList: [Int]] = [:]
    var collectionViewStoredOffsets = [Int: CGFloat]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initFilterData()
    }
    
    func initFilterData() {
        for filter in FilterList.allValues {
            switch filter {
            case .productType:
                let productTypes = self.realm.objects(CategoryProductType.self)
                if productTypes.count > 0 {
                    self.filterTitleData.updateValue("SELECT CATEGORY", forKey: .productType)
                }
                
            case .gender:
                let genders = self.realm.objects(CategoryGender.self)
                if genders.count > 0 {
                    self.filterTitleData.updateValue("GENDER", forKey: .gender)
                }
                
            case .frameType:
                let frameTypes = self.realm.objects(CategoryFrameType.self)
                if frameTypes.count > 0 {
                    self.filterTitleData.updateValue("FRAME TYPE", forKey: .frameType)
                }
                
            case .shape:
                let shapes = self.realm.objects(CategoryShape.self)
                if shapes.count > 0 {
                    self.filterTitleData.updateValue("SHAPE", forKey: .shape)
                }
                
            case .brand:
                let brands = self.realm.objects(CategoryBrand.self)
                if brands.count > 0 {
                    self.filterTitleData.updateValue("BRAND", forKey: .brand)
                }
                
            case .color:
                let colors = self.realm.objects(CategoryColor.self).filter("colorR != nil")
                if colors.count > 0 {
                    self.filterTitleData.updateValue("COLOR", forKey: .color)
                }
            }
        }
        
        self.tableView.reloadData()
    }
}

extension FilterController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterTitleData.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let filter = FilterList(rawValue: indexPath.row)!
        
        switch filter {
        case .productType:
            return 190
            
        case .gender, .frameType, .shape, .brand, .color:
            return 160
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let filter = FilterList(rawValue: indexPath.row)!
        
        switch filter {
        case .productType:
            return 190
            
        case .gender, .frameType, .shape, .brand:
            return 160
        
        case .color:
            return 140
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "filterTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! FilterTableViewCell
        
        let filter = FilterList(rawValue: indexPath.row)!
        cell.titleLabel.text = self.filterTitleData[filter]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let tableViewCell = cell as? FilterTableViewCell {
            tableViewCell.setFilterCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
            tableViewCell.collectionViewOffset = collectionViewStoredOffsets[indexPath.row] ?? 0
        }
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let tableViewCell = cell as? FilterTableViewCell else { return }

        collectionViewStoredOffsets[indexPath.row] = tableViewCell.collectionViewOffset
    }
}

extension FilterController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let filter = FilterList(rawValue: collectionView.tag)!
        
        switch filter {
        case .productType:
            let productTypes = self.realm.objects(CategoryProductType.self)
            return productTypes.count
            
        case .gender:
            let genders = self.realm.objects(CategoryGender.self)
            return genders.count
            
        case .frameType:
            let frameTypes = self.realm.objects(CategoryFrameType.self)
            return frameTypes.count
            
        case .shape:
            let shapes = self.realm.objects(CategoryShape.self)
            return shapes.count
            
        case .brand:
            let brands = self.realm.objects(CategoryBrand.self)
            return brands.count
            
        case .color:
            let colors = self.realm.objects(CategoryColor.self).filter("colorR != nil")
            return colors.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let filter = FilterList(rawValue: collectionView.tag)!
        
        switch filter {
        case .productType:
            return 40
            
        case .gender:
            return 0
            
        case .frameType:
            return 20
            
        case .shape:
            return 20
            
        case .brand:
            return 10
            
        case .color:
            return 30
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "filterCollectionViewCell", for: indexPath) as? FilterCollectionViewCell
        let filter = FilterList(rawValue: collectionView.tag)!
        KingfisherManager.shared.cache.pathExtension = "jpg"

        switch filter {
        case .productType:
            let productTypes = self.realm.objects(CategoryProductType.self).sorted(byKeyPath: "order")
            let productType = productTypes[indexPath.row]
            
            cell?.titleLabel.text = productType.name.uppercased()
            if let url = productType.iconUrl {
                if url != "" {
                    cell?.imageView.kf.setImage(with: URL(string: url)!)
                }
            }
            
        case .gender:
            let genders = self.realm.objects(CategoryGender.self).sorted(byKeyPath: "order")
            let gender = genders[indexPath.row]
            
            cell?.titleLabel.text = gender.name.uppercased()
            if let url = gender.iconUrl {
                if url != "" {
                    cell?.imageView.kf.setImage(with: URL(string: url)!)
                }
            }
            
        case .frameType:
            let frameTypes = self.realm.objects(CategoryFrameType.self).sorted(byKeyPath: "order")
            let frameType = frameTypes[indexPath.row]
           // Base build
            cell?.titleLabel.text = frameType.name
            //arcadio
            
//            if frameType.name == "Fullrim" {
//                cell?.titleLabel.text = "FF"
//            }
//            if frameType.name == "Halfrim" {
//                cell?.titleLabel.text = "SP"
//            }
//            if frameType.name == "Rimless" {
//                cell?.titleLabel.text = "RL"
//            }
//            if frameType.name == "ShellFullRim" {
//                cell?.titleLabel.text = "SF"
//            }
            
            if let url = frameType.iconUrl {
                if url != "" {
                    cell?.imageView.kf.setImage(with: URL(string: url)!)
                }
            }
            
        case .shape:
            let shapes = self.realm.objects(CategoryShape.self).sorted(byKeyPath: "order")
            let shape = shapes[indexPath.row]
            
            cell?.titleLabel.text = shape.name.uppercased()
            if let url = shape.iconUrl {
                if url != "" {
                    cell?.imageView.kf.setImage(with: URL(string: url)!)
                }
            }
            
        case .brand:
            let brands = self.realm.objects(CategoryBrand.self).sorted(byKeyPath: "order")
            let brand = brands[indexPath.row]
            
            cell?.titleLabel.text = ""
            if let url = brand.iconUrl {
                if url != "" {
                    cell?.imageView.kf.setImage(with: URL(string: url)!)
                }
            }
                        
            cell?.imageViewBottomConstraint.constant = 10
            cell?.layoutIfNeeded()
            
        case .color:
            let colorCell = collectionView.dequeueReusableCell(withReuseIdentifier: "filterColorCell", for: indexPath) as? FilterColorCell
            
            let colors = self.realm.objects(CategoryColor.self).filter("colorR != nil").sorted(byKeyPath: "order")
            let color = colors[indexPath.row]
            
            if let r = color.colorR.value, let g = color.colorG.value, let b = color.colorB.value {
                
                colorCell?.backgroundColor = UIColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: 1.0)

                let colorVal: UIColor = UIColor(red:1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                if colorVal == (colorCell?.backgroundColor)!{
                    colorCell?.borderColor = UIColor(red:216/255.0, green: 216/255.0, blue: 216/255.0, alpha: 1.0)
                }
                else {
                    colorCell?.borderColor = UIColor.clear
                }
            }
            
            colorCell?.selectedImageView.image = nil
            if let filterArray = self.selectedFilterIndexPath[filter] {
                if filterArray.contains(indexPath.row) {
                    colorCell?.selectedImageView.image = UIImage(named: "TickIcon")
                }
            }
            
            return colorCell!
        }
        
        cell?.selectedView.isHidden = true
        if let filterArray = self.selectedFilterIndexPath[filter] {
            if filterArray.contains(indexPath.row) {
                cell?.selectedView.isHidden = false
            }
        }

        return cell!
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let filter = FilterList(rawValue: collectionView.tag)!
        
        switch filter {
        case .productType, .gender, .frameType, .shape, .brand:
            let height = collectionView.height
            let width = height * 1.4
            return CGSize(width: width, height: height)
            
        case .color:
            let height = 32
            let width = 32
            
            return CGSize(width: width, height: height)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {        
        let filter = FilterList(rawValue: collectionView.tag)!
        var isAlreadyAdded = false
        
        if let filterArray = self.selectedFilterIndexPath[filter] {
            if filterArray.contains(indexPath.row) {
                //Already added
                isAlreadyAdded = true
            }
        }
        
        if isAlreadyAdded {
            //Remove it
            self.selectedFilterIndexPath[filter] = self.selectedFilterIndexPath[filter]?.filter { $0 != indexPath.row }
            if self.selectedFilterIndexPath[filter]?.count == 0 {
                self.selectedFilterIndexPath.removeValue(forKey: filter)
            }
        } else {
            //Add it
            if let _ = self.selectedFilterIndexPath[filter] {
                self.selectedFilterIndexPath[filter]?.append(indexPath.row)
            } else {
                self.selectedFilterIndexPath.updateValue([indexPath.row], forKey: filter)
            }
        }
        
        switch filter {
        case .productType:
            let productTypes = self.realm.objects(CategoryProductType.self).sorted(byKeyPath: "order")
            let product = productTypes[indexPath.row]
            self.updateFilterData(withFilter: filter, isAlreadyAdded: isAlreadyAdded, id: product.id)

        case .gender:
            let genders = self.realm.objects(CategoryGender.self).sorted(byKeyPath: "order")
            let gender = genders[indexPath.row]
            self.updateFilterData(withFilter: filter, isAlreadyAdded: isAlreadyAdded, id: gender.id)
            
        case .frameType:
            let frameTypes = self.realm.objects(CategoryFrameType.self).sorted(byKeyPath: "order")
            let frameType = frameTypes[indexPath.row]
            self.updateFilterData(withFilter: filter, isAlreadyAdded: isAlreadyAdded, id: frameType.id)
            
        case .shape:
            let shapes = self.realm.objects(CategoryShape.self).sorted(byKeyPath: "order")
            let shape = shapes[indexPath.row]
            self.updateFilterData(withFilter: filter, isAlreadyAdded: isAlreadyAdded, id: shape.id)
            
        case .brand:
            let brands = self.realm.objects(CategoryBrand.self).sorted(byKeyPath: "order")
            let brand = brands[indexPath.row]
            self.updateFilterData(withFilter: filter, isAlreadyAdded: isAlreadyAdded, id: brand.id)
            
        case .color:
            let colors = self.realm.objects(CategoryColor.self).filter("colorR != nil").sorted(byKeyPath: "order")
            let color = colors[indexPath.row]
            self.updateFilterData(withFilter: filter, isAlreadyAdded: isAlreadyAdded, id: color.id)
        }
        
        collectionView.reloadData()
    }
    
    func updateFilterData(withFilter filter: FilterList, isAlreadyAdded: Bool, id: Int) {
        if isAlreadyAdded {
            //Remove it
            self.selectedFilterData[filter] = self.selectedFilterData[filter]?.filter { $0 != id }
            if self.selectedFilterData[filter]?.count == 0 {
               self.selectedFilterData.removeValue(forKey: filter)
            }
        } else {
            //Add it
            if let _ = self.selectedFilterData[filter] {
                self.selectedFilterData[filter]?.append(id)
            } else {
                self.selectedFilterData.updateValue([id], forKey: filter)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
         NotificationCenter.default.post(name: NSNotification.Name(rawValue: "tabClose"), object: nil)
        
        if let resultController = segue.destination as? ResultController {
            if let searchString = sender as? String {
                resultController.resultInputType = .searchString
                resultController.searchString = searchString
                resultController.title = "RESULTS for \"\(searchString)\""
            } else {
                resultController.resultInputType = .filterData
                resultController.filterData = self.selectedFilterData
            }
        }
    }
}

extension FilterController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        processSearchString(textField.text)
    }
    
    fileprivate func processSearchString(_ searchString: String?) {
        if let searchString = searchString?.trimmingCharacters(in: .whitespacesAndNewlines) {
            if !(searchString.isEmpty) {
                 NotificationCenter.default.post(name: NSNotification.Name(rawValue: "tabClose"), object: nil)
                self.performSegue(withIdentifier: "filterToResultSegue", sender: searchString)
            }
        }
        self.searchTextField.text = ""
    }
}
