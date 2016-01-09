//
//  DCXMLTreeNode.m
//  DeliOrder
//
//  Created by Jeffrey Kereakoglow on 2/11/10.
//  Copyright 2010 Droste Consultants, Inc.. All rights reserved.
//

#import "DCXMLTreeNode.h"

@implementation DCXMLTreeNode
@synthesize _hasChild, _parentNode, _childDictionary, _elementName, _parsedCharacters, _attributes;

+ (id) nodeWithName: (NSString *) elementName attributes: (NSDictionary *) attributes parent: (DCXMLTreeNode *) parent children: (NSDictionary *) children parser: (NSXMLParser *) parser {
	return [[[[self class] alloc] initWithName: elementName attributes: attributes parent: parent children: children parser: parser] autorelease];
	
}

- (id) initWithName: (NSString *) elementName attributes:(NSDictionary *) attributes parent: (DCXMLTreeNode *) parent children: (NSDictionary *) children parser: (NSXMLParser *) parser {
    self = [super init];
	
    if (!self) 
		return nil;
	
	//DEBUG_LOG(@"Initializing DCXMLTreeNode...");
	
	_elementName = nil;
	_parsedCharacters = nil;
	_attributes = nil;
	
	_childDictionary = nil;
	_parentNode = nil;
	_hasChild = NO;
    _elementName = [[NSString alloc] initWithString: elementName];
	
    if ([attributes isKindOfClass: [NSDictionary class]])
		_attributes = [[NSDictionary alloc] initWithDictionary: attributes];
	
    if ([children isKindOfClass: [NSDictionary class]])
		_childDictionary = [[NSMutableDictionary alloc] initWithDictionary: children];
	
	_parentNode = parent;
	
    [parser setDelegate:self];
	
    return self;
}

- (void) dealloc {
	//DEBUG_LOG(@"Deallocating DCXMLTreeNode...");
	
	SAFE_RELEASE(_elementName);
	SAFE_RELEASE(_attributes);
	SAFE_RELEASE(_parsedCharacters);
	
	[self destroyChildNodes];
	
	_childDictionary = nil;
	//SAFE_RELEASE(_childDictionary);
	
	_parentNode = nil;
	
	[super dealloc];
}

- (void) destroyChildNodes {
	NSAutoreleasePool *pool = nil;
	pool = [[NSAutoreleasePool alloc] init];
	
	if(_hasChild) {
		NSEnumerator *iterator = nil;
		NSString *key = nil;
		NSUInteger i = 0;
		
		iterator = [_childDictionary keyEnumerator];
		
		//Iterate through the child dictionary, sending each object a release
		//message to force deallocation.
		while (key = [iterator nextObject]) {
			for (i = 0; i != [[_childDictionary objectForKey: key] count]; ++ i) {
				//Must set loop this way because if retainCount = 0, then when we
				//do a check in the beginning of the while loop, we'll get an error
				//for sending a message to a released object
				while ([[[_childDictionary objectForKey: key] objectAtIndex: i] retainCount] > 1)
					[[[_childDictionary objectForKey: key] objectAtIndex: i] release];
				
				[[[_childDictionary objectForKey: key] objectAtIndex: i] autorelease];
				 
				 
				 }
			}
	}
				 
	
	/*
	if(_hasChild) {
		NSEnumerator *iterator = nil;
		NSString *key = nil;
		NSUInteger i = 0;
		
		iterator = [_childDictionary keyEnumerator];
		
		//Iterate through the child dictionary, sending each object a release
		//message to force deallocation.
		while (key = [iterator nextObject]) {
			//[[_childDictionary objectForKey: key] autorelease];
			
			for (i = 0; i != [[_childDictionary objectForKey: key] count]; ++ i)
					[[[_childDictionary objectForKey: key] objectAtIndex: i] release];
			
			}
		}
				 
	
	
	*/
	
	SAFE_AUTORELEASE(pool);
	/*
	if(_hasChild) {
		NSEnumerator *iterator = nil;
		NSString *key = nil;
		NSUInteger i = 0;
		
		iterator = [_childDictionary keyEnumerator];
		
		//Iterate through the child dictionary, sending each object a release
		//message to force deallocation.
		while (key = [iterator nextObject]) {
			for (i = 0; i != [[_childDictionary objectForKey: key] count]; ++ i) {
				//Must set loop this way because if retainCount = 0, then when we
				//do a check in the beginning of the while loop, we'll get an error
				//for sending a message to a released object
				while ([[[_childDictionary objectForKey: key] objectAtIndex: i] retainCount] > 1)
					[[[_childDictionary objectForKey: key] objectAtIndex: i] release];
				
				/*[[[_childDictionary objectForKey: key] objectAtIndex: i] release];
				

			}
		}
	}
	*/
}


