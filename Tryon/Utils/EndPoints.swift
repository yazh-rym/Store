//
//  EndPoints.swift
//  Tryon
//
//  Created by Udayakumar N on 14/03/17.
//  Copyright © 2017 1000Lookz. All rights reserved.
//

import Foundation
import AWSCognito

class EndPoints: NSObject {
    
    // MARK: - Class variables
    let model = TryonModel.sharedInstance
    
    var baseUrl: String = ""
    var registerUserUrl: String
    var getlogoUrl: String
    var getUserUrl: String
    var getModelListUrl: String
    var getInventoryUrl: String
    var getCollectionDistributorUrl: String
    var getCollectionDistributorFrameUrl: String
    var addItemsToCart: String
    var placeDistributorOrder: String
    var s3PreRenderedUrl: String
    var googleCloudVisionApiKey: String
    var googleCloudVisionUrl: String
    
    //TODO: Are these required?
    var placeOrderItemsUrl: String
    var s3BucketNameForVideoUpload: String
    var s3VideoFilePath: String
    var s3BucketNameForModelVideoDownload: String
    var s3BucketNameForModelJsonDownload: String
    
    //"http://ec2-13-232-110-144.ap-south-1.compute.amazonaws.com/api/"//
    // MARK: - Init functions
    override init() {
        if model.environment == .staging {
            baseUrl = "http://ec2-13-233-1-55.ap-south-1.compute.amazonaws.com/api/"//"http://ec2-13-127-33-30.ap-south-1.compute.amazonaws.com:3000/api/"
        } else if model.environment == .production {
            baseUrl = "http://ec2-13-233-1-55.ap-south-1.compute.amazonaws.com/api/"//"http://ec2-13-127-33-30.ap-south-1.compute.amazonaws.com:3000/api/"
        }

        registerUserUrl = baseUrl + "invUsers/login"
        getlogoUrl = baseUrl + "invUsers/"
        getUserUrl = baseUrl + "userTypes/getUsers"
        getModelListUrl = baseUrl + "models"
        getInventoryUrl = baseUrl + "frames"
        getCollectionDistributorUrl = baseUrl + "collectionDists"
        getCollectionDistributorFrameUrl = baseUrl + "collectionDistFrames"
        addItemsToCart = baseUrl + "orderItems/addToCartApi"
        placeDistributorOrder = baseUrl + "orderItems/distOrderApi"
        s3PreRenderedUrl = "https://s3-ap-southeast-1.amazonaws.com/offline-rendering/preRendered/"//"https://s3-ap-southeast-1.amazonaws.com/inventory-images-jsons/"//
        googleCloudVisionApiKey = "AIzaSyBo6gTyEYg3nz7QW5jHipYCqqyEaLo6J-Y"
        googleCloudVisionUrl = "https://vision.googleapis.com/v1/images:annotate"

        //TODO: Are these required?
        placeOrderItemsUrl = baseUrl + "orderItems"
        s3BucketNameForVideoUpload = "files.try1000looks.com/mobile/uservideo"
        s3VideoFilePath = "https://s3-ap-southeast-1.amazonaws.com/" + s3BucketNameForVideoUpload + "/"

        s3BucketNameForModelVideoDownload = "files.try1000looks.com/mobile/models"
        s3BucketNameForModelJsonDownload = "files.try1000looks.com/mobile/models"
    }
    
    func s3Config() {
        let cognitoUnauthRoleArn = "arn:aws:iam::971938541226:role/Cognito_1000lookz_EyewearUnauth_Role"
        let cognitoAuthRoleArn = "arn:aws:iam::971938541226:role/Cognito_1000lookz_EyewearAuth_Role"
        let defaultServiceRegionType = AWSRegionType.APSoutheast1
        let cognitoIdentityPoolId = "ap-northeast-1:eb185cd9-18e0-4346-b25e-437f30226779"
        
        let credentialsProvider = AWSCognitoCredentialsProvider.init(regionType: AWSRegionType.APNortheast1, identityPoolId: cognitoIdentityPoolId, unauthRoleArn: cognitoUnauthRoleArn, authRoleArn: cognitoAuthRoleArn, identityProviderManager: nil)
        
        let configuration = AWSServiceConfiguration(region: defaultServiceRegionType, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        AWSDDLog.sharedInstance.logLevel = .verbose
    }
}
