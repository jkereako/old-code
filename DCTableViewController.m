//
//  GenericTableViewController.m
//  PhoneNumbers
//
//  Created by Matt Gallagher on 27/12/08.
//  Copyright 2008 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import "DCTableViewController.h"


@implementation DCTableViewController
@synthesize _tableGroups;

#pragma mark -
#pragma mark Initializers and Destroyers
- (id) init {
	self = [super init];
	
	if(!self)
		return nil;
	
	[self _initInternal: nil];
	
	return self;
}

- (id) initWithStyle: (UITableViewStyle) style {
	self = [super initWithStyle: style];
	
	if(!self)
		return nil;
	
	[self _initInternal: nil];
	
	return self;
}

- (id) initWithNibName: (NSString *) nibNameOrNil bundle: (NSBundle *) nibBundleOrNil {
	self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil];
	
	if(!self)
		return nil;
	
	[self _initInternal: nil];
	
	return self;
}

- (id) initWithIndexPath: (NSIndexPath *) indexPath {
	self = [super init];
	
	if(!self)
		return nil;
		
	[self _initInternal: indexPath];
	
	return self;
}

- (id) initWithIndexPath: (NSIndexPath *) indexPath style: (UITableViewStyle) style {
	self = [super initWithStyle: style];
	
	if(!self)
		return nil;
	
	[self _initInternal: indexPath];
	
	return self;
}

- (id) initWithIndexPath: (NSIndexPath *) indexPath nib: (NSString *) nibNameOrNil bundle: (NSBundle *) nibBundleOrNil {
	self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil];
	
	if(!self)
		return nil;
	
	[self _initInternal: indexPath];
	
	return self;
}
- (void) _initInternal {
	[self _initInternal: nil];
}

- (void) _initInternal: (NSIndexPath *) indexPath {
	//DEBUG_LOG(@"Initializing DCTableViewController...");
	
	_indexPath = indexPath;
	_temporaryIndexPaths = nil;
	_temporaryIndexSet = nil;
	_temporaryStore = nil;
		
	_tableGroups = [[[NSArray alloc] initWithArray: [[NSArray alloc] init]] retain];
}

- (void) dealloc {
	//DEBUG_LOG(@"Deallocating DCTableViewController...");
	
	SAFE_RELEASE(_tableGroups)

	[super dealloc];
}

- (void) refreshTableGroups {
	SAFE_RELEASE(_tableGroups)
	
	if(_temporaryIndexPaths)
		[self initWithIndexPath: [_temporaryIndexPaths objectAtIndex: 0]];
	
	else
		[self _initInternal: nil];
}


- (void) _updateAndReload {
	SAFE_RELEASE(_tableGroups)
	[self init];
	[[self tableView] reloadData];
}

/*
- (void) updateAndReloadWithAnimation: (UITableViewRowAnimation) animation {
	[self clear_tableGroups];
	[self init];
	[[self tableView] reloadSections:[NSIndexSet] withRowAnimation: animation];
}
*/

- (void) didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	
	SAFE_RELEASE(_tableGroups)
}

#pragma mark - 
#pragma mark Getters
- (NSIndexPath *) initialIndexPath {
	if(!_indexPath)
		return nil;
	
	return _indexPath;
}

- (NSArray *) dataSourceSectionForIndex: (NSUInteger) section {
	if(!_tableGroups)
		[self init];
	
	return [_tableGroups objectAtIndex:  section];
}

- (NSObject <DCTableViewCellControllerDelegate> *) dataSourceCellControllerForIndexPath: (NSIndexPath *) indexPath {
	if(!_tableGroups)
		[self init];
	
	return [[_tableGroups objectAtIndex: [indexPath section]] objectAtIndex: [indexPath row]];
		
}


#pragma mark DCGenericTableViewFunctions

- (void) _createStore: (NSArray *) sectionOrRow withIndexPaths: (NSArray *) indexPaths andIndexSet: (NSIndexSet *) indexSet {
	_temporaryStore = [[NSArray alloc] initWithArray: [sectionOrRow objectsAtIndexes: indexSet]];
	_temporaryIndexPaths = [[NSArray alloc] initWithArray: indexPaths];
	_temporaryIndexSet = [[NSIndexSet alloc] initWithIndexSet: indexSet];
}

- (void) _clearStore {
	SAFE_RELEASE(_temporaryStore);
	SAFE_RELEASE(_temporaryIndexPaths);
	SAFE_RELEASE(_temporaryIndexSet);
}

