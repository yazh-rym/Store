//
//  FeaturedController.swift
//  Tryon
//
//  Created by Udayakumar N on 26/10/17.
//  Copyright © 2017 Adhyas. All rights reserved.
//

import UIKit

class FeaturedController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var collectionViewStoredOffsets = [Int: CGFloat]()
    var featuredData: [FeaturedData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initFeaturedData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initFeaturedData() {
        var data = FeaturedData(title: "Featured", isSeeAllVisible: false, cellType: .featured, inventoryData: nil, imageData:
            [
                "https://s3-ap-southeast-1.amazonaws.com/files.try1000looks.com/mobile/testing/featured/featured5.jpg",
                "https://s3-ap-southeast-1.amazonaws.com/files.try1000looks.com/mobile/testing/featured/featured2.jpg",
                "https://s3-ap-southeast-1.amazonaws.com/files.try1000looks.com/mobile/testing/featured/featured3.jpg",
                "https://s3-ap-southeast-1.amazonaws.com/files.try1000looks.com/mobile/testing/featured/featured4.jpg",
                "https://s3-ap-southeast-1.amazonaws.com/files.try1000looks.com/mobile/testing/featured/featured1.jpg"
            ], textData: nil)
        self.featuredData.append(data)
        data = FeaturedData(title: "Recommended", isSeeAllVisible: true, cellType: .userWithGlass, inventoryData:
            [
                ["https://s3-ap-southeast-1.amazonaws.com/files.try1000looks.com/mobile/testing/model/model.jpg","Carrera"],
                ["https://s3-ap-southeast-1.amazonaws.com/files.try1000looks.com/mobile/testing/model/model.jpg","Dkny"],
                ["https://s3-ap-southeast-1.amazonaws.com/files.try1000looks.com/mobile/testing/model/model.jpg","Dkny"],
                ["https://s3-ap-southeast-1.amazonaws.com/files.try1000looks.com/mobile/testing/model/model.jpg","Giordano"],
                ["https://s3-ap-southeast-1.amazonaws.com/files.try1000looks.com/mobile/testing/model/model.jpg","Guess"],
                ["https://s3-ap-southeast-1.amazonaws.com/files.try1000looks.com/mobile/testing/model/model.jpg","Dkny"],
                ["https://s3-ap-southeast-1.amazonaws.com/files.try1000looks.com/mobile/testing/model/model.jpg","Carrera"],
                ["https://s3-ap-southeast-1.amazonaws.com/files.try1000looks.com/mobile/testing/model/model.jpg","Giordano"],
                ["https://s3-ap-southeast-1.amazonaws.com/files.try1000looks.com/mobile/testing/model/model.jpg","Guess"],
                ["https://s3-ap-southeast-1.amazonaws.com/files.try1000looks.com/mobile/testing/model/model.jpg","Carrera"]
            ], imageData: nil, textData: nil)
        self.featuredData.append(data)
        data = FeaturedData(title: "Fast Moving Frames", isSeeAllVisible: true, cellType: .rectImage, inventoryData: nil, imageData: ["https://s3-ap-southeast-1.amazonaws.com/offline-rendering/preRendered/EG_FR_CAR_00000001/thumbnail.png","https://s3-ap-southeast-1.amazonaws.com/offline-rendering/preRendered/EG_FR_DKN_00000003/thumbnail.png","https://s3-ap-southeast-1.amazonaws.com/offline-rendering/preRendered/EG_FR_DKN_00000004/thumbnail.png","https://s3-ap-southeast-1.amazonaws.com/offline-rendering/preRendered/EG_FR_DKN_00000004/thumbnail.png","https://s3-ap-southeast-1.amazonaws.com/offline-rendering/preRendered/EG_FR_DKN_00000006/thumbnail.png","https://s3-ap-southeast-1.amazonaws.com/offline-rendering/preRendered/EG_FR_GIO_00000001/thumbnail.png","https://s3-ap-southeast-1.amazonaws.com/offline-rendering/preRendered/EG_FR_GUE_00000002/thumbnail.png","https://s3-ap-southeast-1.amazonaws.com/offline-rendering/preRendered/EG_FR_GUE_00000003/thumbnail.png","https://s3-ap-southeast-1.amazonaws.com/offline-rendering/preRendered/EG_FR_GUE_00000006/thumbnail.png"], textData: nil)
        self.featuredData.append(data)
        data = FeaturedData(title: "Top Brands", isSeeAllVisible: true, cellType: .squareImage, inventoryData: nil, imageData: ["https://s3-ap-southeast-1.amazonaws.com/files.try1000looks.com/mobile/testing/brand/dkny.png","https://s3-ap-southeast-1.amazonaws.com/files.try1000looks.com/mobile/testing/brand/oakley.png","https://s3-ap-southeast-1.amazonaws.com/files.try1000looks.com/mobile/testing/brand/vogue.jpg","https://s3-ap-southeast-1.amazonaws.com/files.try1000looks.com/mobile/testing/brand/dkny.png","https://s3-ap-southeast-1.amazonaws.com/files.try1000looks.com/mobile/testing/brand/oakley.png","https://s3-ap-southeast-1.amazonaws.com/files.try1000looks.com/mobile/testing/brand/vogue.jpg"], textData: nil)
        self.featuredData.append(data)
        data = FeaturedData(title: "Frame types", isSeeAllVisible: true, cellType: .userWithGlass, inventoryData:
            [
                ["https://s3-ap-southeast-1.amazonaws.com/files.try1000looks.com/mobile/testing/model/model.jpg","Full Rim"],
                ["https://s3-ap-southeast-1.amazonaws.com/files.try1000looks.com/mobile/testing/model/model.jpg","Half Rim"],
                ["https://s3-ap-southeast-1.amazonaws.com/files.try1000looks.com/mobile/testing/model/model.jpg","Rimless"],
                ["https://s3-ap-southeast-1.amazonaws.com/files.try1000looks.com/mobile/testing/model/model.jpg","Sunglasses"]
            ], imageData: nil, textData: nil)
        self.featuredData.append(data)
        data = FeaturedData(title: "Shapes", isSeeAllVisible: false, cellType: .rectImage, inventoryData: nil, imageData: ["https://s3-ap-southeast-1.amazonaws.com/files.try1000looks.com/mobile/testing/shape/halfrimtop.png","https://s3-ap-southeast-1.amazonaws.com/files.try1000looks.com/mobile/testing/shape/rect.png","https://s3-ap-southeast-1.amazonaws.com/files.try1000looks.com/mobile/testing/shape/circle.png","https://s3-ap-southeast-1.amazonaws.com/files.try1000looks.com/mobile/testing/shape/circle.png","https://s3-ap-southeast-1.amazonaws.com/files.try1000looks.com/mobile/testing/shape/curved.png","https://s3-ap-southeast-1.amazonaws.com/files.try1000looks.com/mobile/testing/shape/rect2.png"], textData: nil)
        self.featuredData.append(data)
        data = FeaturedData(title: "Price", isSeeAllVisible: false, cellType: .text, inventoryData: nil, imageData: nil, textData: ["Under ₹1000", "Under ₹2000", "₹2000 - ₹5000", "₹5000 - ₹10000", "Above ₹10000"])
        self.featuredData.append(data)
    }
}

