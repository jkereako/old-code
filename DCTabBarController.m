//
//  DCTabBarController.m
//  DeliOrder
//
//  Created by Jeffrey Kereakoglow on 2/22/10.
//  Copyright 2010 Droste Consultants, Inc.. All rights reserved.
//

#import "DCTabBarController.h"


@implementation DCTabBarController

- (void) viewDidLoad {
	NSEnumerator *iterator;
	id viewController;
	
	iterator = [[self viewControllers] objectEnumerator];
	
	while (viewController = [iterator nextObject]) {
		if([viewController respondsToSelector: @selector(viewDidLoad)])
			[viewController viewDidLoad];
	}
}

/*
- (BOOL) tabBarController: (UITabBarController *) tabBarController shouldSelectViewController: (UIViewController *) viewController {
	return YES;
}
*/


- (void) tabBarController: (UITabBarController *) tabBarController didSelectViewController: (UIViewController *) viewController {
	;
}

- (void) tabBarController: (UITabBarController *) tabBarController willBeginCustomizingViewControllers: (NSArray *) viewControllers {
}

- (void) tabBarController: (UITabBarController *) tabBarController willEndCustomizingViewControllers: (NSArray *) viewControllers changed: (BOOL) changed {
}

- (void) tabBarController: (UITabBarController *) tabBarController didEndCustomizingViewControllers: (NSArray *) viewControllers changed: (BOOL) changed {
}

@end
