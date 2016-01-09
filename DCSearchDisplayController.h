//
//  DCSearchDisplayController.h
//  DeliOrder
//
//  Created by Jeffrey Kereakoglow on 2/18/10.
//  Copyright 2010 Droste Consultants, Inc.. All rights reserved.
//
//	Description: The purpose of this class is to add separation between the
//	controller of the table view and the controller of the cell.
//	
//	This is identical to DCTableViewController expect that it adopts
//	the UISearchBarDelegate, UISearchDisplayDelegate and will only show one
//	UITableViewCell type at a time. Because of this, it was decided not to make
//	this class a subclass of DCTableViewController as all of the properties and
//	all of the custom-built functions could not be used.
//
//	This class allows the programmer to define a table-view controller as a
//	subclass of this class, and create a subclass of NSObject as a cell controller.
//
//	Usage: Subclass DCSearchDisplayController and override either init or 
//	initWithIndexPath and build an array of CellControllers--subclasses of 
//	NSObject which conform to the protocol DCSearchDisplayControllerDelegate--and 
//	assign that array to the _searchDisplayControllerCells property. 
//

#import <Foundation/Foundation.h>
#import "DCTableViewController.h"
#import "DCSearchDisplayControllerDelegate.h"
#import "DCProtocol.h"
#import "DCMacro.h"

@interface DCSearchDisplayController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate> {
@protected	
	NSArray *_searchDisplayControllerCells;
}


@end
