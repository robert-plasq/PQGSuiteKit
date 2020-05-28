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

@optional
    - (void)driveManager: (PQGSuiteDriveManager)manager didReceiveFiles:(CPArray)files forDriveItem:(PQGSuiteDriveItem)driveItem;
    - (void)driveManager: (PQGSuiteDriveManager)manager didReceiveAttributesForDriveItem:(PQGSuiteDriveItem)driveItem;

    - (void)driveManager: (PQGSuiteDriveManager)manager didDownloadDataForDriveItem:(PQGSuiteDriveItem)driveItem data:(CPData)data;

    - (void)driveManager: (PQGSuiteDriveManager)manager didUploadDataForDriveItem:(PQGSuiteDriveItem)driveItem;

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

+ (PQGSuiteDriveManager)driveManager
{
    var driveManager = [[PQGSuiteDriveManager alloc] init];
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
    [self contentsOfDirectoryForDriveItem: [PQGSuiteDriveItem rootItem] includingPropertiesForKeys: [PQGSuiteDriveManager DefaultProperties]];    
}

- (void)contentsOfDirectoryForDriveItem: (PQGSuiteDriveItem)driveItem
{
    [self contentsOfDirectoryForDriveItem: driveItem includingPropertiesForKeys: [PQGSuiteDriveManager DefaultProperties]];    
}

- (void)contentsOfDirectoryForDriveItem:(PQGSuiteDriveItem)driveItem includingPropertiesForKeys:(CPArray)keys
{
    var query = [CPString stringWithFormat: @"'%@' in parents and trashed = false", [driveItem ID]];
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
            if ([_delegate respondsToSelector:@selector(driveManager:didReceiveFiles:forDriveItem:)]) {
                [_delegate driveManager: self didReceiveFiles: contents forDriveItem: driveItem];
            }
        }
    );
}

- (void)attributesOfDriveItemWithID:(CPString)driveItemID
{
    [self attributesOfDriveItemWithID:driveItemID includingPropertiesForKeys: [PQGSuiteDriveManager DefaultProperties]];
}

- (void)attributesOfDriveItemWithID:(CPString)driveItemID includingPropertiesForKeys:(CPArray)keys
{
    var request = gapi.client.drive.files.get({fileId : driveItemID})
    request.execute(function(resp) {
        var item = [[PQGSuiteDriveItem alloc] initWithFile: resp];
        if ([_delegate respondsToSelector:@selector(driveManager:didReceiveAttributesForDriveItem:)]) {
            [_delegate driveManager: self didReceiveAttributesForDriveItem: item];
        }
    });
}

- (void)downloadDataForDriveItem:(PQGSuiteDriveItem)item
{
    gapi.client.drive.files.get({fileId : [item ID],
                                                alt : 'media'}).then(function(response) {
        var data = [CPData dataWithBytes: response.body];
        if ([_delegate respondsToSelector:@selector(driveManager:didDownloadDataForDriveItem:data:)]) {
            [_delegate driveManager: self didDownloadDataForDriveItem: item data: data];
        }
    });
}

- (void)uploadData:(CPData)data forDriveItem:(PQGSuiteDriveItem)item
{
    gapi.client.request({
        path: '/upload/drive/v3/files/' + [item ID],
        method: 'PATCH',
        params: {
            uploadType: 'media',
            mimeType: [item mimeType]
        },
        body: [data bytes]
    }).execute(function(response) {
        if ([_delegate respondsToSelector:@selector(driveManager:didUploadDataForDriveItem:)]) {
            [_delegate driveManager: self didUploadDataForDriveItem: item];
        }
    });
}

@end
