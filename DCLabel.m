//
//  DCLabel.m
//  DeliOrder
//
//  Created by Jeffrey Kereakoglow on 2/23/10.
//  Copyright 2010 Droste Consultants, Inc.. All rights reserved.
//

#import "DCLabel.h"


@implementation DCLabel

- (void) drawTextInRect: (CGRect) rect {

	//Configure here
	CGFloat components[8] = {
		1.0, 1.0, 1.0, 1.0,  // Start color
		1.0, 1.0, 1.0, 1.0 }; // End color
	//End config
	
	CGGradientRef gradient;
	CGColorSpaceRef rgbColorspace;
	size_t num_locations = 2;
	CGFloat locations[2] = { 0.0, 1.0 };
	
	rgbColorspace = CGColorSpaceCreateDeviceRGB();
	gradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);
	
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	// Get drawing font.
	
	CGFontRef font = CGFontCreateWithFontName((CFStringRef)[[self font] fontName]);
	CGContextSetFont(ctx, font);
	CGContextSetFontSize(ctx, [[self font] pointSize]);
	
	// Transform text characters to unicode glyphs.
	
	NSInteger length = [[self text] length];
	unichar chars[length];
	CGGlyph glyphs[length];
	[[self text] getCharacters:chars range:NSMakeRange(0, length)];
	CGFontGetGlyphsForUnichars(font, chars, glyphs, length);
	
	// Measure text dimensions.
	
	CGContextSetTextDrawingMode(ctx, kCGTextInvisible); 
	CGContextSetTextPosition(ctx, 0, 0);
	CGContextShowGlyphs(ctx, glyphs, length);
	CGPoint textEnd = CGContextGetTextPosition(ctx);
	
	// Calculate text drawing point.
	
	CGPoint alignment = CGPointMake(0, 0);
	CGPoint anchor = CGPointMake(textEnd.x * (-0.5), [[self font] pointSize] * (-0.25));  
	CGPoint p = CGPointApplyAffineTransform(anchor, CGAffineTransformMake(1, 0, 0, -1, 0, 1));
	
	if ([self textAlignment] == UITextAlignmentCenter) {
		alignment.x = [self bounds].size.width * 0.5 + p.x;
	}
	else if ([self textAlignment] == UITextAlignmentLeft) {
		alignment.x = 0;
	}
	else {
		alignment.x = [self bounds].size.width - textEnd.x;
	}
	
	alignment.y = [self bounds].size.height * 0.5 + p.y;
	
	// Flip back mirrored text.
	
	CGContextSetTextMatrix(ctx, CGAffineTransformMakeScale(1, -1));
	
	// Draw shadow.
	
	CGContextSaveGState(ctx);
	CGContextSetTextDrawingMode(ctx, kCGTextFill);
	CGContextSetFillColorWithColor(ctx, [[self shadowColor] CGColor]);
	CGContextSetShadowWithColor(ctx, [self shadowOffset], 0, [[self shadowColor] CGColor]);
	CGContextShowGlyphsAtPoint(ctx, alignment.x, alignment.y, glyphs, length);
	CGContextRestoreGState(ctx);
	
	// Draw text clipping path.
	
	CGContextSetTextDrawingMode(ctx, kCGTextClip);
	CGContextShowGlyphsAtPoint(ctx, alignment.x, alignment.y, glyphs, length);
	
	// Restore text mirroring.
	
	CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
	
	// Fill text clipping path with gradient.
	
	CGPoint start = CGPointMake(rect.origin.x, rect.origin.y);
	CGPoint end = CGPointMake(rect.origin.x, rect.size.height);
	CGContextDrawLinearGradient(ctx, gradient, start, end, 0);
	
	// Cut outside clipping path.
	
	CGContextClip(ctx);
	
}


@end
