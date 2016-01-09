//
//  DCHTTPFetch.m
//  DeliOrder
//
//  Created by Jeffrey Kereakoglow on 2/12/10.
//  Copyright 2010 Droste Consultants, Inc.. All rights reserved.
//

#import "DCHTTPRequest.h"

@implementation DCHTTPRequest
@synthesize _urlString, _requestMethod, _timeoutInterval, _requestParameters, _timestamp, _lastError, didCompleteRequestSuccessfully;

#pragma mark Constuctors and Destructor
- (id) initWithURLString: (NSString *) urlString {
	return [self initWithURLString: urlString notificationName: nil returnObject: nil returnSelector: nil];
}

- (id) initWithURLString: (NSString *) urlString notificationName: (NSString *) notificationName {
	return [self initWithURLString: urlString notificationName: notificationName returnObject: nil returnSelector: nil];
}


- (id) initWithURLString: (NSString *) urlString returnsToSelector: (SEL) selector ofObject: (id) object {
	return [self initWithURLString: urlString notificationName: nil returnObject: object returnSelector: selector];
}

- (id) initWithURLString: (NSString *) urlString notificationName: (NSString *) notificationName returnObject: (id) returnObject returnSelector: (SEL) returnSelector {
	self = [super init];
	
	if (!self)
		return nil;
	
	DEBUG_LOG(@"Initializing DCHTTPRequest...");
	NSLog([NSString stringWithFormat: @"Requesting \"%@\"", urlString]);
	
	_urlString = nil;
	_requestMethod = nil;
	_timeoutInterval = 60.0;
	_timestamp = nil;
	_lastError = nil;
	_request = nil;
	_connection = nil;
	_response = nil;
	_data = nil;
	_requestParameters = nil;
	_returnObject = nil;
	_returnSelector = nil;
	didCompleteRequestSuccessfully = NO;
	
	if(notificationName)
		_notificationName = [[NSString alloc] initWithString: notificationName];
	
	if(returnObject)
		_returnObject = returnObject;
	
	if(returnSelector)
		_returnSelector = returnSelector;
	
	_urlString = [[NSString alloc] initWithString: urlString];
	_requestMethod = @"GET";

	return self;
}

- (void) dealloc {
	DEBUG_LOG(@"Deallocating DCHTTPRequest...");
	
	//if(_urlString != nil && [_urlString isKindOfClass: [ns]])
	//	SAFE_RELEASE(_urlString);
	
	SAFE_RELEASE(_urlString);
	SAFE_RELEASE(_timestamp);
	
	_lastError = nil;
	
	//SAFE_RELEASE(_lastError);
	SAFE_RELEASE(_requestMethod);
	SAFE_RELEASE(_request);
	//SAFE_RELEASE(_response);
	SAFE_RELEASE(_data);
	SAFE_RELEASE(_notificationName);
	SAFE_RELEASE(_requestParameters);
	
	

	_returnObject = nil;
	_returnSelector = nil;
	
	[super dealloc];
}

#pragma mark -
#pragma mark Description

- (NSString *) description {
	NSMutableString *description = nil;
	
	description = [[[NSMutableString alloc] init] autorelease];
	
	[description appendFormat: @"\n  URL: %@\n", _urlString];
	[description appendFormat: @"  Request Method: %@\n", _requestMethod];
	
	if([_requestParameters isKindOfClass: [NSMutableDictionary class]])
		[description appendFormat: @"  Request Parameters: %@\n", [_requestParameters description]];
	
	/*
	if([[self stringResponse] isKindOfClass: [NSString class]])
		[description appendFormat: @"  Response: %@", [self stringResponse]];
	*/
	
	return description;
}

#pragma mark DCStandard
- (void) notifyCaller {
	
	///DEBUG_LOG(@"[DCHTTP notifyCaller]");
	
	if(_notificationName)
		[[NSNotificationCenter defaultCenter] postNotificationName: _notificationName object: _data userInfo: nil];

	else if([_returnObject respondsToSelector: _returnSelector])
		[_returnObject performSelector: _returnSelector];
}

- (void) handleError: (NSError *) error {
	if(_lastError)
		_lastError = nil;
	//	SAFE_RELEASE(_lastError);
	
	_lastError = error;

	
	didCompleteRequestSuccessfully = NO;
}

