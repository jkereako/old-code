//
//  DCBadgedCell.h
//  DCBadgedTableCell
//	DCBageView
//
//	Any rereleasing of this code is prohibited.
//	Please attribute use of this code within your application
//
//	Any Queries should be directed to hi@tmdvs.me | http://www.tmdvs.me
//	
//  Created by Tim on [Dec 30].
//  Copyright 2009 Tim Davies. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DCMacro.h"

@interface DCBadgeView : UIView {
@private
	NSUInteger _width;
	NSUInteger _badgeNumber;
	
	UIFont *_font;
	UITableViewCell *_parent;
	
	UIColor *_badgeColor;
	UIColor *_badgeColorHighlighted;	
}

@property (nonatomic, readonly, getter=width) NSUInteger _width;
@property (nonatomic, assign, getter=badgeNumber, setter=setBadgeNumber) NSUInteger _badgeNumber;
@property (nonatomic, retain, getter=font, setter=setFont) UIFont *_font;
@property (nonatomic, assign) UITableViewCell *_parent;
@property (nonatomic, retain, getter=badgeColor, setter=setBadgeColor) UIColor *_badgeColor;
@property (nonatomic, retain, getter=badgeColorHighlighted, setter=setBadgeColorHighlighted) UIColor *_badgeColorHighlighted;

@end

@interface DCBadgedCell : UITableViewCell {
	NSInteger badgeNumber;
	DCBadgeView *badge;
	
	UIColor *badgeColor;
	UIColor *badgeColorHighlighted;
}

@property NSInteger badgeNumber;
@property (readonly, retain) DCBadgeView *badge;
@property (nonatomic, retain) UIColor *badgeColor;
@property (nonatomic, retain) UIColor *badgeColorHighlighted;

@end