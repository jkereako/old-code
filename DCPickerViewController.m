    //
//  DCPickerViewController.m
//  iOrder
//
//  Created by Jeffrey Kereakoglow on 7/23/10.
//  Copyright 2010 Droste Consultants, Inc. All rights reserved.
//

#import "DCPickerViewController.h"


@implementation DCPickerViewController
@synthesize _picker, _toolbar, _dataSource, _selectedValue, _didMovePicker;

- (id) init {
	self = [super init];
	if(!self)
		return nil;
	
	_dataSource = nil;
	_container = nil;
	_picker = nil;
	_toolbar = nil;
	_selectedValue = nil;
	_container = [[UIView alloc] init];
	_toolbar = [[UIToolbar alloc] init];
	_picker = [[UIPickerView alloc] init];
	_didMovePicker = NO;
	_pickerViewIsInitialized = NO;
	
	[self performSelector: @selector(helpInitPicker) withObject: nil afterDelay: 0.3];
	
	[_picker setDelegate: self];
	[_picker setShowsSelectionIndicator: YES];
	
	return self;
}

- (void)dealloc {
	SAFE_RELEASE(_container);
	SAFE_RELEASE(_picker);
	SAFE_RELEASE(_toolbar);
	SAFE_RELEASE(_dataSource);
	
    [super dealloc];
}


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewDidAppear: (BOOL) animated {
	[super viewDidAppear: animated];
	
	_pickerViewIsInitialized = YES;
}

//A sleezy way to ensure that the actual view has been initialized
- (void) helpInitPicker {
	_pickerViewIsInitialized = YES;
}

- (void) presentPickerViewWithToolbarAsPartialModalViewOnViewController: (UIViewController *) viewController placeToolbarAbovePicker: (BOOL) yesOrNo {
	
	[_container setFrame: CGRectMake(0, 0, 320, 260)];
	
	if(yesOrNo) {
		[_toolbar setFrame: CGRectMake(0, -18, 320, 44)];
		[_picker setFrame: CGRectMake(0, 26, 320, 216)];
	}
	else {
		[_toolbar setFrame: CGRectMake(0, 198, 320, 44)];
		[_picker setFrame: CGRectMake(0, -16, 320, 216)];
	}

	
	[_container setBackgroundColor: [UIColor whiteColor]];
	[_container addSubview: _picker];
	[_container addSubview: _toolbar];
	
	//[super presentViewAsPartialModalView: container onViewController: viewController];
	[super presentViewAsPartialModalView: _container onViewController: viewController additionalOffset: CGPointMake(0, -84)];
}

- (void) presentPickerViewAsPartialModalViewOnViewController: (UIViewController *) viewController {
	if(!_picker)
		[self _initInternal];
	
	//[super presentViewAsPartialModalView: _picker onViewController: viewController];
	[super presentViewAsPartialModalView: _picker onViewController: viewController additionalOffset: CGPointMake(0, -44)];
}

- (void) dismissPickerViewAsPartialModalView {
	[super dismissViewAsPartialModalView: _container];
}

- (NSString *) valueForRow: (NSInteger) row inComponent:(NSInteger) component {
	return [[_dataSource objectAtIndex: row] objectAtIndex: component];
}

#pragma mark -
#pragma mark UIPickerViewDataSource
- (NSInteger) numberOfComponentsInPickerView: (UIPickerView *) pickerView {
	NSAssert([_dataSource isKindOfClass: [NSArray class]], @"The property \"_dataSource is nil or invalid\"");
	
	return [_dataSource count];
}

- (NSInteger) pickerView: (UIPickerView *) pickerView numberOfRowsInComponent: (NSInteger) component {
	NSAssert([_dataSource isKindOfClass: [NSArray class]], @"The property \"_dataSource is nil or invalid\"");
	
//	_selectedValue = [[_dataSource objectAtIndex: component] objectAtIndex: 0];
	
	return [[_dataSource objectAtIndex: component] count];
}

#pragma mark -
#pragma mark UIPickerViewDelegate

- (void) pickerView: (UIPickerView *) pickerView didSelectRow: (NSInteger)row inComponent: (NSInteger) component {
	_selectedValue = [[_dataSource objectAtIndex: component] objectAtIndex: row];
}

- (CGFloat) pickerView: (UIPickerView *) pickerView rowHeightForComponent: (NSInteger) component {
	return 40;
}

- (NSString *) pickerView: (UIPickerView *) pickerView titleForRow: (NSInteger) row forComponent: (NSInteger) component {
	NSAssert([_dataSource isKindOfClass: [NSArray class]], @"The property \"_dataSource is nil or invalid\"");
	
	if(_pickerViewIsInitialized)
		_didMovePicker = YES;
	
	return [[_dataSource objectAtIndex: component] objectAtIndex: row];
}

/*
- (UIView *) pickerView: (UIPickerView *) pickerView viewForRow: (NSInteger) row forComponent: (NSInteger) component reusingView: (UIView *) view {
}
*/

- (CGFloat) pickerView: (UIPickerView *) pickerView widthForComponent: (NSInteger) component {
	if([_dataSource count] == 1)
	return 320 - 16;
}
@end