#pragma mark Public Methods
- (id) encodeRequestParameters {
	NSAssert([_requestParameters isKindOfClass: [NSDictionary class]] && [_requestParameters count],
			 @"DCHTTPRequest._requestParameters is invalid (nil, empty, or dangling pointer).");
	
	NSData *encodedPostData = nil;
	NSString *unencodedData = nil;
	NSMutableArray *requestParameters = nil;
	NSString *key = nil;
	id value = nil;
	NSString *encodedValue = nil;
	NSEnumerator *iterator = nil;
	
	iterator = [_requestParameters keyEnumerator];
	
	requestParameters = [[NSMutableArray alloc] initWithCapacity: [_requestParameters count]];
	
	while (key = [iterator nextObject]) {	
		value = [_requestParameters objectForKey: key];

		//Encodes strings and dates only, numbers are constants, remember?
		if([value isKindOfClass: [NSString class]] || [value isKindOfClass: [NSDate class]])
			encodedValue = (NSString *)CFURLCreateStringByAddingPercentEscapes(
																		NULL,
																		(CFStringRef) value,
																		NULL,
																		(CFStringRef)@"!*'();:@&=+$,/?%#[]",
																		kCFStringEncodingUTF8 );
		
		
		[requestParameters addObject: [NSString stringWithFormat: @"%@=%@", key, encodedValue]];
		
		SAFE_RELEASE(encodedValue);
	}
	
	iterator = nil;
	key = nil;
	value = nil;
	
	//Separate all arguments with the standard separator
	unencodedData = [[NSString alloc] initWithString: [requestParameters componentsJoinedByString: @"&"]];
	
	if([_requestMethod isEqualToString: @"GET"]) {
		NSString *encodedQueryString = nil;		

		encodedQueryString = [[NSString alloc] initWithFormat: @"%@?%@", _urlString, unencodedData];
		
		SAFE_RELEASE(requestParameters);
		SAFE_RELEASE(unencodedData);
		
		return [encodedQueryString autorelease];
	}
	else {
		//encodedPostData = [[NSData alloc] initWithData: [unencodedData dataUsingEncoding: NSASCIIStringEncoding allowLossyConversion: YES]];
		encodedPostData = [[NSData alloc] initWithData: [unencodedData dataUsingEncoding: NSUTF8StringEncoding allowLossyConversion: YES]];		
	}

	SAFE_RELEASE(requestParameters);
	SAFE_RELEASE(unencodedData);
	
	return [encodedPostData autorelease];
}

#pragma mark Setters
- (void) setRequestMethod: (NSString *) method {
	NSParameterAssert(method);
	
	if(_requestMethod == method)
		return;
	
	method = [method uppercaseString];
	
	if(_requestMethod)
		SAFE_RELEASE(_requestMethod);
	
	if([method isEqualToString: @"GET"] ||
	   [method isEqualToString: @"PUT"] ||
		[method isEqualToString: @"POST"])
		_requestMethod = [[NSString alloc] initWithString: method];
	
	else
		_requestMethod = [[NSString alloc] initWithString: @"GET"];
}

- (void) setTimeoutInterval: (NSTimeInterval) interval {
	if(interval <= 0 || interval >= 60)
		return;
	
	_timeoutInterval = interval;
}

- (void) addRequestValue: (id) value forKey: (NSString *) key {
	NSParameterAssert(key);
	NSParameterAssert(value);
		
	if(![_requestParameters isKindOfClass: [NSMutableDictionary class]]) {
		SAFE_RELEASE(_requestParameters);
		
		_requestParameters = [[NSMutableDictionary alloc] init];
	}
	
	[_requestParameters setObject: value forKey: key];
}

- (void) addHTTPHeaderValue: (NSString *) value forField: (NSString *) field {
	NSParameterAssert(value && field);
	NSException *exception = nil;
	
	if(![_request isKindOfClass: [NSMutableURLRequest class]]) {
		exception = [[NSException alloc] initWithName: @"InvalidPointer" 
											   reason: @"Failed to add HTTP header to request, property \"_request\" is nil or invalid"
											 userInfo: nil];
		
		@throw exception;
		
		SAFE_RELEASE(exception);
	}
	
	[_request addValue: value forHTTPHeaderField: field];
}


