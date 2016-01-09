//
//  DCProtocol.h
//  DeliOrder
//
//  Created by Jeffrey Kereakoglow on 2/16/10.
//  Copyright 2010 Droste Consultants, Inc.. All rights reserved.
//
//	Provides declarations of standard functions that should be implemented
//
//
//
//

@protocol DCProtocol
@optional

- (void) handleError: (NSError *) error;
- (void) presentAlertWithTitle: (NSString *) title message: (NSString *) message;
- (void) notifyCaller;
- (void) notifyCallerWithObject: (id) object;
@end

