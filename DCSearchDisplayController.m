//
//  DCSearchDisplayController.m
//  DeliOrder
//
//  Created by Jeffrey Kereakoglow on 2/18/10.
//  Copyright 2010 Droste Consultants, Inc.. All rights reserved.
//

#import "DCSearchDisplayController.h"

@implementation DCSearchDisplayController

- (id) init {
	self = [super init];
	
	if (self != nil)
		return nil;
	
	_searchDisplayControllerCells = nil;
	
	return self;
}

#pragma mark UITableViewDataSource
- (UITableViewCell *) tableView:(UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath {
	if (!_searchDisplayControllerCells)
		[self init];
	
	NSObject <DCSearchDisplayControllerDelegate> *searchController;
	
	searchController = [_searchDisplayControllerCells objectAtIndex: [indexPath section]];
	
	if ([searchController respondsToSelector:@selector(tableView: cellForRowAtIndexPath:)])
		return [searchController tableView: tableView cellForRowAtIndexPath: indexPath];
	
	return nil;
	
}

#pragma mark UITableViewDelegate
- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section {
	if (!_searchDisplayControllerCells)
		[self init];
	
	return [_searchDisplayControllerCells count];
}

- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath {
	if (!_searchDisplayControllerCells)
		[self init];
	
	NSObject <DCSearchDisplayControllerDelegate> *searchController;
	
	searchController = [_searchDisplayControllerCells objectAtIndex: [indexPath section]];
	
	if ([searchController respondsToSelector:@selector(tableView: heightForRowAtIndexPath:)])
		return [searchController tableView: tableView heightForRowAtIndexPath: indexPath];
	
	return 64;
}

#pragma mark UISearchBarDelegate
//Scope
- (void) searchBar: (UISearchBar *) searchBar selectedScopeButtonIndexDidChange: (NSInteger) selectedScope {
}

//Buttons
- (void) searchBarBookmarkButtonClicked: (UISearchBar *) searchBar {
}

- (void) searchBarCancelButtonClicked: (UISearchBar *) searchBar {
}

- (void) searchBarSearchButtonClicked: (UISearchBar *) searchBar {
}


//Editing
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *) searchText {
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *) searchBar {
	return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *) searchBar {
	return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *) searchBar {
}

- (void)searchBarTextDidEndEditing:(UISearchBar *) searchBar {
}

#pragma mark UISearchDisplayController
// when we start/end showing the search UI
- (void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
}
- (void) searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
}
- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
}
- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
}

// called when the table is created destroyed, shown or hidden. configure as necessary.
- (void) searchDisplayController: (UISearchDisplayController *) controller didLoadSearchResultsTableView: (UITableView *) tableView {
	if (!_searchDisplayControllerCells)
		[self init];
	
	NSObject <DCSearchDisplayControllerDelegate> *display;
	
	display = [_searchDisplayControllerCells objectAtIndex: 0];
	
	//If the cell controller has this method defined, execute it
	if ([display respondsToSelector:@selector(searchDisplayController: didLoadSearchResultsTableView:)])
		[display searchDisplayController: controller didLoadSearchResultsTableView: tableView];
}
- (void) searchDisplayController: (UISearchDisplayController *) controller willUnloadSearchResultsTableView: (UITableView *) tableView {
	if (!_searchDisplayControllerCells)
		[self init];
	
	NSObject <DCSearchDisplayControllerDelegate> *display;
	
	display = [_searchDisplayControllerCells objectAtIndex: 0];
	
	//If the cell controller has this method defined, execute it
	if ([display respondsToSelector:@selector(searchDisplayController: willUnloadSearchResultsTableView:)])
		[display searchDisplayController: controller willUnloadSearchResultsTableView: tableView];
}

// called when table is shown/hidden
- (void) searchDisplayController:(UISearchDisplayController *) controller willShowSearchResultsTableView:(UITableView *) tableView {
}

- (void)searchDisplayController:(UISearchDisplayController *) controller didShowSearchResultsTableView:(UITableView *) tableView {
}

- (void)searchDisplayController:(UISearchDisplayController *) controller willHideSearchResultsTableView:(UITableView *) tableView {
}

- (void)searchDisplayController:(UISearchDisplayController *) controller didHideSearchResultsTableView:(UITableView *) tableView {
}

// return YES to reload table. called when search string/option changes. convenience methods on top UISearchBar delegate methods
- (BOOL) searchDisplayController: (UISearchDisplayController *) controller shouldReloadTableForSearchString:(NSString *) searchString {
	if (!_searchDisplayControllerCells)
		[self init];
	
	NSObject <DCSearchDisplayControllerDelegate> *display;
	
	display = [_searchDisplayControllerCells objectAtIndex: 0];
	
	//If the cell controller has this method defined, execute it
	if ([display respondsToSelector:@selector(searchDisplayController: shouldReloadTableForSearchString:)])
		return [display searchDisplayController: controller shouldReloadTableForSearchString: searchString];
	
	return NO;
}

- (BOOL) searchDisplayController: (UISearchDisplayController *) controller shouldReloadTableForSearchScope: (NSInteger) searchOption {
	if (!_searchDisplayControllerCells)
		[self init];
	
	NSObject <DCSearchDisplayControllerDelegate> *display;
	
	display = [_searchDisplayControllerCells objectAtIndex: 0];
	
	//If the cell controller has this method defined, execute it
	if ([display respondsToSelector:@selector(searchDisplayController: shouldReloadTableForSearchScope:)])
		return [display searchDisplayController: controller shouldReloadTableForSearchScope: searchOption];
	
	return NO;
}

@end
