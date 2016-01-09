//
//  DCViewController.h
//  DeliOrder
//
//  Created by Jeffrey Kereakoglow on 3/5/10.
//  Copyright 2010 Droste Consultants, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCMacro.h"
#import "DCProtocol.h"

@interface DCViewController : UIViewController {

}

- (void) presentViewAsPartialModalView: (UIView*) modalView onViewController: (UIViewController *) viewController;
- (void) presentViewAsPartialModalView: (UIView*) modalView onViewController: (UIViewController *) viewController additionalOffset: (CGPoint) offset;
- (void) dismissViewAsPartialModalView: (UIView*) modalView;
- (void) didFinishDismissingPartialModalView: (NSString *) animationID finished: (NSNumber *) finished context: (void *) context;

@end