/** Custom Delegates **/
#pragma mark -
#pragma mark Internal Helper Methods
- (void) helpEditTableViewRows: (DCCustomEditingType) action anObject: (NSObject *) cell indexPath: (NSIndexPath *) indexPath indexSet: (NSIndexSet *) indexSet animation: (UITableViewRowAnimation) animation {
	if (!_tableGroups)
		[self init];
	
	NSMutableArray *section = nil;
	NSMutableArray *sections = nil;

	section = [[[_tableGroups objectAtIndex: [indexPath section]] mutableCopy] autorelease];
	sections = [_tableGroups mutableCopy];	
	
	if(animation == UITableViewRowAnimationNone)
		[[self tableView] setEditing: YES animated: NO];
	else
		[[self tableView] setEditing: YES animated: YES];
	
	switch (action) {
		case DCCustomEditingTypeInsert:
			[[self tableView] beginUpdates];
			[section insertObject: cell atIndex: [indexPath row]];
			[[self tableView] insertRowsAtIndexPaths: [NSArray arrayWithObject: indexPath] withRowAnimation: animation];
			break;
			
		case DCCustomEditingTypeInsertMultiple:
			[section insertObject: cell atIndex: [indexPath row]];
			break;			
	
		case DCCustomEditingTypeRemove:
			[[self tableView] beginUpdates];
			[section removeObjectAtIndex: [indexPath row]];
			
			//Removes the section instead of the row if it's the last row in the section
			if([section count])
				[[self tableView] deleteRowsAtIndexPaths: [NSArray arrayWithObject: indexPath] withRowAnimation: animation];
			else 
				[[self tableView] deleteSections: [NSIndexSet indexSetWithIndex: [indexPath section]] withRowAnimation: animation];
			break;
			
		case DCCustomEditingTypeRemoveMultiple:
			//[section removeObjectAtIndex: [indexPath row]];
			[section removeObjectsAtIndexes: indexSet];
			/*
			@try {
				[section removeObjectsAtIndexes: indexSet];
			}
			@catch (NSException * e) {
				;
			}
			@finally {
				;
			}
			 */
			
			break;	

		case DCCustomEditingTypeReplace:
			[[self tableView] beginUpdates];
			[section replaceObjectAtIndex: [indexPath row] withObject: cell];
			[[self tableView] insertRowsAtIndexPaths: [NSArray arrayWithObject: indexPath] withRowAnimation: animation];
			[[self tableView] deleteRowsAtIndexPaths: [NSArray arrayWithObject: indexPath] withRowAnimation: animation];
			break;
			
		case DCCustomEditingTypeStore:
			[[self tableView] beginUpdates];
			[self _createStore: [NSArray arrayWithObject: [section objectAtIndex: [indexPath row]]]
				withIndexPaths: [NSArray arrayWithObject: indexPath] 
				   andIndexSet: nil];
			break;

		case DCCustomEditingTypeRecall:
			[[self tableView] beginUpdates];
			[section insertObjects: _temporaryStore atIndexes: _temporaryIndexSet];
			[[self tableView] insertRowsAtIndexPaths: _temporaryIndexPaths withRowAnimation: animation];
			[self _clearStore];
			break;
			
		default:
			break;
	}
	
	//Prevents sections with zero rows being inserted into the datasource
	if([section count])
		[sections replaceObjectAtIndex: [indexPath section] withObject: section];
	else
		[sections removeObjectAtIndex: [indexPath section]];
	
	
	SAFE_RELEASE(_tableGroups);
	
//	[self refreshTableGroups];
	
	_tableGroups = [[NSArray alloc] initWithArray: sections];
	
	//SAFE_RELEASE(section);
	SAFE_RELEASE(sections);
	
	//NSLog([NSString stringWithFormat: @"section retain count: %d", [section retainCount]]);
	//NSLog([NSString stringWithFormat: @"sections retain count: %d", [sections retainCount]]);
	
	//SAFE_RELEASE(section);
	//SAFE_RELEASE(sections);
	
	if(action != DCCustomEditingTypeInsertMultiple && action != DCCustomEditingTypeRemoveMultiple)
		[[self tableView] endUpdates];
	
	[[self tableView] setEditing: NO animated: NO];
	
}

