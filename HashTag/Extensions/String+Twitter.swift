//
//  String+Twitter.swift
//  HashTag
//
//  Created by Iegor Shapanov on 6/23/14.
//  Copyright (c) 2014 IegorShapanov. All rights reserved.
//

import Foundation
extension String {
    
    func length() -> Int {
        return countElements(self)
    }
    
    func urlEncodedStringWithEncoding(encoding: NSStringEncoding) -> String {
        let charactersToBeEscaped = ":/?&=;+!@#$()',*" as CFStringRef
        let charactersToLeaveUnescaped = "[]." as CFStringRef
        
        let result =
            CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                    self.bridgeToObjectiveC(),
                                                    charactersToLeaveUnescaped,
                                                    charactersToBeEscaped,
                                                    CFStringConvertNSStringEncodingToEncoding(encoding)) as String
        
        return result
    }
    
    func parametersFromQueryString() -> Dictionary<String, String> {
        var parameters = Dictionary<String, String>()
        
        let scanner = NSScanner(string: self)
        
        var key: NSString?
        var value: NSString?
        
        while !scanner.atEnd {
            key = nil
            scanner.scanUpToString("=", intoString: &key)
            scanner.scanString("=", intoString: nil)
            
            value = nil
            scanner.scanUpToString("&", intoString: &value)
            scanner.scanString("&", intoString: nil)
            
            if key && value {
                parameters.updateValue(value!, forKey: key!)
            }
        }
        
        return parameters
    }
    
}