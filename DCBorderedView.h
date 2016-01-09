//
//  DCTableViewCell.h
//  DeliOrder
//
//  Created by Jeffrey Kereakoglow on 2/23/10.
//  Copyright 2010 Droste Consultants, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCMacro.h"

typedef enum  {
    DCTableViewCellPositionTop, 
    DCTableViewCellPositionMiddle, 
    DCTableViewCellPositionBottom,
	DCTableViewCellPositionSingle
} DCTableViewCellPosition;

@interface DCBorderedView : UIView {
	UIColor *borderColor;
	UIColor *fillColor;
	DCTableViewCellPosition position;
	CGFloat cornerRadius;
	CGFloat borderThickness;
}

@property (nonatomic, retain) UIColor *borderColor;
@property (nonatomic, retain) UIColor *fillColor;
@property (assign) DCTableViewCellPosition position;
@property (assign) CGFloat cornerRadius;
@property (assign) CGFloat borderThickness;

- (void) _initInternal;

@end