- (void) _customSectionEditingDelegate: (DCCustomEditingType) action anObject: (NSArray *) aTableGroup atIndex: (NSUInteger) index withAnimation: (UITableViewRowAnimation) animation {
	if (!_tableGroups)
		[self init];
	
	NSMutableArray *sections = nil;
	
	if(animation == UITableViewRowAnimationNone)
		[[self tableView] setEditing: YES animated: NO];
	else
		[[self tableView] setEditing: YES animated: YES];

	sections = [[_tableGroups mutableCopy] autorelease];
//	sections = [_tableGroups mutableCopy];	
	
	[[self tableView] beginUpdates];
	
	switch (action) {
		case DCCustomEditingTypeInsert:
			[sections insertObject: aTableGroup atIndex: index];
			[[self tableView] insertSections: [NSIndexSet indexSetWithIndex: index] withRowAnimation: animation];
			break;
		
		case DCCustomEditingTypeInsertMultiple:
			[sections insertObject: aTableGroup atIndex: index];
			break;
			
		case DCCustomEditingTypeRemove:
			[sections removeObjectAtIndex: index];
			[[self tableView] deleteSections:[NSIndexSet indexSetWithIndex: index] withRowAnimation: animation];
			break;

		case DCCustomEditingTypeReplace:
			[sections replaceObjectAtIndex: index withObject: aTableGroup];
			[[self tableView] deleteSections:[NSIndexSet indexSetWithIndex: index] withRowAnimation: animation];
			[[self tableView] insertSections: [NSIndexSet indexSetWithIndex: index] withRowAnimation: animation];
			break;
			
		case DCCustomEditingTypeStore:
			[self _createStore: [sections objectAtIndex: index] withIndexPaths: nil andIndexSet:[NSIndexSet indexSetWithIndex: index]];
			break;
			
		case DCCustomEditingTypeRecall:
			[sections insertObject: _temporaryStore atIndex: index];
			
			[[self tableView] insertSections: [NSIndexSet indexSetWithIndex: index] withRowAnimation: animation];

			[self _clearStore];
			break;
			
		default:
			break;
	}
	
	///SAFE_RELEASE(_tableGroups);
	
	//_tableGroups = [[[NSArray alloc] initWithArray: [[NSArray alloc] initWithObjects: section, nil]] retain];
	
	_tableGroups = [sections retain];
	
	[[self tableView] endUpdates];
	
	[[self tableView] setEditing: NO animated: NO];
	
	sections = nil;
}

- (void) _removeAllSectionsExceptAtIndexDelegate: (DCCustomEditingType) action atIndex: (NSUInteger) index withAnimation: (UITableViewRowAnimation) animation {
	if (!_tableGroups)
		[self init];
	
	NSMutableArray *section = nil;
	NSMutableIndexSet *indexSet = nil;
	NSUInteger i = 0;
	NSUInteger limit = 0;
	NSUInteger exception = 0;
	
	//section = [[_tableGroups mutableCopy] autorelease];
	section = [_tableGroups mutableCopy];
	indexSet = [[NSMutableIndexSet alloc] init];
	exception = index;
	limit = [_tableGroups count];
	
	[[self tableView] setEditing: YES animated: YES];
	
	[[self tableView] beginUpdates];
	
	for (i = 0; i != limit; ++i) {
		if(i == exception)
			continue;
		
		[indexSet addIndex: i];
	}
	
	//Save the index set so we can reload it later
	if(action == DCCustomEditingTypeStore)
		[self _createStore: section withIndexPaths: nil andIndexSet: indexSet];
	
	[section removeObjectsAtIndexes: indexSet];
	
	SAFE_RELEASE(_tableGroups);
	
	_tableGroups = [[[NSArray alloc] initWithArray: [[NSArray alloc] initWithObjects: section, nil]] retain];
		
	[[self tableView] deleteSections: indexSet withRowAnimation: animation];
	
	[[self tableView] endUpdates];
	
	[[self tableView] setEditing: NO animated: NO];
	
	SAFE_RELEASE(indexSet);
}

#pragma mark -
#pragma mark External Methods
- (void) pushRow: (NSObject *) cell withIndexPath: (NSIndexPath *) indexPath animation: (UITableViewRowAnimation) animation {
	NSUInteger section = 0;
	NSUInteger row = 0;
	
	section = [indexPath section];
	[self helpEditTableViewRows: DCCustomEditingTypeInsert anObject: cell indexPath: [NSIndexPath indexPathForRow: row inSection: section] indexSet: nil animation: animation];
//	[self _customRowEditingDelegate: DCCustomEditingTypeInsert anObject: cell atIndexPath: [NSIndexPath indexPathForRow: row inSection: section] withAnimation: animation];
}

- (void) popRow: (NSIndexPath *) indexPath  withAnimation: (UITableViewRowAnimation) animation {
	NSUInteger section = 0;
	NSUInteger row = 0;
	
	section = [indexPath section];
	
	[self helpEditTableViewRows: DCCustomEditingTypeRemove anObject: nil indexPath: [NSIndexPath indexPathForRow: row inSection: section] indexSet: nil animation: animation];
	//[self _customRowEditingDelegate: DCCustomEditingTypeRemove anObject: nil atIndexPath: [NSIndexPath indexPathForRow: row inSection: section] withAnimation: animation];
}

- (void) attachRow: (NSObject *) cell withIndexPath: (NSIndexPath *) indexPath animation: (UITableViewRowAnimation) animation {
	NSUInteger section = 0;
	NSUInteger row = 0;
	
	section = [indexPath section];
	row = [_tableGroups count];
	
	[self helpEditTableViewRows: DCCustomEditingTypeInsert anObject: cell indexPath: [NSIndexPath indexPathForRow: row inSection: section] indexSet: nil animation: animation];
	//[self _customRowEditingDelegate: DCCustomEditingTypeInsert anObject: cell atIndexPath: [NSIndexPath indexPathForRow: row inSection: section] withAnimation: animation];
}

