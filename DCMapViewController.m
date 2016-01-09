//
//  DCMapViewController.m
//  DeliOrder
//
//  Created by Jeffrey Kereakoglow on 2/17/10.
//  Copyright 2010 Droste Consultants, Inc.. All rights reserved.
//

#import "DCMapViewController.h"

#define MERCATOR_OFFSET 268435456
#define MERCATOR_RADIUS 85445659.44705395
#import "DCLocation.h"

@implementation DCMapViewController
@synthesize dcMapView, navController;

- (id) init {
	self = [super init];
	
	if (!self)
		return nil;
	
	if(! dcMapView)
		dcMapView = [[MKMapView alloc] init];
	
	if(!navController)
		navController = [[UINavigationController alloc] initWithRootViewController: self];
	
	[[self dcMapView] setDelegate: self];
	
	return self;
}

- (void) awakeFromNib {
	[[self dcMapView] setDelegate: self];
	
	_awokeFromNib = YES;
}

- (void) dealloc {
	SAFE_RELEASE(dcMapView);
	
	[super dealloc];
}


#pragma mark -
#pragma mark DCProtocol
- (void) handleError: (NSError *) error {
    NSString *title;
	NSString *message;
	UIAlertView *alert;
	
	title = [[NSString alloc] initWithString: NSLocalizedString(@"Map Error", @"General title for MapViewController errors.")];
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

#pragma mark -
#pragma mark Coodinate to Pixel Conversions
- (CGFloat) longitudeToPixelSpaceX: (CGFloat) longitude {
    return round(MERCATOR_OFFSET + MERCATOR_RADIUS * longitude * M_PI / 180.0);
}

- (CGFloat) latitudeToPixelSpaceY: (CGFloat) latitude {
    return round(MERCATOR_OFFSET - MERCATOR_RADIUS * logf((1 + sinf(latitude * M_PI / 180.0)) / (1 - sinf(latitude * M_PI / 180.0))) / 2.0);
}

- (CGFloat) pixelSpaceXToLongitude: (CGFloat) pixelX {
    return ((round(pixelX) - MERCATOR_OFFSET) / MERCATOR_RADIUS) * 180.0 / M_PI;
}

- (CGFloat) pixelSpaceYToLatitude: (CGFloat) pixelY {
    return (M_PI / 2.0 - 2.0 * atan(exp((round(pixelY) - MERCATOR_OFFSET) / MERCATOR_RADIUS))) * 180.0 / M_PI;
}

#pragma mark -
#pragma mark Helper methods
- (MKCoordinateSpan) coordinateSpanWithMapView: (MKMapView *) aMapView centerCoordinate: (CLLocationCoordinate2D) centerCoordinate andZoomLevel: (NSUInteger) zoomLevel {
    // convert center coordiate to pixel space
    CGFloat centerPixelX = [self longitudeToPixelSpaceX:centerCoordinate.longitude];
    CGFloat centerPixelY = [self latitudeToPixelSpaceY:centerCoordinate.latitude];
    
    // determine the scale value from the zoom level
    NSInteger zoomExponent = 20 - zoomLevel;
    CGFloat zoomScale = pow(2, zoomExponent);
    
    // scale the map’s size in pixel space

    CGSize mapSizeInPixels = [aMapView bounds].size;
    CGFloat scaledMapWidth = mapSizeInPixels.width * zoomScale;
    CGFloat scaledMapHeight = mapSizeInPixels.height * zoomScale;
    
    // figure out the position of the top-left pixel
    CGFloat topLeftPixelX = centerPixelX - (scaledMapWidth / 2);
    CGFloat topLeftPixelY = centerPixelY - (scaledMapHeight / 2);
    
    // find delta between left and right longitudes
    CLLocationDegrees minLng = [self pixelSpaceXToLongitude:topLeftPixelX];
    CLLocationDegrees maxLng = [self pixelSpaceXToLongitude:topLeftPixelX + scaledMapWidth];
    CLLocationDegrees longitudeDelta = maxLng - minLng;
    
    // find delta between top and bottom latitudes
    CLLocationDegrees minLat = [self pixelSpaceYToLatitude:topLeftPixelY];
    CLLocationDegrees maxLat = [self pixelSpaceYToLatitude:topLeftPixelY + scaledMapHeight];
    CLLocationDegrees latitudeDelta = -1 * (maxLat - minLat);
    
    // create and return the lat/lng span
    MKCoordinateSpan span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta);
    return span;
} 

