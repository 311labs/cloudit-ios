//
//  CIUser.m
//  ThreeDMe
//
//  Created by Ian Starnes on 6/24/14.
//  Copyright (c) 2014 Ian Starnes. All rights reserved.
//

#import "CIFacebook.h"
#import <Social/Social.h>

#include "CIEXT.h"

@interface CIFacebook ()
@property(nonatomic, copy) NSString* appID;
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
        self.appID = [settings objectForKey:@"appID"];
    }

    return self;
}

-(void)authenticate:(CIAuthSuccessCallback)successBlock onFailure:(CIAuthFailureCallback)failBlock
{
    self.successCallback = successBlock;
    self.failCallback = failBlock;

    __weak CIFacebook *blockSelf = self;
//    if ([FBSession activeSession].appID)
//    {
//        [FBSession.activeSession closeAndClearTokenInformation];
//    }

    FBSession *session = [[FBSession alloc] initWithAppID:self.appID
                                              permissions:nil
                                          urlSchemeSuffix:nil
                                       tokenCacheStrategy:nil];
    
    [FBSession setActiveSession:session];
    [session openWithBehavior:FBSessionLoginBehaviorWithFallbackToWebView
            completionHandler:^(FBSession *blockSession,
                                FBSessionState state,
                                NSError *error) {
                [blockSelf sessionStateChanged:blockSession state:state error:error];
            }];
//    if (session.state == FBSessionStateCreatedTokenLoaded) {
////        [FBSession setActiveSession:session userInfo:@{FBSessionDidSetActiveSessionNotificationUserInfoIsOpening: @YES}];
//        // we open after the fact, in order to avoid overlapping close
//        // and open handler calls for blocks
//        //FBSessionLoginBehaviorUseSystemAccountIfPresent : FBSessionLoginBehaviorWithFallbackToWebView
//
//    }
    
    
//    [FBSession openActiveSessionWithReadPermissions:self.scope
//                                       allowLoginUI:YES
//                                  completionHandler:];


}

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState)state
                      error:(NSError *)error
{
    if (!error) {
        if (state == FBSessionStateOpen) {
//            __weak CIFacebook *blockSelf = self;
            self.successCallback(@{@"access_token": session.accessTokenData.accessToken});
//            [FBRequestConnection
//             startForMeWithCompletionHandler:^(FBRequestConnection *connection,
//                                               NSDictionary <FBGraphUser> *user,
//                                               NSError *blockError) {
//                 if (!blockError) {
//                     NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
//                     [dict setObject:session.accessTokenData.accessToken forKey:@"access_token"];
//                     [dict setObjectIfNotNil:[user objectForKey:@"email"] forKey:@"email"];
//                     [dict setObjectIfNotNil:[user objectForKey:@"verified"] forKey:@"verified"];
//                     [dict setObjectIfNotNil:user.username forKey:@"username"];
//                     [dict setObjectIfNotNil:user.objectID forKey:@"userID"];
//                     blockSelf.successCallback(dict);
//                 } else {
//                     //LogError(@"error retrieving session info %@", blockError);
//                     self.failCallback(error);
//                 }
//
//             }];
            
            
        }
    }

}

-(void)logout
{

}

+ (BOOL) shareURL:(NSString*)url withText:(NSString*)text withVC:(UIViewController*)vc
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewController *facebookSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [facebookSheet setInitialText:text];
        // obfuscation hack
        [facebookSheet addURL:[NSURL URLWithString:url]];
        [vc presentViewController:facebookSheet animated:YES completion:nil];
        return YES;
        
        
//        NSURL* link = [NSURL URLWithString:url];
//        [FBDialogs presentShareDialogWithLink:link
//                                      handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
//                                          if(error) {
//                                              NSLog(@"Error: %@", error.description);
//                                          } else {
//                                              NSLog(@"Success!");
//                                          }
//                                      }];
    } else {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       text, @"caption",
                                       url, @"link",
                                       nil];
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                               parameters:params
                                                  handler:nil];
    }
    return NO;
}

@end