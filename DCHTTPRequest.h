//
//  DCHTTPFetch.h
//  DeliOrder
//
//  Created by Jeffrey Kereakoglow on 2/12/10.
//  Copyright 2010 Droste Consultants, Inc.. All rights reserved.
//
//	Description: This class simply implements the delegate functions of NSURLConnection.
//	It handles all NSURLConnection errors
//
//	Handles data requests asynchronously and synchronously, for POST, GET and PUT
//
//	Required: CFNetwork
//

#import <Foundation/Foundation.h>
#import <CFNetwork/CFNetwork.h>
#import "DCProtocol.h"
#import "DCMacro.h"

@interface DCHTTPRequest : NSObject <DCProtocol>{
@private
	NSString *_notificationName;
	NSMutableData *_data;
	NSString *_urlString;
	NSString *_requestMethod;
	NSTimeInterval _timeoutInterval;
	NSMutableDictionary *_requestParameters;
	NSMutableURLRequest *_request;
	NSURLConnection *_connection;
	NSURLResponse *_response;
	NSDate *_timestamp;
	NSError *_lastError;

	id _returnObject;
	SEL _returnSelector;

@public
	BOOL didCompleteRequestSuccessfully;
}

@property (retain, readonly, getter=urlString) NSString *_urlString;
@property (retain, getter=requestMethod, setter=setRequestMethod) NSString *_requestMethod;
@property (assign, getter=timeoutInterval, setter=setTimeoutInterval) NSTimeInterval _timeoutInterval;
@property (retain, getter=requestParameters, setter=setRequestParameters) NSDictionary *_requestParameters;
@property (retain, readonly, getter=timestamp) NSDate *_timestamp;
@property (retain, readonly, getter=lastError) NSError *_lastError;
@property (assign) BOOL didCompleteRequestSuccessfully;

- (id) initWithURLString: (NSString *) urlString;
- (id) initWithURLString: (NSString *) urlString notificationName: (NSString *) notificationName returnObject: (id) returnObject returnSelector: (SEL) returnSelector;
- (id) initWithURLString: (NSString *) urlString notificationName: (NSString *) notificationName;	//Use with an NSNotificationCenter
- (id) initWithURLString: (NSString *) urlString returnsToSelector: (SEL) selector ofObject: (id) object;

//Setters
- (void) setTimeoutInterval: (NSTimeInterval) interval;
- (void) addRequestValue: (id) value forKey: (NSString *) key;
- (void) addHTTPHeaderValue: (NSString *) value forField: (NSString *) field;
- (void) setHTTPHeaders: (NSDictionary *) headerData;

//Requests
- (id) encodeRequestParameters;
- (void) sendSynchronousRequest;
- (void) sendAsynchronousRequest;
- (void) cancelRequest;
- (NSData *) dataResponse;
- (NSString *) stringResponse;
@end
