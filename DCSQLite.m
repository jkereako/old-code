//
//  DCSQLLite.m
//  DeliOrder
//
//  Created by Jeffrey Kereakoglow on 2/25/10.
//  Copyright 2010 Droste Consultants, Inc.. All rights reserved.
//

#import "DCSQLite.h"

@implementation DCSQLite
@synthesize shouldOverwriteExistingDatabase, _whereClause, _groupByClause, _havingClause, _orderByList, _sql;

const NSString *kColumnNameKey = @"name";
const NSString *kColumnValueKey = @"value";
const NSString *kColumnOmitIfEmptyKey = @"omit";
const NSString *kColumnTypeKey = @"type";
const NSString *kColumnDefaultValue = @"default";
const NSString *kColumnNotNullKey = @"notnull";
const NSString *kColumnPrimaryKeyKey = @"pk";

//KVO
const NSString *kTableNameKey = @"tableName";
const NSString *kCommitUpdateToTableKey = @"tableName";
const NSString *kCommitUpdateKey = @"commit";

SYNTHESIZE_SINGLETON_FOR_CLASS(DCSQLite);

- (void) dealloc {
	//DEBUG_LOG(@"Deallocating DCSQLite...");
	
	SAFE_RELEASE(_database);
	SAFE_RELEASE(_dataModel);
	SAFE_RELEASE(_changedValues);
	SAFE_RELEASE(_dataModelKeys);
	
	SAFE_RELEASE(_whereClause);
	SAFE_RELEASE(_groupByClause);
	SAFE_RELEASE(_havingClause);
	SAFE_RELEASE(_orderByList);
	SAFE_RELEASE(_sql);
	
	[super dealloc];
}

#pragma mark -
#pragma mark DCProtocol

/*
 
 SQLITE_OK           0   Successful result 
 SQLITE_ERROR        1    SQL error or missing database 
 SQLITE_INTERNAL     2    Internal logic error in SQLite 
 SQLITE_PERM         3    Access permission denied 
 SQLITE_ABORT        4    Callback routine requested an abort 
 SQLITE_BUSY         5    The database file is locked
 SQLITE_LOCKED       6    A table in the database is locked 
 SQLITE_NOMEM        7    A malloc() failed 
 SQLITE_READONLY     8    Attempt to write a readonly database 
 SQLITE_INTERRUPT    9    Operation terminated by sqlite3_interrupt()
 SQLITE_IOERR       10    Some kind of disk I/O error occurred 
 SQLITE_CORRUPT     11    The database disk image is malformed
 SQLITE_NOTFOUND    12    NOT USED. Table or record not found 
 SQLITE_FULL        13    Insertion failed because database is full 
 SQLITE_CANTOPEN    14    Unable to open the database file 
 SQLITE_PROTOCOL    15    NOT USED. Database lock protocol error 
 SQLITE_EMPTY       16    Database is empty 
 SQLITE_SCHEMA      17    The database schema changed 
 SQLITE_TOOBIG      18    String or BLOB exceeds size limit 
 SQLITE_CONSTRAINT  19    Abort due to constraint violation 
 SQLITE_MISMATCH    20    Data type mismatch 
 SQLITE_MISUSE      21    Library used incorrectly 
 SQLITE_NOLFS       22    Uses OS features not supported on host 
 SQLITE_AUTH        23    Authorization denied 
 SQLITE_FORMAT      24    Auxiliary database format error 
 SQLITE_RANGE       25    2nd parameter to sqlite3_bind out of range 
 SQLITE_NOTADB      26    File opened that is not a database file 
 SQLITE_ROW         100   sqlite3_step() has another row ready 
 SQLITE_DONE        101   sqlite3_step() has finished executing 
 
 */
- (void) handleError: (NSError *) error {
	UIAlertView *alert = nil;
	NSString *title = nil;
	NSString *message = nil;
	NSUInteger sqliteErrorCode = [_database lastErrorCode];
	/*
	switch (sqliteErrorCode) {
		case SQLITE_ERROR:
			message = [[NSString alloc] initWithString: [_database lastErrorMessage]];
			break;
		default:
			break;
	}
	*/
	
	title = [[NSString alloc] initWithString: NSLocalizedString(@"Database Error", @"General title for DCSQLLite errors")];
	message = [[NSString alloc] initWithString: [_database lastErrorMessage]];
	
	//NSLog(message);
    
	alert = [[UIAlertView alloc] initWithTitle: title
									   message: message delegate:nil 
							 cancelButtonTitle:@"OK"
							 otherButtonTitles:nil];
	[alert show];
    
	SAFE_RELEASE(title);
	SAFE_RELEASE(message);
	SAFE_RELEASE(alert);
}

