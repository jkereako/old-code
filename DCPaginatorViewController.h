//
//  DCScrollViewController.h
//  DeliOrder
//
//  Created by Jeffrey Kereakoglow on 2/19/10.
//  Copyright 2010 Droste Consultants, Inc.. All rights reserved.
//
//	Description: A control to use the UIScrollView and UIPageControl in one class
//
//	Usage: Subclass this class and assign an array of UIViewControllers--
//	if using a NIB, initializE with "initWithNibName()"--to the property _dataSource.
//	The properties dcScrollView and dcPageControl are NIB ready, so in your NIB,
//	drop in a UIScrollView and a UIPageControl and connect the NIB to the respective
//	IBOutlets.
//

#import <Foundation/Foundation.h>
#import "DCMacro.h"
#import "DCProtocol.h"

@interface DCPaginatorViewController : UIViewController <UIScrollViewDelegate> {
@private
	id _lastObjectCalled;

@protected
	NSUInteger _pageCount;
	NSArray *_dataSource;	//An array of UITableViewControllers
	
@public
	UIScrollView *dcScrollView;
	UIPageControl *dcPageControl;
}
@property (nonatomic, copy, getter=dataSource, setter= setDataSource) NSArray *_dataSource;
@property (assign, readonly, getter=pageCount) NSUInteger _pageCount;
@property (nonatomic, retain) IBOutlet UIScrollView *dcScrollView;
@property (nonatomic, retain) IBOutlet UIPageControl *dcPageControl;

- (void) _initInternal;


- (UIView *) viewForPage: (NSUInteger) page;
- (void) insertViewIntoPaginator: (UIView *) aView atPageIndex: (NSUInteger) page;

@end