- (void) detachRow: (NSIndexPath *) indexPath withAnimation: (UITableViewRowAnimation) animation {
	NSUInteger section = 0;
	NSUInteger row = 0;
	
	section = [indexPath section];
	row = [_tableGroups count] - 1;

	[self helpEditTableViewRows: DCCustomEditingTypeInsert anObject: nil indexPath: [NSIndexPath indexPathForRow: row inSection: section] indexSet: nil animation: animation];
	//[self _customRowEditingDelegate: DCCustomEditingTypeInsert anObject: nil atIndexPath: [NSIndexPath indexPathForRow: row inSection: section] withAnimation: animation];
}

- (void) insertRowAtIndexPath: (NSIndexPath *) indexPath withRow: (NSObject *) cell animation: (UITableViewRowAnimation) animation {
	[self helpEditTableViewRows: DCCustomEditingTypeInsert anObject: cell indexPath: indexPath indexSet: nil animation: animation];
	//[self _customRowEditingDelegate: DCCustomEditingTypeInsert anObject: cell atIndexPath: indexPath withAnimation: animation];
}

- (void) insertRowsAtIndexPaths: (NSArray *) indexPaths withRows: (NSArray *) cells animation: (UITableViewRowAnimation) animation {
	NSUInteger i = 0;
	
	for (i = 0;  i != [indexPaths count]; ++ i)
		[self helpEditTableViewRows: DCCustomEditingTypeInsertMultiple anObject: [cells objectAtIndex: i] indexPath: [indexPaths objectAtIndex: i] indexSet: nil animation: animation];
//		[self _customRowEditingDelegate: DCCustomEditingTypeInsertMultiple anObject: [cells objectAtIndex: i] atIndexPath: [indexPaths objectAtIndex: i] withAnimation: animation];
	
	[[self tableView] beginUpdates];
	[[self tableView] insertRowsAtIndexPaths: indexPaths withRowAnimation: animation];
	[[self tableView] endUpdates];
}

- (void) replaceRowAtIndexPath: (NSIndexPath *) indexPath withRow: (NSObject *) cell animation: (UITableViewRowAnimation) animation {
	[self helpEditTableViewRows: DCCustomEditingTypeReplace anObject: cell indexPath: indexPath indexSet: nil animation: animation];
	//[self _customRowEditingDelegate: DCCustomEditingTypeReplace anObject: cell atIndexPath: indexPath withAnimation: animation];
}

- (void) removeRowAtIndexPath: (NSIndexPath *) indexPath animation: (UITableViewRowAnimation) animation {
	[self helpEditTableViewRows: DCCustomEditingTypeRemove anObject: nil indexPath: indexPath indexSet: nil animation: animation];
	//[self _customRowEditingDelegate: DCCustomEditingTypeRemove anObject: nil atIndexPath: indexPath withAnimation: animation];
}

- (void) removeRowsAtIndexPaths: (NSArray *) indexPaths animation: (UITableViewRowAnimation) animation {
	NSUInteger i = 0;
	NSMutableIndexSet *indexSet = nil;
	NSUInteger section = 0;
	
	indexSet = [[NSMutableIndexSet alloc] init];
	section = [[indexPaths objectAtIndex: 0] section];
	
	for (i = 0;  i != [indexPaths count]; ++ i) {

		[indexSet addIndex: [[indexPaths objectAtIndex: i] row]];
		//[self helpEditTableViewRows: DCCustomEditingTypeRemoveMultiple anObject: nil indexPath: [indexPaths objectAtIndex: i] indexSet: nil animation: animation];
		//[self _customRowEditingDelegate: DCCustomEditingTypeRemoveMultiple anObject: nil atIndexPath: [indexPaths objectAtIndex: i] withAnimation: animation];
	}
	
	[self helpEditTableViewRows: DCCustomEditingTypeRemoveMultiple anObject: nil indexPath: [indexPaths lastObject] indexSet: indexSet animation: animation];
	
	[[self tableView] beginUpdates];
	[[self tableView] deleteRowsAtIndexPaths: indexPaths withRowAnimation: animation];
	[[self tableView] endUpdates];
}