- (void) setHTTPHeaders: (NSDictionary *) headerData {
	if(!headerData)
		return;
	
	[_request setAllHTTPHeaderFields: headerData];
}

#pragma mark Send Request
- (void) sendSynchronousRequest {
	NSError *error = nil;
	NSString *queryString = nil;
	
	//NSLog(_urlString);
	
	if([_request isKindOfClass: [NSMutableURLRequest class]])
		SAFE_RELEASE(_request);
	
	if([_data isKindOfClass: [NSMutableData class]])
		SAFE_RELEASE(_data);
	
	if([_timestamp isKindOfClass: [NSDate class]])
		SAFE_RELEASE(_timestamp);
	
	if([_response isKindOfClass: [NSURLResponse class]])
		_response = nil;
		//SAFE_RELEASE(_response);
		
	_data = [[NSMutableData alloc] init];
	_timestamp = [[NSDate alloc] init];
	_response = [[[NSURLResponse alloc] init] autorelease];
		
	if(_requestParameters && ![_requestMethod isEqualToString: @"GET"]) {
		_request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString: _urlString]
												cachePolicy: NSURLRequestReloadIgnoringCacheData
											timeoutInterval: _timeoutInterval];
		
		[_request setHTTPMethod: _requestMethod];
		[_request setHTTPBody: (NSData *) [self encodeRequestParameters]];
		[_request setValue: [NSString stringWithFormat: @"%d", [[_request HTTPBody] length]] forHTTPHeaderField: @"Content-Length"];
		[_request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	}
	
	else {
		if(_requestParameters) {
			queryString = [[NSString alloc] initWithString: (NSString *) [self encodeRequestParameters]];
			_request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString: queryString]
													cachePolicy: NSURLRequestReloadIgnoringCacheData
												timeoutInterval: _timeoutInterval];
			SAFE_RELEASE(queryString);
		}
		else
			//Wrap in try block
			_request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString: _urlString]
													cachePolicy: NSURLRequestReloadIgnoringCacheData
												timeoutInterval: _timeoutInterval];
	}
	
	NSAssert(_request, @"ERROR! Failed to create URL connection.");
		
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: YES];
		
	[_data setData: [NSURLConnection sendSynchronousRequest: _request returningResponse: &_response error: &error]];
	
	SAFE_RELEASE(_request);
	//SAFE_RELEASE(_response);
	
	if(error)
		[self connection: nil didFailWithError: error];
	
	else {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
	
		didCompleteRequestSuccessfully = YES;
	
		[self notifyCaller];
	}
	

}

- (void) sendAsynchronousRequest {
	NSString *queryString = nil;

	if(_request)
		SAFE_RELEASE(_request);
	
	if(_data)
		SAFE_RELEASE(_data);
	
	if(_timestamp)
		SAFE_RELEASE(_timestamp);

	_timestamp = [[NSDate alloc] init];
	
	if(_requestParameters && ![_requestMethod isEqualToString: @"GET"]) {		
		_request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString: _urlString]
												cachePolicy: NSURLRequestReloadIgnoringCacheData
											timeoutInterval: _timeoutInterval];
		
		[_request setHTTPMethod: _requestMethod];
		[_request setHTTPBody: (NSData *) [self encodeRequestParameters]];
		[_request setValue: [NSString stringWithFormat: @"%d", [[_request HTTPBody] length]] forHTTPHeaderField: @"Content-Length"];
		[_request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	}
	
	else {
		if(_requestParameters) {
			queryString = [[NSString alloc] initWithString: (NSString *) [self encodeRequestParameters]];
		
			_request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString: queryString]
													cachePolicy: NSURLRequestReloadIgnoringCacheData
												timeoutInterval: _timeoutInterval];
		
			SAFE_RELEASE(queryString);
		}
		
		else
			_request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString: _urlString]
													cachePolicy: NSURLRequestReloadIgnoringCacheData
												timeoutInterval: _timeoutInterval];

	}
	
	NSAssert(_request, @"ERROR! Failed to create URL connection.");	
	
	_connection = [[[NSURLConnection alloc] initWithRequest: _request delegate: self startImmediately: YES] autorelease];
		
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: YES];

}

