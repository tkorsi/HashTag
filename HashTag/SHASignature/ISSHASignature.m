//
//  ISSHASignature.m
//  HashTag
//
//  Created by Iegor Shapanov on 6/23/14.
//  Copyright (c) 2014 IegorShapanov. All rights reserved.
//

#import "ISSHASignature.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation ISSHASignature

+ (NSData *)signatureForKey:(NSData *)keyData data:(NSData *)data
{
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CCHmacContext cx;
    CCHmacInit(&cx, kCCHmacAlgSHA1, keyData.bytes, keyData.length);
    CCHmacUpdate(&cx, data.bytes, data.length);
    CCHmacFinal(&cx, digest);
    
    return [NSData dataWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
}

@end
