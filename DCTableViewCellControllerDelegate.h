//
//  CellController.h
//  
//
//  Created by Matt Gallagher on 27/12/08.
//  Copyright 2008 Matt Gallagher. All rights reserved.
//
//  This file contains all of the delegate function declarations in
//	UITableView.h, including both datasource and delegate functions. These
//	functions are to be defined in both GenericTableViewController.m and in
//	each UITableViewCellController file.
//

@protocol DCTableViewCellControllerDelegate
@required

- (UITableViewCell *) tableView:(UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath;

@optional

/*
 //Configure text label
 [[cell textLabel] setBackgroundColor: HEXCOLOR_TO_UICOLOR(0x5A1408FF)];
 [[cell textLabel] setTextColor: HEXCOLOR_TO_UICOLOR(0xFFFFFFFF)];
 [[cell textLabel] setShadowColor: HEXCOLOR_TO_UICOLOR(0x000000FF)];
 [[cell textLabel] setShadowOffset: CGSizeMake(-1.0, -1.0)]; //width, height
 [[cell textLabel] setFont: [UIFont boldSystemFontOfSize: 17.0]];
 */


#pragma mark -
#pragma mark Properties I've found useful
//Cell
@property (nonatomic, copy, getter=cellIdentifier, setter=setCellIdentifier) NSString *_identifier;
@property (nonatomic, copy, getter=cellValue, setter=setCellValue) NSString *_value;

@property (nonatomic, retain, getter=cellBackgroundView, setter=setCellBackgroundView) UIView *_cellBackgroundView;
@property (nonatomic, retain, getter=cellSelectedBackgroundView, setter=setCellSelectedBackgroundView) UIView *_cellSelectedBackgroundView;
@property (nonatomic, retain, getter=cellBackgroundColor, setter=setCellBackgroundColor) UIColor *_cellBackgroundColor;
@property (assign, getter=cellStyle, setter=setCellStyle) UITableViewCellStyle _cellStyle;
@property (assign, getter=cellSelected, setter=setCellSelected) BOOL _cellSelected;
@property (assign, getter=cellSelectionStyle, setter=setCellSelectionStyle) UITableViewCellSelectionStyle _cellSelectionStyle;
@property (assign, getter=cellSeparatorStyle, setter=setCellSeparatorStyle) UITableViewCellSeparatorStyle _cellSeparatorStyle;
@property (assign, getter=cellAccessoryType, setter=setCellAccessoryType) UITableViewCellAccessoryType _cellAccessoryType;
@property (assign, getter=cellAffineTransform, setter=setCellAffineTransform) CGAffineTransform _cellAffineTransform;

//Image View
@property (nonatomic, retain, getter=imageView, setter=setImageView) UIImage *_imageView;

//Text Label
@property (nonatomic, copy, getter=textLabel, setter=setTextLabel) NSString *_textLabel;
@property (nonatomic, retain, getter=textLabelBackgroundColor, setter=setTextLabelBackgroundColor) UIColor *_textLabelBackgroundColor;
@property (nonatomic, retain, getter=textLabelTextColor, setter=setTextLabelTextColor) UIColor *_textLabelTextColor;
@property (nonatomic, retain, getter=textLabelShadowColor, setter=setTextLabelShadowColor) UIColor *_textLabelShadowColor;
@property (assign, getter=textLabelShadowOffset, setter=setTextLabelShadowOffset) CGSize _textLabelShadowOffset;
@property (nonatomic, retain, getter=textLabelFont, setter=setTextLabelFont) UIFont *_textLabelFont;
@property (assign, getter=textLabelAlignment, setter=setTextLabelAlignment) UITextAlignment _textLabelAlignment;
@property (assign, getter=textLabelNumberOfLines, setter=setTextLabelNumberOfLines) NSInteger _textLabelNumberOfLines;

//Detail Text Label
@property (nonatomic, copy, getter=detailTextLabel, setter=setDetailTextLabel) NSString *_detailTextLabel;
@property (nonatomic, retain, getter=_detailTextLabelBackgroundColor, setter=setDetailTextLabelBackgroundColor) UIColor *_detailTextLabelBackgroundColor;
@property (nonatomic, retain, getter=_detailTextLabelTextColor, setter=setDetailTextLabelTextColor) UIColor *_detailTextLabelTextColor;
@property (nonatomic, retain, getter=_detailTextLabelShadowColor, setter=setDetailTextLabelShadowColor) UIColor *_detailTextLabelShadowColor;
@property (assign, getter=_detailTextLabelShadowOffset, setter=setDetailTextLabelShadowOffset) CGSize _detailTextLabelShadowOffset;
@property (nonatomic, retain, getter=_detailTextLabelFont, setter=setDetailTextLabelFont) UIFont *_detailTextLabelFont;
@property (assign, getter=textDetailLabelAlignment, setter=setDetailTextLabelAlignment) UITextAlignment _detailTextLabelAlignment;
@property (assign, getter=detailTextLabelNumberOfLines, setter=setDetailTextLabelNumberOfLines) NSInteger _detailTextLabelNumberOfLines;

//Accessory View
@property (nonatomic, retain, getter=accessoryView, setter=setAccessoryView) UIView *_accessoryView;

//UITableViewDelegate
@property (assign, getter=rowHeight, setter=setRowHeight) CGFloat _rowHeight;


#pragma mark UITableViewDataSource
- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section;

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView;              // Default is 1 if not implemented

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;    // fixed font style. use custom view (UILabel) if you want something different
- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section;

// Editing

// Individual rows can opt out of having the -editing property set for them. If not implemented, all rows are assumed to be editable.
- (BOOL) tableView: (UITableView *) tableView canEditRowAtIndexPath: (NSIndexPath *) indexPath;

// Moving/reordering

// Allows the reorder accessory view to optionally be shown for a particular row. By default, the reorder control will be shown only if the datasource implements -tableView:moveRowAtIndexPath:toIndexPath:
- (BOOL) tableView: (UITableView *) tableView canMoveRowAtIndexPath: (NSIndexPath *) indexPath;

// Index

- (NSArray *) sectionIndexTitlesForTableView: (UITableView *) tableView;                                                    // return list of section titles to display in section index view (e.g. "ABCD...Z#")
- (NSInteger) tableView: (UITableView *) tableView sectionForSectionIndexTitle: (NSString *) title atIndex: (NSInteger) index;  // tell table which section corresponds to section title/index (e.g. "B",1))

// Data manipulation - insert and delete support

// After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
- (void) tableView: (UITableView *) tableView commitEditingStyle: (UITableViewCellEditingStyle) editingStyle forRowAtIndexPath: (NSIndexPath *) indexPath;

// Data manipulation - reorder / moving support

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath;


#pragma mark UITableViewDelegate
// Display customization
- (void) tableView: (UITableView *) tableView willDisplayCell: (UITableViewCell *) cell forRowAtIndexPath: (NSIndexPath *) indexPath;

// Variable height support

- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath;
- (CGFloat) tableView: (UITableView *) tableView heightForHeaderInSection: (NSInteger) section;
- (CGFloat) tableView: (UITableView *) tableView heightForFooterInSection: (NSInteger) section;

// Section header & footer information. Views are preferred over title should you decide to provide both

- (UIView *) tableView: (UITableView *) tableView viewForHeaderInSection: (NSInteger) section;   // custom view for header. will be adjusted to default or specified header height
- (UIView *) tableView: (UITableView *) tableView viewForFooterInSection: (NSInteger) section;   // custom view for footer. will be adjusted to default or specified footer height

// Accessories (disclosures). 
- (UITableViewCellAccessoryType) tableView: (UITableView *) tableView accessoryTypeForRowWithIndexPath: (NSIndexPath *) indexPath __OSX_AVAILABLE_BUT_DEPRECATED(__MAC_NA,__MAC_NA,__IPHONE_2_0,__IPHONE_3_0);
- (void) tableView: (UITableView *) tableView accessoryButtonTappedForRowWithIndexPath: (NSIndexPath *) indexPath;

// Selection

// Called before the user changes the selection. Return a new indexPath, or nil, to change the proposed selection.
- (NSIndexPath *) tableView: (UITableView *) tableView willSelectRowAtIndexPath: (NSIndexPath *) indexPath;
- (NSIndexPath *) tableView: (UITableView *) tableView willDeselectRowAtIndexPath: (NSIndexPath *) indexPath __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_0);

// Called after the user changes the selection.
- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath;
- (void) tableView: (UITableView *) tableView didDeselectRowAtIndexPath: (NSIndexPath *) indexPath __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_0);

// Editing

// Allows customization of the editingStyle for a particular cell located at 'indexPath'. If not implemented, all editable cells will have UITableViewCellEditingStyleDelete set for them when the table has editing property set to YES.
- (UITableViewCellEditingStyle) tableView: (UITableView *) tableView editingStyleForRowAtIndexPath: (NSIndexPath *) indexPath;
- (NSString *) tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_0);

// Controls whether the background is indented while editing.  If not implemented, the default is YES.  This is unrelated to the indentation level below.  This method only applies to grouped style table views.
- (BOOL) tableView:(UITableView *) tableView shouldIndentWhileEditingRowAtIndexPath: (NSIndexPath *) indexPath;

// The willBegin/didEnd methods are called whenever the 'editing' property is automatically changed by the table (allowing insert/delete/move). This is done by a swipe activating a single row
- (void) tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath;
- (void) tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath;

// Moving/reordering

// Allows customization of the target row for a particular row as it is being moved/reordered
- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath;               

// Indentation

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath; // return 'depth' of row for hierarchies

@end

