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
@property(nonatomic, copy) NSDictionary* pending_post;

@property(assign)BOOL isAuthenticated;

@property(copy) CIAuthSuccessCallback successCallback;
@property(copy) CIAuthFailureCallback failCallback;

@property(copy) CISocialPostSuccessCallback postCallback;
@property(copy) CISocialPostFailureCallback postFail;
@end

@implementation CIFacebook

+ (id)shared {
    static dispatch_once_t pred = 0; \
    __strong static id _sharedObject = nil; \
    dispatch_once(&pred, ^{ \
        _sharedObject = [[self alloc] init]; \
    }); \
    return _sharedObject;
}

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
                                              permissions:self.scope
                                          urlSchemeSuffix:nil
                                       tokenCacheStrategy:nil];
    
    [FBSession setActiveSession:session];
    [session openWithBehavior:FBSessionLoginBehaviorWithFallbackToWebView
            completionHandler:^(FBSession *blockSession,
                                FBSessionState state,
                                NSError *error) {
                [blockSelf sessionStateChanged:blockSession state:state error:error];
            }];
    
    
//    // You must ALWAYS ask for public_profile permissions when opening a session
//    [FBSession openActiveSessionWithReadPermissions:@[@"public_profile"]
//                                       allowLoginUI:YES
//                                  completionHandler:
//     ^(FBSession *session, FBSessionState state, NSError *error) {
//         
//         // Retrieve the app delegate
//         AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
//         // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
//         [appDelegate sessionStateChanged:session state:state error:error];
//     }];
    
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
            self.isAuthenticated = YES;
            if (self.successCallback) {
                self.successCallback(@{@"access_token": session.accessTokenData.accessToken});
                self.successCallback = nil;
                self.failCallback = nil;
            }
            
            if (self.pending_post) {
                [self postPending];
            }

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
            
            return;
        }
    }
    
    if (self.postFail) {
        NSLog(@"%@", error);
        self.postFail(error);
        self.postFail = nil;
        self.postCallback = nil;
    }

}

-(void)logout
{

}

- (void) requestPermissions:(NSArray*)permissionsNeeded completionHandler:(FBSessionRequestPermissionResultHandler)handler
{
    // We will request the user's public profile and the user's birthday
    // These are the permissions we need:
    
    // Request the permissions the user currently has
    [FBRequestConnection startWithGraphPath:@"/me/permissions"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error){
                                  // These are the current permissions the user has:
                                  NSDictionary *currentPermissions= [(NSArray *)[result data] objectAtIndex:0];
                                  
                                  // We will store here the missing permissions that we will have to request
                                  NSMutableArray *requestPermissions = [[NSMutableArray alloc] initWithArray:@[]];
                                  
                                  // Check if all the permissions we need are present in the user's current permissions
                                  // If they are not present add them to the permissions to be requested
                                  for (NSString *permission in permissionsNeeded){
                                      if (![currentPermissions objectForKey:permission]){
                                          [requestPermissions addObject:permission];
                                      }
                                  }
                                  
                                  // If we have permissions to request
                                  if ([requestPermissions count] > 0){
                                      // Ask for the missing permissions
                                      [FBSession.activeSession
                                       requestNewReadPermissions:requestPermissions
                                       completionHandler:handler];
                                  } else {
                                      // Permissions are present
                                      // We can request the user information
                                      handler([FBSession activeSession], error);
                                  }
                                  
                              } else {
                                  // An error occurred, we need to handle the error
                                  // See: https://developers.facebook.com/docs/ios/errors
                                  handler([FBSession activeSession], error);
                              }
                          }];
}

- (void) postPending
{
    if (self.pending_post == nil) {
        return;
    }
    
    NSDictionary *params = self.pending_post;
    self.pending_post = nil;
    
    [self requestPermissions:@[@"publish_actions"] completionHandler:^(FBSession *session, NSError *error) {
        if (error) {
            self.postFail(error);
        } else {
            [FBRequestConnection startWithGraphPath:@"me/feed" parameters:params HTTPMethod:@"POST"
                                  completionHandler:^(FBRequestConnection *connection, id result, NSError *error){
                                      if ((error)&&(self.postFail)) {
                                          self.postFail(error);
                                          self.postFail = nil;
                                          self.postCallback = nil;
                                      } else if (self.postCallback) {
                                          self.postCallback(@"facebook");
                                          self.postFail = nil;
                                          self.postCallback = nil;
                                      }
                                  }];
        }
    }];
}

