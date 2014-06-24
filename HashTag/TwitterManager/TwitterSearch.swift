//
//  TwitterTweets.swift
//  HashTag
//
//  Created by Iegor Shapanov on 6/23/14.
//  Copyright (c) 2014 IegorShapanov. All rights reserved.
//

import Foundation
extension TwitterManager {
    
    //	GET		search/tweets
    func getSearchTweetsWithQuery(q:                String,
                                  geocode:          String?,
                                  lang:             String?,
                                  locale:           String?,
                                  resultType:       String?,
                                  count:            Int?,
                                  until:            String?,
                                  sinceID:          String?,
                                  maxID:            String?,
                                  includeEntities:  Bool?,
                                  callback:         String?,
                                  success:          JSONSuccessHandler?,
                                  failure:          TwitterHttpRequest.FailureHandler) {
                                    
        let path = "search/tweets.json"
        
        var parameters = Dictionary<String, AnyObject>()
        parameters["q"] = q
        
        if geocode {
            parameters["geocode"] = geocode!
        }
        if lang {
            parameters["lang"] = lang!
        }
        if locale {
            parameters["locale"] = locale!
        }
        if resultType {
            parameters["result_type"] = resultType!
        }
        if count {
            parameters["count"] = count!
        }
        if until {
            parameters["until"] = until!
        }
        if sinceID {
            parameters["since_id"] = sinceID!
        }
        if maxID {
            parameters["max_id"] = maxID!
        }
        if includeEntities {
            parameters["include_entities"] = includeEntities!
        }
        if callback {
            parameters["callback"] = callback!
        }
        
        self.getJSONWithPath(path, baseURL: self.apiURL, parameters: parameters, uploadProgress: nil, downloadProgress: nil, success: success, failure: failure)
    }
    
}