- (void) _removeAllRowsExceptAtIndexPathDelegate: (DCCustomEditingType) action atIndexPath: (NSIndexPath *) indexPath withAnimation: (UITableViewRowAnimation) animation {
	if (!_tableGroups)
		[self init];
	
	NSMutableArray *section = nil;
	NSMutableArray *sections = nil;
	NSMutableArray *indexPathCollection = nil;
	NSMutableIndexSet *indexSet = nil;
	NSUInteger i = 0;
	NSUInteger limit = 0;
	NSUInteger exception = 0;
	NSUInteger sectionIndex = 0;
	
	indexPathCollection = [[NSMutableArray alloc] init];
	indexSet = [[NSMutableIndexSet alloc] init];
	sectionIndex = [indexPath section];
	exception = [indexPath row];
	section = [[_tableGroups objectAtIndex: [indexPath section]] mutableCopy];
	sections = [_tableGroups mutableCopy];
	limit = [section count];
	
	[[self tableView] setEditing: YES animated: YES];
	
	[[self tableView] beginUpdates];
	
	for (i = 0; i != limit; ++i) {
		if(i == exception)
			continue;
		
		[indexSet addIndex: i];
		
		[indexPathCollection addObject: [NSIndexPath indexPathForRow: i inSection: sectionIndex]];
	}
	
	if(action == DCCustomEditingTypeStore)
		[self _createStore: section withIndexPaths: indexPathCollection andIndexSet: indexSet];

	[[self tableView] deleteRowsAtIndexPaths: indexPathCollection withRowAnimation: animation];
	
	[section removeObjectsAtIndexes: indexSet];
	[sections replaceObjectAtIndex: sectionIndex withObject: section];
	
	SAFE_RELEASE(_tableGroups);
	
	_tableGroups = [[NSArray alloc] initWithArray: sections];
	
	SAFE_RELEASE(section);
	SAFE_RELEASE(sections);
	SAFE_RELEASE(indexPathCollection);
	SAFE_RELEASE(indexSet);
	
	[[self tableView] endUpdates];
	
	[[self tableView] setEditing: NO animated: NO];
	
}

- (void) removeAllRowsExceptAtIndexPath: (NSIndexPath *) indexPath animation: (UITableViewRowAnimation) animation {
	[self _removeAllRowsExceptAtIndexPathDelegate: DCCustomEditingTypeRemove atIndexPath: indexPath withAnimation: animation];
}

- (void) removeAllRowsTemporarilyExceptAtIndexPath: (NSIndexPath *) indexPath animation: (UITableViewRowAnimation) animation {
	[self _removeAllRowsExceptAtIndexPathDelegate: DCCustomEditingTypeStore atIndexPath: indexPath withAnimation: animation];
}

- (void) recallRowsWithAnimation: (UITableViewRowAnimation) animation; {
	//If there is only one row in one section, do this
	if(![_temporaryIndexPaths count] && [_tableGroups count] == 1 && [[_tableGroups objectAtIndex: 0] count] == 1)
		//[self _customRowEditingDelegate: DCCustomEditingTypeRecall anObject: nil atIndexPath: [NSIndexPath indexPathForRow: 0 inSection: 0] withAnimation: animation];
		[self helpEditTableViewRows: DCCustomEditingTypeRecall anObject: nil indexPath: [NSIndexPath indexPathForRow: 0 inSection: 0] indexSet: nil animation: animation];
	else
		[self helpEditTableViewRows: DCCustomEditingTypeRecall anObject: nil indexPath: [_temporaryIndexPaths objectAtIndex: 0] indexSet: nil animation: animation];
		//[self _customRowEditingDelegate: DCCustomEditingTypeRecall anObject: nil atIndexPath: [_temporaryIndexPaths objectAtIndex: 0] withAnimation: animation];
}

/** Custom Section Editing **/

- (void) pushSection: (NSArray *) aTableGroup withAnimation: (UITableViewRowAnimation) animation {
	NSUInteger index = 0;

	[self  _customSectionEditingDelegate: DCCustomEditingTypeInsert anObject: aTableGroup atIndex: index withAnimation: animation];
	
}

- (void) popSection: (UITableViewRowAnimation) animation {
	NSUInteger index = 0;
		
	[self  _customSectionEditingDelegate: DCCustomEditingTypeRemove anObject: nil atIndex: index withAnimation: animation];
}


- (void) attachSection: (NSArray *) aTableGroup withAnimation: (UITableViewRowAnimation) animation {
	NSUInteger index = 0;
	
	index = [_tableGroups count];
	
	[self  _customSectionEditingDelegate: DCCustomEditingTypeInsert anObject: aTableGroup atIndex: index withAnimation: animation];

}

- (void) detachSection: (UITableViewRowAnimation) animation {
	NSUInteger index = 0;
	
	index = [_tableGroups count] - 1;
	
	[self  _customSectionEditingDelegate: DCCustomEditingTypeRemove anObject: nil atIndex: index withAnimation: animation];
}

- (void) replaceSectionAtIndex: (NSUInteger) index withTableGroup: (NSArray *) aTableGroup animation: (UITableViewRowAnimation) animation {	
	[self  _customSectionEditingDelegate: DCCustomEditingTypeReplace anObject: aTableGroup atIndex: index withAnimation: animation];
}

- (void) removeSectionAtIndex: (NSUInteger) index withAnimation: (UITableViewRowAnimation) animation {
	[self _customSectionEditingDelegate: DCCustomEditingTypeRemove anObject: nil atIndex: index withAnimation: animation];
}

- (void) removeAllSectionsExceptAtIndex: (NSUInteger) index withAnimation: (UITableViewRowAnimation) animation {
	[self _removeAllSectionsExceptAtIndexDelegate: DCCustomEditingTypeRemove atIndex: index withAnimation: animation];
}