- (void) postLink:(NSString*)link withText:(NSString*)text onSuccess:(CISocialPostSuccessCallback)successBlock onFailure:(CISocialPostFailureCallback)failBlock
{
    NSMutableDictionary *fbArguments = [[NSMutableDictionary alloc] init];
    NSString* encodedUrl = [link stringByAddingPercentEscapesUsingEncoding:
                            NSASCIIStringEncoding];
    
    [fbArguments setObject:text forKey:@"message"];
    [fbArguments setObject:encodedUrl  forKey:@"link"];
    // ONLY FOR DEBUGING
    NSLog(@"ERRROR DEBUG CODE ENABLED");
    [fbArguments setObject:@"{'value': 'SELF'}" forKey:@"privacy"];
    self.pending_post = fbArguments;
    self.postCallback = successBlock;
    self.postFail = failBlock;
    
    if (self.isAuthenticated) {
        [self postPending];
    } else {
        [self authenticate:nil onFailure:^(NSError *error) {
            // fail
            if (self.postFail) {
                NSLog(@"%@", error);
                self.postFail(error);
                self.postFail = nil;
                self.postCallback = nil;
            }
        }];
    }
    
}

+ (BOOL) postURL:(NSString*)url withText:(NSString*)text onSuccess:(CISocialPostSuccessCallback)successBlock onFailure:(CISocialPostFailureCallback)failBlock
{
    CIFacebook *fb = [CIFacebook shared];
    // Ask for publish_actions permissions in context
    // We will post on behalf of the user, these are the permissions we need:
//    NSArray *permissionsNeeded = @[@"publish_actions"];
    [fb postLink:url withText:text onSuccess:successBlock onFailure:failBlock];
    
    
//    
//    // Request the permissions the user currently has
//    [FBRequestConnection startWithGraphPath:@"/me/permissions"
//                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//                              if (!error){
//                                  NSDictionary *currentPermissions= [(NSArray *)[result data] objectAtIndex:0];
//                                  NSMutableArray *requestPermissions = [[NSMutableArray alloc] initWithArray:@[]];
//                                  
//                                  // Check if all the permissions we need are present in the user's current permissions
//                                  // If they are not present add them to the permissions to be requested
//                                  for (NSString *permission in permissionsNeeded){
//                                      if (![currentPermissions objectForKey:permission]){
//                                          [requestPermissions addObject:permission];
//                                      }
//                                  }
//                                  
//                                  // If we have permissions to request
//                                  if ([requestPermissions count] > 0){
//                                      // Ask for the missing permissions
//                                      [FBSession.activeSession requestNewPublishPermissions:requestPermissions
//                                                                            defaultAudience:FBSessionDefaultAudienceFriends
//                                                                          completionHandler:^(FBSession *session, NSError *error) {
//                                                                              if (!error) {
//                                                                                  // Permission granted, we can request the user information
//                                                                                  [fb postLink:url withText:text onSuccess:successBlock onFailure:failBlock];
//                                                                              } else {
//                                                                                  // An error occurred, handle the error
//                                                                                  // See our Handling Errors guide: https://developers.facebook.com/docs/ios/errors/
//                                                                                  NSLog(@"%@", error.description);
//                                                                                  failBlock(error);
//                                                                              }
//                                                                          }];
//                                  } else {
//                                      // Permissions are present, we can request the user information
//                                      
//                                  }
//                                  
//                              } else {
//                                  // There was an error requesting the permission information
//                                  // See our Handling Errors guide: https://developers.facebook.com/docs/ios/errors/
//                                  NSLog(@"%@", error.description);
//                                  failBlock(error);
//                              }
//                          }];
    return YES;

}

+ (BOOL) shareURL:(NSString*)url withText:(NSString*)text withVC:(UIViewController*)vc completion:(CISocialPostSuccessCallback)successBlock
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewController *facebookSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [facebookSheet setInitialText:text];
        // obfuscation hack
        [facebookSheet addURL:[NSURL URLWithString:url]];
        [vc presentViewController:facebookSheet animated:YES completion:^{
            //
            successBlock(@"facebook");
        }];
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
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      //
                                                      successBlock(@"facebook");
                                                  }];
    }
    return NO;
}

@end