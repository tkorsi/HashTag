//
//  TwitterManager.swift
//  HashTag
//
//  Created by Iegor Shapanov on 6/23/14.
//  Copyright (c) 2014 IegorShapanov. All rights reserved.
//

import Foundation
import Accounts

#if os(iOS)
    import UIKit
#else
    import AppKit
#endif

class TwitterManager {
    
    var apiURL: NSURL
    var uploadURL: NSURL
    var streamURL: NSURL
    var userStreamURL: NSURL
    var siteStreamURL: NSURL
    
    typealias JSONSuccessHandler = (json: AnyObject, response: NSHTTPURLResponse) -> Void
    typealias FailureHandler = (error: NSError) -> Void
    
    struct CallbackNotification {
        static let notificationName = "ISTwitterManagerCallbackNotificationName"
        static let optionsURLKey = "ISTwitterManagerCallbackNotificationOptionsURLKey"
    }
    
    struct SwifterError {
        static let domain = "ISTwitterManagerErrorDomain"
    }
    
    struct DataParameters {
        static let dataKey = "ISTwitterManagerDataParameterKey"
        static let fileNameKey = "ISTwitterManagerDataParameterFilename"
    }
    
    var client: TwitterClientProtocol
    
    init(consumerKey: String, consumerSecret: String) {
        self.client = TwitterOAuthClient(consumerKey: consumerKey, consumerSecret: consumerSecret)
        
        self.apiURL = NSURL(string: "https://api.twitter.com/1.1/")
        self.uploadURL = NSURL(string: "https://upload.twitter.com/1.1/")
        self.streamURL = NSURL(string: "https://stream.twitter.com/1.1/")
        self.userStreamURL = NSURL(string: "https://userstream.twitter.com/1.1/")
        self.siteStreamURL = NSURL(string: "https://sitestream.twitter.com/1.1/")
    }
    
    init(consumerKey:       String,
         consumerSecret:    String,
         oauthToken:        String,
         oauthTokenSecret:  String) {
            
        self.client = TwitterOAuthClient(consumerKey: consumerKey, consumerSecret: consumerSecret , accessToken: oauthToken, accessTokenSecret: oauthTokenSecret)
        
        self.apiURL = NSURL(string: "https://api.twitter.com/1.1/")
        self.uploadURL = NSURL(string: "https://upload.twitter.com/1.1/")
        self.streamURL = NSURL(string: "https://stream.twitter.com/1.1/")
        self.userStreamURL = NSURL(string: "https://userstream.twitter.com/1.1/")
        self.siteStreamURL = NSURL(string: "https://sitestream.twitter.com/1.1/")
    }
    
    init(account: ACAccount) {
        self.client = TwitterAccountsClient(account: account)
        
        self.apiURL = NSURL(string: "https://api.twitter.com/1.1/")
        self.uploadURL = NSURL(string: "https://upload.twitter.com/1.1/")
        self.streamURL = NSURL(string: "https://stream.twitter.com/1.1/")
        self.userStreamURL = NSURL(string: "https://userstream.twitter.com/1.1/")
        self.siteStreamURL = NSURL(string: "https://sitestream.twitter.com/1.1/")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func jsonRequestWithPath(path:              String,
                             baseURL:           NSURL,
                             method:            String,
                             parameters:        Dictionary<String, AnyObject>,
                             uploadProgress:    TwitterHttpRequest.UploadProgressHandler?,
                             downloadProgress:  JSONSuccessHandler?,
                             success:           JSONSuccessHandler?,
                             failure:           TwitterHttpRequest.FailureHandler?) {
                                
        let jsonDownloadProgressHandler: TwitterHttpRequest.DownloadProgressHandler = {
            data, _, _, response in
            
            if !downloadProgress {
                return
            }
            
            var error: NSError?
            if let jsonResult: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &error) {
                downloadProgress?(json: jsonResult, response: response)
            }
            else {
                let jsonString = NSString(data: data, encoding: NSUTF8StringEncoding)
                let jsonChunks = jsonString.componentsSeparatedByString("\r\n") as String[]
                
                for chunk in jsonChunks {
                    if chunk.utf16count == 0 {
                        continue
                    }
                    
                    let chunkData = chunk.dataUsingEncoding(NSUTF8StringEncoding)
                    
                    
                    if let jsonResult: AnyObject = NSJSONSerialization.JSONObjectWithData(chunkData, options: nil, error: &error) {
                        downloadProgress?(json: jsonResult, response: response)
                    }
                }
            }
        }
        
        let jsonSuccessHandler: TwitterHttpRequest.SuccessHandler = {
            data, response in
            
            var error: NSError?
            let jsonResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &error)
            
            if error {
                failure?(error: error!)
            }
            else {
                success?(json: jsonResult!, response: response)
            }
        }
        
        if method == "GET" {
            println(path)
            self.client.get(path, baseURL: baseURL, parameters: parameters, uploadProgress: uploadProgress, downloadProgress: jsonDownloadProgressHandler, success: jsonSuccessHandler, failure: failure)
        }
        else {
            self.client.post(path, baseURL: baseURL, parameters: parameters, uploadProgress: uploadProgress, downloadProgress: jsonDownloadProgressHandler, success: jsonSuccessHandler, failure: failure)
        }
    }
    
    func getJSONWithPath(path:              String,
                         baseURL:           NSURL,
                         parameters:        Dictionary<String, AnyObject>,
                         uploadProgress:    TwitterHttpRequest.UploadProgressHandler?,
                         downloadProgress:  JSONSuccessHandler?,
                         success:           JSONSuccessHandler?,
                         failure:           TwitterHttpRequest.FailureHandler?) {
                            
        self.jsonRequestWithPath(path, baseURL: baseURL, method: "GET", parameters: parameters, uploadProgress: uploadProgress, downloadProgress: downloadProgress, success: success, failure: failure)
    }
    
    func postJSONWithPath(path:             String,
                          baseURL:          NSURL,
                          parameters:       Dictionary<String, AnyObject>,
                          uploadProgress:   TwitterHttpRequest.UploadProgressHandler?,
                          downloadProgress: JSONSuccessHandler?,
                          success:          JSONSuccessHandler?,
                          failure:          TwitterHttpRequest.FailureHandler?) {
                            
        self.jsonRequestWithPath(path, baseURL: baseURL, method: "POST", parameters: parameters, uploadProgress: uploadProgress, downloadProgress: downloadProgress, success: success, failure: failure)
    }

}