- (void) removeAllSectionsTemporarilyExceptAtIndex: (NSUInteger) index withAnimation: (UITableViewRowAnimation) animation {
	[self _removeAllSectionsExceptAtIndexDelegate: DCCustomEditingTypeStore atIndex: index withAnimation: animation];
}

- (void) recallSectionsWithAnimation: (UITableViewRowAnimation) animation {
	[self _updateAndReload];
	[[self tableView] reloadSections: _temporaryIndexSet withRowAnimation: animation];
}

#pragma mark -
#pragma mark Getters and Setters
- (NSArray *) tableGroups {
	return _tableGroups;
}

- (void) setTableGroups: (NSArray *) tableGroups {
	if(!tableGroups)
		return;
	
	_tableGroups = [tableGroups retain];
}

#pragma mark UITableViewDataSource
- (UITableViewCell *) tableView:(UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath {
	if (!_tableGroups)
		[self init];
	
	return [[[_tableGroups objectAtIndex: [indexPath section]] objectAtIndex: [indexPath row]] tableView: (UITableView *) tableView cellForRowAtIndexPath: indexPath];
}

- (BOOL) tableView: (UITableView *) tableView canEditRowAtIndexPath: (NSIndexPath *) indexPath {
	if (!_tableGroups)
		[self init];
	
	NSObject <DCTableViewCellControllerDelegate> *cell = nil;
		
	cell = [[_tableGroups objectAtIndex: [indexPath section]] objectAtIndex: [indexPath row]];
	
	//If the cell controller has this method defined, execute it
	if ([cell respondsToSelector:@selector(tableView: canEditRowAtIndexPath:)])
		return [cell tableView: tableView canEditRowAtIndexPath: indexPath];
	
	return NO;
}

- (void) tableView: (UITableView *) tableView commitEditingStyle: (UITableViewCellEditingStyle) editingStyle forRowAtIndexPath: (NSIndexPath *) indexPath {
	if (!_tableGroups)
		[self init];
	
	NSObject <DCTableViewCellControllerDelegate> *cell = nil;
	
	cell = [[_tableGroups objectAtIndex: [indexPath section]] objectAtIndex: [indexPath row]];
	
	//If the cell controller has this method defined, execute it
	if ([cell respondsToSelector:@selector(tableView: commitEditingStyle: forRowAtIndexPath:)])
		[cell tableView: tableView commitEditingStyle: editingStyle forRowAtIndexPath: indexPath];
}

#pragma mark UITableViewDelegate
- (NSString *) tableView: (UITableView *) tableView titleForHeaderInSection: (NSInteger) section {
	if (!_tableGroups)
		[self init];
	
	NSObject <DCTableViewCellControllerDelegate> *cell = nil;
	
	cell = [[_tableGroups objectAtIndex: section] objectAtIndex: 0];
	
	//If the cell controller has this method defined, execute it
	if ([cell respondsToSelector:@selector(tableView: titleForHeaderInSection:)])
		return [cell tableView:tableView titleForHeaderInSection: section];
	
	return nil;
}

- (UIView *) tableView: (UITableView *) tableView viewForHeaderInSection: (NSInteger) section {
	if (!_tableGroups)
		[self init];
	
	NSObject <DCTableViewCellControllerDelegate> *cell = nil;
	
	cell = [[_tableGroups objectAtIndex: section] objectAtIndex: 0];
	
	//If the cell controller has this method defined, execute it
	if ([cell respondsToSelector:@selector(tableView: viewForHeaderInSection:)])
		return [cell tableView: tableView viewForHeaderInSection: section];
	
	return nil;
}

- (NSString *) tableView: (UITableView *) tableView titleForFooterInSection: (NSInteger) section {
	if (!_tableGroups)
		[self init];
	
	NSObject <DCTableViewCellControllerDelegate> *cell = nil;
	
	cell = [[_tableGroups objectAtIndex: section] objectAtIndex: 0];
	
	//If the cell controller has this method defined, execute it
	if ([cell respondsToSelector:@selector(tableView: titleForFooterInSection:)])
		return [cell tableView:tableView titleForFooterInSection: section];
	
	return nil;
}

- (UIView *) tableView: (UITableView *) tableView viewForFooterInSection:(NSInteger) section {
	if (!_tableGroups)
		[self init];
	
	NSObject <DCTableViewCellControllerDelegate> *cell = nil;
	
	cell = [[_tableGroups objectAtIndex: section] objectAtIndex: 0];
	
	//If the cell controller has this method defined, execute it
	if ([cell respondsToSelector:@selector(tableView: viewForFooterInSection:)])
		return [cell tableView: tableView viewForFooterInSection: section];
	
	return nil;
}

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView {
	if (![_tableGroups isKindOfClass: [NSArray class]])
		[self init];
	
	return [_tableGroups count];
}


- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section {
	if (!_tableGroups)
		[self init];
	
	NSUInteger rowCount = [[_tableGroups objectAtIndex:section] count];
	
	return rowCount;
}

- (void) tableView: (UITableView *) tableView willDisplayCell: (UITableViewCell *) cell forRowAtIndexPath: (NSIndexPath *) indexPath {
	if (!_tableGroups)
		[self init];
	
	NSObject <DCTableViewCellControllerDelegate> *aCell = nil;
	
	aCell = [[_tableGroups objectAtIndex: [indexPath section]] objectAtIndex: [indexPath row]];
	
	//If the cell controller has this method defined, execute it
	if ([aCell respondsToSelector:@selector(tableView: willDisplayCell: forRowAtIndexPath:)])
		[aCell tableView: tableView willDisplayCell: cell forRowAtIndexPath: indexPath];
}

- (CGFloat) tableView: (UITableView *) tableView heightForHeaderInSection: (NSInteger) section {
	if (!_tableGroups)
		[self init];
	
	NSObject <DCTableViewCellControllerDelegate> *cell = nil;
	
	cell = [[_tableGroups objectAtIndex: section] objectAtIndex: 0];
	
	//If the cell controller has this method defined, execute it
	if ([cell respondsToSelector:@selector(tableView: heightForHeaderInSection:)])
		return [cell tableView: tableView heightForHeaderInSection: section];
	
	return 10.0;
}

- (CGFloat) tableView: (UITableView *) tableView heightForFooterInSection: (NSInteger) section {
	if (!_tableGroups)
		[self init];
	
	NSObject <DCTableViewCellControllerDelegate> *cell = nil;
	
	cell = [[_tableGroups objectAtIndex: section] objectAtIndex: 0];
	
	//If the cell controller has this method defined, execute it
	if ([cell respondsToSelector:@selector(tableView: heightForFooterInSection:)])
		return [cell tableView:tableView heightForFooterInSection: section];
	
	return 10.0;
}

- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath {
	if (!_tableGroups)
		[self init];
	
	NSObject <DCTableViewCellControllerDelegate> *cell = nil;
	
	cell = [[_tableGroups objectAtIndex: [indexPath section]] objectAtIndex: [indexPath row]];
	
	//If the cell controller has this method defined, execute it
	if ([cell respondsToSelector:@selector(tableView: heightForRowAtIndexPath:)])
		return [cell tableView:tableView heightForRowAtIndexPath: indexPath];
	
	return 50;
}

- (NSInteger) tableView: (UITableView *) tableView indentationLevelForRowAtIndexPath: (NSIndexPath *) indexPath {
	if (!_tableGroups)
		[self init];
	
	NSObject <DCTableViewCellControllerDelegate> *cell = nil;
	
	cell = [[_tableGroups objectAtIndex: [indexPath section]] objectAtIndex: [indexPath row]];
	
	//If the cell controller has this method defined, execute it
	if ([cell respondsToSelector:@selector(tableView: indentationLevelForRowAtIndexPath:)])
		return [cell tableView:tableView indentationLevelForRowAtIndexPath: indexPath];
	
	return 0;
}


/** Selection **/
- (NSIndexPath *) tableView: (UITableView *) tableView willSelectRowAtIndexPath: (NSIndexPath *) indexPath {
	if (!_tableGroups)
		[self init];
	
	NSObject <DCTableViewCellControllerDelegate> *cell = nil;
	
	cell = [[_tableGroups objectAtIndex: [indexPath section]] objectAtIndex: [indexPath row]];
	
	//If the cell controller has this method defined, execute it
	if ([cell respondsToSelector:@selector(tableView: willSelectRowAtIndexPath:)])
		return [cell tableView:tableView willSelectRowAtIndexPath: indexPath];
	
	return indexPath;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
	if (!_tableGroups)
		[self init];
	
	NSObject <DCTableViewCellControllerDelegate> *cell = nil;
	
	cell = [[_tableGroups objectAtIndex: [indexPath section]] objectAtIndex: [indexPath row]];
	
	//If the cell controller has this method defined, execute it
	if ([cell respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)])
		[cell tableView:tableView didSelectRowAtIndexPath: indexPath];
}

