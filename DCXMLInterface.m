//
//  XMLDatasourceInterface.m
//  DeliOrder
//
//  Created by Jeffrey Kereakoglow on 11/16/09.
//  Copyright 2009 Droste Consultants, Inc.. All rights reserved.
//


#import "DCXMLInterface.h"
#import "DCHTTPRequest.h"
#import "DCSQLite.h"

@implementation DCXMLInterface
@synthesize _urlString, _tableName, _sqlStatements, _error;

//SYNTHESIZE_SINGLETON_FOR_CLASS(DCXMLObjectInterface);


#pragma mark Constructors and Destructors

- (id) init {
	self = [super init];
	
	if (!self)
		return nil;
	
	//DEBUG_LOG(@"Initializing DCXMLObjectInterface...");
	
	_urlString = nil;
	_request = nil;
	_xmlData = nil;
	_parsedCharacters = nil;
	_parsedStrings = nil;
	_parsedElementNames = nil;
	_lastParsedElementNamesCount = 0;
	_tableFieldNames = nil;
	_createTableStatement = nil;
	_tableName = nil;
	_sqlStatements = nil;
	_didFinishParsing = NO;
	
	return self;
}


- (void) dealloc {
	//DEBUG_LOG(@"Deallocating DCXMLObjectInterface...");
	
	if(_urlString)
		SAFE_RELEASE(_urlString);
	
	SAFE_RELEASE(_request);
	SAFE_RELEASE(_xmlData);
	SAFE_RELEASE(_tableFieldNames);
	SAFE_RELEASE(_createTableStatement);
	SAFE_RELEASE(_tableName);
	SAFE_RELEASE(_parsedStrings);
	SAFE_RELEASE(_sqlStatements);
	
	[super dealloc];
}

#pragma mark DCStandard 
- (void) handleError: (NSError *) error {
	
	SAFE_RELEASE(_error);
	
	_error = [error copy];
	
	NSLog([error description]);
}


#pragma mark Private Methods
- (void) parseDataInMainThread: (NSData *) data {
	NSXMLParser *parser = nil;

	parser = [[NSXMLParser alloc] initWithData: data];
	
	[parser setDelegate:self];
    [parser parse];
	
	SAFE_RELEASE(_xmlData);
	
	_didFinishParsing = YES;
	
	/************************************/
	
	//This causes all sorts of weird stuff as noted here: http://www.fatcatsoftware.com/blog/2010/04
	
	//DEBUG_LOG([_xmlTree description]);
	/************************************/
	SAFE_RELEASE(parser);
	SAFE_RELEASE(_request);

}

#pragma mark Private Methods
- (void) parseDataInNewThread: (NSData *) data {
	NSXMLParser *parser = nil;
	NSAutoreleasePool *pool = nil;
	
	pool = [[NSAutoreleasePool alloc] init];	
	parser = [[NSXMLParser alloc] initWithData: data];

	
	[parser setDelegate:self];
    [parser parse];
	
	SAFE_RELEASE(_xmlData);
	
	_didFinishParsing = YES;
	
	/************************************/
	
	//This causes all sorts of weird stuff as noted here: http://www.fatcatsoftware.com/blog/2010/04
	
	//DEBUG_LOG([_xmlTree description]);
	/************************************/
	
	SAFE_AUTORELEASE(pool);	
	SAFE_RELEASE(parser);
	SAFE_RELEASE(_request);
	
}


- (void) parseSynchronously {
	if([_xmlData length]) {
		[self parseDataInMainThread: _xmlData];
		return;
	}
	
	SAFE_RELEASE(_xmlData);
	
	if([_request isKindOfClass: [DCHTTPRequest class]])
		SAFE_RELEASE(_request);
	
		
	_request = [[DCHTTPRequest alloc] initWithURLString: _urlString];
	
	[_request setTimeoutInterval: 4.0];
	
	[_request sendSynchronousRequest];
	
	_xmlData = [[NSData alloc] initWithData: [_request dataResponse]];
	
		
	[self parseDataInMainThread: _xmlData];
}

