//
//  XMLDatasourceInterface.h
//  DeliOrder
//
//  Created by Jeffrey Kereakoglow on 7/22/2010.
//  Copyright 2010 Droste Consultants, Inc.. All rights reserved.
//
//	Description: Converts linear, record-separated XML into SQLite database
//
//	The first iteration of this class was the receiver of both NSXMLParser
//	delegate messages and NSURLConnection delegate messages, but was later separated
//	to enhance performance and also because XML data may not come from the internet.
//

#import <Foundation/Foundation.h>
#import "DCProtocol.h"
#import "DCMacro.h"

@class DCHTTPRequest;
@interface DCXMLInterface : NSObject <DCProtocol, NSXMLParserDelegate> {
@private
	NSString *_urlString;
	DCHTTPRequest *_request;
	NSData *_xmlData;
	
	NSMutableSet *_tableFieldNames;
	NSString *_createTableStatement;
	NSString *_tableName;
	NSMutableArray *_sqlStatements;
	NSUInteger _lastParsedElementNamesCount;
	NSMutableArray *_parsedElementNames;
	NSMutableArray *_parsedStrings;
	NSMutableString *_parsedCharacters;
	
	NSError *_error;
	
	BOOL _didFinishParsing;
@public
	BOOL downloadAndParse;

}

@property (copy, getter=urlString, setter=setURLString) NSString* _urlString;
@property (copy, getter=tableName, setter=setTableName) NSString* _tableName;
@property (readonly, getter=sqlStatements) NSMutableArray* _sqlStatements;
@property (readonly, getter=lastError) NSError *_error;
- (void) parseDataInNewThread: (NSData *) data;
- (void) parseDataInMainThread: (NSData *) data;
- (void) parseAsynchronously;
- (void) parseSynchronously;
- (void) refreshAsynchronously;
- (void) refreshSynchronously;
- (void) sanatizeSQL;
- (BOOL) executeSQL;

@end
