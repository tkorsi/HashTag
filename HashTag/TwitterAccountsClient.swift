//
//  TwitterAccountsClient.swift
//  HashTag
//
//  Created by Iegor Shapanov on 6/23/14.
//  Copyright (c) 2014 IegorShapanov. All rights reserved.
//

import Foundation
import Accounts
import Social

class TwitterAccountsClient: TwitterClientProtocol {
    
    var credential: TwitterCredential?
    
    init(account: ACAccount) {
        self.credential = TwitterCredential(account: account)
    }
    
    func get(path:             String,
             baseURL:          NSURL,
             parameters:       Dictionary<String, AnyObject>,
             uploadProgress:   TwitterHttpRequest.UploadProgressHandler?,
             downloadProgress: TwitterHttpRequest.DownloadProgressHandler?,
             success:          TwitterHttpRequest.SuccessHandler?,
             failure:          TwitterHttpRequest.FailureHandler?) {
                
        let url = NSURL(string: path, relativeToURL: baseURL)
        
        var localParameters = Dictionary<String, String>()
        for (key, value: AnyObject) in parameters {
            localParameters[key] = "\(value)"
        }
        
        let socialRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: url, parameters: localParameters)
        socialRequest.account = self.credential!.account!
        
        let request = TwitterHttpRequest(request: socialRequest.preparedURLRequest())
        request.parameters = parameters
        request.downloadProgressHandler = downloadProgress
        request.successHandler = success
        request.failureHandler = failure
        
        request.start()
    }
    
    func post(path:             String,
              baseURL:          NSURL,
              parameters:       Dictionary<String, AnyObject>,
              uploadProgress:   TwitterHttpRequest.UploadProgressHandler?,
              downloadProgress: TwitterHttpRequest.DownloadProgressHandler?,
              success:          TwitterHttpRequest.SuccessHandler?,
              failure:          TwitterHttpRequest.FailureHandler?) {
                
        let url = NSURL(string: path, relativeToURL: baseURL)
        
        var localParameters = parameters
        
        var postData: NSData?
        var postDataKey: String?
        
        if let key : AnyObject = localParameters[TwitterManager.DataParameters.dataKey] {
            postDataKey = key as? String
            postData = localParameters[postDataKey!] as? NSData
            
            localParameters.removeValueForKey(TwitterManager.DataParameters.dataKey)
            localParameters.removeValueForKey(postDataKey!)
        }
        
        var postDataFileName: String?
        if let fileName : AnyObject = localParameters[TwitterManager.DataParameters.fileNameKey] {
            postDataFileName = fileName as? String
            localParameters.removeValueForKey(postDataFileName!)
        }
        
        for (key, value: AnyObject) in localParameters {
            localParameters[key] = "\(value)"
        }
        
        let socialRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.POST, URL: url, parameters: localParameters)
        socialRequest.account = self.credential!.account!
        
        if postData {
            let fileName = postDataFileName ? postDataFileName! as String : "media.jpg"
            
            socialRequest.addMultipartData(postData!, withName: postDataKey!, type: "application/octet-stream", filename: fileName)
        }
        
        let request = TwitterHttpRequest(request: socialRequest.preparedURLRequest())
        request.parameters = parameters
        request.downloadProgressHandler = downloadProgress
        request.successHandler = success
        request.failureHandler = failure
        
        request.start()
    }
    
}