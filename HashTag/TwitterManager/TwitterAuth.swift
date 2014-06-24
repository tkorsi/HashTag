//
//  TwitterAuth.swift
//  HashTag
//
//  Created by Iegor Shapanov on 6/23/14.
//  Copyright (c) 2014 IegorShapanov. All rights reserved.
//

import Foundation
import UIKit
extension TwitterManager {
    
    typealias TokenSuccessHandler = (accessToken: TwitterCredential.OAuthAccessToken, response: NSURLResponse) -> Void
    
    func authorizeWithCallbackURL(callbackURL:  NSURL,
                                  success:      TokenSuccessHandler,
                                  failure:      ((error: NSError) -> Void)?) {
                                    
        self.postOAuthRequestTokenWithCallbackURL(callbackURL, success: {
            token, response in
            
            var requestToken = token
            
            NSNotificationCenter.defaultCenter().addObserverForName(CallbackNotification.notificationName, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock:{
                notification in
                
                NSNotificationCenter.defaultCenter().removeObserver(self)
                
                let url = notification.userInfo[CallbackNotification.optionsURLKey] as NSURL

                let parameters = url.query.parametersFromQueryString()
                requestToken.verifier = parameters["oauth_verifier"]
                
                self.postOAuthAccessTokenWithRequestToken(requestToken, success: {
                    accessToken, response in
                    
                    self.client.credential = TwitterCredential(accessToken: accessToken)
                    success(accessToken: accessToken, response: response)
                    
                    }, failure: failure)
                })
            
            let authorizeURL = NSURL(string: "/oauth/authorize", relativeToURL: self.apiURL)
            let queryURL = NSURL(string: authorizeURL.absoluteString + "?oauth_token=\(token.key)")
            
            #if os(iOS)
                UIApplication.sharedApplication().openURL(queryURL)
            #else
                NSWorkspace.sharedWorkspace().openURL(queryURL)
            #endif
            }, failure: failure)
    }
    
    func postOAuthRequestTokenWithCallbackURL(callbackURL: NSURL, success: TokenSuccessHandler, failure: FailureHandler?) {
        let path = "/oauth/request_token"
        
        var parameters =  Dictionary<String, AnyObject>()
        
        if let callbackURLString = callbackURL.absoluteString {
            parameters["oauth_callback"] = callbackURLString
        }
        
        self.client.post(path,
                         baseURL: self.apiURL,
                         parameters: parameters,
                         uploadProgress: nil,
                         downloadProgress: nil,
                         success: {
                             data, response in
                             
                             let responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
                             let accessToken = TwitterCredential.OAuthAccessToken(queryString: responseString)
                             success(accessToken: accessToken, response: response)
                        
                         },
                         failure: failure)
    }
    
    func postOAuthAccessTokenWithRequestToken(requestToken: TwitterCredential.OAuthAccessToken, success: TokenSuccessHandler, failure: FailureHandler?) {
        if let verifier = requestToken.verifier {
            let path =  "/oauth/access_token"
            
            var parameters = Dictionary<String, AnyObject>()
            parameters["oauth_token"] = requestToken.key
            parameters["oauth_verifier"] = verifier
            
            self.client.post(path, baseURL: self.apiURL, parameters: parameters, uploadProgress: nil, downloadProgress: nil, success: {
                data, response in
                
                let responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
                let accessToken = TwitterCredential.OAuthAccessToken(queryString: responseString)
                success(accessToken: accessToken, response: response)
                
                }, failure: failure)
        }
        else {
            let userInfo = [NSLocalizedFailureReasonErrorKey: "Bad OAuth response received from server"]
            let error = NSError(domain: SwifterError.domain, code: NSURLErrorBadServerResponse, userInfo: userInfo)
            failure?(error: error)
        }
    }
    
    class func handleOpenURL(url: NSURL) {
        let notification = NSNotification(name: CallbackNotification.notificationName, object: nil,
            userInfo: [CallbackNotification.optionsURLKey: url])
        NSNotificationCenter.defaultCenter().postNotification(notification)
    }
    
}
