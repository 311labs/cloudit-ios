//
//  CIUser.m
//  ThreeDMe
//
//  Created by Ian Starnes on 6/24/14.
//  Copyright (c) 2014 Ian Starnes. All rights reserved.
//

#import "CIGooglePlus.h"

#import <GoogleOpenSource/GoogleOpenSource.h>
#include "CIEXT.h"

@interface CIGooglePlus ()
    @property(copy) CIAuthSuccessCallback successCallback;
    @property(copy) CIAuthFailureCallback failCallback;
@end

@implementation CIGooglePlus

// initialize provider with settings
-(id)initWithSettings:(NSDictionary*)settings
{
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGooglePlusUser = YES;
    signIn.shouldFetchGoogleUserEmail = YES;
    signIn.clientID = [settings objectForKey:@"clientID"];
    signIn.delegate = self;
    return self;
}

-(void)authenticate:(CIAuthSuccessCallback)successBlock onFailure:(CIAuthFailureCallback)failBlock
{
    self.successCallback = successBlock;
    self.failCallback = failBlock;
    
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.scopes = @[kGTLAuthScopePlusMe];
    [signIn authenticate];
}

-(void)trySilentAuthentication:(CIAuthSuccessCallback)successBlock onFailure:(CIAuthFailureCallback)failBlock
{
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.scopes = @[kGTLAuthScopePlusMe];
    [signIn trySilentAuthentication];
}

-(void)authForYouTube:(CIAuthSuccessCallback)successBlock onFailure:(CIAuthFailureCallback)failBlock
{
    self.successCallback = successBlock;
    self.failCallback = failBlock;
    
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.scopes = @[kGTLAuthScopePlusMe, @"https://www.googleapis.com/auth/youtube", @"https://www.googleapis.com/auth/youtube.readonly"];
    [signIn authenticate];
}

-(void)logout
{
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    [signIn signOut];
    [signIn disconnect];
}


//////////////////////////////////////////////////////////////
#pragma mark GPPSignInDelegate impl
//////////////////////////////////////////////////////////////

- (void)finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error
{
    if (error == nil) {
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        [dict setObject:[auth valueForKey:@"accessToken"] forKey:@"access_token"];
        [dict setObjectIfNotNil:auth.userEmail forKey:@"email"];
        [dict setObjectIfNotNil:auth.userEmailIsVerified forKey:@"verified"];
        [dict setObjectIfNotNil:auth.refreshToken forKey:@"refresh_token"];
        [dict setObjectIfNotNil:auth.userID forKey:@"userID"];
        self.successCallback(dict);
    } else {
        [[GPPSignIn sharedInstance] signOut];
        self.failCallback(error);
    }
}


@end