//
//  DCViewControllerDelegate.h
//  DeliOrder
//
//  Created by Jeffrey Kereakoglow on 2/22/10.
//  Copyright 2010 Droste Consultants, Inc.. All rights reserved.
//
//	Description: This is a protocol reference for UIViewController and is to be
//	used ONLY when an object that is a view controller inherits from NSObject.
//	UIViewController subclasses should not adopt this protocol as it will cause
//	naming collision.
//
//	This is used with the paginator controller. First, the programmer subclasses
//	DCPaginatorViewController and in that class builds an array of individual
//	view controllers which could be UIViewController subclasses or NSObject
//	subclasses adopting the DCViewControllerDelegate protocol. It's
//	reccomended to use the latter.
//



@protocol DCViewControllerDelegate
@optional
- (void) loadView; // This is where subclasses should create their custom view hierarchy if they aren't using a nib. Should never be called directly.
- (void) viewDidLoad; // Called after the view has been loaded. For view controllers created in code, this is after -loadView. For view controllers unarchived from a nib, this is after the view is set.
- (void) viewDidUnload __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_0); // Called after the view controller's view is released and set to nil. For example, a memory warning which causes the view to be purged. Not invoked as a result of -dealloc.
- (BOOL) isViewLoaded __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_0);
- (void) viewWillAppear:(BOOL)animated;    // Called when the view is about to made visible. Default does nothing
- (void) viewDidAppear:(BOOL)animated;     // Called when the view has been fully transitioned onto the screen. Default does nothing
- (void) viewWillDisappear:(BOOL)animated; // Called when the view is dismissed, covered or otherwise hidden. Default does nothing
- (void) viewDidDisappear:(BOOL)animated;  // Called after the view was dismissed, covered or otherwise hidden. Default does nothing
- (void) didReceiveMemoryWarning; // Called when the parent application receives a memory warning. Default implementation releases the view if it doesn't have a superview.

//Modal
- (void) presentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated; // Display another view controller as a modal child. Uses a vertical sheet transition if animated.
- (void) dismissModalViewControllerAnimated:(BOOL)animated; // Dismiss the current modal child. Uses a vertical sheet transition if animated.


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation; // Override to allow rotation. Default returns YES only for UIDeviceOrientationPortrait

// The rotating header and footer views will slide out during the rotation and back in once it has completed.
- (UIView *) rotatingHeaderView;     // Must be in the view hierarchy. Default returns nil.
- (UIView *) rotatingFooterView;     // Must be in the view hierarchy. Default returns the active keyboard.

// Notifies when rotation begins, reaches halfway point and ends.
- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;

// Faster one-part variant, called from within a rotating animation block, for additional animations during rotation.
// A subclass may override this method, or the two-part variants below, but not both.
- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_0);

// Slower two-part variant, called from within a rotating animation block, for additional animations during rotation.
// A subclass may override these methods, or the one-part variant above, but not both.
- (void) willAnimateFirstHalfOfRotationToInterfaceOrientation: (UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
- (void) didAnimateFirstHalfOfRotationToInterfaceOrientation: (UIInterfaceOrientation)toInterfaceOrientation; // The rotating header and footer views are offscreen.
- (void) willAnimateSecondHalfOfRotationFromInterfaceOrientation: (UIInterfaceOrientation)fromInterfaceOrientation duration:(NSTimeInterval)duration; // A this point, our view orientation is set to the new orientation.


@end