#pragma mark DCStandard
- (void) handleError: (NSError *) error {
    NSString *title = nil;
	NSString *message = nil;
	UIAlertView *alert = nil;
	
	title = [[NSString alloc] initWithString: NSLocalizedString(@"Parsing Error", @"General title for NSXMLParser errors.")];
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

//TODO: Remove unecessary newlines and indent for multiple levels.
- (NSString*) description {
	NSMutableString* objectDescription = nil;
	NSArray* arrayOfChildren = nil;
	NSEnumerator *childIterator = nil;
	NSString *childName = nil;
	NSEnumerator *nodeIterator = nil;
	DCXMLTreeNode *node = nil;
	NSAutoreleasePool *pool = nil;
	objectDescription = [[NSMutableString alloc] init];
	arrayOfChildren = [[[NSArray alloc] init] autorelease];
	
	//Begin element tag
	if(_elementName)
		[objectDescription appendFormat:@"<%@ ", _elementName];
	
	//Retrieve the attributes
	for (id key in _attributes)
		[objectDescription appendFormat:@"%@=\"%@\" ", key, [_attributes objectForKey: key]];
	
	//If children and text don't exist for this tag, terminate the tag
	if (![_childDictionary count] && ![_parsedCharacters length]) {
		[objectDescription appendString:@"/>\n"];
		
		return objectDescription;
	}
	
	//Else, close the opening tag
	if (_elementName) 
		[objectDescription appendString:@">\n"];
	
	
	//Display the data enclosed by the tags
	if ([_parsedCharacters length]) 
		[objectDescription appendFormat: @"%@\n", _parsedCharacters];
	
	
	//Retrive children
	childIterator = [_childDictionary keyEnumerator];
	
	while (childName = [childIterator nextObject]) {
		arrayOfChildren = [_childDictionary objectForKey: childName];
		
		nodeIterator = [arrayOfChildren objectEnumerator];
		
		while (node = [nodeIterator nextObject])
			[objectDescription appendFormat:@"%@", [node description]];
		
	}
	
	childIterator = nil;
	nodeIterator = nil;
	childName = nil;
	node = nil;
	
	// stick on the end element
	if(_elementName)
		[objectDescription appendFormat:@"</%@>\n", _elementName];
	
	SAFE_AUTORELEASE(pool);
		
	return [objectDescription autorelease];
	
}



- (void) setChildren: (NSDictionary *) children {
	if(!_childDictionary)
		_childDictionary = [[NSMutableDictionary alloc] init];

	[_childDictionary setDictionary: children];
}

#pragma mark Getters
- (DCXMLTreeNode*) nodeForKey: (NSString*) key {
	NSParameterAssert([key isKindOfClass: [NSString class]]);
	NSParameterAssert([self isKindOfClass: [DCXMLTreeNode class]]);
	
	if(!_childDictionary)
		return nil;

	NSArray* tokens = nil;
	NSString* subString = nil;
	DCXMLTreeNode* node = nil;
	NSInteger index = 0;
	NSRange position = NSMakeRange(0, 0);
	NSAutoreleasePool *pool = nil;
	//BOOL tokenIsANumericIndex = YES;
	
	//Check if token has hierarchy denoted by "/"
	tokens = [key componentsSeparatedByString: @"/"];
	node = [[self retain] autorelease];
	
	for (NSString* token in tokens) {
		index = 0;
		
		//Check if token indicates index with "[n]"
		position = [token rangeOfString:@"["];
		
		if(position.location != NSNotFound) {
			// now pull the substring out
			subString = [token substringWithRange: NSMakeRange(position.location + 1, [token length] - position.location - 2)];
			
			//if([subString rangeOfCharacterFromSet: [NSCharacterSet letterCharacterSet]].location != NSNotFound)
			//	tokenIsANumericIndex = NO;
			
			// get the new position
			
			//if(tokenIsANumericIndex)
				index = [subString integerValue];
			// take out the index from the token
			token = [token substringToIndex: position.location];
		}
		
		//if(tokenIsANumericIndex)
		
		@try {
			node = [node nodeForKey: token atIndex: index];
		}
		@catch (NSException * e) {
			node = nil;
		}
		@finally {
			;
		}
		//else
		//	node = [node nodeForKey: token containingValue: subString];

	}
	
	SAFE_AUTORELEASE(pool);
	tokens = nil;
	subString = nil;
	
	return node;
}

- (DCXMLTreeNode*) nodeForKey: (NSString*) key atIndex: (NSInteger) index {
	NSArray* children = nil;
	DCXMLTreeNode *node = nil;
	
	children = [self childrenForKey: key];
	
	if(!children)
		return nil;
	
	@try {
		node = [children objectAtIndex: index];
	}
	@catch (NSException * e) {
		node = nil;
	}
	@finally {
		;
	}
	
	return node;
	
}
/*
- (DCXMLTreeNode*) nodeForKey: (NSString*) key containingValue: (NSString *) value  {
	NSArray* children = nil;
	
	children = [self childrenForKey: key];
	
	if(!children)
		return nil;
	
	return ([[[children objectAtIndex: 0] elementContent] isEqualToString: value]) ? [children objectAtIndex: 0] : nil;
	
}
*/
- (NSArray *) childrenForKey: (NSString*) key {
	NSParameterAssert([key isKindOfClass: [NSString class]]);
	NSAssert([_childDictionary isKindOfClass: [NSDictionary class]], @"The property _childDictionary has become invalid.");
	
	if(!_childDictionary)
		return nil;
	
	NSArray *children = nil;
		
	@try {
		NSAssert([[_childDictionary objectForKey: key] isKindOfClass: [NSArray class]], @"The local variable children, has become invalid.");
		
		//NSLog([_childDictionary description]);
		
		children = [[[NSArray alloc] initWithArray: [_childDictionary objectForKey: key]] autorelease];
		

	}
	@catch (NSException * e) {
		children = nil;
	}
	@finally {
		;
	}

	return children;
}

- (NSDictionary*) attributesOfNodeForKey: (NSString*) key {
	if(!_attributes)
		return nil;
	
	return [[self nodeForKey: key] attributes];
}

//Will return the count for a given element name
- (NSUInteger) countForElementName: (NSString *) anElementName {
	NSArray* arrayOfChildren = nil;
	NSEnumerator *childIterator = nil;
	NSString *childName = nil;
	NSEnumerator *nodeIterator = nil;
	DCXMLTreeNode *node = nil;
	NSUInteger count = 0;
	NSAutoreleasePool *pool = nil;
	
	pool = [[NSAutoreleasePool alloc] init];
	
	arrayOfChildren = [[[NSArray alloc] init] autorelease];
	
	//Retrive children
	childIterator = [_childDictionary keyEnumerator];
	
	while (childName = [childIterator nextObject]) {
		arrayOfChildren = [_childDictionary objectForKey: childName];
		nodeIterator = [arrayOfChildren objectEnumerator];
		
		while (node = [nodeIterator nextObject]) {
			if([anElementName isEqualToString: [node elementName]])
				++ count;
			
			else if([node hasChild])
				count += [node countForElementName: anElementName];
			

		}
	}
	
	
	childIterator = nil;
	nodeIterator = nil;
	childName = nil;
	node = nil;
	
	SAFE_AUTORELEASE(pool);
	
	return count;
}

// Compiles CSV string of the content for a given element
- (NSString *) csvStringOfContentForElementName: (NSString *) anElementName wrapInQuotes: (BOOL) yesOrNo {
	return [self csvStringOfContentForElementName: anElementName
									 wrapInQuotes: yesOrNo
										csvString: @""];
}

- (NSString *) csvStringOfContentForElementName: (NSString *) anElementName wrapInQuotes: (BOOL) yesOrNo csvString:(NSString *) csvString {
	NSArray* arrayOfChildren = nil;
	NSEnumerator *childIterator = nil;
	NSString *childName = nil;
	NSEnumerator *nodeIterator = nil;
	DCXMLTreeNode *node = nil;
	NSMutableString *elementContent = nil;
	NSAutoreleasePool *pool = nil;
	
	pool = [[NSAutoreleasePool alloc] init];
	
	if(!csvString)
		csvString = @"";
	
	arrayOfChildren = [[[NSArray alloc] init] autorelease];
	elementContent = [[NSMutableString alloc] initWithString: @""];
	
	//Retrive children
	childIterator = [_childDictionary keyEnumerator];
	
	while (childName = [childIterator nextObject]) {
		arrayOfChildren = [_childDictionary objectForKey: childName];
		nodeIterator = [arrayOfChildren objectEnumerator];
		
		while (node = [nodeIterator nextObject]) {
			if([anElementName isEqualToString: [node elementName]]) {
				if([csvString rangeOfString: [node elementContent]].location == NSNotFound)
					if(yesOrNo)
						[elementContent appendFormat: @"\"%@\", ", [node elementContent]];
					else
						[elementContent appendFormat: @"%@, ", [node elementContent]];

			}
			
			else if([node hasChild])
				if(yesOrNo)
					[elementContent appendFormat: @"\"%@\", ", [node csvStringOfContentForElementName: anElementName
																						 wrapInQuotes: yesOrNo
																							csvString: (NSString *)elementContent]];
				else
					[elementContent appendFormat: @"%@, ", [node csvStringOfContentForElementName: anElementName
																					 wrapInQuotes: yesOrNo
																						csvString: (NSString *)elementContent]];


			
		}
	}
	
	
	childIterator = nil;
	nodeIterator = nil;
	childName = nil;
	node = nil;
	
	SAFE_AUTORELEASE(pool);
	
	return [elementContent autorelease];
}


#pragma mark NSXMLParser Delegate Functions
- (void) parser: (NSXMLParser *) parser didStartElement: (NSString *) elementName namespaceURI: (NSString *) namespaceURI qualifiedName: (NSString *) qName attributes: (NSDictionary *) attributeDict {
	DCXMLTreeNode *node = nil;
	
	node = [[DCXMLTreeNode alloc] initWithName: elementName attributes: attributeDict parent: self children: nil parser: parser];
	
	_hasChild = YES;
	
	[self addChild: node forKey: elementName];
}

- (void ) parser: (NSXMLParser *) parser didEndElement: (NSString *) elementName namespaceURI: (NSString *) namespaceURI qualifiedName: (NSString *) qName {
    DCXMLTreeNode *parent = nil;

	parent = _parentNode;
	
	//[_parsedCharacters setString: [_parsedCharacters stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]]];
		
	//Reset delegate to parent
    [parser setDelegate: parent];
	
	parent = nil;
	
}

- (void) parserDidEndDocument: (NSXMLParser *) parser {
	NSLog(@"Finished parsing XML...");
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

#pragma mark Private Methods
- (void) addChild: (DCXMLTreeNode *) child forKey: (NSString *) key{
	NSParameterAssert([child isKindOfClass: [DCXMLTreeNode class]]);
	NSParameterAssert([key isKindOfClass: [NSString class]]);
	
	NSAutoreleasePool *pool = nil;
	
	pool = [[NSAutoreleasePool alloc] init];
	
	if(![_childDictionary isKindOfClass: [NSMutableDictionary class]])
		_childDictionary = [[NSMutableDictionary alloc] init];
	
	NSMutableArray *childList = nil;
	
	//Check if children with this element name exist
	childList = [[[child parentNode] childDictionary] objectForKey: key];
	
	//If not, create a new array of children with this element name
	if(!childList) {
		//DO NOT RELEASE OR CREATE AN AUTORELEASED OBJECT!!
		childList = [[[NSMutableArray alloc] init] autorelease];

		[[[child parentNode] childDictionary] setObject: childList forKey: key];
	}
	
	//Append the child
	//NOTE: According to Apple's documentation, the parent should retain the child.
	[childList addObject: [child retain]];
	
	SAFE_AUTORELEASE(pool);
	
	//	childList = nil;
	
}

@end
