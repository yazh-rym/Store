//
//  String+TryonConfig.swift
//  Tryon
//
//  Created by Udayakumar N on 16/03/17.
//  Copyright © 2017 1000Lookz. All rights reserved.
//

import Foundation
import Alamofire

extension String: ParameterEncoding {
    
    // MARK: - Parameter encoding 
    
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = data(using: .utf8, allowLossyConversion: false)
        return request
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return self.capitalized
        
        //Return Capitalized. But implement as required, if capitalization requirement changes.
//        let first = String(characters.prefix(1)).capitalized
//        let other = String(characters.dropFirst())
//        return first + other
    
//        var currentIndex = self.startIndex
//        var shouldCapitalizeNextChar = false
//        var value: [Character] = []
//        
//        while currentIndex != self.endIndex {
//            if shouldCapitalizeNextChar == true {
//                value.append(self.characters[currentIndex])
//            } else {
//                value.append(self.characters[currentIndex])
//            }
//            
//            if currentIndex == self.startIndex {
//                shouldCapitalizeNextChar = true
//            } else if (self.characters[currentIndex] == "." || self.characters[currentIndex] == "-") {
//                shouldCapitalizeNextChar = true
//            }
//            currentIndex = self.index(after: currentIndex)
//        }
//        
//        return String(value)
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

extension NSMutableAttributedString {
    @discardableResult func bold(_ text:String, size: CGFloat, color: UIColor) -> NSMutableAttributedString {
        var attrs:[String:AnyObject] = [NSFontAttributeName: UIFont(name: "SFUIText-Bold", size: size)!]
        attrs[NSForegroundColorAttributeName] = color //UIColor.primaryDarkColor
        let boldString = NSMutableAttributedString(string: text, attributes:attrs)
        self.append(boldString)
        return self
    }
    
    @discardableResult func normal(_ text:String, size: CGFloat, color: UIColor)->NSMutableAttributedString {
        var attrs:[String:AnyObject] = [NSFontAttributeName: UIFont(name: "SFUIText-Regular", size: size)!]
        attrs[NSForegroundColorAttributeName] = color //UIColor.primaryDarkColor
        let normalString =  NSMutableAttributedString(string: text, attributes:attrs)
        self.append(normalString)
        return self
    }
    
    @discardableResult func light(_ text:String, size: CGFloat, color: UIColor)->NSMutableAttributedString {
        var attrs:[String:AnyObject] = [NSFontAttributeName: UIFont(name: "SFUIText-Light", size: size)!]
        attrs[NSForegroundColorAttributeName] = color //UIColor.primaryDarkColor
        let lightString =  NSMutableAttributedString(string: text, attributes:attrs)
        self.append(lightString)
        return self
    }
}
