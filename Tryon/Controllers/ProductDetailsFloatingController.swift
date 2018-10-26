//
//  ProductDetailsFloatingController.swift
//  Tryon
//
//  Created by Udayakumar N on 07/04/17.
//  Copyright © 2017 1000Lookz. All rights reserved.
//

import UIKit
import ImageSlideshow
import Appsee


class ProductDetailsFloatingController: UIViewController {

    
    // MARK: - Class variables
    
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productDetailsLabel: UILabel!
    @IBOutlet weak var imageSlideshowView: ImageSlideshow!
    @IBOutlet weak var productDetailsTableView: UITableView!

    let imageSlideshowInterval = 1.5 //secs
    
    var frame: InventoryFrame?
    
    var productDetailsTitle: [String] = []
    var productDetailsValue: [String] = []
    
    
    // MARK: - Init functions
    
    override func viewDidAppear(_ animated: Bool) {
        Appsee.startScreen("ProductDetailsFloating")
        
        super.viewDidAppear(animated)
    }

    
    // MARK: - Product Details functions
    
    func updateProductDetails() {
        //Add Product Name and Details
        productNameLabel.text = frame?.productName?.lowercased().capitalizingFirstLetter()
        productDetailsLabel.text = frame?.brand?.name.lowercased().capitalizingFirstLetter()
        addProductDetails()
        productDetailsTableView.reloadData()
        
        //Configure Image Slide show
        imageSlideshowView.pageControlPosition = .insideScrollView
        imageSlideshowView.pageControl.pageIndicatorTintColor = UIColor.productDetailsImageBorderColor
        imageSlideshowView.pageControl.currentPageIndicatorTintColor = UIColor.primaryColor
        imageSlideshowView.slideshowInterval = imageSlideshowInterval
        addProductImages()
    }
    
    func addProductImages() {
//        if let imgs = frame?.imgUrls {
//            
//            var imgsData: [Any] = []
//            for img in imgs {
//                if img != "" {
//                    imgsData.append(AlamofireSource(urlString: img)!)
//                }
//            }
//            
//            imageSlideshowView.setImageInputs(imgsData as! [InputSource])
//        }
    }
    
    func addProductDetails() {
        productDetailsTitle.removeAll()
        productDetailsValue.removeAll()
        
        if let name = frame?.productName {
            if name != "" {
                productDetailsTitle.append(ProductDetails.name.rawValue)
                productDetailsValue.append(name.lowercased().capitalizingFirstLetter())
            }
        }
        if let brand = frame?.brand {
            if brand.name != "" {
                productDetailsTitle.append(ProductDetails.brandName.rawValue)
                productDetailsValue.append(brand.name.lowercased().capitalizingFirstLetter())
            }
        }
        if let category = frame?.category {
            if category.name != "" {
                productDetailsTitle.append(ProductDetails.frameCategory.rawValue)
                productDetailsValue.append(category.name.lowercased().capitalizingFirstLetter())
            }
        }
        if let frameType = frame?.frameType {
            if frameType.name != "" {
                productDetailsTitle.append(ProductDetails.frameType.rawValue)
                productDetailsValue.append(frameType.name.lowercased().capitalizingFirstLetter())
            }
        }
        if let shape = frame?.shape {
            if shape.name != "" {
                productDetailsTitle.append(ProductDetails.frameShape.rawValue)
                productDetailsValue.append(shape.name.lowercased().capitalizingFirstLetter())
            }
        }
        if let material = frame?.frameMaterial {
            if material.name != "" {
                productDetailsTitle.append(ProductDetails.material.rawValue)
                productDetailsValue.append(material.name.lowercased().capitalizingFirstLetter())
            }
        }
        if let size = frame?.size {
            if size != "" {
                productDetailsTitle.append(ProductDetails.size.rawValue)
                productDetailsValue.append(size.lowercased().capitalizingFirstLetter())
            }
        }
        if let color = frame?.frameColor {
            if color.name != "" {
                productDetailsTitle.append(ProductDetails.color.rawValue)
                productDetailsValue.append(color.name.lowercased().capitalizingFirstLetter())
            }
        }
    }
}


// MARK: - Product Details TableView

extension ProductDetailsFloatingController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productDetailsTitle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productDetailsCell", for: indexPath) as! ProductDetailsCell
        cell.productDetailsTitleLabel.text = productDetailsTitle[indexPath.row]
        cell.productDetailsValueLabel.text = productDetailsValue[indexPath.row]
        cell.selectionStyle = .none
        
        return cell
    }
}
