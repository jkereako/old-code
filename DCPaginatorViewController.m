//
//  DCScrollViewController.m
//  DeliOrder
//
//  Created by Jeffrey Kereakoglow on 2/19/10.
//  Copyright 2010 Droste Consultants, Inc.. All rights reserved.
//

#import "DCPaginatorViewController.h"

@implementation DCPaginatorViewController
@synthesize _dataSource, _pageCount, dcScrollView, dcPageControl;

- (id) init {
	self = [super init];
	
	if (!self)
		return nil;
		
	return self;
}

- (id) initWithNibName: (NSString *) nibNameOrNil bundle: (NSBundle *) nibBundleOrNil {
	self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil];
	
	if (!self)
		return nil;
		
	return self;
}

- (void) _initInternal {
	CGFloat width = 0.0;
	CGFloat height = 0.0;
		
	if(!dcScrollView)
		[self setDcScrollView: [[UIScrollView alloc] init]];
	
	if(!dcPageControl)
		[self setDcPageControl: [[UIPageControl alloc] init]];
	
	width = [dcScrollView frame].size.width;
	height = [dcScrollView frame].size.height;
		
	[dcScrollView setPagingEnabled: YES];
	[dcScrollView setShowsVerticalScrollIndicator: NO];
	[dcScrollView setShowsHorizontalScrollIndicator: NO];
	[dcScrollView setScrollsToTop: NO];
	[dcScrollView setContentSize: CGSizeMake(width * _pageCount, height)];
	[dcScrollView setDelegate: self];
	
	[dcPageControl setCurrentPage: 0];
}

- (void) dealloc {
	SAFE_RELEASE(_dataSource);
	SAFE_RELEASE(dcScrollView);
	SAFE_RELEASE(dcPageControl);

	[super dealloc];
}


#pragma mark -
#pragma mark Public Methods

//Adds a view to the UIScroller.
-(UIView *) viewForPage: (NSUInteger) page {
	NSAssert([_dataSource isKindOfClass: [NSArray class]], @"The datasource property is nil or invalid");
	
	return [[_dataSource objectAtIndex: page] view];
}

- (void) insertViewIntoPaginator: (UIView *) aView atPageIndex: (NSUInteger) page {
	NSParameterAssert([aView isKindOfClass: [UIView class]]);
	
	CGRect scrollViewFrame = CGRectMake(0, 0, 0, 0);
	
	//If the view already has a superview, don't add another one.
	if([[aView superview] isKindOfClass: [UIScrollView class]])
		return;
	
	scrollViewFrame = [dcScrollView frame];
	
	scrollViewFrame.origin.x = scrollViewFrame.size.width * page;
	scrollViewFrame.origin.y = 0;
	
	[aView setFrame: scrollViewFrame];
	
	[dcScrollView addSubview: aView];
	
}

#pragma mark -
#pragma mark UIViewController

#pragma mark -
#pragma mark UIScrollViewDelegate

// any offset changes
- (void) scrollViewDidScroll: (UIScrollView *) scrollView {
    CGFloat pageWidth;
	NSUInteger page;
	id viewController;
	
	pageWidth = [dcScrollView frame].size.width;
	
    page = floor(([dcScrollView contentOffset].x - pageWidth / 2) / pageWidth) + 1;
	
	[dcPageControl setCurrentPage: page];
	
	viewController = [_dataSource objectAtIndex: [dcPageControl currentPage]];
		
	//Simulate viewWillAppear
	if(viewController != _lastObjectCalled && [viewController respondsToSelector: @selector(viewWillAppear:)]) {
		[viewController viewWillAppear: YES];
		
		_lastObjectCalled = viewController;
	}
		
	//Load the current page, and preload the pages before and after it to enhance scrolling smoothness
	if(page > 0)
		[self insertViewIntoPaginator: [[_dataSource objectAtIndex: page - 1] view] atPageIndex: page - 1];
	
	[self insertViewIntoPaginator: [[_dataSource objectAtIndex: page] view] atPageIndex: page];
	
	if(page < [_dataSource count] - 1)
		[self insertViewIntoPaginator: [[_dataSource objectAtIndex: page + 1] view] atPageIndex: page + 1];

}

// called on start of dragging (may require some time and or distance to move)
- (void) scrollViewWillBeginDragging: (UIScrollView *) scrollView {

}

// called on finger up if user dragged. decelerate is true if it will continue moving afterwards
- (void) scrollViewDidEndDragging:(UIScrollView *) scrollView willDecelerate: (BOOL) decelerate {
}

// called on finger up as we are moving
- (void) scrollViewWillBeginDecelerating: (UIScrollView *) scrollView {
}

// called when scroll view grinds to a halt
//DC - Simulate viewDidAppear
- (void) scrollViewDidEndDecelerating: (UIScrollView *) scrollView {
	id viewController;
	viewController = [_dataSource objectAtIndex: [dcPageControl currentPage]];
	
	if([viewController respondsToSelector: @selector(viewDidAppear:)])
		[viewController viewDidAppear: YES];
}

// called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
- (void) scrollViewDidEndScrollingAnimation: (UIScrollView *) scrollView {
}

// return a view that will be scaled. if delegate returns nil, nothing happens
- (UIView *) viewForZoomingInScrollView: (UIScrollView *) scrollView {
	return nil;
}

// scale between minimum and maximum. called after any 'bounce' animations
- (void) scrollViewDidEndZooming: (UIScrollView *) scrollView withView: (UIView *) view atScale: (float) scale {
}

// return a yes if you want to scroll to the top. if not defined, assumes YES
- (BOOL) scrollViewShouldScrollToTop: (UIScrollView *) scrollView {
	return NO;
}


// called when scrolling animation finished. may be called immediately if already at top
- (void) scrollViewDidScrollToTop: (UIScrollView *) scrollView {
}

@end
