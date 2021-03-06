//
//  splashView.h
//  version 1.1
//
//  Created by Shannon Appelcline on 5/22/09.
//  Copyright 2009 Skotos Tech Inc.
//
//  Licensed Under Creative Commons Attribution 3.0:
//  http://creativecommons.org/licenses/by/3.0/
//  You may freely use this class, provided that you maintain these attribute comments
//
//  Visit our iPhone blog: http://iphoneinaction.manning.com
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol DCSplashViewDelegate <NSObject>
@optional
- (void)splashIsDone;
@end

typedef enum {
	DCSplashViewAnimationNone,
	DCSplashViewAnimationSlideLeft,
	DCSplashViewAnimationFade,
} DCSplashViewAnimation;

@interface DCSplashView : UIView {
	
	id<DCSplashViewDelegate> delegate;
	UIImageView *splashImage;
	
	UIImage *image;
	NSTimeInterval delay;
	BOOL touchAllowed;
	DCSplashViewAnimation animation;
	NSTimeInterval animationDelay;
	
	BOOL isFinishing;
	
}
@property (retain) id<DCSplashViewDelegate> delegate;
@property (retain) UIImage *image;
@property NSTimeInterval delay;
@property BOOL touchAllowed;
@property DCSplashViewAnimation animation;
@property NSTimeInterval animationDelay;
@property BOOL isFinishing;

- (id)initWithImage:(UIImage *)screenImage;
- (void)startSplash;
- (void)dismissSplash;
- (void)dismissSplashFinish;

@end
