//
//  DCPickerViewController.h
//  iOrder
//
//  Created by Jeffrey Kereakoglow on 7/23/10.
//  Copyright 2010 Droste Consultants, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCViewController.h"
#import "DCMacro.h"

@interface DCPickerViewController : DCViewController <UIPickerViewDataSource, UIPickerViewDelegate>{
@private
	UIPickerView *_picker;
	UIToolbar *_toolbar;
	UIView *_container; 
	NSArray *_dataSource;
	NSString *_selectedValue;
	BOOL _didMovePicker;
	BOOL _pickerViewIsInitialized;
}

@property (nonatomic, readonly, getter=toolbar) UIToolbar *_toolbar;
@property (nonatomic, readonly, getter=pickerView) UIPickerView *_picker;
@property (nonatomic, copy, getter=dataSource, setter=setDataSource) NSArray *_dataSource;
@property (nonatomic, readonly, getter=selectedValue) NSString *_selectedValue;
@property (assign, readonly, getter=didMovePicker) BOOL _didMovePicker;

//- (void) _initInternal;
- (void) helpInitPicker;
- (void) presentPickerViewWithToolbarAsPartialModalViewOnViewController: (UIViewController *) viewController placeToolbarAbovePicker: (BOOL) yesOrNo;
- (void) presentPickerViewAsPartialModalViewOnViewController: (UIViewController *) viewController;
- (void) dismissPickerViewAsPartialModalView;

- (NSString *) valueForRow: (NSInteger) row inComponent:(NSInteger) component;

@end
