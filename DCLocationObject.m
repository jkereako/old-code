//
//  DCLocationObject.m
//  DeliOrder
//
//  Created by Jeffrey Kereakoglow on 5/6/10.
//  Copyright 2010 Droste Consultants, Inc.. All rights reserved.
//

#import "DCLocationObject.h"


@implementation DCLocationObject
@synthesize _address, _detail, _distance, _location, _coordinate, _title, _subtitle;

- (id) init {
	self = [super init];
	
	if (!self)
		return nil;
	
	_address = nil;
	_detail = nil;
	_distance = 0.0;
	_location = nil;
	_title = nil;
	_subtitle = nil;
	
	return self;
}

- (void) dealloc {	
	SAFE_RELEASE(_address);
	SAFE_RELEASE(_detail);
	SAFE_RELEASE(_location);
	SAFE_RELEASE(_title);
	SAFE_RELEASE(_subtitle);
	
	[super dealloc];
}

- (NSString *) description {
	NSString *description = nil;
	
	description = [NSString stringWithFormat: @"\n  %@ = %@\n  %@ = %@\n  %@ = %@\n  %@ = %@\n  %@ = %1.2f\n  %@ = %@\n %@ = %@\n", 
				   @"address", [_address description],
				   @"detail", [_detail description],
				   @"location", [_location description],
				   @"coordinate", @"I DON'T KNOW HOW TO DO THIS ONE",
				   @"distance", _distance,
				   @"title", _title ,
				   @"subtitle", _subtitle
	];
	
	return description;
}


@end
