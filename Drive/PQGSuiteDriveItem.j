/*
 * PQGSuiteDriveItem.j
 * PQGSuiteKit
 *
 * Created by Robert Grant on April 30, 2020.
 *
 * See LICENSE file for license information.
 *
 */

@import <Foundation/Foundation.j>

@import "PQGSuiteClient.j"

@implementation PQGSuiteDriveItem : CPObject
{
    CPString _id;
    CPString _name;    
    CPString _mimeType;
}

- (id)initWithFile:(id)file
{
    [super init];
    _id = file.id;
    _name = file.name;
    _mimeType = file.mimeType;
    return self;
}


- (CPString)ID
{
    return _id;
}

- (CPString)name
{
    return _name;
}

- (CPString)mimeType
{
    return _mimeType;
}

- (CPString)description
{
    return [CPString stringWithFormat: @"%@:[name: %@, mimeType: %@]", [super description], _name, _mimeType];
}

@end

