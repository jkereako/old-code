//
//  DCEncoding.h
//  DeliOrder
//
//  Created by Jeffrey Kereakoglow on 2/16/10.
//  Copyright 2010 Droste Consultants, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCProtocol.h"
#import "DCMacro.h"

@interface DCEncoding : NSObject <DCProtocol> {
@private
	BOOL _hadError;
	NSError *_lastError;
}

@property (assign, getter=hadError) BOOL _hadError;
@property (nonatomic, retain, getter=lastError) NSError *_lastError;

//Singleton Getter
+ (DCEncoding *) sharedDCEncoding;
- (NSString*) uuidString;
//JSON
- (NSString *) jsonStringForCollectionObject: (id) object;
- (id) collectionForJSONString: (NSString *) encodedString;

- (NSString *) stringForCArrayOfBytes: (const unsigned char *) array length: (NSUInteger) length;
- (NSString *) hmacSHA1ForString: (NSString *) plainString key: (NSString *) key;
//MD5
- (NSString *) hmacMD5ForString: (NSString *) plainString key: (NSString *) key;
- (NSString *) hashMD5ForString: (NSString *) plainString;
@end
