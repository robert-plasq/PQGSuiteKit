/*
 * PQGSuiteClient.j
 * PQGSuiteKit
 *
 * Created by Robert Grant on April 30, 2020.
 *
 * See LICENSE file for license information.
 *
 */

@import <Foundation/Foundation.j>

/*
 * Oauth2 general reference: https://developers.google.com/identity/protocols/oauth2/
 * Oauth2 flow for web apps: https://developers.google.com/identity/protocols/oauth2/javascript-implicit-flow
 * Google Scopes reference:  https://developers.google.com/identity/protocols/oauth2/scopes
 */

var PQ_GSUITE_CLIENTID="PQGSuiteClientID";
var GOOGLE_SIGNIN_PROFILE = "profile";
var GOOGLE_SIGNIN_EMAIL = "email";

var gSuiteClient = nil;

@protocol PQGSuiteClientDelegate <CPObject>

    - (void)gsuiteClient: (PQGSuiteClient)client signInStatusChanged:(BOOL)status;

@end
    
@implementation PQGSuiteClient : CPObject
{
    BOOL _isSignedIn;
    id<PQGSuiteClientDelegate> _delegate;
    id _auth2; // Javascript object
}


+ (PQGSuiteClient)sharedGSuiteClient
{
    if (gSuiteClient == nil) {
        gapi.load('client:auth2', start);
        gSuiteClient = [[PQGSuiteClient alloc] init];
    }
    
    return gSuiteClient;
}

- (id)authorization
{
    return _auth2;
}

- (void)setDelegate:(id<PQGSuiteClientDelegate>)delegate
{
    _delegate = delegate;
}

function start() {
// Todo: Figure out a better time to load Drive
    gapi.client.load('drive', 'v3', function () {
        var clientID = [[CPBundle mainBundle] objectForInfoDictionaryKey: PQ_GSUITE_CLIENTID];
    
        if (clientID == nil) {
            [CPException raise:CPInternalInconsistencyException
                        reason:@"PQGSuiteClientID required to be set in Info.plist"];
        }
        
        gapi.client.init({
            clientId: clientID,
		// Todo: Figure out a cleaner way to establish scopes.
            scope: 'profile email https://www.googleapis.com/auth/drive'
        }).then(function () {
          // Listen for sign-in state changes.
          gapi.auth2.getAuthInstance().isSignedIn.listen(updateSigninStatus);
    
          // Handle the initial sign-in state.
          updateSigninStatus(gapi.auth2.getAuthInstance().isSignedIn.get());
        });
    });
    
}

function updateSigninStatus(isSignedIn)
{
        [gSuiteClient signInStatusChanged: isSignedIn];
}

- (void)signInStatusChanged:(BOOL)status
{
    _isSignedIn = status;
    if (_isSignedIn) {
        _auth2 = gapi.auth2.getAuthInstance();
    } else {
        _auth2 = nil;   
    }

    if (_delegate != nil) {
        [_delegate gsuiteClient: self signInStatusChanged: status];
    }
}

- (BOOL)isSignedIn
{
    return _isSignedIn;
}

- (void)signIn
{
     gapi.auth2.getAuthInstance().signIn();
}

- (void)signOut
{
     _auth2.signOut();
}

- (CPString)getName
{
    if (_isSignedIn) {
        var profile = _auth2.currentUser.get().getBasicProfile();
        return profile.getName();
    }
    return nil;
}

- (CPString)firstName
{
    if (_isSignedIn) {
        var profile = _auth2.currentUser.get().getBasicProfile();
        return profile.getGivenName();
    }
    return nil;    
}

- (CPString)getEmail
{
    if (_isSignedIn) {
        var profile = _auth2.currentUser.get().getBasicProfile();
        return profile.getEmail();
    }
    return nil;
}

@end
    