- (void) cancelRequest {
	[_connection cancel];
	
	_connection = nil;
	//SAFE_RELEASE(_connection);
	SAFE_RELEASE(_request);
}

#pragma mark Thread-safe Getters
- (NSData *) dataResponse {
	id result = nil;
	
	@synchronized (self) {
		result = [_data retain];
	}
	
	return [result autorelease];
}

- (NSString *) stringResponse {
	NSAssert([_data isKindOfClass: [NSData class]], 
			 @"DCHTTPRequest._data is invalid (empty or nil). Cannot convert data to string");
	
	NSString *response = nil;
	
	response = [[NSString alloc] initWithData: _data encoding: NSStringEncodingConversionAllowLossy];
	
	return [response autorelease];
}


#pragma mark NSURLConnection delegate methods
- (void) connection: (NSURLConnection *) connection didSendBodyData: (NSInteger) bytesWritten totalBytesWritten: (NSInteger) totalBytesWritten totalBytesExpectedToWrite: (NSInteger) totalBytesExpectedToWrite {
	;
}
/*
- (NSURLRequest *) connection: (NSURLConnection *) connection willSendRequest: (NSURLRequest *) request redirectResponse: (NSURLResponse *) redirectResponse {
}
*/
- (void) connection: (NSURLConnection *) connection didReceiveResponse: (NSURLResponse *) response {
	_data = [[NSMutableData alloc] init];
}

- (void) connection: (NSURLConnection *) connection didReceiveData: (NSData *) data {
	if(_data)
		[_data appendData: data];
}