- (void) parseAsynchronously {
	if([_xmlData length]) {
		[NSThread detachNewThreadSelector: @selector(parseDataInNewThread:) toTarget: self withObject: _xmlData];
		return;
	}
	
	SAFE_RELEASE(_xmlData);
	
	if(_request)
		SAFE_RELEASE(_request);
	
	_request = [[DCHTTPRequest alloc] initWithURLString: _urlString];
	
	[_request setTimeoutInterval: 4.0];
	
	[_request sendSynchronousRequest];
		
	if(![[_request dataResponse] length])
		return;
	
	_xmlData = [[NSData alloc] initWithData: [_request dataResponse]];

///	//DEBUG_LOG(@"Creating new thread for to parse XML...");
	
	[self parseDataInNewThread: _xmlData];

}

- (void) refreshAsynchronously {
	NSAssert([_urlString isKindOfClass: [NSString class]], @"Property \"_urlString\" is nil or invalid.");
	
	SAFE_RELEASE(_request);
	SAFE_RELEASE(_parsedCharacters);
	SAFE_RELEASE(_xmlData);
	
	[self parseAsynchronously];
}

- (void) refreshSynchronously {
	NSAssert([_urlString isKindOfClass: [NSString class]], @"Property \"_urlString\" is nil or invalid.");
	
	SAFE_RELEASE(_request);
	SAFE_RELEASE(_parsedCharacters);
	SAFE_RELEASE(_xmlData);
	
	[self parseSynchronously];
}

- (void) sanatizeSQL {
	[_parsedCharacters setString: [_parsedCharacters stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]]];
	[_parsedCharacters setString: [_parsedCharacters stringByReplacingOccurrencesOfString: @"'" withString: @"''"]];
}

- (BOOL) executeSQL {
	NSUInteger i = 0;
	NSUInteger limit = 0;
	
	if(_createTableStatement){
		//NSLog(_createTableStatement);

		[[DCSQLite sharedDCSQLite] setSQL: (NSMutableString *) _createTableStatement];
		[[DCSQLite sharedDCSQLite] executeSQL];
	}
	
	//NSLog([_sqlStatements description]);
	
	limit = [_sqlStatements count];
	
	for (i = 0; i != limit; ++ i) {

		[[DCSQLite sharedDCSQLite] setSQL: [_sqlStatements objectAtIndex:i]];
		[[DCSQLite sharedDCSQLite] executeSQL];
	}

	return YES;
}

#pragma mark NSXMLParser
//DTD data
- (void) parser: (NSXMLParser *) parser foundElementDeclarationWithName: (NSString *) elementName model: (NSString *) model {
	;
}
- (void) parser: (NSXMLParser *) parser foundAttributeDeclarationWithName: (NSString *) attributeName forElement: (NSString *) elementName type: (NSString *) type defaultValue: (NSString *) defaultValue {
	;
}

- (void) parserDidStartDocument: (NSXMLParser *) parser {
	_tableFieldNames = [[NSMutableSet alloc] init];
	_sqlStatements = [[NSMutableArray alloc] init];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	NSArray *fieldNames = nil;
	
	fieldNames = [_tableFieldNames sortedArrayUsingDescriptors: nil];
	
	SAFE_RELEASE(_tableFieldNames);
	
	_createTableStatement = [[NSString alloc] initWithFormat: @"CREATE TABLE IF NOT EXISTS [%@] (\n[id] INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL  UNIQUE, \n%@ VARCHAR, \n[date_created] DATETIME DEFAULT CURRENT_TIMESTAMP, \n[date_modified] DATETIME DEFAULT CURRENT_TIMESTAMP)", _tableName, [fieldNames componentsJoinedByString: @" VARCHAR, \n"]];
	
	[self executeSQL];
}

