//
//  CIUser.m
//  ThreeDMe
//
//  Created by Ian Starnes on 6/24/14.
//  Copyright (c) 2014 Ian Starnes. All rights reserved.
//
#import <FacebookSDK/FacebookSDK.h>

#import "CIFacebook.h"

#include "CIEXT.h"

@interface CIFacebook ()
@property(nonatomic, copy) NSArray* scope;
@property(copy) CIAuthSuccessCallback successCallback;
@property(copy) CIAuthFailureCallback failCallback;
@end

@implementation CIFacebook

// initialize provider with settings
-(id)initWithSettings:(NSDictionary*)settings
{
    if (settings) {
        self.scope = [settings objectForKey:@"scope"];
        if (!self.scope) {
            self.scope = @[@"public_profile", @"email"];
        }
    }

    return self;
}

-(void)authenticate:(CIAuthSuccessCallback)successBlock onFailure:(CIAuthFailureCallback)failBlock
{
    self.successCallback = successBlock;
    self.failCallback = failBlock;

    __weak CIFacebook *blockSelf = self;
    [FBSession.activeSession closeAndClearTokenInformation];
    FBSessionTokenCachingStrategy *tokenCachingStrategy =
    [[FBSessionTokenCachingStrategy alloc] initWithUserDefaultTokenInformationKeyName:@"reauth"];
    
    FBSession *session = [[FBSession alloc] initWithAppID:nil
                                              permissions:nil
                                          urlSchemeSuffix:nil
                                       tokenCacheStrategy:tokenCachingStrategy];
    
    [FBSession setActiveSession:session];
    [FBSession openActiveSessionWithReadPermissions:self.scope
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *blockSession,
                                                      FBSessionState state,
                                                      NSError *error) {
                                      [blockSelf sessionStateChanged:blockSession state:state error:error];
                                  }];


}

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState)state
                      error:(NSError *)error
{
    if (!error) {
        if (state == FBSessionStateOpen) {
            __weak CIFacebook *blockSelf = self;
            [FBRequestConnection
             startForMeWithCompletionHandler:^(FBRequestConnection *connection,
                                               NSDictionary <FBGraphUser> *user,
                                               NSError *blockError) {
                 if (!blockError) {
                     NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
                     [dict setObject:session.accessTokenData.accessToken forKey:@"access_token"];
                     [dict setObjectIfNotNil:[user objectForKey:@"email"] forKey:@"email"];
                     [dict setObjectIfNotNil:[user objectForKey:@"verified"] forKey:@"verified"];
                     [dict setObjectIfNotNil:user.username forKey:@"username"];
                     [dict setObjectIfNotNil:user.objectID forKey:@"userID"];
                     blockSelf.successCallback(dict);
                 } else {
                     //LogError(@"error retrieving session info %@", blockError);
                 }

             }];
            
            
        }
    }

}

-(void)logout
{

}


@end