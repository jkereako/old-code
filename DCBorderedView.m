//
//  DCTableViewCell.m
//  DeliOrder
//
//  Created by Jeffrey Kereakoglow on 2/23/10.
//  Copyright 2010 Droste Consultants, Inc.. All rights reserved.
//

#import "DCBorderedView.h"

@implementation DCBorderedView
@synthesize borderColor, fillColor, position, cornerRadius, borderThickness;

- (id) initWithFrame: (CGRect) frame {
	self = [super initWithFrame: frame];
	
	if(!self)
		return nil;
		
	[self setPosition: DCTableViewCellPositionSingle];
	
	[self performSelector: @selector(_initInternal) withObject: nil afterDelay: 0.05];
	
	return self;
}


- (void) _initInternal {
}

- (void)dealloc {
	SAFE_RELEASE(borderColor);
	SAFE_RELEASE(fillColor);
	
    [super dealloc];
}

- (BOOL) isOpaque {
    return NO;
}

- (void) drawRect: (CGRect) rect {
    // Drawing code
	
    CGContextRef c;
	CGFloat minx, midx, maxx;
	CGFloat miny, midy, maxy;
	
	c = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(c, [fillColor CGColor]);
    CGContextSetStrokeColorWithColor(c, [borderColor CGColor]);
    CGContextSetLineWidth(c, [self borderThickness]);
		
	switch ([self position]) {
		case DCTableViewCellPositionTop:
			minx = CGRectGetMinX(rect) , midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect) ;
			miny = CGRectGetMinY(rect) , maxy = CGRectGetMaxY(rect) ;
			minx = minx + 1;
			miny = miny + 1;
			
			maxx = maxx - 1;
			maxy = maxy ;
			
			CGContextMoveToPoint(c, minx, maxy);
			CGContextAddArcToPoint(c, minx, miny, midx, miny, [self cornerRadius]);
			CGContextAddArcToPoint(c, maxx, miny, maxx, maxy, [self cornerRadius]);
			CGContextAddLineToPoint(c, maxx, maxy);
			
			// Close the path
			CGContextClosePath(c);
			// Fill & stroke the path
			CGContextDrawPath(c, kCGPathFillStroke);

			break;
			
		case DCTableViewCellPositionBottom:
			minx = CGRectGetMinX(rect) , midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect) ;
			miny = CGRectGetMinY(rect) , maxy = CGRectGetMaxY(rect) ;
			minx = minx + 1;
			miny = miny ;
			
			maxx = maxx - 1;
			maxy = maxy - 1;
			
			CGContextMoveToPoint(c, minx, miny);
			CGContextAddArcToPoint(c, minx, maxy, midx, maxy, [self cornerRadius]);
			CGContextAddArcToPoint(c, maxx, maxy, maxx, miny, [self cornerRadius]);
			CGContextAddLineToPoint(c, maxx, miny);
			// Close the path
			CGContextClosePath(c);
			// Fill & stroke the path
			CGContextDrawPath(c, kCGPathFillStroke);
			
			break;
			
		case DCTableViewCellPositionMiddle:
			minx = CGRectGetMinX(rect) , maxx = CGRectGetMaxX(rect) ;
			miny = CGRectGetMinY(rect) , maxy = CGRectGetMaxY(rect) ;
			minx = minx + 1;
			miny = miny ;
			
			maxx = maxx - 1;
			maxy = maxy ;
			
			CGContextMoveToPoint(c, minx, miny);
			CGContextAddLineToPoint(c, maxx, miny);
			CGContextAddLineToPoint(c, maxx, maxy);
			CGContextAddLineToPoint(c, minx, maxy);
			
			CGContextClosePath(c);
			// Fill & stroke the path
			CGContextDrawPath(c, kCGPathFillStroke);  
			
			break;

		case DCTableViewCellPositionSingle:
		default:
			minx = CGRectGetMinX(rect) , midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect) ;
			miny = CGRectGetMinY(rect) , midy = CGRectGetMidY(rect) , maxy = CGRectGetMaxY(rect) ;
			minx = minx + 1;
			miny = miny + 1;
			
			maxx = maxx - 1;
			maxy = maxy - 1;
			
			CGContextMoveToPoint(c, minx, midy);
			CGContextAddArcToPoint(c, minx, miny, midx, miny, [self cornerRadius]);
			CGContextAddArcToPoint(c, maxx, miny, maxx, midy, [self cornerRadius]);
			CGContextAddArcToPoint(c, maxx, maxy, midx, maxy, [self cornerRadius]);
			CGContextAddArcToPoint(c, minx, maxy, minx, midy, [self cornerRadius]);
			
			// Close the path
			CGContextClosePath(c);
			// Fill & stroke the path
			CGContextDrawPath(c, kCGPathFillStroke);     
			break;
	}
	
}

@end
