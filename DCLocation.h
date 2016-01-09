//
//  LocationInterface.h
//  DeliOrder
//
//  Created by Jeffrey Kereakoglow on 2/4/10.
//  Copyright 2010 Droste Consultants, Inc.. All rights reserved.
//
//	Description: Singleton class that handles user's location, distance calcuations,
//	and reverse geocoding.
//
//	Required: MapKit and AddressBook frameworks
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <AddressBook/AddressBook.h>
#import "DCProtocol.h"
#import "DCMacro.h"

//Constants: keys for the _storedLocations dictionary
/*
extern const NSString *kLocationKey = @"location";		//CLLocation
extern const NSString *kAddressKey = @"address";		//ABAddressDictionary
extern const NSString *kDetailKey = @"detail";			//User defined detail
extern const NSString *kDistanceKey = @"distance";		//Calculated distance from current position
*/
extern const NSString *kLocationKey;		//CLLocation
extern const NSString *kAddressKey;		//ABAddressDictionary
extern const NSString *kDetailKey;			//User defined detail
extern const NSString *kDistanceKey;		//Calculated distance from current position

@class CLLocationManager, CLLocation, DCLocationObject;
@interface DCLocation : NSObject <CLLocationManagerDelegate, MKReverseGeocoderDelegate> {
@private
	BOOL _notifyOnFirstLocationUpdatetOnly;
	BOOL _notifyOnAllLocationUpdates;
	BOOL _forInternalUse;
	id _returnObject;
	SEL _returnSelector;
	CLLocationManager *_locationManager;
	NSDate *_locationManagerStartDate;
	NSMutableDictionary *_storedLocations;
	NSMutableArray *_locationMeasurements;
	NSArray *_sortedLocations;
	NSArray *_addressKeys;

@public
	CLLocation *currentLocation;
}

@property (nonatomic, retain, readonly) CLLocation *currentLocation;
@property (nonatomic, retain, readonly, getter=addressKeys) NSArray *_addressKeys;
@property (nonatomic, retain, readonly, getter=dictionaryForLocations) NSMutableDictionary *_storedLocations;
@property (nonatomic, retain, readonly, getter=sortedLocationArray) NSArray *_sortedLocations;



+ (DCLocation *) sharedDCLocation;
- (NSArray *) arrayForLocations;
- (NSUInteger) numberOfLocations;
- (void) setAccuracy: (CLLocationAccuracy) accuracy;
- (void) setDistanceFilter: (CLLocationDistance) distanceFilter;
- (void) setNotifySelector: (SEL) selector ofObject: (id) object;
- (void) alwaysNotify;
- (void) notifyOnce;

- (NSArray *) locationsByProximity;

- (BOOL) shouldForceUpdate;

- (BOOL) locationManager: (CLLocationManager *) manager hasValidLocation: (CLLocation *) newLocation oldLocation: (CLLocation *) oldLocation;

- (void) start;
- (void) stop;
- (BOOL) addressDictionaryIsValid: (NSDictionary *) addressDictionary;
- (void) addLookupLocation: (NSString *) identifier lattitude: (CLLocationDegrees) lattitude longitude: (CLLocationDegrees) longitude;
- (void) addLookupLocation: (NSString *) identifier lattitude: (CLLocationDegrees) lattitude longitude: (CLLocationDegrees) longitude mkAnnotationTitle: (NSString *) title mkAnnotationSubtitle: (NSString *) subtitle;
- (void) addLookupLocation: (NSString *) identifier lattitude: (CLLocationDegrees) lattitude longitude: (CLLocationDegrees) longitude addressInformation: (NSArray *) addressInformation detail: (NSDictionary *) detail;
- (void) addLookupLocation: (NSString *) identifier lattitude: (CLLocationDegrees) lattitude longitude: (CLLocationDegrees) longitude addressInformation: (NSArray *) addressInformation detail: (NSDictionary *) detail mkAnnotationTitle: (NSString *) title mkAnnotationSubtitle: (NSString *) subtitle;
- (DCLocationObject *) locationObjectForIdentifier: (NSString *) identifier;
- (void) calculateDistanceAndSort;
- (void) convertCoordinateToAddress: (CLLocationCoordinate2D) coordinate;

@end
