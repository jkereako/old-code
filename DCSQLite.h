//
//  DCSQLLite.h
//  DeliOrder
//
//  Created by Jeffrey Kereakoglow on 2/25/10.
//  Copyright 2010 Droste Consultants, Inc.. All rights reserved.
//
//	Description: A singleton class, provides a global interface for database of
//	app and act as an interface for the FMDB wrapper class. Here, the programmer
//	can send execute SQL without having to know the FMDB class.
//
//	Some utility functions are included in this class, such as SQL building,
//	which is intended to save time instead of writing out SQL.
//
//	Also, this class is support KVO where the data model is KVC compliant. The
//	datamodel must also define a property as defined by the constant in this class.
//
//	If using KVC, update cannot be used, only insert and delete.

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "DCMacro.h"
#import "DCProtocol.h"

#define SET_DATA_MODEL(__DM) {[[DCSQLite sharedDCSQLite] setDataModel: [[DataModel sharedDataModel] __DM]]; \
[[DCSQLite sharedDCSQLite] createDatabase]; \
[[DCSQLite sharedDCSQLite] createTable]; }

extern const NSString *kColumnNameKey;
extern const NSString *kColumnValueKey;
extern const NSString *kColumnOmitIfEmptyKey;
extern const NSString *kColumnTypeKey;
extern const NSString *kColumnDefaultValue;
extern const NSString *kColumnNotNullKey;
extern const NSString *kColumnPrimaryKeyKey;

//KVO
extern const NSString *kTableNameKey;
extern const NSString *kCommitUpdateToTableKey;
extern const NSString *kCommitUpdateKey;

@class FMDatabase, DataModel;
@interface DCSQLite : NSObject {
@private
	FMDatabase *_database;
	id _dataModel;
	NSMutableDictionary *_changedValues;
	NSArray *_dataModelKeys;
	BOOL _inTransaction;
	NSString *_whereClause;
	NSString *_groupByClause;
	NSString *_havingClause;
	NSString *_orderByList;
	NSMutableString *_sql;
	
@public
	BOOL shouldOverwriteExistingDatabase;
}
@property (nonatomic, copy, getter=sql, setter=setSQL) NSString *_sql;
@property (nonatomic, copy, getter=where, setter=setWhere) NSString * _whereClause;
@property (nonatomic, copy, getter=groupBy, setter=setGroupBy) NSString * _groupByClause;
@property (nonatomic, copy, getter=having, setter=setHaving) NSString * _havingClause;
@property (nonatomic, copy, getter=orderBy, setter=orderBy) NSString * _orderByList;
@property (assign) BOOL shouldOverwriteExistingDatabase;

+ (DCSQLite *) sharedDCSQLite;

- (void) setDataModel: (NSDictionary *) dataModel;
- (void) setDataModel: (id) kvcObject keys: (NSArray *) keys;
- (id) dataModel;
- (BOOL) executeSQL;
- (void) createDatabaseWithName: (NSString *) databaseName;
- (void) createTableWithName: (NSString *) tableName fields: (NSArray *) fields;
- (BOOL) createForeignKeyOnField: (NSString *) fieldName ofTable: (NSString *) tableName foreignKey: (NSString *) fkField foreignTable: (NSString *) fkTableName;

- (NSString *) buildSQLInsert: (NSArray *) fieldsAndValues table: (NSString *) tableName;
- (NSString *) buildSQLDelete: (NSString *) tableName where: (NSString *) whereClause;
- (NSString *) buildSQLUpdate: (NSArray *) fieldsAndValues table: (NSString *) tableName where: (NSString *) whereClause;

- (NSString *) buildSQLSelect: (NSString *) selectStatement table: (NSString *) tableName where: (NSString *) whereClause orderBy: (NSString *) orderBy;
- (NSString *) buildSQLSelect: (NSString *) selectStatement table: (NSString *) tableName groupBy: (NSString *) groupByClause having: (NSString *) havingClause orderBy: (NSString *) orderBy;
- (NSString *) buildSQLSelect: (NSString *) selectStatement table: (NSString *) tableName where: (NSString *) whereClause groupBy: (NSString *) groupByClause having: (NSString *) havingClause orderBy: (NSString *) orderBy;

- (NSString *) buildWhereClauseWithCollection: (NSDictionary *) collection comparisonOperator: (NSString *) operator conjoinedBy: (NSString *) andOr;
- (NSString *) _toSQL: (id) value;