- (void) connection: (NSURLConnection *) connection didFailWithError: (NSError *) error {
	NSError *preciseError = nil;
	NSDictionary *userInfo = nil;
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];   
	
	if(_data)
		SAFE_RELEASE(_data);

	SAFE_RELEASE(_request);
		
	//If the error can be identified, we can present a more precise message to the user and possibly recover from the error.
	switch ([error code]) {
		case kCFURLErrorCancelled:
			userInfo = [NSDictionary dictionaryWithObject: NSLocalizedString(@"Connection to host has been cancelled.",
																			 @"Error message displayed when action is cancelled.")
												   forKey: NSLocalizedDescriptionKey];
			preciseError = [[NSError alloc] initWithDomain: NSCocoaErrorDomain code: kCFURLErrorCancelled userInfo: userInfo];
			break;
			
		case kCFURLErrorBadURL:
			userInfo = [NSDictionary dictionaryWithObject: NSLocalizedString(@"Bad URL.",
																			 @"Error message displayed when URL is bad.")
												   forKey: NSLocalizedDescriptionKey];
			preciseError = [[NSError alloc] initWithDomain: NSCocoaErrorDomain code: kCFURLErrorBadURL userInfo: userInfo];
			break;
			
		case kCFURLErrorTimedOut:
			userInfo = [NSDictionary dictionaryWithObject: NSLocalizedString(@"Request has timed out.",
																			 @"Error message displayed when timed out.")
												   forKey: NSLocalizedDescriptionKey];
			preciseError = [[NSError alloc] initWithDomain: NSCocoaErrorDomain code: kCFURLErrorTimedOut userInfo: userInfo];
			break;
			
		case kCFURLErrorUnsupportedURL:
			userInfo = [NSDictionary dictionaryWithObject: NSLocalizedString(@"Unsupported URL protocol.",
																			 @"Error message displayed when URL is unsupported.")
												   forKey: NSLocalizedDescriptionKey];
			preciseError = [[NSError alloc] initWithDomain: NSCocoaErrorDomain code: kCFURLErrorUnsupportedURL userInfo: userInfo];
			break;
			
		case kCFURLErrorCannotFindHost:
			userInfo = [NSDictionary dictionaryWithObject: NSLocalizedString(@"Could not find host.",
																			 @"Error message displayed when host cannot be found.")
												   forKey: NSLocalizedDescriptionKey];
			preciseError = [[NSError alloc] initWithDomain: NSCocoaErrorDomain code: kCFURLErrorCannotFindHost userInfo: userInfo];
			break;
			
		case kCFURLErrorCannotConnectToHost:
			userInfo = [NSDictionary dictionaryWithObject: NSLocalizedString(@"Could not connect to host.",
																			 @"Error message displayed when host refuses connections.")
												   forKey: NSLocalizedDescriptionKey];
			preciseError = [[NSError alloc] initWithDomain: NSCocoaErrorDomain code: kCFURLErrorCannotConnectToHost userInfo: userInfo];
			break;
			
		case kCFURLErrorNetworkConnectionLost:
			userInfo = [NSDictionary dictionaryWithObject: NSLocalizedString(@"Network connection has been lost.",
																			 @"Error message displayed when network connection is lost.")
												   forKey: NSLocalizedDescriptionKey];
			preciseError = [[NSError alloc] initWithDomain: NSCocoaErrorDomain code: kCFURLErrorNetworkConnectionLost userInfo: userInfo];
			break;
			
		case kCFURLErrorDNSLookupFailed:
			userInfo = [NSDictionary dictionaryWithObject: NSLocalizedString(@"DNS look-up has failed.",
																			 @"Error message displayed when the DNS look-up failed.")
												   forKey: NSLocalizedDescriptionKey];
			preciseError = [[NSError alloc] initWithDomain: NSCocoaErrorDomain code: kCFURLErrorDNSLookupFailed userInfo: userInfo];
			break;
			
		case kCFURLErrorHTTPTooManyRedirects:
			userInfo = [NSDictionary dictionaryWithObject: NSLocalizedString(@"Too many HTTP redirects.",
																			 @"Error message displayed when there are too many HTTP redirects.")
												   forKey: NSLocalizedDescriptionKey];
			preciseError = [[NSError alloc] initWithDomain: NSCocoaErrorDomain code: kCFURLErrorHTTPTooManyRedirects userInfo: userInfo];
			break;
			
		case kCFURLErrorResourceUnavailable:
			userInfo = [NSDictionary dictionaryWithObject: NSLocalizedString(@"Resource is unavailable.",
																			 @"Error message displayed when resource is unavailable.")
												   forKey: NSLocalizedDescriptionKey];
			preciseError = [[NSError alloc] initWithDomain: NSCocoaErrorDomain code: kCFURLErrorResourceUnavailable userInfo: userInfo];
			break;
			
		case kCFURLErrorNotConnectedToInternet:
			userInfo = [NSDictionary dictionaryWithObject: NSLocalizedString(@"Not connected to internet.",
																			 @"Error message displayed when not connected to the Internet.")
												   forKey: NSLocalizedDescriptionKey];
			preciseError = [[NSError alloc] initWithDomain: NSCocoaErrorDomain code: kCFURLErrorNotConnectedToInternet userInfo: userInfo];
			break;
			
		case kCFURLErrorRedirectToNonExistentLocation:
			userInfo = [NSDictionary dictionaryWithObject: NSLocalizedString(@"Redirected to an invaild location",
																			 @"Error message displayed when redirected to a non-exsistant location.")
												   forKey: NSLocalizedDescriptionKey];
			preciseError = [[NSError alloc] initWithDomain: NSCocoaErrorDomain code: kCFURLErrorRedirectToNonExistentLocation userInfo: userInfo];
			break;
			
		case kCFURLErrorBadServerResponse:
			userInfo = [NSDictionary dictionaryWithObject: NSLocalizedString(@"Server returned a bad response.",
																			 @"Error message displayed when a bad response is received from the server.")
												   forKey: NSLocalizedDescriptionKey];
			preciseError = [[NSError alloc] initWithDomain: NSCocoaErrorDomain code: kCFURLErrorBadServerResponse userInfo: userInfo];
			break;
			
			// otherwise handle the error generically
		default:
			[self handleError: error];
			return;
	}
		
	[self handleError: preciseError];
	
	SAFE_RELEASE(preciseError);
	
	userInfo = nil;
	
	[self notifyCaller];

}

- (void) connectionDidFinishLoading: (NSURLConnection *) connection {
	SAFE_RELEASE(_request);
	
	didCompleteRequestSuccessfully = YES;
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
	
	[self notifyCaller];
}
@end