#pragma mark -
#pragma mark Getters and Setters
- (void) setDataModel: (NSDictionary *) dataModel {
	NSParameterAssert(dataModel);
	
	NSEnumerator *iterator = nil;
	NSString *key = nil;
	
	_whereClause = nil;
	_groupByClause = nil;
	_havingClause = nil;
	_orderByList = nil;
	
	if(_dataModel) {
		iterator = [_dataModel keyEnumerator];
		
		while (key = [iterator nextObject]) 
			[_dataModel removeObserver: self forKeyPath: key];
		
		iterator = nil;
		key = nil;
		SAFE_RELEASE(_dataModel);
		SAFE_RELEASE(_dataModelKeys);
	}
	
	_dataModelKeys = [[NSArray alloc] initWithArray: [dataModel allKeys]];
	_dataModel = [dataModel retain];
	
	[_dataModel retain];
	[_dataModel retain];
	
	iterator = [dataModel keyEnumerator];
	
	while (key = [iterator nextObject]) 
		[_dataModel addObserver: self forKeyPath: key options: (NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context: nil];
}

- (void) setDataModel: (id) kvcObject keys: (NSArray *) keys {
	if(_dataModel) {
		_dataModel = nil;
		SAFE_RELEASE(_dataModelKeys);
	}
	
	NSEnumerator *iterator = nil;
	NSString *key = nil;
	
	_whereClause = nil;
	_groupByClause = nil;
	_havingClause = nil;
	_orderByList = nil;
	_dataModelKeys = [[NSArray alloc] initWithArray: keys];
	_dataModel = kvcObject;
	
	//NSLog([NSString stringWithFormat: @"RETAIN COUNT: %d", [_dataModel retainCount]]);	

	[_dataModel retain];
	[_dataModel retain];
	
	//NSLog([NSString stringWithFormat: @"RETAIN COUNT: %d", [_dataModel retainCount]]);	
	
	iterator = [keys objectEnumerator];
	
	while (key = [iterator nextObject]) 
		[_dataModel addObserver: self forKeyPath: key options: (NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context: nil];

}

- (id) dataModel {
	return _dataModel;
}

#pragma mark -
#pragma mark Generic Database Utility Methods

- (BOOL) executeSQL {
	NSAssert([_sql isKindOfClass: [NSString class]], @"There is no SQL to execute.");
	//NSAssert([_database open], [_database lastErrorMessage]);
	
	BOOL success = NO;
	
	if ([[_sql lowercaseString] rangeOfString: @"create"].location != NSNotFound ||
		[[_sql lowercaseString] rangeOfString: @"insert"].location != NSNotFound ||
		[[_sql lowercaseString] rangeOfString: @"update"].location != NSNotFound ||
		[[_sql lowercaseString] rangeOfString: @"delete"].location != NSNotFound) {
		
		success = [_database executeUpdate: _sql];
	}
	else
		success = [_database executeQuery: _sql];
	
	
//	NSAssert(![_database hadError], [_database lastErrorMessage]);
	
	return success;
}

- (void) createDatabaseWithName: (NSString *) databaseName {
	NSParameterAssert([databaseName isKindOfClass: [NSString class]]);
	
	DEBUG_LOG(@"Creating database...");
	
	NSAutoreleasePool *pool = nil;
	NSFileManager *fileManager = nil;
	NSString *tempDir = nil;
	NSString *fullPath = nil;
	NSProcessInfo *info = nil;
	NSString *databaseFileName = nil;
	
	pool = [[NSAutoreleasePool alloc] init];
	fileManager = [NSFileManager defaultManager];
	databaseFileName = [databaseName stringByAppendingString: @".sqlite"];
	info = [[NSProcessInfo alloc] init];
	
	if(TARGET_IPHONE_SIMULATOR) {
		tempDir = [NSString stringWithFormat: @"/Users/%@/Desktop/iphone_db/", [[info environment] objectForKey: @"USER"]];
				
		//Creates the directory "iphone_db"
		if(![fileManager fileExistsAtPath: tempDir])
			[fileManager createDirectoryAtPath: tempDir withIntermediateDirectories: NO attributes: nil error: nil];
		
	}
	
	else if(TARGET_OS_IPHONE)
		tempDir = NSTemporaryDirectory();
	
	fullPath = [tempDir stringByAppendingString: databaseFileName];
	
	if([fileManager fileExistsAtPath: tempDir])
		if(shouldOverwriteExistingDatabase)
			[fileManager removeItemAtPath: tempDir error: nil];
	
	_database = [[FMDatabase alloc] initWithPath: fullPath];
	
    
	SAFE_AUTORELEASE(pool);
	SAFE_RELEASE(info);
	    
	//Make sure we can open the database connection3
	NSAssert([_database open], [_database lastErrorMessage]);
	
	NSAssert(![_database hadError], [_database lastErrorMessage]);
	
}

- (void) createTableWithName: (NSString *) tableName fields: (NSArray *) fields {
	//NSAssert([_database open], @"Database is not open.");
	NSParameterAssert([tableName isKindOfClass: [NSString class]]);
	NSParameterAssert([fields isKindOfClass: [NSArray class]]);
	
	NSEnumerator *iterator = nil;
	NSDictionary *attributes = nil;
	NSMutableString *accumulator = nil;
	NSMutableArray *accumulators = nil;
	BOOL success = NO;

	iterator = [fields objectEnumerator];
	accumulator = [[NSMutableString alloc] init];
	accumulators = [[NSMutableArray alloc] init];
	
	while (attributes = [iterator nextObject]) {

		[accumulator appendFormat: @"\"%@\"", [attributes objectForKey: kColumnNameKey]];
		[accumulator appendFormat: @"%@", [attributes objectForKey: kColumnTypeKey]];
		
		if([attributes objectForKey: kColumnPrimaryKeyKey])
			[accumulator appendFormat: @"PRIMARY KEY AUTOINCREMENT", [attributes objectForKey: kColumnPrimaryKeyKey]];
		
		if([attributes objectForKey: kColumnNotNullKey])
			[accumulator appendString: @"NOT NULL"];
		
		if([attributes objectForKey: kColumnDefaultValue])
			[accumulator appendFormat: @"DEFAULT @%", [attributes objectForKey: kColumnDefaultValue]];
		
		[accumulators addObject: accumulator];
		
	}
	
	if(_sql)
		SAFE_RELEASE(_sql);
	
	_sql = [[NSMutableString alloc] initWithFormat: @"CREATE TABLE IF NOT EXISTS \"%@\" (\n%@)", tableName, [accumulators componentsJoinedByString: @",\n"]];
	
	SAFE_RELEASE(accumulator);
	SAFE_RELEASE(accumulators);
	
	success = [_database executeUpdate: _sql];
	
	if(!success)
		[self handleError: nil];
	
	//[_database close];
	
}

- (BOOL) createForeignKeyOnField: (NSString *) fieldName ofTable: (NSString *) tableName foreignKey: (NSString *) fkField foreignTable: (NSString *) fkTableName {
/*
 -- Foreign Key Preventing insert
 CREATE TRIGGER fki_"cart"_"order_id"_foo_id
 BEFORE INSERT ON ["cart"]
 FOR EACH ROW BEGIN
 SELECT RAISE(ROLLBACK, 'insert on table ""cart"" violates foreign key constraint "fki_"cart"_"order_id"_foo_id"')
 WHERE NEW."order_id" IS NOT NULL AND (SELECT id FROM foo WHERE id = NEW."order_id") IS NULL;
 END;
 
 -- Foreign key preventing update
 CREATE TRIGGER fku_"cart"_"order_id"_foo_id
 BEFORE UPDATE ON ["cart"]
 FOR EACH ROW BEGIN
 SELECT RAISE(ROLLBACK, 'update on table ""cart"" violates foreign key constraint "fku_"cart"_"order_id"_foo_id"')
 WHERE NEW."order_id" IS NOT NULL AND (SELECT id FROM foo WHERE id = NEW."order_id") IS NULL;
 END;
 
 -- Foreign key preventing delete
 CREATE TRIGGER fkd_"cart"_"order_id"_foo_id
 BEFORE DELETE ON foo
 FOR EACH ROW BEGIN
 SELECT RAISE(ROLLBACK, 'delete on table "foo" violates foreign key constraint "fkd_"cart"_"order_id"_foo_id"')
 WHERE (SELECT "order_id" FROM "cart" WHERE "order_id" = OLD.id) IS NOT NULL;
 END;
 
 */
	NSUInteger i = 0;
	NSString *description = nil;
	NSString *event = nil;
	NSString *prefix = nil;
	NSMutableString *sql = nil;
	BOOL success = NO;
	
	sql = [[NSMutableString alloc] init];
	
	for (i = 0; i != 3; ++ i) {
		switch (i) {
			case 0:
				description = @" -- Foreign key constraint preventing INSERT\n";
				event = @"INSERT";
				prefix = @"fki";
				break;
				
			case 1:
				description = @" -- Foreign key constraint preventing UPDATE\n";
				event = @"UPDATE";
				prefix = @"fkd";
				break;
				
			case 2:
				description = @" -- Foreign key constraint preventing DELETE\n";
				event = @"DELETE";
				prefix = @"fkd";
				break;
				
			default:
				break;
		}
		
		[sql setString: description];
		
		[sql appendFormat: @"CREATE TRIGGER \"%@_%@_%@_%@_%@\"\n", prefix, tableName, fieldName, fkTableName, fkField];
		
		if([event isEqualToString: @"DELETE"]) 
			[sql appendFormat: @"BEFORE %@ ON \"%@\"\n", event, fkTableName];
		else
			[sql appendFormat: @"BEFORE %@ ON \"%@\"\n", event, tableName];
		
		@"FOR EACH ROW BEGIN";
		
		[sql appendFormat: @"SELECT RAISE(ROLL BACK, '%@ on table \"%@\" violates foreign key constraint')\n", event, tableName ];
		
		if([event isEqualToString: @"DELETE"])
			[sql appendFormat: @"WHERE (SELECT %@ FROM \"%@\" WHERE %@ = OLD.%@) IS NOT NULL\n", fieldName, tableName, fieldName, fkField];
		else
			[sql appendFormat: @"WHERE NEW.%@ IS NOT NULL AND (SELECT %@ FROM \"%@\" WHERE %@ = NEW.%@) IS NULL\n", fieldName, fkField, fkTableName, fkField, fieldName];
		
		[sql appendString: @"END;"];
		
		//DEBUG_LOG(sql);
	}
	
	success = YES;
	
	return success;
}

#pragma mark -
#pragma mark Utility Methods

/**
 *	Expects and array in this format
 *
 *	NSArray	[0] =>	NSDictionary =>	{name => "name",
 *									value => "value", 
 *									omit => "omit"}
 *
 */
- (NSString *) buildSQLInsert: (NSArray *) fieldsAndValues table: (NSString *) tableName {
	NSParameterAssert([fieldsAndValues isKindOfClass: [NSArray class]]);
	NSParameterAssert([tableName isKindOfClass: [NSString class]]);
	
	NSEnumerator *iterator = nil;
	NSDictionary *field = nil;
	
	NSMutableArray *fields = nil;
	NSMutableArray *values = nil;
	
	NSString *formattedFields = nil;
	NSString *formattedValues = nil;
	
	fields = [[NSMutableArray alloc] initWithCapacity: [fieldsAndValues count]];
	values = [[NSMutableArray alloc] initWithCapacity: [fieldsAndValues count]];
	iterator = [fieldsAndValues objectEnumerator];
	
	while (field = [iterator nextObject]) {
		if([field objectForKey: kColumnOmitIfEmptyKey])
			continue;
		
		[fields addObject: [field objectForKey: kColumnNameKey]];
		[values addObject: [self _toSQL: [field objectForKey: kColumnValueKey]]];
		
	}
	
	formattedFields = [[NSString alloc] initWithString: [fields componentsJoinedByString: @", "]];
	formattedValues = [[NSString alloc] initWithString: [values componentsJoinedByString: @", "]];
	
	if(_sql)
		SAFE_RELEASE(_sql);
	
	_sql = ([fields count]) ? [[NSMutableString alloc] initWithFormat: @"INSERT INTO \"%@\" (%@) \nVALUES(%@)", tableName, formattedFields, formattedValues] : nil;
	
	SAFE_RELEASE(fields);
	SAFE_RELEASE(values);
	SAFE_RELEASE(formattedFields);
	SAFE_RELEASE(formattedValues);
	
	return _sql;
}

- (NSString *) buildSQLUpdate: (NSArray *) fieldsAndValues table: (NSString *) tableName where: (NSString *) whereClause {
	NSParameterAssert([fieldsAndValues isKindOfClass: [NSArray class]]);
	NSParameterAssert([tableName isKindOfClass: [NSString class]]);
	
	NSEnumerator *iterator = nil;
	NSDictionary *field = nil;
	
	NSMutableArray *fields = nil;
	NSMutableArray *formattedFieldsArray= nil;
	NSString *formattedFieldsString = nil;
	
	formattedFieldsArray = [[NSMutableArray alloc] init];
	iterator = [fieldsAndValues objectEnumerator];
	
	while (field = [iterator nextObject]) {
		if([field objectForKey: kColumnOmitIfEmptyKey])
			continue;

		fields = [[NSMutableArray alloc] initWithCapacity: 2];
		//fields = [[[NSMutableArray alloc] initWithCapacity: 2] autorelease];
		
		[fields addObject: [field objectForKey: kColumnNameKey]];
		[fields addObject: [self _toSQL: [field objectForKey: kColumnValueKey]]];
		
		[formattedFieldsArray addObject: [fields componentsJoinedByString: @" = "]];
	}
	
	formattedFieldsString = [[NSString alloc] initWithString: [formattedFieldsArray componentsJoinedByString: @", "]];
	
	if(_sql)
		SAFE_RELEASE(_sql);
	
	if(whereClause)
		_sql = [[NSMutableString alloc] initWithFormat: @"UPDATE \"%@\"\n SET %@\n WHERE %@", tableName, formattedFieldsString, whereClause];
	else
		_sql = [[NSMutableString alloc] initWithFormat: @"UPDATE \"%@\"\n SET %@", tableName, formattedFieldsString];
	
	SAFE_RELEASE(fields);
	SAFE_RELEASE(formattedFieldsArray);
	SAFE_RELEASE(formattedFieldsString);
	
	return _sql;
}

- (NSString *) buildSQLDelete: (NSString *) tableName where: (NSString *) whereClause {
	NSParameterAssert([tableName isKindOfClass: [NSString class]]);
	NSParameterAssert([whereClause isKindOfClass: [NSString class]] || !whereClause);
	
	if(_sql)
		SAFE_RELEASE(_sql);
	
	if([whereClause length])
		_sql = [[NSMutableString alloc] initWithFormat: @"DELETE FROM \"%@\" \nWHERE %@", tableName, whereClause];
	
	//Deletes all records in table
	else
		_sql = [[NSMutableString alloc] initWithFormat: @"DELETE FROM \"%@\"", tableName, whereClause];
	
	return _sql;
}

- (NSString *) buildSQLSelect: (NSString *) selectStatement table: (NSString *) tableName where: (NSString *) whereClause orderBy: (NSString *) orderBy {
	NSParameterAssert([selectStatement isKindOfClass: [NSString class]]);
	NSParameterAssert([tableName isKindOfClass: [NSString class]]);
	//NSParameterAssert([whereClause isKindOfClass: [NSString class]]);
	//NSParameterAssert([orderBy isKindOfClass: [NSString class]]);
	
	if(_sql)
		SAFE_RELEASE(_sql);
	
	_sql = [[NSMutableString alloc] init];
	
	if([[tableName componentsSeparatedByCharactersInSet: [NSCharacterSet whitespaceCharacterSet]] count] > 1)
		[_sql appendFormat: @"SELECT %@ \nFROM %@", selectStatement, tableName];
	else
		[_sql appendFormat: @"SELECT %@ \nFROM \"%@\"", selectStatement, tableName];
	
	if(whereClause)
		[_sql appendFormat: @" \nWHERE %@", whereClause];
	
	if(orderBy)
		[_sql appendFormat: @" \nORDER BY %@", orderBy];
	
	return _sql;
}

- (NSString *) buildSQLSelect: (NSString *) selectStatement table: (NSString *) tableName groupBy: (NSString *) groupByClause having: (NSString *) havingClause orderBy: (NSString *) orderBy {
	return [self buildSQLSelect: selectStatement table: tableName where: nil groupBy: groupByClause having: havingClause orderBy: orderBy];
}

- (NSString *) buildSQLSelect: (NSString *) selectStatement table: (NSString *) tableName where: (NSString *) whereClause groupBy: (NSString *) groupByClause having: (NSString *) havingClause orderBy: (NSString *) orderBy {
	NSParameterAssert([selectStatement isKindOfClass: [NSString class]]);
	NSParameterAssert([tableName isKindOfClass: [NSString class]]);
	NSParameterAssert([groupByClause isKindOfClass: [NSString class]]);
	NSParameterAssert([havingClause isKindOfClass: [NSString class]] || !havingClause);
	
	if(_sql)
		SAFE_RELEASE(_sql);
	
	_sql = [[NSMutableString alloc] init];
	
	if([[tableName componentsSeparatedByCharactersInSet: [NSCharacterSet whitespaceCharacterSet]] count] > 1)
		[_sql appendFormat: @"SELECT %@ \nFROM %@", selectStatement, tableName];
	else
		[_sql appendFormat: @"SELECT %@ \nFROM \"%@\"", selectStatement, tableName];		
	
		
	if(whereClause)
		[_sql appendFormat: @" \nWHERE %@", whereClause];
	
	[_sql appendFormat: @" \nGROUP BY %@", groupByClause];
	
	if(havingClause)
		[_sql appendFormat: @" \nHAVING %@", havingClause];
	
	if(orderBy)
		[_sql appendFormat: @" \nORDER BY %@", orderBy];
	
	return _sql;
}

- (NSString *) buildWhereClauseWithCollection: (NSDictionary *) collection comparisonOperator: (NSString *) operator conjoinedBy: (NSString *) andOr {
	NSParameterAssert([collection isKindOfClass: [NSDictionary class]]);
	NSParameterAssert([operator isKindOfClass: [NSString class]]);
	NSParameterAssert([andOr isKindOfClass: [NSString class]]);
	
	NSEnumerator *iterator = nil;
	NSMutableArray *fragments = nil;
	NSString *key = nil;
	NSString *sqlValue = nil;
	NSString *whereClause = nil;
		
	iterator = [collection keyEnumerator];
	fragments = [[NSMutableArray alloc] init];
	
	while (key = [iterator nextObject]) {
		sqlValue = [self _toSQL: [collection valueForKey: key]];
		
		[fragments addObject: [NSString stringWithFormat: @"%@ %@ %@", key, operator, sqlValue]];
		
	}
	
	whereClause = [[[NSString alloc] initWithString: [fragments componentsJoinedByString: andOr]] autorelease];
	
	SAFE_RELEASE(fragments);
	
	return whereClause;
}

- (NSString *) _toSQL: (id) value {
	NSParameterAssert(value != nil);
	
	NSString *cleanedString = nil;
	NSDateFormatter *dateFormatter = nil;
	
	if([value isKindOfClass: [NSString class]]) {
		value = [value stringByReplacingOccurrencesOfString: @"\"" withString: @"'"];
		cleanedString = [[NSString alloc] initWithFormat: @"\"%@\"", value];
	}
	
	//YYYY-mm-dd HH:MM:SS
	else if([value isKindOfClass: [NSDate class]]) {
		dateFormatter = [[NSDateFormatter alloc] init];
		
		[dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
		
		cleanedString = [[NSString alloc] initWithFormat: @"\"%@\"", [dateFormatter stringFromDate: value]];
		
		SAFE_RELEASE(dateFormatter);
	}
	
	else if([value isKindOfClass: [NSNumber class]])
		cleanedString = [[NSString alloc] initWithFormat: @"%@", value];
	
	else if([value isKindOfClass: [NSNull class]])
		cleanedString = [[NSString alloc] initWithString: @""];
	
	return [cleanedString autorelease];
	
}

#pragma mark -
#pragma mark Database Utility Methods
- (NSUInteger) fieldCountForTable: (NSString *) tableName {
//	NSAssert([_database open],  @"The database is not open");
	NSParameterAssert([tableName isKindOfClass: [NSString class]]);
	
	FMResultSet *result;
	NSUInteger count = 0;
		
	result = [_database getTableSchema: tableName];
	
	while ([result next])
		++ count;
	
	[result close];
	//[_database close];
	
	return count;
}

- (NSUInteger) recordCountForTable: (NSString *) tableName {
//	NSAssert([_database open],  @"The database is not open");
	NSParameterAssert([tableName isKindOfClass: [NSString class]]);
	
	NSString *pkField = nil;
	NSUInteger result = 0;
	
	pkField = [self primaryKeyFieldNameForTable: tableName];
	
	result = [[self numberForSQLQuery: [NSString stringWithFormat: @"COUNT(%@)", pkField] 
					 fromTable: tableName 
						 where: nil] intValue];
	
	//[_database close];
	
	return result;
}

- (NSString *) primaryKeyFieldNameForTable: (NSString *) tableName {
	//NSAssert([_database open],  @"The database is not open");
	NSParameterAssert([tableName isKindOfClass: [NSString class]]);
	
	FMResultSet *resultSet = nil;
	NSString *fieldName = nil;
	
	resultSet = [_database getTableSchema: tableName];
	
	while ([resultSet next]) {
		if([resultSet boolForColumn: @"pk"])
			fieldName = [resultSet stringForColumn: @"name"];
	}
	
	[resultSet close];
	
	//[_database close];
	
	return fieldName;
}


- (BOOL) tableExists: (NSString *) tableName {
		
	//NSAssert([_database open], [_database lastErrorMessage]);
	NSParameterAssert([tableName isKindOfClass: [NSString class]]);
	
	FMResultSet *resultSet = nil;
	BOOL tableDoesExist = NO;
	
	resultSet = [_database getSchema];
	
	while ([resultSet next]) {
		if([[resultSet stringForColumn: @"tbl_name"] isEqualToString: tableName]) {
			tableDoesExist = YES;
			break;
		}
	}
	
	[resultSet close];
	
	return tableDoesExist;
}

- (void) reseedAutoIncrementFieldForTable: (NSString *) tableName {
	//NSAssert([_database open],  @"The database is not open");
	NSParameterAssert([tableName isKindOfClass: [NSString class]]);
		
	_sql = [[NSString alloc] initWithFormat: @"UPDATE [sqlite_sequence] \nSET seq = 1 \nWHERE name = '%@'", tableName];
	
	[_database executeUpdate: _sql];
}

- (NSString *) stringForSQLQuery: (NSString *) selectStatement fromTable: (NSString *) tableName where: (NSString *) whereClause {
	//NSAssert([_database open], [_database lastErrorMessage]);
	NSParameterAssert([selectStatement isKindOfClass: [NSString class]]);
	NSParameterAssert([tableName isKindOfClass: [NSString class]]);
	NSParameterAssert([whereClause isKindOfClass: [NSString class]] || !whereClause);
	
	FMResultSet *resultSet = nil;	
	NSString *result = nil;
	
	if(_sql)
		SAFE_RELEASE(_sql);
	
	_sql = [[NSMutableString alloc] init];
	
	//If the FROM table is not a subquery, enclose the table name in quotations
	if([[tableName componentsSeparatedByCharactersInSet: [NSCharacterSet whitespaceCharacterSet]] count] > 1)
		[_sql appendFormat: @"SELECT %@ \nFROM %@", selectStatement, tableName];
	else
		[_sql appendFormat: @"SELECT %@ \nFROM \"%@\"", selectStatement, tableName];		
		
	if(whereClause)
		[_sql appendFormat: @" \nWHERE %@", whereClause];
		
	if(![_database inUse])
		resultSet = [_database executeQuery: _sql];
	
	
	if([resultSet next]);
		result = [resultSet stringForColumnIndex: 0];
		
	//NSAssert(![_database hadError], [_database lastErrorMessage]);
	
	return result;
}

- (NSString *) stringForSQLQuery: (NSString *) selectStatement fromTable: (NSString *) tableName groupBy: (NSString *) groupByClause having: (NSString *) havingClause {
	return [self stringForSQLQuery: selectStatement fromTable: tableName where: nil groupBy: groupByClause having: havingClause];
}

- (NSString *) stringForSQLQuery: (NSString *) selectStatement fromTable: (NSString *) tableName where: (NSString *) whereClause groupBy: (NSString *) groupByClause having: (NSString *) havingClause {
	//NSAssert([_database open], [_database lastErrorMessage]);
	NSParameterAssert([selectStatement isKindOfClass: [NSString class]]);
	NSParameterAssert([tableName isKindOfClass: [NSString class]]);
	
	FMResultSet *resultSet = nil;	
	NSString *sql = nil;
	NSString *result = nil;
	
	if(_sql)
		SAFE_RELEASE(_sql);
	
	_sql = [[NSMutableString alloc] initWithFormat: @"SELECT %@ \nFROM \"%@\"", selectStatement, tableName];
		
	if(whereClause)
		[_sql appendFormat: @" \nWHERE %@", whereClause];
	
	if(groupByClause) {
		[_sql appendFormat: @" \nGROUP BY %@", groupByClause];
		
		if(havingClause)
			[_sql appendFormat: @" \nHAVING %@", havingClause];
	}
	
	//DEBUG_LOG(sql);
	
	resultSet = [_database executeQuery: sql];
	
	if([resultSet next]);
	
	result = [resultSet stringForColumnIndex: 0];
		
	NSAssert([_database hadError], [_database lastErrorMessage]);
	
	return result;
}



- (NSNumber *) numberForSQLQuery: (NSString *) selectStatement fromTable: (NSString *) tableName where: (NSString *) whereClause {
	//NSAssert([_database open],  @"The database is not open");
	NSParameterAssert([selectStatement isKindOfClass: [NSString class]]);
	NSParameterAssert([tableName isKindOfClass: [NSString class]]);
	NSParameterAssert([whereClause isKindOfClass: [NSString class]] || !whereClause);
	
	FMResultSet *resultSet = nil;	
	NSNumber *result = nil;
	
	if(_sql)
		SAFE_RELEASE(_sql);
	
	_sql = [[NSMutableString alloc] init];
	
	//resultSet = [_database getTableSchema: tableName];
	
	//If the FROM table is not a subquery, enclose the table name in quotations
	if([[tableName componentsSeparatedByCharactersInSet: [NSCharacterSet whitespaceCharacterSet]] count] > 1)
		[_sql appendFormat: @"SELECT %@ \nFROM %@", selectStatement, tableName];
	else
		[_sql appendFormat: @"SELECT %@ \nFROM \"%@\"", selectStatement, tableName];		
	
	if(whereClause)
		[_sql appendFormat: @" \nWHERE %@", whereClause];
	
	resultSet = [_database executeQuery: _sql];
		
	if([resultSet next]);
		result = [[NSNumber alloc] initWithDouble: [resultSet doubleForColumnIndex: 0]];
	
	[resultSet close];
	
	//[_database close];
	
	return [result autorelease];
}

- (NSNumber *) numberForSQLQuery: (NSString *) selectStatement fromTable: (NSString *) tableName groupBy: (NSString *) groupByClause having: (NSString *) havingClause {
	return [self numberForSQLQuery: selectStatement fromTable: tableName where: nil groupBy: groupByClause having: havingClause];
}

- (NSNumber *) numberForSQLQuery: (NSString *) selectStatement fromTable: (NSString *) tableName where: (NSString *) whereClause groupBy: (NSString *) groupByClause having: (NSString *) havingClause {
	//	NSAssert([_database open],  @"The database is not open");
	NSParameterAssert([selectStatement isKindOfClass: [NSString class]]);
	NSParameterAssert([tableName isKindOfClass: [NSString class]]);
	
	FMResultSet *resultSet = nil;	
	NSNumber *result = nil;
	
	if(_sql)
		SAFE_RELEASE(_sql);
	
	_sql = [[NSMutableString alloc] initWithFormat:  @"SELECT %@ \nFROM \"%@\"", selectStatement, tableName];
	
	if(whereClause)
		[_sql appendFormat: @" \nWHERE %@", whereClause];
	
	if(groupByClause) {
		[_sql appendFormat: @" \nGROUP BY %@", groupByClause];
		
		if(havingClause)
			[_sql appendFormat: @" \nHAVING %@", havingClause];
	}
		
	resultSet = [_database executeQuery: _sql];
	
	if([resultSet next]);
	result = [[NSNumber alloc] initWithDouble: [resultSet doubleForColumnIndex: 0]];
	
	[resultSet close];
	
	//[_database close];
	
	return [result autorelease];
}


//Returns an array of 
- (NSArray *) resultSetForSQLQuery: (NSString *) selectStatement fromTable: (NSString *) tableName where: (NSString *) whereClause orderBy: (NSString *) orderBy {
	//NSAssert([_database open], @"Database is not open.");
	NSParameterAssert([selectStatement isKindOfClass: [NSString class]]);
	NSParameterAssert([tableName isKindOfClass: [NSString class]]);
	NSParameterAssert([whereClause isKindOfClass: [NSString class]] || !whereClause);
	NSParameterAssert([orderBy isKindOfClass: [NSString class]] || !orderBy);
	
	NSAutoreleasePool *pool = nil;
	FMResultSet *resultSet = nil;
	NSMutableArray *accumulator = nil;
	NSMutableDictionary *keyValuePairs = nil;
	NSUInteger i = 0;
	NSUInteger fieldCount = 0;
	id value = nil;
	NSString *key = nil;
	
	pool = [[NSAutoreleasePool alloc] init];
	
	[self buildSQLSelect: selectStatement table: tableName where: whereClause orderBy: orderBy];
		
	accumulator = [[NSMutableArray alloc] initWithCapacity: fieldCount];
		
	//Query to retreive data
	resultSet = [_database executeQuery: _sql];
	
	fieldCount = [resultSet columnCount];
	
	while ([resultSet next]) {
		
		keyValuePairs = [[[NSMutableDictionary alloc] init] autorelease];
				
		for (i = 0; i != fieldCount; ++ i) {
			key = [resultSet columnNameForIndex: i];

			if([[_dataModel objectForKey: key] isKindOfClass: [NSString class]])
				value = [resultSet stringForColumnIndex: i];
			
			else if([[_dataModel objectForKey: key] isKindOfClass: [NSDate class]])
				value = [resultSet stringForColumnIndex: i];

			else if([[_dataModel objectForKey: key] isKindOfClass: [NSNumber class]]) {
				if (strcmp([[_dataModel objectForKey: key] objCType], @encode(BOOL)) == 0)
					value = [NSNumber numberWithBool: [resultSet boolForColumnIndex: i]];
				
				else if(strcmp([[_dataModel objectForKey: key] objCType], @encode(int)) == 0)
					value = [NSNumber numberWithInt: [resultSet intForColumnIndex: i]];
				
				else if(strcmp([[_dataModel objectForKey: key] objCType], @encode(long)) == 0)
					value = [NSNumber numberWithLong: [resultSet longForColumnIndex: i]];
				
				else if(strcmp([[_dataModel objectForKey: key] objCType], @encode(long long)) == 0)
					value = [NSNumber numberWithLongLong: [resultSet longLongIntForColumnIndex: i]];
				
				else if ((strcmp([[_dataModel objectForKey: key] objCType], @encode(double)) == 0) || (strcmp([[_dataModel objectForKey: key] objCType], @encode(float)) == 0))
					value = [NSNumber numberWithDouble: [resultSet doubleForColumnIndex: i]];
			}
			
			else if([resultSet columnIndexIsNull: i])
				value = @"";
			
			//Else, it must be the PK
			else if([key isEqualToString: [self primaryKeyFieldNameForTable: tableName]])
				value = [NSNumber numberWithInt: [resultSet intForColumnIndex: i]];
			
			else
				value = [resultSet stringForColumnIndex: i];

			
			[keyValuePairs setObject: value forKey: key];
		}
		
		
		[accumulator addObject: keyValuePairs];
		
	}
	
	[resultSet close];
	
	SAFE_AUTORELEASE(pool);
	
	//[_database close];
		
	return [accumulator autorelease];
}

- (NSArray *) resultSetForSQLQuery: (NSString *) selectStatement fromTable: (NSString *) tableName groupBy: (NSString *) groupByClause having: (NSString *) havingClause orderBy: (NSString *) orderBy {
	//NSAssert([_database open], @"A connection to the database could not be opened.");
	NSParameterAssert([selectStatement isKindOfClass: [NSString class]]);
	NSParameterAssert([tableName isKindOfClass: [NSString class]]);
	NSParameterAssert([groupByClause isKindOfClass: [NSString class]]);
	NSParameterAssert([havingClause isKindOfClass: [NSString class]] || !havingClause);
	NSParameterAssert([orderBy isKindOfClass: [NSString class]] || !orderBy);
	
	FMResultSet *resultSet = nil;
	NSMutableArray *accumulator = nil;
	NSMutableDictionary *keyValuePairs = nil;
	NSUInteger i = 0;
	NSUInteger fieldCount = 0;
	NSString *value = nil;
	NSString *key = nil;
	
	accumulator = [[NSMutableArray alloc] initWithCapacity: fieldCount];
	
	[self buildSQLSelect: selectStatement table: tableName groupBy: groupByClause having: havingClause orderBy: orderBy];
	
	//Query to retreive data
	resultSet = [_database executeQuery: _sql];
	
	fieldCount = [resultSet columnCount];
	
	while ([resultSet next]) {
		
		keyValuePairs = [[[NSMutableDictionary alloc] init] autorelease];
		
		for (i = 0; i != fieldCount; ++ i) {
			key = [resultSet columnNameForIndex: i];
			value = [resultSet stringForColumnIndex: i];
			
			if([resultSet columnIndexIsNull: i])
				value = @"";
			
			[keyValuePairs setObject: value forKey: key];
		}
		
		
		[accumulator addObject: keyValuePairs];
		
	}
	
	[resultSet close];
	
	//[_database close];
	
	//NSAssert([_database hadError],  [_database lastErrorMessage]);
	
	return [accumulator autorelease];
}

- (NSArray *) resultSetForSQLQuery: (NSString *) selectStatement fromTable: (NSString *) tableName where: (NSString *) whereClause groupBy: (NSString *) groupByClause having: (NSString *) havingClause orderBy: (NSString *) orderBy {
	//	NSAssert([_database open], @"Database is not open.");
	NSParameterAssert([selectStatement isKindOfClass: [NSString class]]);
	NSParameterAssert([tableName isKindOfClass: [NSString class]]);
	NSParameterAssert([groupByClause isKindOfClass: [NSString class]]);
	NSParameterAssert([havingClause isKindOfClass: [NSString class]] || !havingClause);
	NSParameterAssert([orderBy isKindOfClass: [NSString class]] || !orderBy);
	
	FMResultSet *resultSet = nil;
	NSMutableArray *accumulator = nil;
	NSMutableDictionary *keyValuePairs = nil;
	NSUInteger i = 0;
	NSUInteger fieldCount = 0;
	NSString *value = nil;
	NSString *key = nil;
	
	accumulator = [[NSMutableArray alloc] initWithCapacity: fieldCount];
	
	if(whereClause)
		[self buildSQLSelect: selectStatement table: tableName where: whereClause groupBy: groupByClause having: havingClause orderBy: orderBy];
	else
		[self buildSQLSelect: selectStatement table: tableName groupBy: groupByClause having: havingClause orderBy: orderBy];
	
	//Query to retreive data
	resultSet = [_database executeQuery: _sql];
	
	fieldCount = [resultSet columnCount];
	
	while ([resultSet next]) {
		
		keyValuePairs = [[[NSMutableDictionary alloc] init] autorelease];
		
		for (i = 0; i != fieldCount; ++ i) {
			key = [resultSet columnNameForIndex: i];
			value = [resultSet stringForColumnIndex: i];
			
			if([resultSet columnIndexIsNull: i])
				value = @"";
			
			[keyValuePairs setObject: value forKey: key];
		}
		
		
		[accumulator addObject: keyValuePairs];
		
	}
	
	[resultSet close];
	
	//[_database close];
	
	return [accumulator autorelease];
}

#pragma mark -
#pragma mark KVO Database Routines
- (void) beginInsert {
	[self _beginOperation];
}

- (void) endInsert {
	[self insert];
	[self _endOperation];
}

- (void) beginUpdate {
	[self _beginOperation];
}

- (void) endUpdate {
	[self update];
	[self _endOperation];
}

- (void) beginDelete {
	[self _beginOperation];
}

- (void) endDelete {
	[self delete];
	[self _endOperation];
}

- (void) _beginOperation {
	if(_inTransaction)
		return;
	
	if(_changedValues)
		SAFE_RELEASE(_changedValues);
	
	_changedValues = [[NSMutableDictionary alloc] initWithCapacity: [_dataModelKeys count]];
	
	_inTransaction = YES;
}

- (void) _endOperation {
	if(!_inTransaction)
		return;
	
	_inTransaction = NO;
	
	SAFE_RELEASE(_changedValues);
}

- (void) createDatabase {
	NSAssert(_dataModel, @"Property \"_dataModel\" is nil.");
	
	NSString *databaseName = nil;
	
	databaseName = NSStringFromClass([[[UIApplication sharedApplication] delegate] class]);
	databaseName = [databaseName stringByReplacingOccurrencesOfString: @"AppDelegate" withString: @""];
	databaseName = [databaseName lowercaseString];
	
	[self createDatabaseWithName: databaseName];
	
	databaseName = nil;
}

- (BOOL) createTable {
	NSAssert(_dataModel, @"Error in selector [DCSQLite createDatabase], property \"_dataModel\" is nil.");
	NSAssert(_dataModelKeys, @"Error in selector [DCSQLite createDatabase], property \"_dataModelKeys\" is nil.");
	
	NSMutableArray *fields = nil;
	NSEnumerator *iterator = nil;
	id value = nil;
	BOOL success = NO;
	NSUInteger i = 0;
	NSUInteger limit = 0;
	NSString *key = nil;
	NSString *tableName = nil;
	NSString *type = nil;
	NSString *pkFieldName = nil;
	NSString *idxFieldName = nil;
	NSString *sql = nil;
	
	limit = [_dataModelKeys count];
	
	if([_dataModel isKindOfClass: [NSDictionary class]]) {
		if([_dataModel objectForKey: kTableNameKey])
			tableName = [[NSString alloc] initWithString: [[_dataModel objectForKey: kTableNameKey] lowercaseString]];
	}
	
	else
		tableName = [[NSString alloc] initWithString: [NSStringFromClass([_dataModel class]) lowercaseString]];
	/*
	 sql = @"CREATE TABLE \"order_odr\" (
	 \"id_odr\" INTEGER PRIMARY KEY  NOT NULL ,
	 \"iditm_odr\" INTEGER NOT NULL ,
	 \"title_odr\" VARCHAR NOT NULL ,
	 \"price_odr\" FLOAT NOT NULL ,
	 \"weight_odr\" FLOAT NOT NULL ,
	 \"thickness_odr\" FLOAT,
	 \"timestamp_odr\" DATETIME DEFAULT CURRENT_TIMESTAMP , 
	 \"is_active_odr\" BOOL)";
	 
	 */
	fields = [[NSMutableArray alloc] initWithCapacity: limit];

	iterator = [_dataModelKeys objectEnumerator];
	
	pkFieldName = [[NSString alloc] initWithFormat: @"id_%@", tableName];
	idxFieldName = [[NSString alloc] initWithFormat: @"idx_%@", tableName];
	
	[fields addObject: [NSString stringWithFormat: @" \"%@\" INTEGER PRIMARY KEY NOT NULL", pkFieldName]];
		
	//The type checking code below is non-essential. In SQLite, the only true
	//types are INTEGER, TEXT, NONE, REAL, and NUMERIC. I chose to give the typedef'd
	//SQL types for readability and portability.
	while (key = [iterator nextObject]) {
		if([key isEqualToString: kTableNameKey])
			continue;
	
		value = [_dataModel valueForKey: key];
		
		if([value isKindOfClass: [NSNumber class]]) {
			
			if (strcmp([value objCType], @encode(BOOL)) == 0)
				type = [[NSString alloc] initWithString: @"BOOL NOT NULL DEFAULT 0"];
			
			else if (strcmp([value objCType], @encode(int)) == 0)
				type = [[NSString alloc] initWithString: @"INTEGER"];
			
			else if (strcmp([value objCType], @encode(long)) == 0)
				type = [[NSString alloc] initWithString: @"MEDIUM INT"];
			
			else if (strcmp([value objCType], @encode(long long)) == 0)
				type = [[NSString alloc] initWithString: @"LONG INT"];
			
			else if (strcmp([value objCType], @encode(float)) == 0)
				type = [[NSString alloc] initWithString: @"FLOAT"];
			
			else if (strcmp([value objCType], @encode(double)) == 0)
				type = [[NSString alloc] initWithString: @"DOUBLE"];
		}
		
		else if([value isKindOfClass: [NSString class]])
			type = [[NSString alloc] initWithString: @"VARCHAR(255)"];
		
		else if([value isKindOfClass: [NSDate class]])
			type = [[NSString alloc] initWithString: @"DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP"];
		
		[fields addObject: [NSString stringWithFormat: @" \"%@\" %@", key, type]];
	}
	
	//Create table, then create index
	for (i = 0; i != 2; ++ i) {
		if(!i)
			sql = [[NSString alloc] initWithFormat:@"CREATE TABLE IF NOT EXISTS \"%@\" (\n%@);", tableName, [fields componentsJoinedByString: @",\n"]];
		else
			sql = [[NSString alloc] initWithFormat: @"CREATE UNIQUE INDEX IF NOT EXISTS %@ ON \"%@\" (%@);", idxFieldName, tableName, pkFieldName];
		
		//DEBUG_LOG(sql);
		
		success = [_database executeUpdate: sql];
		
		SAFE_RELEASE(sql);
		
		if(!success)
			[self handleError: nil];
	}
	
	SAFE_RELEASE(tableName);
	SAFE_RELEASE(fields);
	
	return success;
}

- (BOOL) duplicateRows {
	NSAssert([_whereClause isKindOfClass: [NSString class]], @"DCSQLite._whereClause is nil or invalid.");
	
	NSString *tableName = nil;
	NSArray *dataModels = nil;
	NSDictionary *dataModel = nil;
	NSString *key = nil;
	NSUInteger i = 0;
	NSEnumerator *iterator = nil;
	NSMutableDictionary *fieldDictionary = nil;
	NSMutableArray *fieldsAndValues = nil;
	BOOL success = NO;
	
	if([_dataModel isKindOfClass: [NSDictionary class]]) {
		if([_dataModel objectForKey: kTableNameKey])
			tableName = [[NSString alloc] initWithString: [[_dataModel objectForKey: kTableNameKey] lowercaseString]];
	}
	
	else
		tableName = [[NSString alloc] initWithString: [NSStringFromClass([_dataModel class]) lowercaseString]];
	
	dataModels = [self resultSetForSQLQuery: @"*" 
								  fromTable: tableName 
									  where: _whereClause
									orderBy: nil];
	
	iterator = [dataModels objectEnumerator];
	
	fieldsAndValues = [[NSMutableArray alloc] init];
	
	for (i = 0; i != [dataModels count]; ++ i) {
		dataModel = [dataModels objectAtIndex: i];
		
		iterator = [dataModel keyEnumerator];
		
		while (key = [iterator nextObject]) {
			if([[self primaryKeyFieldName] isEqualToString: key])
				continue;
			
			fieldDictionary = [[NSMutableDictionary alloc] initWithCapacity: 2];
			
			[fieldDictionary setObject: key forKey: kColumnNameKey];
			[fieldDictionary setObject: [dataModel objectForKey: key] forKey: kColumnValueKey];
			
			[fieldsAndValues addObject: fieldDictionary];
		}
		
		success = [_database executeUpdate: [self buildSQLInsert: fieldsAndValues table: tableName]];
		
		//DEBUG_LOG(_sql);
	}
	
	
	SAFE_RELEASE(tableName);
	SAFE_RELEASE(fieldsAndValues);
	
	return success;
}

- (BOOL) insert {
//	NSAssert([_database open], @"Database is not open.");
	
	NSEnumerator *iterator = nil;
	NSMutableDictionary *fieldDictionary = nil;
	NSMutableArray *fieldsAndValues = nil;
	BOOL success = NO;
	NSString *key = nil;
	NSString *tableName = nil;
	
	fieldsAndValues = [[NSMutableArray alloc] initWithCapacity: [_dataModelKeys count]];
	iterator = [_changedValues keyEnumerator];
	
	if([_dataModel isKindOfClass: [NSDictionary class]]) {
		if([_dataModel objectForKey: kTableNameKey])
			tableName = [[NSString alloc] initWithString: [[_dataModel objectForKey: kTableNameKey] lowercaseString]];
	}
	
	else
		tableName = [[NSString alloc] initWithString: [NSStringFromClass([_dataModel class]) lowercaseString]];
	
//	DEBUG_LOG([_changedValues description]);
	
	while (key = [iterator nextObject]) {
		fieldDictionary = [[NSMutableDictionary alloc] initWithCapacity: 2];
		
		[fieldDictionary setObject: key forKey: kColumnNameKey];
		[fieldDictionary setObject: [_changedValues valueForKey: key] forKey: kColumnValueKey];
		
		[fieldsAndValues addObject: fieldDictionary];
	}
	
	[self buildSQLInsert: fieldsAndValues table: tableName];
	
	SAFE_RELEASE(tableName);
	SAFE_RELEASE(fieldsAndValues);
	
	success = [_database executeUpdate: _sql];
	
	if(!success)
		[self handleError: nil];
	
	//[_database close];
	
	return success;
}

/**
 *	Expects and array in this format
 *
 *	NSArray	[0] =>	NSDictionary =>	{name => "name",
 *									value => "value", 
 *									omit => "omit"}
 *
 */

- (BOOL) update {
//	NSAssert([_database open], @"Database is not open.");
	NSAssert([_changedValues isKindOfClass: [NSDictionary class]] && [_changedValues count], 
			 @" DCSQLite._changedValues is invalid (empty, nil, or dangling pointer).");
	
	NSEnumerator *iterator = nil;
	NSString *key = nil;
	NSString *tableName = nil;
	NSMutableDictionary *fieldDictionary = nil;
	NSMutableArray *fieldsAndValues = nil;
	NSString *whereClause = nil;
	BOOL success = NO;
	
	fieldsAndValues = [[NSMutableArray alloc] initWithCapacity: [_dataModel count]];
	
	if([_dataModel isKindOfClass: [NSDictionary class]]) {
		if([_dataModel objectForKey: kTableNameKey])
			tableName = [[NSString alloc] initWithString: [[_dataModel objectForKey: kTableNameKey] lowercaseString]];
	}
	
	else
		tableName = [[NSString alloc] initWithString: [NSStringFromClass([_dataModel class]) lowercaseString]];
	
	iterator = [_changedValues keyEnumerator];
	
	while (key = [iterator nextObject]) {
		fieldDictionary = [[[NSMutableDictionary alloc] initWithCapacity: 2] autorelease];
		
		[fieldDictionary setObject: key forKey: kColumnNameKey];
		[fieldDictionary setObject: [_changedValues objectForKey: key] forKey: kColumnValueKey];
		
		[fieldsAndValues addObject: fieldDictionary];
	}
	
	iterator = nil;
		
	if(_whereClause)
		whereClause = [[NSString alloc] initWithString: _whereClause];
		
	[self buildSQLUpdate: fieldsAndValues table: tableName where: whereClause];
	
	SAFE_RELEASE(fieldsAndValues);
	SAFE_RELEASE(whereClause);
	
	success = [_database executeUpdate: _sql];
		
	if(!success)
		[self handleError: nil];
	
	//[_database close];
	
	return success;
}


- (BOOL) delete {
//	NSAssert([_database open], @"Database is not open.");
	
	BOOL success = NO;
	NSString *tableName = nil;
	NSString *whereClause = nil;
	
	if([_dataModel isKindOfClass: [NSDictionary class]]) {
		if([_dataModel objectForKey: kTableNameKey])
			tableName = [[NSString alloc] initWithString: [[_dataModel objectForKey: kTableNameKey] lowercaseString]];
	}
	
	else
		tableName = [[NSString alloc] initWithString: [NSStringFromClass([_dataModel class]) lowercaseString]];
	
	if(!_whereClause)
		whereClause = [[NSString alloc] initWithString: [self buildWhereClauseWithCollection: _changedValues comparisonOperator: @"=" conjoinedBy: @"AND"]];
	else
		whereClause = [[NSString alloc] initWithString: _whereClause];

	[self buildSQLDelete: tableName where: whereClause];
		
	SAFE_RELEASE(tableName);
	SAFE_RELEASE(whereClause);
	
	//success = YES;
	success = [_database executeUpdate: _sql];
	
	if(!success)
		[self handleError: nil];
	
	//[_database close];
	
	return success;
}

- (NSUInteger) recordCount {
	NSString *tableName = nil;
	NSUInteger result = 0;
	
	if([_dataModel isKindOfClass: [NSDictionary class]]) {
		if([_dataModel objectForKey: kTableNameKey])
			tableName = [[NSString alloc] initWithString: [[_dataModel objectForKey: kTableNameKey] lowercaseString]];
	}
	
	else
		tableName = [[NSString alloc] initWithString: [NSStringFromClass([_dataModel class]) lowercaseString]];
	
	result = [self recordCountForTable: tableName];
	
	SAFE_RELEASE(tableName);
	
	return result;
}

- (NSUInteger) fieldCount {
	NSString *tableName = nil;
	NSUInteger result = 0;
	
	if([_dataModel isKindOfClass: [NSDictionary class]]) {
		if([_dataModel objectForKey: kTableNameKey])
			tableName = [[NSString alloc] initWithString: [[_dataModel objectForKey: kTableNameKey] lowercaseString]];
	}
	
	else
		tableName = [[NSString alloc] initWithString: [NSStringFromClass([_dataModel class]) lowercaseString]];
	
	result = [self fieldCountForTable: tableName];
	
	SAFE_RELEASE(tableName);
	
	return result;
}

- (NSString *) primaryKeyFieldName {
	NSString *tableName = nil;
	NSString *result = nil;
	
	if([_dataModel isKindOfClass: [NSDictionary class]]) {
		if([_dataModel objectForKey: kTableNameKey])
			tableName = [[NSString alloc] initWithString: [[_dataModel objectForKey: kTableNameKey] lowercaseString]];
	}
	
	else
		tableName = [[NSString alloc] initWithString: [NSStringFromClass([_dataModel class]) lowercaseString]];
	
	result = [[NSString alloc] initWithString: [self primaryKeyFieldNameForTable: tableName]];
	
	SAFE_RELEASE(tableName);
	
	return [result autorelease];
}

- (NSString *) stringForSQLQuery: (NSString *) selectStatement where: (NSString *) whereClause {
	NSString *tableName = nil;
	NSString *result = nil;
	
	if([_dataModel isKindOfClass: [NSDictionary class]]) {
		if([_dataModel objectForKey: kTableNameKey])
			tableName = [[NSString alloc] initWithString: [[_dataModel objectForKey: kTableNameKey] lowercaseString]];
	}
	
	else
		tableName = [[NSString alloc] initWithString: [NSStringFromClass([_dataModel class]) lowercaseString]];
	
	result = [self stringForSQLQuery: selectStatement fromTable: tableName where: whereClause];
	
	SAFE_RELEASE(tableName);
	
	return result;
}

- (NSString *) stringForSQLQuery: (NSString *) selectStatement groupBy: (NSString *) groupByClause having: (NSString *) havingClause {
	return [self stringForSQLQuery: selectStatement where: nil groupBy: groupByClause having: havingClause];
}

- (NSString *) stringForSQLQuery: (NSString *) selectStatement where: (NSString *) whereClause groupBy: (NSString *) groupByClause having: (NSString *) havingClause {
	NSString *tableName = nil;
	NSString *result = nil;
	
	if([_dataModel isKindOfClass: [NSDictionary class]]) {
		if([_dataModel objectForKey: kTableNameKey])
			tableName = [[NSString alloc] initWithString: [[_dataModel objectForKey: kTableNameKey] lowercaseString]];
	}
	
	else
		tableName = [[NSString alloc] initWithString: [NSStringFromClass([_dataModel class]) lowercaseString]];
	
	if(whereClause)
		result = [self stringForSQLQuery: selectStatement fromTable: tableName where: whereClause groupBy: groupByClause having: havingClause];
	
	else
		result = [self stringForSQLQuery: selectStatement fromTable: tableName groupBy: groupByClause having: havingClause];

	
	SAFE_RELEASE(tableName);
	
	return result;
}

- (NSNumber *) numberForSQLQuery: (NSString *) selectStatement where: (NSString *) whereClause {
	NSNumber *result = nil;
	NSString *tableName = nil;
	
	if([_dataModel isKindOfClass: [NSDictionary class]]) {
		if([_dataModel objectForKey: kTableNameKey])
			tableName = [[NSString alloc] initWithString: [[_dataModel objectForKey: kTableNameKey] lowercaseString]];
	}
	
	else
		tableName = [[NSString alloc] initWithString: [NSStringFromClass([_dataModel class]) lowercaseString]];
	
	result = [[self numberForSQLQuery: selectStatement fromTable: tableName where: whereClause] copy];
	
	SAFE_RELEASE(tableName);
		
	return [result autorelease];
}


- (NSNumber *) numberForSQLQuery: (NSString *) selectStatement groupBy: (NSString *) groupByClause having: (NSString *) havingClause {
	return [self numberForSQLQuery: selectStatement where: nil groupBy: groupByClause having: havingClause];
}

- (NSNumber *) numberForSQLQuery: (NSString *) selectStatement where: (NSString *) whereClause groupBy: (NSString *) groupByClause having: (NSString *) havingClause {
	NSNumber *result = nil;
	NSString *tableName = nil;
	
	if([_dataModel isKindOfClass: [NSDictionary class]]) {
		if([_dataModel objectForKey: kTableNameKey])
			tableName = [[NSString alloc] initWithString: [[_dataModel objectForKey: kTableNameKey] lowercaseString]];
	}
	
	else
		tableName = [[NSString alloc] initWithString: [NSStringFromClass([_dataModel class]) lowercaseString]];

	if(whereClause)
		result = [self numberForSQLQuery: selectStatement fromTable: tableName where: whereClause groupBy: groupByClause having: havingClause];
	
	else
		result = [self numberForSQLQuery: selectStatement fromTable: tableName groupBy: groupByClause having: havingClause];
	
	SAFE_RELEASE(tableName);
	
	return result;
}

- (NSArray *) resultSetForSQLQuery: (NSString *) selectStatement where: (NSString *) whereClause orderBy: (NSString *) orderBy {
	NSString *tableName = nil;
	NSArray *result = nil;
	
	if([_dataModel isKindOfClass: [NSDictionary class]]) {
		if([_dataModel objectForKey: kTableNameKey])
			tableName = [[NSString alloc] initWithString: [[_dataModel objectForKey: kTableNameKey] lowercaseString]];
	}
	
	else
		tableName = [[NSString alloc] initWithString: [NSStringFromClass([_dataModel class]) lowercaseString]];
	
	result = [[NSArray alloc] initWithArray: [self resultSetForSQLQuery: selectStatement fromTable: tableName where: whereClause orderBy: orderBy]];
	
 	SAFE_RELEASE(tableName);
	
	return [result autorelease];
}

- (NSArray *) resultSetForSQLQuery: (NSString *) selectStatement groupBy: (NSString *) groupByClause having: (NSString *) havingClause orderBy: (NSString *) orderBy {
	return [self resultSetForSQLQuery: selectStatement where: nil groupBy: groupByClause having: havingClause orderBy: orderBy];
}

- (NSArray *) resultSetForSQLQuery: (NSString *) selectStatement where: (NSString *) whereClause groupBy: (NSString *) groupByClause having: (NSString *) havingClause orderBy: (NSString *) orderBy {
	NSString *tableName = nil;
	NSArray *result = nil;
	
	if([_dataModel isKindOfClass: [NSDictionary class]]) {
		if([_dataModel objectForKey: kTableNameKey])
			tableName = [[NSString alloc] initWithString: [[_dataModel objectForKey: kTableNameKey] lowercaseString]];
	}
	
	else
		tableName = [[NSString alloc] initWithString: [NSStringFromClass([_dataModel class]) lowercaseString]];
	
	if(whereClause)
		result = [[NSArray alloc] initWithArray: [self resultSetForSQLQuery: selectStatement fromTable: tableName where: whereClause groupBy: groupByClause having: havingClause orderBy: orderBy]];
	
	else
		result = [[NSArray alloc] initWithArray: [self resultSetForSQLQuery: selectStatement fromTable: tableName groupBy: groupByClause having: havingClause orderBy: orderBy]];
 	
	SAFE_RELEASE(tableName);
	
	return [result autorelease];
}


- (NSArray *) resultSetForDatamodel {
	return [self resultSetForSQLQuery: @"*" where: nil orderBy: nil];
}

#pragma mark -
#pragma mark NSKeyValueObserving Protocol

- (void) setValue: (id) value forKey: (NSString *) key {
	NSAssert(_dataModel, @"DCSQLite._dataModel is nil");
	
	[_dataModel setValue: value forKey: key];
}

/*
//Invoked to inform the receiver that the value of a given property is about to change.
- (void) willChangeValueForKey: (NSString *) key {
}

//Invoked to inform the receiver that the specified change is about to be made to a specified unordered to-many relationship.
- (void) willChangeValueForKey: (NSString *) key withSetMutation: (NSKeyValueSetMutationKind) mutationKind usingObjects: (NSSet *) objects {

}

//Invoked to inform the receiver that the specified change is about to be executed at given indexes for a specified ordered to-many relationship.
- (void) willChange: (NSKeyValueChange) change valuesAtIndexes: (NSIndexSet *) indexes forKey: (NSString *) key {
}

//Invoked to inform the receiver that the value of a given property has changed.
- (void) didChangeValueForKey: (NSString *) key {
}
*/
//This message is sent to the receiver when the value at the specified key path relative to the given object has changed.
- (void) observeValueForKeyPath: (NSString *) keyPath ofObject: (id) object change: (NSDictionary *) change context: (void *) context {
	id newObject = nil;
	
	newObject = [change objectForKey: NSKeyValueChangeNewKey];
	
	[_changedValues setObject: newObject forKey: keyPath];
	
}

@end
