//
//  FilterCategorySubTypeCell.swift
//  Tryon
//
//  Created by Udayakumar N on 13/03/17.
//  Copyright © 2017 1000Lookz. All rights reserved.
//

import UIKit
import NHRangeSlider


class FilterCategorySubTypeCell: UITableViewCell {

    @IBOutlet weak var categorySubTypeName: UILabel!
    @IBOutlet weak var categorySubTypeImage: UIImageView!
    
    var sliderView: NHRangeSliderView?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        //Set the image to nil if the imageview exists
        if categorySubTypeImage != nil {
            categorySubTypeImage.image = nil
        }
    }
    
    func addRangeSlider(withMinValue minValue: Double, maxValue: Double) {
        if self.sliderView == nil {
            sliderView = NHRangeSliderView(frame: CGRect(x: 20, y: 20, width: self.bounds.width - 40, height: 40))
            sliderView?.maximumValue = maxValue
            sliderView?.minimumValue = minValue
            sliderView?.upperValue = maxValue
            sliderView?.lowerValue = minValue
            sliderView?.gapBetweenThumbs = (maxValue - minValue) * 40 / 100
            sliderView?.stepValue = 100
            sliderView?.trackHighlightTintColor = UIColor.primaryColor
            sliderView?.upperDisplayStringFormat = "%.0f"
            sliderView?.lowerDisplayStringFormat = "₹%.0f"
            sliderView?.thumbLabelStyle = .STICKY
            sliderView?.sizeToFit()
            
            self.addSubview(sliderView!)
            
        } else {
            sliderView?.upperValue = maxValue
            sliderView?.lowerValue = minValue
        }
    }
}