extension FeaturedController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.featuredData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cellIdentifier = "featuredCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! FeaturedCell

            return cell
        } else {
            let cellIdentifier = "collectionCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! FeaturedCollectionCell
            cell.titleLabel.text = self.featuredData[indexPath.row].title
            cell.seeAllButton.isHidden = !self.featuredData[indexPath.row].isSeeAllVisible
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let tableViewCell = cell as? FeaturedCell {
            tableViewCell.setFeaturedViewDataSourceDelegate(self, forRow: indexPath.row)
            
        } else if let tableViewCell = cell as? FeaturedCollectionCell {
            tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
            tableViewCell.collectionViewOffset = collectionViewStoredOffsets[indexPath.row] ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let tableViewCell = cell as? FeaturedCollectionCell else { return }
        
        collectionViewStoredOffsets[indexPath.row] = tableViewCell.collectionViewOffset
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch self.featuredData[indexPath.row].cellType {
        case .featured:
            return 250
        case .userWithGlass:
            return 290
        case .text:
            return 190
        case .squareImage:
            return 190
        case .rectImage:
            return 190
        }
    }
}

extension FeaturedController: iCarouselDataSource, iCarouselDelegate {
    func numberOfItems(in carousel: iCarousel) -> Int {
        return (self.featuredData[carousel.tag].imageData?.count)!
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        let tempFrame = CGRect(x: 0, y: 0, width: 508, height: 250)
        let tempView = UIView(frame: tempFrame)
        
        if let urls = self.featuredData[carousel.tag].imageData {
            let imageView = UIImageView()
            imageView.frame = tempFrame
            imageView.contentMode = .scaleAspectFit
            imageView.af_setImage(withURL: URL(string: (urls[index]))!)
            tempView.addSubview(imageView)
        }
        
        return tempView
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        switch (option) {
        case .wrap:
            return 1.0
        default:
            return value
        }
    }
}

extension FeaturedController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch self.featuredData[collectionView.tag].cellType {
        case .userWithGlass:
            return (self.featuredData[collectionView.tag].inventoryData?.count)!
        case .text:
            return (self.featuredData[collectionView.tag].textData?.count)!
        case .rectImage, .squareImage:
            return (self.featuredData[collectionView.tag].imageData?.count)!
        default:
            return 10
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch self.featuredData[collectionView.tag].cellType {
        case .userWithGlass:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "userWithGlassCell", for: indexPath) as? FeaturedUserWithGlassCell
            cell?.imageView.af_setImage(withURL: URL(string: (self.featuredData[collectionView.tag].inventoryData?[indexPath.row][0])!)!)
            cell?.titleLabel.text = self.featuredData[collectionView.tag].inventoryData?[indexPath.row][1]
            return cell!
        case .text:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "textCell", for: indexPath) as? FeaturedTextCell
            cell?.textLabel.text = self.featuredData[collectionView.tag].textData?[indexPath.row]
            return cell!
        case .squareImage:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "squareImageCell", for: indexPath) as? FeaturedSquareImageCell
            cell?.imageView.af_setImage(withURL: URL(string: (self.featuredData[collectionView.tag].imageData?[indexPath.row])!)!)
            return cell!
        case .rectImage:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "rectImageCell", for: indexPath) as? FeaturedRectImageCell
            cell?.imageView.af_setImage(withURL: URL(string: (self.featuredData[collectionView.tag].imageData?[indexPath.row])!)!)
            return cell!
        
        default:
            //This code shouldn't execute
            log.error("Error: EmptyCell creation is reached in CollectionView. Check the indexpath row.")
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "userWithGlassCell", for: indexPath)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch self.featuredData[collectionView.tag].cellType {
        case .userWithGlass:
            return CGSize(width: 180, height: 209)
        case .text:
            return CGSize(width: 200, height: 110)
        case .squareImage:
            return CGSize(width: 110, height: 110)
        case .rectImage:
            return CGSize(width: 200, height: 110)
            
        default:
            //This code shouldn't execute
            log.error("Error: Incorrect cell type.")
            return CGSize(width: 155, height: 155)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Collection view at row \(collectionView.tag) selected index path \(indexPath)")
    }
}
