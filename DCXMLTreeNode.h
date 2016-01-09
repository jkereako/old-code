//
//  DCXMLTreeNode.h
//  DeliOrder
//
//  Created by Jeffrey Kereakoglow on 2/11/10.
//  Copyright 2010 Droste Consultants, Inc.. All rights reserved.
//
//	Description: Builds a tree of DCXMLTreeNode objects.
//
//	Coupled with an interface, this class will recursively instantiate itself
//	whenever an element is encountered. Since this is a recursive SAX parser, 
//	this is the fastest way to parse XML and is ideal for large sets of data.
//
//
// Idea from Apple and Osmorphis at http://osmorphis.blogspot.com/2009/03/enhancing-standard-nsxmlparser-class.html
//

#import <Foundation/Foundation.h>
#import "DCMacro.h"
#import "DCProtocol.h"

@interface DCXMLTreeNode : NSObject <DCProtocol, NSXMLParserDelegate> {
@private
	NSString *_elementName;					//Name of the element
	NSDictionary *_attributes;				//Attribute dictionary
	NSMutableString *_parsedCharacters;		//Accumulation of element content
	BOOL _hasChild;
	DCXMLTreeNode *_parentNode;				//1:1 relationship
	NSMutableDictionary *_childDictionary;	//1:m relationship
}

//Properties
@property (retain, readonly, getter=elementName) NSString *_elementName;
@property (retain, readonly, getter=attributes) NSDictionary *_attributes;
@property (retain, readonly, getter=elementContent) NSString *_parsedCharacters;
@property (assign, readonly, getter=hasChild) BOOL _hasChild;
@property (retain, readonly, getter=parentNode) DCXMLTreeNode *_parentNode;
@property (retain, readonly, getter=childDictionary) NSMutableDictionary *_childDictionary;

+ (id) nodeWithName: (NSString *) elementName attributes: (NSDictionary *) attributes parent: (DCXMLTreeNode *) parent children: (NSDictionary *) children parser: (NSXMLParser *) parser;
- (id) initWithName: (NSString *) elementName attributes:(NSDictionary *) attributes parent: (DCXMLTreeNode *) parent children: (NSDictionary *) children parser: (NSXMLParser *) parser;
- (void) destroyChildNodes;

- (void) addChild: (DCXMLTreeNode *) child forKey: (NSString *) key;
- (void) setChildren: (NSDictionary *) children;

- (DCXMLTreeNode *) nodeForKey: (NSString*) key;
- (DCXMLTreeNode *) nodeForKey: (NSString*) key atIndex: (NSInteger) key;
//- (DCXMLTreeNode*) nodeForKey: (NSString*) key containingValue: (NSString *) value;
- (NSArray *) childrenForKey: (NSString*) key;
- (NSDictionary *) attributesOfNodeForKey: (NSString*) key;
- (NSUInteger) countForElementName: (NSString *) anElementName;
- (NSString *) csvStringOfContentForElementName: (NSString *) anElementName wrapInQuotes: (BOOL) yesOrNo;
- (NSString *) csvStringOfContentForElementName: (NSString *) anElementName wrapInQuotes: (BOOL) yesOrNo csvString:(NSString *) csvString;
@end
