//
//  DCSearchDisplayControllerDelegate.h
//  DeliOrder
//
//  Created by Jeffrey Kereakoglow on 2/18/10.
//  Copyright 2010 Droste Consultants, Inc.. All rights reserved.
//

@protocol DCSearchDisplayControllerDelegate

@required
#pragma mark UITableViewDataSource
- (UITableViewCell *) tableView:(UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath;

@optional
#pragma mark UITableViewDataSource
- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section;

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;              // Default is 1 if not implemented

- (NSString *) tableView: (UITableView *) tableView titleForHeaderInSection: (NSInteger) section;    // fixed font style. use custom view (UILabel) if you want something different
- (NSString *) tableView: (UITableView *) tableView titleForFooterInSection: (NSInteger) section;

// Editing

// Individual rows can opt out of having the -editing property set for them. If not implemented, all rows are assumed to be editable.
- (BOOL) tableView: (UITableView *) tableView canEditRowAtIndexPath: (NSIndexPath *) indexPath;

// Moving/reordering

// Allows the reorder accessory view to optionally be shown for a particular row. By default, the reorder control will be shown only if the datasource implements -tableView:moveRowAtIndexPath:toIndexPath:
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath;

// Index

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView;                                                    // return list of section titles to display in section index view (e.g. "ABCD...Z#")
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index;  // tell table which section corresponds to section title/index (e.g. "B",1))

// Data manipulation - insert and delete support

// After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;

// Data manipulation - reorder / moving support

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath;

#pragma mark UITableViewDelegate
// Display customization

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

// Variable height support

- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath;
- (CGFloat) tableView: (UITableView *) tableView heightForHeaderInSection: (NSInteger) section;
- (CGFloat) tableView: (UITableView *) tableView heightForFooterInSection: (NSInteger) section;

// Section header & footer information. Views are preferred over title should you decide to provide both

- (UIView *) tableView: (UITableView *) tableView viewForHeaderInSection: (NSInteger) section;   // custom view for header. will be adjusted to default or specified header height
- (UIView *) tableView: (UITableView *) tableView viewForFooterInSection: (NSInteger) section;   // custom view for footer. will be adjusted to default or specified footer height

// Accessories (disclosures). 

- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath __OSX_AVAILABLE_BUT_DEPRECATED(__MAC_NA,__MAC_NA,__IPHONE_2_0,__IPHONE_3_0);
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath;

// Selection

// Called before the user changes the selection. Return a new indexPath, or nil, to change the proposed selection.
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_0);
// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_0);

// Editing

// Allows customization of the editingStyle for a particular cell located at 'indexPath'. If not implemented, all editable cells will have UITableViewCellEditingStyleDelete set for them when the table has editing property set to YES.
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_0);

// Controls whether the background is indented while editing.  If not implemented, the default is YES.  This is unrelated to the indentation level below.  This method only applies to grouped style table views.
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath;

// The willBegin/didEnd methods are called whenever the 'editing' property is automatically changed by the table (allowing insert/delete/move). This is done by a swipe activating a single row
- (void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath;

// Moving/reordering

// Allows customization of the target row for a particular row as it is being moved/reordered
- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath;               

// Indentation

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath; // return 'depth' of row for hierarchies

#pragma mark UISearchBarDelegate
//Scope
- (void) searchBar: (UISearchBar *) searchBar selectedScopeButtonIndexDidChange: (NSInteger) selectedScope;

//Buttons
- (void) searchBarBookmarkButtonClicked: (UISearchBar *) searchBar;
- (void) searchBarCancelButtonClicked: (UISearchBar *) searchBar;
- (void) searchBarSearchButtonClicked: (UISearchBar *) searchBar;

//Editing
- (void) searchBar: (UISearchBar *) searchBar textDidChange: (NSString *) searchText;
- (BOOL) searchBarShouldBeginEditing: (UISearchBar *) searchBar;
- (BOOL) searchBarShouldEndEditing: (UISearchBar *) searchBar;
- (void) searchBarTextDidBeginEditing: (UISearchBar *) searchBar;
- (void) searchBarTextDidEndEditing: (UISearchBar *) searchBar;

#pragma mark UISearchDisplayController
// when we start/end showing the search UI
- (void) searchDisplayControllerWillBeginSearch: (UISearchDisplayController *) controller;
- (void) searchDisplayControllerDidBeginSearch: (UISearchDisplayController *) controller;
- (void) searchDisplayControllerWillEndSearch: (UISearchDisplayController *) controller;
- (void) searchDisplayControllerDidEndSearch: (UISearchDisplayController *) controller;

// called when the table is created destroyed, shown or hidden. configure as necessary.
- (void) searchDisplayController: (UISearchDisplayController *) controller didLoadSearchResultsTableView: (UITableView *) tableView;
- (void) searchDisplayController: (UISearchDisplayController *) controller willUnloadSearchResultsTableView: (UITableView *) tableView;

// called when table is shown/hidden
- (void) searchDisplayController: (UISearchDisplayController *) controller willShowSearchResultsTableView: (UITableView *) tableView;
- (void) searchDisplayController: (UISearchDisplayController *) controller didShowSearchResultsTableView: (UITableView *) tableView;
- (void) searchDisplayController: (UISearchDisplayController *) controller willHideSearchResultsTableView: (UITableView *) tableView;
- (void) searchDisplayController: (UISearchDisplayController *) controller didHideSearchResultsTableView: (UITableView *) tableView;

// return YES to reload table. called when search string/option changes. convenience methods on top UISearchBar delegate methods
- (BOOL) searchDisplayController: (UISearchDisplayController *) controller shouldReloadTableForSearchString: (NSString *) searchString;
- (BOOL) searchDisplayController: (UISearchDisplayController *) controller shouldReloadTableForSearchScope: (NSInteger) searchOption;

@end
