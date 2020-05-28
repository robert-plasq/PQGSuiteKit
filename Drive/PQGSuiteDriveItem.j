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

@import "../PQGSuiteClient.j"

var sFolderThumbnail = nil;
var sGoogleDocThumbnail = nil;
var sComicThumbnail = nil;

@implementation PQGSuiteDriveItem : CPObject
{
    CPString _id;
    CPString _name;    
    CPString _mimeType;
    CPURL _thumbnailLink;
    CPImage _thumbnail;
}

+ (PQGSuiteDriveItem)rootItem
{
    var rootItem = [PQGSuiteDriveItem new];
    rootItem._id = @"root";
    rootItem._name = @"My Drive";
    rootItem._mimeType = @"application/vnd.google-apps.folder";
    return rootItem;
}

- (id)initWithFile:(id)file
{
    [super init];
    _id = file.id;
    _name = file.name;
    _mimeType = file.mimeType;
    if (file.thumbnailLink != nil) {
        _thumbnailLink = [CPURL URLWithString: file.thumbnailLink];
    }
    return self;
}

+ (CPImage)folderThumbnail
{
    if (sFolderThumbnail === nil) {
        sFolderThumbnail = [[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:@"google-folder.png"]  size: CGSizeMake(64, 64)];
    }
    return sFolderThumbnail;
}

+ (CPImage)googleDocThumbnail
{
    if (sGoogleDocThumbnail === nil) {
        sGoogleDocThumbnail = [[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:@"google-document.png"]  size: CGSizeMake(64, 64)];
    }
    return sGoogleDocThumbnail;
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

- (BOOL)isFolder
{
    return [_mimeType isEqualToString: @"application/vnd.google-apps.folder"];
}

- (CPImage)thumbnail
{
    if ([self isFolder]) {
        return [PQGSuiteDriveItem folderThumbnail];
    }
    
    // Google docs are weird
    if (_thumbnailLink === nil) {
        return [PQGSuiteDriveItem googleDocThumbnail];
    }
        
    if (_thumbnail === nil) {
        _thumbnail = [[CPImage alloc] initWithContentsOfURL: _thumbnailLink];
    }
    return _thumbnail;
}

- (CPString)description
{
    return [CPString stringWithFormat: @"%@:[name: %@, mimeType: %@]", [super description], _name, _mimeType];
}

@end