- (void) setCenterCoordinate: (CLLocationCoordinate2D) centerCoordinate withMapView: (MKMapView *) mapView atZoomLevel: (NSUInteger) zoomLevel animated: (BOOL) animated {
	MKCoordinateSpan span;
	MKCoordinateRegion region;
	
	//Limit the zoom level to 28.
    zoomLevel = MIN(zoomLevel, 28);
    
    //Use the zoom level to compute region
    span = [self coordinateSpanWithMapView: mapView centerCoordinate: centerCoordinate andZoomLevel: zoomLevel];
	
    region = MKCoordinateRegionMake(centerCoordinate, span);
    
    // set the region like normal
    [mapView setRegion: region animated: animated];
}



#pragma mark UIViewController
- (void) viewDidLoad {
}

- (void) viewWillAppear:(BOOL) animated {
}

#pragma mark MKMapViewDelegate
/*
- (void) mapView: (MKMapView *) mapView regionWillChangeAnimated: (BOOL) animated {
	if([_mapViewController respondsToSelector: @selector(mapView: regionWillChangeAnimated:)])
		[_mapViewController mapView: mapView regionWillChangeAnimated: animated];
}

- (void) mapView: (MKMapView *) mapView regionDidChangeAnimated: (BOOL) animated {
	if([_mapViewController respondsToSelector: @selector(mapView: regionDidChangeAnimated:)])
		[_mapViewController mapView: mapView regionDidChangeAnimated: animated];
}

- (void) mapViewWillStartLoadingMap: (MKMapView *) mapView {
	if([_mapViewController respondsToSelector: @selector(mapViewWillStartLoadingMap:)])
		[_mapViewController mapViewWillStartLoadingMap: mapView];
}

- (void) mapViewDidFinishLoadingMap: (MKMapView *) mapView {
	if([_mapViewController respondsToSelector: @selector(mapViewDidFinishLoadingMap:)])
		[_mapViewController mapViewDidFinishLoadingMap: mapView];
}

- (void) mapViewDidFailLoadingMap: (MKMapView *) mapView withError: (NSError *) error {
	if([_mapViewController respondsToSelector: @selector(mapViewDidFailLoadingMap: withError:)])
		[_mapViewController mapViewDidFailLoadingMap: mapView withError: error];
}
*/

// mapView:viewForAnnotation: provides the view for each annotation.
// This method may be called for all or some of the added annotations.
// For MapKit provided annotations (eg. MKUserLocation) return nil to use the MapKit provided annotation view.
- (MKAnnotationView *) mapView: (MKMapView *) mapView viewForAnnotation: (id <MKAnnotation>) annotation {
	if(annotation == [[self dcMapView] userLocation]) {
		[self setCenterCoordinate: [[[self dcMapView] userLocation] coordinate] withMapView: mapView atZoomLevel: 10 animated: YES];
		return nil;
	}
	
	//if([_mapViewController respondsToSelector: @selector(mapview: viewForAnnotation:)])
	//	return [_mapViewController mapView: mapView viewForAnnotation: annotation];
	
	MKAnnotationView* annotationView = nil;
	NSString static *identifier = @"Pin";
	MKPinAnnotationView* pin = nil;
		
	pin = (MKPinAnnotationView *)[[self dcMapView] dequeueReusableAnnotationViewWithIdentifier:identifier];
	
	if(!pin)
		pin = [[[MKPinAnnotationView alloc] initWithAnnotation: annotation reuseIdentifier:identifier] autorelease];
	
	[pin setPinColor: MKPinAnnotationColorGreen];
	
	//[pin setPinColor:(csAnnotation.annotationType == CSMapAnnotationTypeEnd) ? MKPinAnnotationColorRed : MKPinAnnotationColorGreen];
	
	[pin setAnimatesDrop: YES];
	
	annotationView = pin;
		
	[annotationView setEnabled: YES];
	[annotationView setCanShowCallout: YES];
	
	return annotationView;

}
/*
// mapView:didAddAnnotationViews: is called after the annotation views have been added and positioned in the map.
// The delegate can implement this method to animate the adding of the annotations views.
// Use the current positions of the annotation views as the destinations of the animation.
- (void) mapView: (MKMapView *) mapView didAddAnnotationViews: (NSArray *) views {
	if([_mapViewController respondsToSelector: @selector(mapview: didAddAnnotationViews:)])
		[_mapViewController mapView: mapView didAddAnnotationViews: views];
	
}


// mapView:annotationView:calloutAccessoryControlTapped: is called when the user taps on left & right callout accessory UIControls.
- (void) mapView: (MKMapView *) mapView annotationView: (MKAnnotationView *) view calloutAccessoryControlTapped: (UIControl *) control {
}
*/
@end