- (void) parser: (NSXMLParser *) parser didStartElement: (NSString *) elementName namespaceURI: (NSString *) namespaceURI qualifiedName: (NSString *) qName attributes: (NSDictionary *) attributeDict {
	if([elementName isEqualToString: @"Record"]) {
		_parsedElementNames = [[NSMutableArray alloc] init];
		_parsedCharacters = [[NSMutableString alloc] init];
		_parsedStrings = [[NSMutableArray alloc] init];
	}
	
	else
		[_parsedElementNames addObject: [NSString stringWithFormat: @"[%@]", [elementName lowercaseString]]];
			
}


- (void ) parser: (NSXMLParser *) parser didEndElement: (NSString *) elementName namespaceURI: (NSString *) namespaceURI qualifiedName: (NSString *) qName {
	
	if([elementName isEqualToString: @"Record"]) {
		NSUInteger i = 0;
		NSMutableArray *whereClauseArray = nil;
		NSString *whereClause = nil;
		NSString *sql = nil;
		DCSQLite *dbInterface = nil;
		BOOL recordExists = NO;
	
		whereClauseArray = [[NSMutableArray alloc] initWithCapacity: [_parsedElementNames count]];
		dbInterface = [DCSQLite sharedDCSQLite];
		
		//Creates a well-formed WHERE clause checking if this particular record
		//already exists
		for (i = 0; i != [_parsedStrings count];  ++ i) {
			NSArray *tempArray = [[NSArray alloc] initWithObjects: [_parsedStrings objectAtIndex: i], [_parsedElementNames objectAtIndex:i], nil];
			
			[whereClauseArray addObject: [tempArray componentsJoinedByString: @" = "]];
			
			SAFE_RELEASE(tempArray);
		}
		
		whereClause = [[NSString alloc] initWithString: [whereClauseArray componentsJoinedByString: @" AND "]];
		
		SAFE_RELEASE(whereClauseArray);
		
		//NSLog(whereClause);
		
		sql = [[NSString alloc] initWithFormat: @"INSERT INTO [%@] \n(%@) \nVALUES(%@)",
			   _tableName,
			   [_parsedElementNames componentsJoinedByString: @", "],
			   [_parsedStrings componentsJoinedByString: @", "]];
		
		//Adds the element names to an NSMutableSet that way we can be certain
		//we have accounted for every field in the entire XML document
		[_tableFieldNames addObjectsFromArray: _parsedElementNames];
		
		recordExists = [[dbInterface numberForSQLQuery: @"COUNT(*)" fromTable: _tableName where: whereClause] boolValue];
		
		if(!recordExists)
			[_sqlStatements addObject: sql];
		
		SAFE_RELEASE(_parsedElementNames);
		SAFE_RELEASE(_parsedStrings);
		SAFE_RELEASE(whereClause);
		SAFE_RELEASE(sql);
	}
	
	else {
		[self sanatizeSQL];
		
		[_parsedStrings addObject:[NSString stringWithFormat:@"'%@'", _parsedCharacters]];
	}

	SAFE_RELEASE(_parsedCharacters);	
}

- (void) parser: (NSXMLParser *) parser foundCDATA: (NSData *) CDATABlock {
	;
}

- (void) parser: (NSXMLParser *) parser foundIgnorableWhitespace: (NSString *) whitespaceString {
	if(![_parsedCharacters isKindOfClass: [NSMutableString class]])
		_parsedCharacters = [[NSMutableString alloc] init];
	
	[_parsedCharacters appendString: whitespaceString];
}

- (void) parser: (NSXMLParser *) parser foundCharacters: (NSString *) string {
	if(![_parsedCharacters isKindOfClass: [NSMutableString class]])
		_parsedCharacters = [[NSMutableString alloc] init];
	
	[_parsedCharacters appendString: string];
}

- (void) parser: (NSXMLParser *) parser parseErrorOccurred: (NSError *) parseError {
	[self handleError: parseError];
}

@end