- (NSUInteger) fieldCountForTable: (NSString *) tableName;
- (NSUInteger) recordCountForTable: (NSString *) tableName;
- (NSString *) primaryKeyFieldNameForTable: (NSString *) tableName;

- (NSString *) stringForSQLQuery: (NSString *) selectStatement fromTable: (NSString *) tableName where: (NSString *) whereClause;
- (NSString *) stringForSQLQuery: (NSString *) selectStatement fromTable: (NSString *) tableName groupBy: (NSString *) groupByClause having: (NSString *) havingClause;
- (NSString *) stringForSQLQuery: (NSString *) selectStatement fromTable: (NSString *) tableName where: (NSString *) whereClause groupBy: (NSString *) groupByClause having: (NSString *) havingClause;

- (NSNumber *) numberForSQLQuery: (NSString *) selectStatement fromTable: (NSString *) tableName where: (NSString *) whereClause;
- (NSNumber *) numberForSQLQuery: (NSString *) selectStatement fromTable: (NSString *) tableName groupBy: (NSString *) groupByClause having: (NSString *) havingClause;
- (NSNumber *) numberForSQLQuery: (NSString *) selectStatement fromTable: (NSString *) tableName where: (NSString *) whereClause groupBy: (NSString *) groupByClause having: (NSString *) havingClause;

- (NSArray *) resultSetForSQLQuery: (NSString *) selectStatement fromTable: (NSString *) tableName where: (NSString *) whereClause orderBy: (NSString *) orderBy;
- (NSArray *) resultSetForSQLQuery: (NSString *) selectStatement fromTable: (NSString *) tableName groupBy: (NSString *) groupByClause having: (NSString *) havingClause orderBy: (NSString *) orderBy;
- (NSArray *) resultSetForSQLQuery: (NSString *) selectStatement fromTable: (NSString *) tableName where: (NSString *) whereClause groupBy: (NSString *) groupByClause having: (NSString *) havingClause orderBy: (NSString *) orderBy;

- (void) beginInsert;
- (void) endInsert;
- (void) beginUpdate;
- (void) endUpdate;
- (void) beginDelete;
- (void) endDelete;

- (void) _beginOperation;
- (void) _endOperation;
- (void) createDatabase;		//Creates database using the app name
- (BOOL) createTable;		//Creates a table using the data model class name
- (BOOL) duplicateRows;
- (BOOL) insert;				//Uses current data model values
- (BOOL) update;
- (BOOL) delete;				//Uses current data model values as an AND filter

- (NSUInteger) recordCount;
- (NSUInteger) fieldCount;
- (NSString *) primaryKeyFieldName;		//The primary key field name is generated by this class
- (BOOL) tableExists: (NSString *) tableName;
- (void) reseedAutoIncrementFieldForTable: (NSString *) tableName;

- (NSString *) stringForSQLQuery: (NSString *) selectStatement where: (NSString *) whereClause;
- (NSString *) stringForSQLQuery: (NSString *) selectStatement groupBy: (NSString *) groupByClause having: (NSString *) havingClause;
- (NSString *) stringForSQLQuery: (NSString *) selectStatement where: (NSString *) whereClause groupBy: (NSString *) groupByClause having: (NSString *) havingClause;

- (NSNumber *) numberForSQLQuery: (NSString *) selectStatement where: (NSString *) whereClause;
- (NSNumber *) numberForSQLQuery: (NSString *) selectStatement groupBy: (NSString *) groupByClause having: (NSString *) havingClause;
- (NSNumber *) numberForSQLQuery: (NSString *) selectStatement where: (NSString *) whereClause groupBy: (NSString *) groupByClause having: (NSString *) havingClause;

- (NSArray *) resultSetForSQLQuery: (NSString *) selectStatement where: (NSString *) whereClause orderBy: (NSString *) orderBy;
- (NSArray *) resultSetForSQLQuery: (NSString *) selectStatement groupBy: (NSString *) groupByClause having: (NSString *) havingClause orderBy: (NSString *) orderBy;
- (NSArray *) resultSetForSQLQuery: (NSString *) selectStatement where: (NSString *) whereClause groupBy: (NSString *) groupByClause having: (NSString *) havingClause orderBy: (NSString *) orderBy;
- (NSArray *) resultSetForDatamodel;	//Performs a SELECT *

@end
