//
//  LocationInterface.m
//  DeliOrder
//
//  Created by Jeffrey Kereakoglow on 2/4/10.
//  Copyright 2010 Droste Consultants, Inc.. All rights reserved.
//

#import "DCLocation.h"
#import "DCLocationObject.h"

@implementation DCLocation
@synthesize currentLocation, _addressKeys, _sortedLocations, _storedLocations;

SYNTHESIZE_SINGLETON_FOR_CLASS(DCLocation)

const NSString *kLocationKey = @"location";		//CLLocation
const NSString *kAddressKey = @"address";		//ABAddressDictionary
const NSString *kDetailKey = @"detail";			//User defined detail
const NSString *kDistanceKey = @"distance";		//Calculated distance from current position

- (void) dealloc {
	DEBUG_LOG(@"Deallocating DCLocation...");
	SAFE_RELEASE(_locationManager);
	SAFE_RELEASE(_locationManagerStartDate);
	SAFE_RELEASE(_locationMeasurements);
	SAFE_RELEASE(_storedLocations);
	SAFE_RELEASE(currentLocation);
	
	_returnObject = nil;
	_returnSelector = nil;

	[super dealloc];
	
}

#pragma mark DCProtocol
- (void) handleError: (NSError *) error {
	NSString *title = nil;
	NSString *message = nil;
	UIAlertView *alert = nil;
	
	title = [[NSString alloc] initWithString: NSLocalizedString(@"Location Error", @"General title for CLLocation errors")];
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

- (void) notifyCaller {
	if([_returnObject respondsToSelector: _returnSelector])
		[_returnObject performSelector: _returnSelector];
}

- (void) notifyCallerWithObject: (id) object {
	if([_returnObject respondsToSelector: _returnSelector])
		[_returnObject performSelector: _returnSelector withObject: object];
}

#pragma mark Public methods
- (NSArray *) arrayForLocations {
	if(!_sortedLocations)
		return nil;
	
	NSEnumerator *iterator = nil;
	NSString *identifier = nil;
	NSMutableArray *arrayOfLocations = nil;
	
	iterator = [_sortedLocations objectEnumerator];
	arrayOfLocations = [[NSMutableArray alloc] initWithCapacity: [_sortedLocations count]];
	
	while (identifier = [iterator nextObject])
		[arrayOfLocations addObject: [_storedLocations objectForKey: identifier]];
	
	
	return [arrayOfLocations autorelease];
	
}

- (NSUInteger) numberOfLocations {
	if(!_sortedLocations)
		return 0;
	
	return [_sortedLocations count];
}

- (NSArray *) addressKeys { 
	if(_addressKeys)
		return _addressKeys;
	
	NSString *street = nil;
	NSString *city = nil;
	NSString *state = nil;
	NSString *zip = nil;
	NSString *country = nil;
	NSString *countryCode = nil;
	
	street = [[[NSString alloc] initWithString: (NSString *) kABPersonAddressStreetKey] autorelease];
	city = [[[NSString alloc] initWithString: (NSString *) kABPersonAddressCityKey] autorelease];
	state = [[[NSString alloc] initWithString: (NSString *) kABPersonAddressStateKey] autorelease];
	zip = [[[NSString alloc] initWithString: (NSString *) kABPersonAddressZIPKey] autorelease];
	country = [[[NSString alloc] initWithString: (NSString *) kABPersonAddressCountryKey] autorelease];
	countryCode = [[[NSString alloc] initWithString: (NSString *) kABPersonAddressCountryCodeKey] autorelease];
	
	_addressKeys = [[NSArray alloc] initWithObjects: 
				   street,
				   city,
				   state,
				   zip,
				   country,
				   countryCode,
				   nil];
	
	return _addressKeys;
}

- (void) setAccuracy: (CLLocationAccuracy) accuracy {
	if(!_locationManager)
		_locationManager = [[CLLocationManager alloc] init];
	
	[_locationManager setDesiredAccuracy: accuracy];
}

- (void) setDistanceFilter: (CLLocationDistance) distanceFilter {
	if(!_locationManager)
		_locationManager = [[CLLocationManager alloc] init];
	
	[_locationManager setDistanceFilter: distanceFilter];
}

- (void) setNotifySelector: (SEL) selector ofObject: (id) object {
	if(!_locationManager)
		_locationManager = [[CLLocationManager alloc] init];
	
	_returnSelector = selector;
	_returnObject = object;
}

- (void) alwaysNotify {
	if(!_locationManager)
		_locationManager = [[CLLocationManager alloc] init];
	
	_notifyOnAllLocationUpdates = YES;
	_notifyOnFirstLocationUpdatetOnly = NO;
}

- (void) notifyOnce {
	if(!_locationManager)
		_locationManager = [[CLLocationManager alloc] init];
	
	_notifyOnAllLocationUpdates = NO;
	_notifyOnFirstLocationUpdatetOnly = YES;
}

- (NSArray *) locationsByProximity {
	if(!_storedLocations || !_sortedLocations)
		return nil;
	
	return nil;
}

- (BOOL) shouldForceUpdate {
	CLLocation *location = nil;
	NSTimeInterval locationAge = 0.0;
	
	location = [_locationManager location];
	locationAge = -[[location timestamp] timeIntervalSinceNow];
	
	if(locationAge > 5.0)
		return YES;
	
	return NO;
}

- (void) start {
	DEBUG_LOG(@"Began updating current location...");
	/*
	if(![[NSUserDefaults standardUserDefaults] boolForKey:@"UseLocations"]) {
		[self stop];
		return;
	}
	*/
	if(_locationManager) {
		SAFE_RELEASE(_locationManager);
		
		_locationManager = [[CLLocationManager alloc] init];
	}
	
	if(![_locationManager locationServicesEnabled])
		return;
	
	if(![_locationManager distanceFilter])
		[_locationManager setDistanceFilter: 50.0];
	
	if(![_locationManager desiredAccuracy])
		[_locationManager setDesiredAccuracy: kCLLocationAccuracyHundredMeters];
	
	if(_locationManagerStartDate)
		SAFE_RELEASE(_locationManagerStartDate);
	
	_locationManagerStartDate = [[NSDate alloc] init];
	
	[_locationManager setDelegate: self];
	
	[_locationManager startUpdatingLocation];
	
}

- (void) stop {
	if([_locationManager isKindOfClass: [CLLocationManager class]])
		[_locationManager stopUpdatingLocation];
}

- (BOOL) addressDictionaryIsValid: (NSDictionary *) addressDictionary {
	/*
	 const ABPropertyID kABPersonAddressProperty;
	 const CFStringRef kABPersonAddressStreetKey;
	 const CFStringRef kABPersonAddressCityKey;
	 const CFStringRef kABPersonAddressStateKey;
	 const CFStringRef kABPersonAddressZIPKey;
	 const CFStringRef kABPersonAddressCountryKey;
	 const CFStringRef kABPersonAddressCountryCodeKey;
	 */
	if(!addressDictionary)
		return NO;
	
	NSArray *requiredFields;
	
	requiredFields = [[NSArray alloc] initWithObjects:
					  (NSString *) kABPersonAddressProperty,
					  (NSString *) kABPersonAddressStreetKey,
					  (NSString *) kABPersonAddressCityKey,
					  (NSString *) kABPersonAddressStateKey,
					  (NSString *) kABPersonAddressZIPKey, nil];

	
	if(![requiredFields isEqualToArray: [addressDictionary allKeys]])
		return NO;
	
	if ([[addressDictionary objectForKey: (NSString *) kABPersonAddressStateKey] length] != 2)
		return NO;
		
	/*
	if(![addressDictionary objectForKey: (NSString *) kABPersonAddressProperty])
		return NO;
	
	if(![addressDictionary objectForKey: (NSString *) kABPersonAddressStreetKey])
		return NO;
	
	if(![addressDictionary objectForKey: (NSString *) kABPersonAddressCityKey])
		return NO;
	
	if(![addressDictionary objectForKey: (NSString *) kABPersonAddressStateKey])
		return NO;
	
	if(![addressDictionary objectForKey: (NSString *) kABPersonAddressZIPKey])
		return NO;
	*/
	
	return YES;
}

- (void) addLookupLocation: (NSString *) identifier lattitude: (CLLocationDegrees) lattitude longitude: (CLLocationDegrees) longitude {
	[self addLookupLocation: identifier lattitude: lattitude longitude: longitude addressInformation: nil detail: nil ];
}

- (void) addLookupLocation: (NSString *) identifier lattitude: (CLLocationDegrees) lattitude longitude: (CLLocationDegrees) longitude mkAnnotationTitle: (NSString *) title mkAnnotationSubtitle: (NSString *) subtitle {
	[self addLookupLocation: identifier lattitude: lattitude longitude: longitude addressInformation: nil detail: nil mkAnnotationTitle: title mkAnnotationSubtitle: subtitle];
}

- (void) addLookupLocation: (NSString *) identifier lattitude: (CLLocationDegrees) lattitude longitude: (CLLocationDegrees) longitude addressInformation: (NSArray *) addressInformation detail: (NSDictionary *) detail {
	[self addLookupLocation: identifier lattitude: lattitude longitude: longitude addressInformation: addressInformation detail: detail mkAnnotationTitle: nil mkAnnotationSubtitle: nil];
}

- (void) addLookupLocation: (NSString *) identifier lattitude: (CLLocationDegrees) lattitude longitude: (CLLocationDegrees) longitude addressInformation: (NSArray *) addressInformation detail: (NSDictionary *) detail mkAnnotationTitle: (NSString *) title mkAnnotationSubtitle: (NSString *) subtitle {
	
	DCLocationObject *locationObject = nil;	
	CLLocationCoordinate2D coordinate;
	CLLocation *location = nil;
	//MKReverseGeocoder *reverseGeocoder;	
	NSDictionary *locationDictionary = nil;
	NSArray *objects = nil;
	NSArray *keys = nil;
	NSUInteger i = 0;
	NSString *value = nil;
	NSMutableDictionary *addressDictionary = nil;
	
	if(![_storedLocations isKindOfClass: [NSDictionary class]])
		_storedLocations = [[NSMutableDictionary alloc] init];
	
	if(!_addressKeys)
		[self addressKeys];
	
	_forInternalUse = YES;
	coordinate.latitude = lattitude;
	coordinate.longitude = longitude;
	
	addressDictionary = [[NSMutableDictionary alloc] initWithCapacity: [addressInformation count]];
	location = [[CLLocation alloc] initWithLatitude: lattitude longitude: longitude];
	//reverseGeocoder = [[MKReverseGeocoder alloc] initWithCoordinate: coordinate];
		
	for (i = 0; i != [_addressKeys count]; ++ i) {
		if(value = [addressInformation objectAtIndex: i])
			[addressDictionary setObject: value forKey:[_addressKeys objectAtIndex: i]];
	}
	/*
	if(![self addressDictionaryIsValid: addressDictionary])
		addressDictionary = [NSNull null];
	*/
	
	locationObject = [[[DCLocationObject alloc] init] autorelease];
	
	[locationObject setAddress: addressDictionary];
	[locationObject setDetail: detail];
	[locationObject setLocation: location];
	[locationObject setCoordinate: [location coordinate]];
	[locationObject setTitle: title];
	[locationObject setSubtitle: subtitle];
	
	//DEBUG_LOG([locationObject description]);
	
	[_storedLocations setObject: locationObject forKey: identifier];
	
	
	//[reverseGeocoder setDelegate: self];
	//[reverseGeocoder start];
	//[reverseGeocoder performSelectorOnMainThread: @selector(start) withObject: nil waitUntilDone: YES];
	
	SAFE_RELEASE(addressDictionary);
	SAFE_RELEASE(location);
	SAFE_RELEASE(objects);
	SAFE_RELEASE(keys);
	SAFE_RELEASE(locationDictionary);
}

- (DCLocationObject *) locationObjectForIdentifier: (NSString *) identifier {
	NSParameterAssert([identifier isKindOfClass: [NSString class]]);
	DCLocationObject *location = nil;
	
	if(!_storedLocations)
		return nil;
	
	location = [[[DCLocationObject alloc] init] autorelease];
	
	location = [_storedLocations objectForKey: identifier];

	return location;
}

//Calculates the distance between the current location and all of the stored locations
// creates an array of locations sorted from closest to furthest.
- (void) calculateDistanceAndSort {
	if(!_storedLocations)
		return;
	
	else if(!currentLocation)
		return;
	
	DCLocationObject *locationObject = nil;
	NSEnumerator *iterator = nil;
	NSString *key = nil;
	NSMutableDictionary *storedLocations = nil;
	NSMutableDictionary *keysToDistances = nil;
	CLLocation *location = nil;
	CLLocationDistance distance = 0.0;
	NSArray *sortedLocations = nil;
	//NSAutoreleasePool *pool = nil;

	//pool = [[NSAutoreleasePool alloc] init];
	
	storedLocations = [[_storedLocations mutableCopy] autorelease];
	iterator = [_storedLocations keyEnumerator];
	keysToDistances = [[NSMutableDictionary alloc] init];
	
	while (key = [iterator nextObject]) {
		locationObject = [_storedLocations objectForKey: key];
		
		location = [locationObject location];
		
		distance = [currentLocation distanceFromLocation: location];
		
		//Associate the identifier with the calculated distance
		[keysToDistances setObject: [NSNumber numberWithDouble: distance] forKey: key];

		[locationObject setDistance: distance];
	}
	
	//Sort the identifier keys based on the distances and return an array of ordered
	//identifiers
	sortedLocations = [keysToDistances keysSortedByValueUsingSelector: @selector(compare:)];
	
	SAFE_RELEASE(keysToDistances);
	
	if([_sortedLocations isKindOfClass: [NSArray class]])
		SAFE_RELEASE(_sortedLocations);
	
	_sortedLocations = [[NSArray alloc] initWithArray: sortedLocations];
	
	if([_storedLocations isKindOfClass: [NSMutableDictionary class]])
		SAFE_RELEASE(_storedLocations);
	
	_storedLocations = [storedLocations copy];
	
	//SAFE_AUTORELEASE(pool);
	
	//DEBUG_LOG([_sortedLocations description]);
	//DEBUG_LOG([_storedLocations description]);
	
}

- (void) convertCoordinateToAddress: (CLLocationCoordinate2D) coordinate {
	MKReverseGeocoder *reverseGeocoder = nil;
	_forInternalUse = NO;
	
	reverseGeocoder = [[MKReverseGeocoder alloc] initWithCoordinate: coordinate];
	[reverseGeocoder setDelegate: self];
	[reverseGeocoder start];
}

- (BOOL) locationManager: (CLLocationManager *) manager hasValidLocation: (CLLocation *) newLocation oldLocation: (CLLocation *) oldLocation {
    // Filter out nil locations
    if (!newLocation)
		return NO;
	
    // Filter out points by invalid accuracy
    if (newLocation.horizontalAccuracy < 0)
		return NO;
        
    // Filter out points that are out of order
    NSTimeInterval secondsSinceLastPoint =	[[newLocation timestamp] timeIntervalSinceDate: [oldLocation timestamp]];
    
    if (secondsSinceLastPoint < 0)
		return NO;
    
    // Filter out points created before the manager was initialized
    NSTimeInterval secondsSinceManagerStarted =	[[newLocation timestamp] timeIntervalSinceDate: _locationManagerStartDate];
    
    if (secondsSinceManagerStarted < 0)
		return NO;
	
	//Filter out cached measurements
    NSTimeInterval locationAge = -[[newLocation timestamp] timeIntervalSinceNow];
    
	if (locationAge > 5.0)
		return NO;
	
	//Filter out location if we haven't moved
	if([oldLocation coordinate].latitude == [newLocation coordinate].latitude 
	   && [oldLocation coordinate].longitude == [newLocation coordinate].longitude
	   && [oldLocation horizontalAccuracy] == [newLocation horizontalAccuracy])
		return NO;
        
    // The newLocation is good to use
    return YES;
} 

#pragma mark CLLocationManagerDelegate

/*
 *  locationManager:didUpdateToLocation:fromLocation:
 *  
 *  Discussion:
 *    Invoked when a new location is available. oldLocation may be nil if there is no previous location
 *    available.
 */
- (void) locationManager: (CLLocationManager *) manager didUpdateToLocation:(CLLocation *) newLocation fromLocation: (CLLocation *) oldLocation {
	
	//Force a new update should this fail.
	if(![self locationManager: manager hasValidLocation: newLocation oldLocation: oldLocation]) {
		[manager stopUpdatingLocation];
		[manager startUpdatingLocation];
		
		return;
	}
	   	
    // store all of the measurements, just so we can see what kind of data we might receive
	if(!_locationMeasurements)
		_locationMeasurements = [[NSMutableArray alloc] init];
	
    [_locationMeasurements addObject: newLocation];
	
	currentLocation = nil;
	currentLocation = newLocation;
	
	[self calculateDistanceAndSort];
	
	if(_notifyOnFirstLocationUpdatetOnly) {
		_notifyOnFirstLocationUpdatetOnly = NO;
		[self notifyCallerWithObject: currentLocation];
	}
	
	else if(_notifyOnAllLocationUpdates)
		[self notifyCallerWithObject: currentLocation];
}

/*
 *  locationManager:didUpdateHeading:
 *  
 *  Discussion:
 *    Invoked when a new heading is available.
 */
- (void) locationManager: (CLLocationManager *) manager didUpdateHeading: (CLHeading *) newHeading {
}

/*
 *  locationManager:shouldDisplayHeadingCalibrationForDuration:
 *
 *  Discussion:
 *    Invoked when a new heading is available. Return YES to display heading calibration info. The display 
 *    will remain until heading is calibrated, unless dismissed early via dismissHeadingCalibrationDisplay.
 */
- (BOOL) locationManagerShouldDisplayHeadingCalibration: (CLLocationManager *) manager {
	return NO;
}

/*
 *  locationManager:didFailWithError:
 *  
 *  Discussion:
 *    Invoked when an error has occurred. Error types are defined in "CLError.h".
 */
- (void) locationManager: (CLLocationManager *) manager didFailWithError: (NSError *) error {
	[self handleError: error];
}

#pragma mark -
#pragma mark MKReverseGeocoderDelegate
- (void) reverseGeocoder: (MKReverseGeocoder *) geocoder didFailWithError: (NSError *) error {
	SAFE_RELEASE(geocoder);
	
	[self handleError: error];
}

- (void) reverseGeocoder: (MKReverseGeocoder *) geocoder didFindPlacemark: (MKPlacemark *) placemark {
	NSEnumerator *iterator = nil;
	NSMutableDictionary *locationDictionary = nil;
	CLLocation *location = nil;
	
	iterator = [_storedLocations objectEnumerator];
	
	while (locationDictionary = [iterator nextObject]) {
		location = [locationDictionary objectForKey: kLocationKey];
		
		if([location coordinate].latitude == [geocoder coordinate].latitude && 
		   [location coordinate].longitude == [geocoder coordinate].longitude)
			[locationDictionary setObject: placemark forKey: kDetailKey];
	}
	
	SAFE_RELEASE(geocoder);
	
	if(_forInternalUse)
		return;
	
	else
		[self notifyCaller];
}

@end
