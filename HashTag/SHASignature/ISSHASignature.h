//
//  ISSHASignature.h
//  HashTag
//
//  Created by Iegor Shapanov on 6/23/14.
//  Copyright (c) 2014 IegorShapanov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ISSHASignature : NSObject

+ (NSData *)signatureForKey:(NSData *)keyData data:(NSData *)data;

@end
