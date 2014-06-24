//
//  TwitterOAuthClent.swift
//  HashTag
//
//  Created by Iegor Shapanov on 6/23/14.
//  Copyright (c) 2014 IegorShapanov. All rights reserved.
//

import Foundation
import Accounts

class TwitterOAuthClient: TwitterClientProtocol  {
    
    struct OAuth {
        static let version = "1.0"
        static let signatureMethod = "HMAC-SHA1"
    }
    
    var consumerKey: String
    var consumerSecret: String
    
    var credential: TwitterCredential?
    
    var stringEncoding: NSStringEncoding
    
    init(consumerKey: String, consumerSecret: String) {
        self.consumerKey = consumerKey
        self.consumerSecret = consumerSecret
        self.stringEncoding = NSUTF8StringEncoding
    }
    
    init(consumerKey: String, consumerSecret: String, accessToken: String, accessTokenSecret: String) {
        self.consumerKey = consumerKey
        self.consumerSecret = consumerSecret
        
        let credentialAccessToken = TwitterCredential.OAuthAccessToken(key: accessToken, secret: accessTokenSecret)
        self.credential = TwitterCredential(accessToken: credentialAccessToken)
        
        self.stringEncoding = NSUTF8StringEncoding
    }
    
    func get(path:              String,
             baseURL:           NSURL,
             parameters:        Dictionary<String, AnyObject>,
             uploadProgress:    TwitterHttpRequest.UploadProgressHandler?,
             downloadProgress:  TwitterHttpRequest.DownloadProgressHandler?,
             success:           TwitterHttpRequest.SuccessHandler?,
             failure:           TwitterHttpRequest.FailureHandler?) {
                
        let url = NSURL(string: path, relativeToURL: baseURL)
        let method = "GET"
        
        let request = TwitterHttpRequest(URL: url, method: method, parameters: parameters)
                
        request.headers =
            ["Authorization": self.authorizationHeaderForMethod(method, url: url, parameters: parameters, isMediaUpload: false)]
        request.downloadProgressHandler = downloadProgress
        request.successHandler = success
        request.failureHandler = failure
        request.dataEncoding = self.stringEncoding
        
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
        let method = "POST"
        
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
        
        let request = TwitterHttpRequest(URL: url, method: method, parameters: localParameters)
                
        request.headers =
            ["Authorization": self.authorizationHeaderForMethod(method, url: url, parameters: localParameters, isMediaUpload: postData != nil)]
        request.downloadProgressHandler = downloadProgress
        request.successHandler = success
        request.failureHandler = failure
        request.dataEncoding = self.stringEncoding
        
        if postData {
            let fileName = postDataFileName ? postDataFileName! as String : ""
            request.addMultipartData(postData!, parameterName: postDataKey!, mimeType: "application/octet-stream", fileName: fileName)
        }
        
        request.start()
    }
    
    func authorizationHeaderForMethod(method:        String,
                                      url:           NSURL,
                                      parameters:    Dictionary<String, AnyObject>,
                                      isMediaUpload: Bool) -> String {
                                        
        var authorizationParameters = Dictionary<String, AnyObject>()
        authorizationParameters["oauth_version"] = OAuth.version
        authorizationParameters["oauth_signature_method"] =  OAuth.signatureMethod
        authorizationParameters["oauth_consumer_key"] = self.consumerKey
        authorizationParameters["oauth_timestamp"] = String(Int(NSDate().timeIntervalSince1970))
        authorizationParameters["oauth_nonce"] = NSUUID().UUIDString.bridgeToObjectiveC()
        
        if self.credential?.accessToken {
            authorizationParameters["oauth_token"] = self.credential!.accessToken!.key
        }
        
        for (key, value: AnyObject) in parameters {
            if key.hasPrefix("oauth_") {
                authorizationParameters.updateValue(value, forKey: key)
            }
        }
        
        let combinedParameters = authorizationParameters.join(parameters)
        
        let finalParameters = isMediaUpload ? authorizationParameters : combinedParameters
        
        authorizationParameters["oauth_signature"] = self.oauthSignatureForMethod(method, url: url, parameters: finalParameters, accessToken: self.credential?.accessToken)
        
        let authorizationParameterComponents = authorizationParameters.urlEncodedQueryStringWithEncoding(self.stringEncoding).componentsSeparatedByString("&") as String[]
        authorizationParameterComponents.sort { $0 < $1 }
        
        var headerComponents = String[]()
        for component in authorizationParameterComponents {
            let subcomponent = component.componentsSeparatedByString("=") as String[]
            if subcomponent.count == 2 {
                headerComponents.append("\(subcomponent[0])=\"\(subcomponent[1])\"")
            }
        }
        
        return "OAuth " + headerComponents.bridgeToObjectiveC().componentsJoinedByString(", ")
    }
    
    func oauthSignatureForMethod(method:     String,
                                 url:        NSURL,
                                 parameters: Dictionary<String, AnyObject>,
                     accessToken token:      TwitterCredential.OAuthAccessToken?) -> String {
                        
        var tokenSecret: NSString = ""
        if token {
            tokenSecret = token!.secret.urlEncodedStringWithEncoding(self.stringEncoding)
        }
        
        let encodedConsumerSecret = self.consumerSecret.urlEncodedStringWithEncoding(self.stringEncoding)
        
        let signingKey = "\(encodedConsumerSecret)&\(tokenSecret)"
        let signingKeyData = signingKey.bridgeToObjectiveC().dataUsingEncoding(self.stringEncoding)
        
        let parameterComponents = parameters.urlEncodedQueryStringWithEncoding(self.stringEncoding).componentsSeparatedByString("&") as String[]
        parameterComponents.sort { $0 < $1 }
        
        let parameterString = parameterComponents.bridgeToObjectiveC().componentsJoinedByString("&")
        let encodedParameterString = parameterString.urlEncodedStringWithEncoding(self.stringEncoding)
        
        let encodedURL = url.absoluteString.urlEncodedStringWithEncoding(self.stringEncoding)
        
        let signatureBaseString = "\(method)&\(encodedURL)&\(encodedParameterString)"
        let signatureBaseStringData = signatureBaseString.dataUsingEncoding(self.stringEncoding)
        
        return ISSHASignature.signatureForKey(signingKeyData, data: signatureBaseStringData).base64EncodedStringWithOptions(nil)
    }
    
}