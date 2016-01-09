//
//  DCEncoding.m
//  DeliOrder
//
//  Created by Jeffrey Kereakoglow on 2/16/10.
//  Copyright 2010 Droste Consultants, Inc.. All rights reserved.
//

#import "DCEncoding.h"
#import "JSON.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

@implementation DCEncoding
@synthesize _hadError, _lastError;

SYNTHESIZE_SINGLETON_FOR_CLASS(DCEncoding)

#pragma mark DCProtocol
- (void) handleError: (NSError *) error {
    NSString *title = nil;
	NSString *message = nil;
	UIAlertView *alert = nil;
	
	title = [[NSString alloc] initWithString: NSLocalizedString(@"Encoding Error", @"General title for DCEncoding errors.")];
	message = [[NSString alloc] initWithString: [error localizedDescription]];
	
	//NSLog(message);
    
	alert = [[UIAlertView alloc] initWithTitle: title
									   message: message delegate:nil 
							 cancelButtonTitle:@"OK"
							 otherButtonTitles:nil];
	[alert show];
    
	SAFE_RELEASE(title);
	SAFE_RELEASE(message);
	SAFE_RELEASE(alert);
}

- (NSString*) uuidString{
	NSString *uuidString = nil;
	CFUUIDRef uuidObj = CFUUIDCreate(nil);//create a new UUID
	
	//get the string representation of the UUID
	uuidString = (NSString *) CFUUIDCreateString(nil, uuidObj);
	
	CFRelease(uuidObj);
	
	return [uuidString autorelease];
}

#pragma mark JSON
- (NSString *) jsonStringForCollectionObject: (id) object {
	SBJSON *encoder = nil;
	NSError *error = nil;
	NSString *result = nil;

	NSParameterAssert([object isKindOfClass: [NSDictionary class]] || [object isKindOfClass: [NSArray class]]);
		
	encoder = [[SBJSON alloc] init];
	error = [[NSError alloc] init];
	
	result = [encoder stringWithObject: object error: &error];
	
	if([error code]) {
		_hadError = YES;
		_lastError = error;
	}
	
	else {
		_hadError = NO;
		_lastError = nil;
	}
	
	SAFE_RELEASE(encoder);
	SAFE_RELEASE(error);
	
	return result;
}

- (id) collectionForJSONString: (NSString *) encodedString {
	SBJSON *decoder = nil;
	NSError *error = nil;
	id result = nil;
	
	error = [[NSError alloc] init];
	decoder = [[SBJSON alloc] init];
	
	// parse the JSON string into an object - assuming json_string is a NSString of JSON data
	result = [decoder objectWithString: encodedString error: &error];
	
	if([error code]) {
		_hadError = YES;
		_lastError = error;
	}
	
	else {
		_hadError = NO;
		_lastError = nil;
	}

	
	SAFE_RELEASE(decoder);
	SAFE_RELEASE(error);
		
	return result;
}

/*
 kCCHmacAlgSHA1,
 kCCHmacAlgMD5,
 kCCHmacAlgSHA256,
 kCCHmacAlgSHA384,
 kCCHmacAlgSHA512,
 kCCHmacAlgSHA224
 
 */

- (NSString *) stringForCArrayOfBytes: (const unsigned char *) array length: (NSUInteger) length {
	NSUInteger i = 0;
	NSMutableString *decodedString = nil;
	
	decodedString = [[[NSMutableString alloc] initWithCapacity: length] autorelease];
	
	for (i = 0; i != length; ++ i)
		[decodedString appendFormat:@"%02x", array[i]];
	
	return decodedString;
}

- (NSString *) hmacSHA1ForString: (NSString *) plainString key: (NSString *) key {
	NSParameterAssert(plainString || key);
	
	const char *cKey  = [key cStringUsingEncoding: NSASCIIStringEncoding];
	const char *cData = [plainString cStringUsingEncoding: NSASCIIStringEncoding];
	NSString *hashedString = nil;
	unsigned char hashedData[CC_SHA1_DIGEST_LENGTH];
	
	CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), hashedData);
		
	hashedString = [self stringForCArrayOfBytes: hashedData length: CC_SHA1_DIGEST_LENGTH];
	
	return hashedString;
	
}


- (NSString *) hmacMD5ForString: (NSString *) plainString key: (NSString *) key {
	NSParameterAssert(plainString || key);
	
	const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
	const char *cData = [plainString cStringUsingEncoding:NSASCIIStringEncoding];
	NSString *hashedString = nil;
	unsigned char hashedData[CC_MD5_DIGEST_LENGTH];
	
	CCHmac(kCCHmacAlgMD5, cKey, strlen(cKey), cData, strlen(cData), hashedData);
		
	hashedString = [self stringForCArrayOfBytes: hashedData length: CC_MD5_DIGEST_LENGTH];
	
	return hashedString;
	
}

#pragma mark MD5
- (NSString *) hashMD5ForString: (NSString *) plainString {
	NSData *plainData = nil;
	NSString *hashedString = nil;
	unsigned char hashedData[CC_MD5_DIGEST_LENGTH];
	
	plainData = [[NSData alloc] initWithData: [plainString dataUsingEncoding: NSUTF8StringEncoding]];
	
	CC_MD5([plainData bytes], [plainData length], hashedData);
	
	SAFE_RELEASE(plainData);
	
	hashedString = [self stringForCArrayOfBytes: hashedData length: CC_MD5_DIGEST_LENGTH];
			
	return hashedString;
}
@end
