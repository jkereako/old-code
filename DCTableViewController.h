//
//  GenericTableViewController.h
//  PhoneNumbers
//
//  Created by Matt Gallagher on 12/27/08.
//  Copyright 2008 Matt Gallagher. All rights reserved.
//
//  Description: Provides a very simple and atomic way to incorporate multiple
//	groups of UITableViewCells into one UITableViewController.
//
//	In using this class, it is easy to remove, add and replace rows and sections
//	either permenantly or temporarily (for effect) with verbose methods such as
//	replaceRowAtIndexPath: withRow: animation:. These functions alter both the 
//	UITableView internal row count and the datasource so everything is synchronized.
//
//	Usage: Subclass DCTableViewController and override either init or 
//	initWithIndexPath and build an array of CellControllers--subclasses of 
//	NSObject which conform to the protocol DCTableViewControllerDelegate--and 
//	assign that array to the tableGroups property. The section count for the 
//	table view will be [tableGroups count] and the row count will be
//	[[tableGroups objectAtIndex: [indexPath section]] count].
//
//	NOTE: If you want control on the table-view level, you must do so in the
//	subclass you made of DCTableViewController. The CellContollers are only used
//	for cell-level customization, such as background color and content.
//

#import <UIKit/UIKit.h>
#import "DCTableViewCellControllerDelegate.h"
#import "DCProtocol.h"
#import "DCMacro.h"

typedef enum {
    DCCustomEditingTypeInsert,
	DCCustomEditingTypeInsertMultiple,
	DCCustomEditingTypeReplace,
	DCCustomEditingTypeRemove,
	DCCustomEditingTypeRemoveMultiple,
	DCCustomEditingTypeStore,
	DCCustomEditingTypeRecall,
	DCCustomEditingTypeRecallAndReload
} DCCustomEditingType;


@interface DCTableViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource> {
@private
	NSArray *_temporaryStore; //This can be rows or sections
	NSIndexSet *_temporaryIndexSet;
	NSArray *_temporaryIndexPaths;
	NSArray *_tableGroups;
	NSIndexPath *_indexPath;
	
}

@property (nonatomic, retain, getter=tableGroups) NSArray *_tableGroups;

- (id) initWithIndexPath: (NSIndexPath *) indexPath;
- (id) initWithIndexPath: (NSIndexPath *) indexPath style: (UITableViewStyle) style;
- (id) initWithIndexPath: (NSIndexPath *) indexPath nib: (NSString *) nibNameOrNil bundle: (NSBundle *) nibBundleOrNil;
- (void) _initInternal;
- (void) _initInternal: (NSIndexPath *) indexPath;
- (void) refreshTableGroups;
- (void) _updateAndReload;

- (NSIndexPath *) initialIndexPath;
- (NSArray *) dataSourceSectionForIndex: (NSUInteger) section;
- (NSObject <DCTableViewCellControllerDelegate> *) dataSourceCellControllerForIndexPath: (NSIndexPath *) indexPath;

// These functions remove objects from the datasource AND the tableview. Created to simplify table view editing and to increase readability of the code
/** Custom delegates **/
- (void) helpEditTableViewRows: (DCCustomEditingType) action anObject: (NSObject *) cell indexPath: (NSIndexPath *) indexPath indexSet: (NSIndexSet *) indexSet animation: (UITableViewRowAnimation) animation;
- (void) _removeAllRowsExceptAtIndexPathDelegate: (DCCustomEditingType) action atIndexPath: (NSIndexPath *) indexPath withAnimation: (UITableViewRowAnimation) animation;
- (void) _customSectionEditingDelegate: (DCCustomEditingType) action anObject: (NSArray *) aTableGroup atIndex: (NSUInteger) index withAnimation: (UITableViewRowAnimation) animation;
- (void) _removeAllSectionsExceptAtIndexDelegate: (DCCustomEditingType) action atIndex: (NSUInteger) index withAnimation: (UITableViewRowAnimation) animation;
- (void) _createStore: (NSArray *) sectionOrRow withIndexPaths: (NSArray *) indexPaths andIndexSet: (NSIndexSet *) indexSet;
- (void) _clearStore;

/** Row edit functions **/
- (void) pushRow: (NSObject *) cell withIndexPath: (NSIndexPath *) indexPath animation: (UITableViewRowAnimation) animation;
- (void) popRow: (NSIndexPath *) indexPath withAnimation: (UITableViewRowAnimation) animation;
- (void) attachRow: (NSObject *) cell withIndexPath: (NSIndexPath *) indedPath animation: (UITableViewRowAnimation) animation;
- (void) detachRow: (NSIndexPath *) indexPath withAnimation: (UITableViewRowAnimation) animation;
- (void) insertRowAtIndexPath: (NSIndexPath *) indexPath withRow: (NSObject *) cell animation: (UITableViewRowAnimation) animation;
- (void) insertRowsAtIndexPaths: (NSArray *) indexPaths withRows: (NSArray *) cells animation: (UITableViewRowAnimation) animation;
- (void) replaceRowAtIndexPath: (NSIndexPath *) indexPath withRow: (NSObject *) cell animation: (UITableViewRowAnimation) animation;
- (void) removeRowAtIndexPath: (NSIndexPath *) indexPath animation: (UITableViewRowAnimation) animation;
- (void) removeRowsAtIndexPaths: (NSArray *) indexPaths animation: (UITableViewRowAnimation) animation;
- (void) removeAllRowsExceptAtIndexPath: (NSIndexPath *) indexPath animation: (UITableViewRowAnimation) animation;
- (void) removeAllRowsTemporarilyExceptAtIndexPath: (NSIndexPath *) indexPath animation: (UITableViewRowAnimation) animation;
- (void) recallRowsWithAnimation: (UITableViewRowAnimation) animation;

/** Section edit functions **/
- (void) pushSection: (NSArray *) aTableGroup withAnimation: (UITableViewRowAnimation) animation;
- (void) popSection: (UITableViewRowAnimation) withAnimation;
- (void) attachSection: (NSArray *) aTableGroup withAnimation: (UITableViewRowAnimation) animation;
- (void) detachSection: (UITableViewRowAnimation) withAnimation;
- (void) replaceSectionAtIndex: (NSUInteger) index withTableGroup: (NSArray *) aTableGroup animation: (UITableViewRowAnimation) animation;
- (void) removeSectionAtIndex: (NSUInteger) index withAnimation: (UITableViewRowAnimation) animation;
- (void) removeAllSectionsExceptAtIndex: (NSUInteger) index withAnimation: (UITableViewRowAnimation) animation;
- (void) removeAllSectionsTemporarilyExceptAtIndex: (NSUInteger) index withAnimation: (UITableViewRowAnimation) animation;
- (void) recallSectionsWithAnimation: (UITableViewRowAnimation) animation;

- (NSArray *) tableGroups;
- (void) setTableGroups: (NSArray *) tableGroups;
//- (void) reloadSectionAtIndex: (NSUInteger) index;

@end
