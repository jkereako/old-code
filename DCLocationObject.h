//
//  DCLocationObject.h
//  DeliOrder
//
//  Created by Jeffrey Kereakoglow on 5/6/10.
//  Copyright 2010 Droste Consultants, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "DCProtocol.h"
#import "DCMacro.h"

@interface DCLocationObject : NSObject <MKAnnotation> {
@private
	NSDictionary *_address;
	NSDictionary *_detail;
	CLLocationDistance _distance;
	CLLocation *_location;
	
	
	//MKAnnotation Protocol
	//required
	CLLocationCoordinate2D _coordinate;
	//optional
	NSString *_title;
	NSString *_subtitle;
	
	/*
	 address =         {
	 City = Danvers;
	 Country = "United States of America";
	 CountryCode = US;
	 State = MA;
	 Street = "73 Holten";
	 ZIP = 01234;
	 };
	 detail = <null>;
	 distance = 4323306.692313679;
	 location = <+42.56130000, -70.94770000> +/- 0.00m (speed -1.00 mps / course -1.00) @ 2010-05-06 09:56:31 -0400;
	 */
}

@property (nonatomic, retain, getter=address, setter=setAddress) NSDictionary *_address;
@property (nonatomic, retain, getter=detail, setter=setDetail) NSDictionary *_detail;
@property (assign, getter=distance, setter=setDistance) CLLocationDistance _distance;
@property (nonatomic, retain, getter=location, setter=setLocation) CLLocation *_location;

//MKAnnotation Protocol
//required
@property (nonatomic, getter=coordinate, setter=setCoordinate) CLLocationCoordinate2D _coordinate;
//optional
@property (nonatomic, retain, getter=title, setter=setTitle) NSString *_title;
@property (nonatomic, retain, getter=subtitle, setter=setSubtitle) NSString *_subtitle;

@end
