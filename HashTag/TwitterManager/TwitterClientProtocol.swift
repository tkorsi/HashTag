//
//  TwitterClientProtocol.swift
//  HashTag
//
//  Created by Iegor Shapanov on 6/23/14.
//  Copyright (c) 2014 IegorShapanov. All rights reserved.
//

import Foundation
import Accounts

protocol TwitterClientProtocol {
    
    var credential: TwitterCredential? { get set }
    
    func get(path:             String,
             baseURL:          NSURL,
             parameters:       Dictionary<String, AnyObject>,
             uploadProgress:   TwitterHttpRequest.UploadProgressHandler?,
             downloadProgress: TwitterHttpRequest.DownloadProgressHandler?,
             success:          TwitterHttpRequest.SuccessHandler?,
             failure:          TwitterHttpRequest.FailureHandler?)
    
    func post(path:             String,
              baseURL:          NSURL,
              parameters:       Dictionary<String, AnyObject>,
              uploadProgress:   TwitterHttpRequest.UploadProgressHandler?,
              downloadProgress: TwitterHttpRequest.DownloadProgressHandler?,
              success:          TwitterHttpRequest.SuccessHandler?,
              failure:          TwitterHttpRequest.FailureHandler?)
    
}

class TwitterCredential {
    
    struct OAuthAccessToken {
        
        var key: String
        var secret: String
        var verifier: String?
        
        var screenName: String?
        var userID: String?
        
        init(key: String, secret: String) {
            self.key = key
            self.secret = secret
        }
        
        init(queryString: String) {
            var attributes = queryString.parametersFromQueryString()
            
            self.key = attributes["oauth_token"]!
            self.secret = attributes["oauth_token_secret"]!
            
            self.screenName = attributes["screen_name"]
            self.userID = attributes["user_id"]
        }
        
    }
    
    var accessToken: OAuthAccessToken?
    var account: ACAccount?
    
    init(accessToken: OAuthAccessToken) {
        self.accessToken = accessToken
    }
    
    init(account: ACAccount) {
        self.account = account
    }
    
}