- (NSIndexPath *) tableView: (UITableView *) tableView willDeselectRowAtIndexPath: (NSIndexPath *) indexPath {
	if (!_tableGroups)
		[self init];
	
	NSObject <DCTableViewCellControllerDelegate> *cell = nil;
	
	cell = [[_tableGroups objectAtIndex: [indexPath section]] objectAtIndex: [indexPath row]];
	
	//If the cell controller has this method defined, execute it
	if ([cell respondsToSelector:@selector(tableView: willDeselectRowAtIndexPath:)])
		return [cell tableView:tableView willDeselectRowAtIndexPath: indexPath];
	
	return indexPath;
}

- (void) tableView: (UITableView *) tableView didDeselectRowAtIndexPath: (NSIndexPath *) indexPath {
	if (!_tableGroups)
		[self init];
	
	NSObject <DCTableViewCellControllerDelegate> *cell = nil;
	
	cell = [[_tableGroups objectAtIndex: [indexPath section]] objectAtIndex: [indexPath row]];
	
	//If the cell controller has this method defined, execute it
	if ([cell respondsToSelector:@selector(tableView:didDeselectRowAtIndexPath:)])
		[cell tableView:tableView didDeselectRowAtIndexPath: indexPath];
}

- (void) tableView: (UITableView *) tableView accessoryButtonTappedForRowWithIndexPath: (NSIndexPath *) indexPath {
	if (!_tableGroups)
		[self init];
	
	NSObject <DCTableViewCellControllerDelegate> *cell = nil;
	
	cell = [[_tableGroups objectAtIndex: [indexPath section]] objectAtIndex: [indexPath row]];
	
	//If the cell controller has this method defined, execute it
	if ([cell respondsToSelector:@selector(tableView: accessoryButtonTappedForRowWithIndexPath:)])
		[cell tableView:tableView accessoryButtonTappedForRowWithIndexPath: indexPath];
}

