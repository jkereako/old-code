//
//  DCViewController.m
//  DeliOrder
//
//  Created by Jeffrey Kereakoglow on 3/5/10.
//  Copyright 2010 Droste Consultants, Inc.. All rights reserved.
//

#import "DCViewController.h"
#import "iOrderAppDelegate.h"
@implementation DCViewController

#pragma mark -
#pragma mark UIViewController Life Cycle
- (void)didReceiveMemoryWarning {
	;
}

#pragma mark -
#pragma mark MyStuff
/*
 * http://ramin.firoozye.com/2009/09/29/semi-modal-transparent-dialogs-on-the-iphone/
 */

- (void) presentViewAsPartialModalView: (UIView*) modalView onViewController: (UIViewController *) viewController {
	[self presentViewAsPartialModalView: modalView onViewController: viewController additionalOffset: CGPointMake(0, 0)];
}
- (void) presentViewAsPartialModalView: (UIView*) modalView onViewController: (UIViewController *) viewController additionalOffset: (CGPoint) offset {
	
	id app = nil;
	UIWindow* mainWindow = nil;
	CGSize screenSize = CGSizeMake(0, 0);
	CGSize viewSize = CGSizeMake(0, 0);
	//CGPoint screenCenter = CGPointMake(0, 0);
	CGPoint startingViewCenterPoint = CGPointMake(0, 0);
	CGPoint endingViewCenterPoint = CGPointMake(0, 0);
	NSString *appDelegateName = nil;
	
	appDelegateName = NSStringFromClass([[[UIApplication sharedApplication] delegate] class]);
	
	app = APP_DELEGATE_FOR_CLASS(iOrderAppDelegate);
	
	mainWindow = [app window];
	
	screenSize = [[UIScreen mainScreen] bounds].size;
	viewSize = [modalView bounds].size;
	
	//screenCenter = CGPointMake(screenSize.width / 2, screenSize.height / 2);
	startingViewCenterPoint = CGPointMake(screenSize.width / 2.0, screenSize.height * 1.5);
	
	endingViewCenterPoint = CGPointMake((screenSize.width / 2.0) - offset.x, (screenSize.height - viewSize.height) - offset.y);
	

	[modalView setCenter: startingViewCenterPoint]; // we start off-screen

	[[viewController view] addSubview: modalView];
	
	// Show it with a transition effect
	[UIView beginAnimations: nil context:nil];
	[UIView setAnimationDuration: 0.7]; // animation duration in seconds
	
	[modalView setCenter: endingViewCenterPoint];
	
	[UIView commitAnimations];
}

// Use this to slide the semi-modal view back down.
- (void) dismissViewAsPartialModalView: (UIView*) modalView {
	CGSize screenSize = CGSizeMake(0, 0);
	CGPoint startingViewCenterPoint;
	
	screenSize = [[UIScreen mainScreen] bounds].size;
	
	startingViewCenterPoint = CGPointMake(screenSize.width / 2.0, screenSize.height * 1.5);
	
	[UIView beginAnimations: nil context:modalView];
	[UIView setAnimationDuration: 0.7];
	[UIView setAnimationDelegate: self];
	
	[UIView setAnimationDidStopSelector:@selector(hideModalEnded:finished:context:)];
	
	[modalView setCenter: startingViewCenterPoint];
	
	[UIView commitAnimations];
}

- (void) didFinishDismissingPartialModalView: (NSString *) animationID finished: (NSNumber *) finished context: (void *) context {
	UIView* modalView = nil;
	
	modalView = (UIView *) context;
	[modalView removeFromSuperview];
	[modalView release];
}


@end
