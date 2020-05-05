/*
 * PQGSuiteDriveManager.j
 * PQGSuiteKit
 *
 * Created by Robert Grant on April 30, 2020.
 *
 * See LICENSE file for license information.
 *
 */

@import <Foundation/Foundation.j>

@import "../PQGSuiteClient.j"
@import "PQGSuiteDriveItem.j"

sDefaultProperties = nil;

PQGSuiteDriveIDProperty            = @"id";
PQGSuiteDriveNameProperty          = @"name";
PQGSuiteDriveThumbnailLinkProperty = @"thumbnailLink";
PQGSuiteDriveMimeTypeProperty      = @"mimeType"; 

@protocol PQGSuiteDriveManagerDelegate <CPObject>

    - (void)driveManager: (PQGSuiteDriveManager)manager didReceiveFiles:(CPArray)files forDirectory:(CPString)directoryID;

@end

@implementation PQGSuiteDriveManager : CPObject
{
    id _auth; // Javascript object
    id<PQGSuiteDriveManagerDelegate> _delegate;
}
    

- (id)init
{
    return self;   
}

+ (PQGSuiteDriveManager)driveManagerWithAuthorization:(id)authorization
{
    var driveManager = [[PQGSuiteDriveManager alloc] init];
     driveManager._auth = authorization;
    return driveManager;
}


+ (CPArray)DefaultProperties
{
    if (sDefaultProperties === nil) {
        sDefaultProperties = [CPArray arrayWithObjects: PQGSuiteDriveIDProperty,
                                                        PQGSuiteDriveNameProperty,
                                                        PQGSuiteDriveThumbnailLinkProperty,
                                                        PQGSuiteDriveMimeTypeProperty, nil];
    }
    return sDefaultProperties;
}

- (void)setDelegate:(id<PQGSuiteDriveManagerDelegate>)delegate
{
    _delegate = delegate;
}

- (void)contentsOfHomeDirectory
{
    [self contentsOfDirectoryWithID: @"root" includingPropertiesForKeys: [PQGSuiteDriveManager DefaultProperties]];    
}

- (void)contentsOfDirectoryWithID:(CPString)directoryID includingPropertiesForKeys:(CPArray)keys
{
    var query = [CPString stringWithFormat: @"'%@' in parents", directoryID];
    var fields = [CPString stringWithFormat: @"nextPageToken, files(%@)", [keys componentsJoinedByString: @", "]];
    gapi.client.drive.files.list({
        'q': query,
        'fields': fields
        }).then(function(response) {
            var files = response.result.files;
            var contents = [CPArray array];
            if (files && files.length > 0) {
                for (var i = 0; i < files.length; i++) {
                    var file = files[i];
                    var item = [[PQGSuiteDriveItem alloc] initWithFile: file];
                    [contents addObject: item];
                }
            }
            [_delegate driveManager: self didReceiveFiles: contents forDirectory: directoryID];
        }
    );
}

@end