/** Editing **/
// Allows customization of the editingStyle for a particular cell located at 'indexPath'.
//If not implemented, all editable cells will have UITableViewCellEditingStyleDelete
//set for them when the table has editing property set to YES.
- (UITableViewCellEditingStyle) tableView:(UITableView *) tableView editingStyleForRowAtIndexPath: (NSIndexPath *) indexPath {
	if (!_tableGroups)
		[self init];
	
	NSObject <DCTableViewCellControllerDelegate> *cell = nil;
	
	cell = [[_tableGroups objectAtIndex: [indexPath section]] objectAtIndex: [indexPath row]];
	
	//If the cell controller has this method defined, execute it
	if ([cell respondsToSelector:@selector(tableView: editingStyleForRowAtIndexPath:)])
		return [cell tableView:tableView editingStyleForRowAtIndexPath: indexPath];
	
	return UITableViewCellEditingStyleNone;
}

- (NSString *) tableView: (UITableView *) tableView titleForDeleteConfirmationButtonForRowAtIndexPath: (NSIndexPath *) indexPath {
	if (!_tableGroups)
		[self init];
	
	NSObject <DCTableViewCellControllerDelegate> *cell = nil;
	
	cell = [[_tableGroups objectAtIndex: [indexPath section]] objectAtIndex: [indexPath row]];
	
	//If the cell controller has this method defined, execute it
	if ([cell respondsToSelector:@selector(tableView: titleForDeleteConfirmationButtonForRowAtIndexPath:)])
		return [cell tableView:tableView titleForDeleteConfirmationButtonForRowAtIndexPath: indexPath];
	
	return nil;
}

// Controls whether the background is indented while editing.  If not implemented, the default is YES.
//This is unrelated to the indentation level below.  This method only applies to grouped style table views.
- (BOOL) tableView: (UITableView *) tableView shouldIndentWhileEditingRowAtIndexPath: (NSIndexPath *) indexPath {
	if (!_tableGroups)
		[self init];
	
	NSObject <DCTableViewCellControllerDelegate> *cell = nil;
	
	cell = [[_tableGroups objectAtIndex: [indexPath section]] objectAtIndex: [indexPath row]];
	
	//If the cell controller has this method defined, execute it
	if ([cell respondsToSelector:@selector(tableView: shouldIndentWhileEditingRowAtIndexPath:)])
		return [cell tableView:tableView shouldIndentWhileEditingRowAtIndexPath: indexPath];
	
	return NO;
}

// The willBegin/didEnd methods are called whenever the 'editing' property is automatically changed by the table (allowing insert/delete/move). This is done by a swipe activating a single row
- (void) tableView: (UITableView*) tableView willBeginEditingRowAtIndexPath: (NSIndexPath *) indexPath {
	if (!_tableGroups)
		[self init];
	
	NSObject <DCTableViewCellControllerDelegate> *cell = nil;
	
	cell = [[_tableGroups objectAtIndex: [indexPath section]] objectAtIndex: [indexPath row]];
	
	//If the cell controller has this method defined, execute it
	if ([cell respondsToSelector:@selector(tableView: willBeginEditingRowAtIndexPath:)])
		[cell tableView:tableView willBeginEditingRowAtIndexPath: indexPath];
}

- (void) tableView: (UITableView*) tableView didEndEditingRowAtIndexPath: (NSIndexPath *) indexPath {
	if (!_tableGroups)
		[self init];
	
	NSObject <DCTableViewCellControllerDelegate> *cell = nil;
	
	cell = [[_tableGroups objectAtIndex: [indexPath section]] objectAtIndex: [indexPath row]];
	
	//If the cell controller has this method defined, execute it
	if ([cell respondsToSelector:@selector(tableView: didEndEditingRowAtIndexPath:)])
		[cell tableView:tableView didEndEditingRowAtIndexPath: indexPath];
}

@end

