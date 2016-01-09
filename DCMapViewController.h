//
//  DCMapViewController.h
//  DeliOrder
//
//  Created by Jeffrey Kereakoglow on 2/17/10.
//  Copyright 2010 Droste Consultants, Inc.. All rights reserved.
//
//	Description: Offers a base class with which initial configurations can be
//	set, subclasses of this will house more specific configurations.
//
//	This base-class is set for use with or without a XIB and includes a reverse
//	geocoder that will return address information on a point on the map. Another
//	useful feature in this class is an animated zoom to center the map on. By
//	defauly, the MapKit does not support this, it only centers a coordinate on 
//	the map without zooming in.
//
//
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "DCMapViewControllerDelegate.h"
#import "DCProtocol.h"
#import "DCMacro.h"

@class DCLocation;
@interface DCMapViewController : UIViewController <DCProtocol, MKMapViewDelegate> {
@private
	BOOL _awokeFromNib;

@public
	MKMapView *dcMapView;
	UINavigationController *navController;
}

@property (nonatomic, retain) IBOutlet MKMapView *dcMapView;
@property (nonatomic, retain) UINavigationController *navController;

- (CGFloat) longitudeToPixelSpaceX: (CGFloat) longitude;
- (CGFloat) latitudeToPixelSpaceY: (CGFloat) latitude;
- (CGFloat) pixelSpaceXToLongitude: (CGFloat) pixelX;
- (CGFloat) pixelSpaceYToLatitude: (CGFloat) pixelY;

- (MKCoordinateSpan) coordinateSpanWithMapView: (MKMapView *) aMapView centerCoordinate: (CLLocationCoordinate2D) centerCoordinate andZoomLevel: (NSUInteger) zoomLevel;

- (void) setCenterCoordinate: (CLLocationCoordinate2D) centerCoordinate withMapView: (MKMapView *) mapView atZoomLevel: (NSUInteger) zoomLevel animated: (BOOL) animated;

@end
