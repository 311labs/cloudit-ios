//
//  CloudItResponse.m
//  ThreeDMe
//
//  Created by Ian Starnes on 6/24/14.
//  Copyright (c) 2014 Ian Starnes. All rights reserved.
//

#import "CloudItAccount.h"
#import "CIGooglePlus.h"
#import "CIFacebook.h"
#import "CIModel.h"
#import "CIUser.h"

@implementation CloudItAccount {
    NSMutableDictionary* authProviders;
}


+ (id)shared {
    static dispatch_once_t pred = 0; \
    __strong static id _sharedObject = nil; \
    dispatch_once(&pred, ^{ \
        _sharedObject = [[self new] init]; \
    }); \
    return _sharedObject;
}

-(id)init
{
    self = [super init];
    if (self) {
        authProviders = [NSMutableDictionary new];
    }
    return self;
}

-(void)loadAuthProvider:(NSString*)provider withSettings:(NSDictionary*)settings
{
    CIAuthProvider* authProvider = nil;
    if ([provider isEqualToString:@"google"] || [provider isEqualToString:@"googleplus"])
    {
        authProvider = [[CIGooglePlus new] initWithSettings:settings];
    } else if ([provider isEqualToString:@"facebook"]) {
        authProvider = [[CIFacebook new] initWithSettings:settings];
    }
    
    [authProviders setObject:authProvider forKey:provider];
}


// check if authenticated
-(void)checkIfAuthenticated:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock
{
    [[CloudItService shared] GET:@"rpc/account/loggedin" params:nil onSuccess:successBlock onFailure:failBlock];
}

-(void)fetchMe:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock
{
    [[CloudItService shared] GET:@"rpc/account/user/me" params:nil onSuccess:successBlock onFailure:failBlock model:[CIUser class]];
}


// we will want to be able to login
-(void)loginWithUsername:(NSString*)username andPassword:(NSString*)password onSuccess:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock
{
    
}

-(void)handleServerProxy:(NSDictionary*)account provider:(NSString*)provider onSuccess:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock
{
    NSLog(@"social authenticated %@", account);
    NSString *path = [NSString stringWithFormat:@"rpc/account/login/%@", provider];
    [[CloudItService shared]POST:path params:account onSuccess:^(CloudItResponse *response) {
        // the server returns a profile field instead of data field here
        self.lastSocialProvider = provider;
        self.user = (CIUser*)response.model;
        self.email = self.user.email;
        self.displayName = self.user.displayName;
        self.thumbnailPath = self.user.thumbnailPath;
        successBlock(response);
    } onFailure:^(NSError *error) {
        failBlock(error);
    }];
}

// login with social
-(void)loginWithSocial:(NSString*)provider onSuccess:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock
{
    __weak CloudItAccount *blockSelf = self;
    CIAuthProvider* authProvider = [authProviders objectForKey:provider];
    if (authProvider) {
        [authProvider authenticate:^(NSDictionary *account) {
            // handle account dictonary to cloudit service
            [blockSelf handleServerProxy:account provider:provider onSuccess:successBlock onFailure:failBlock];
        } onFailure:^(NSError *error) {
            // report error
            failBlock(error);
        }];
    }
}

-(void)loginWithSocialVC:(UIViewController*)vc provider:(NSString*)provider onSuccess:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock
{
    __weak CloudItAccount *blockSelf = self;
    CIAuthProvider* authProvider = [authProviders objectForKey:provider];
    if (authProvider) {
        [authProvider authenticateWithVC: vc onSuccess:^(NSDictionary *account) {
            // handle account dictonary to cloudit service
            [blockSelf handleServerProxy:account provider:provider onSuccess:successBlock onFailure:failBlock];
        } onFailure:^(NSError *error) {
            // report error
            failBlock(error);
        }];
    }
}

// link a social account with your current account
-(void)linkSocial:(NSString*)provider onSuccess:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock
{
    
}

// logout
-(void)logout:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock
{
    [[CloudItService shared] GET:@"rpc/account/logout" params:nil onSuccess:successBlock onFailure:failBlock model:[CIUser class]];
}

// get my data
-(void)fetch:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock
{
    
}


- (void) syncUser:(CIUser *)user {
    _user = user;
    self.displayName = user.displayName;
    self.firstName = user.firstName;
    self.lastName = user.lastName;
    self.thumbnailPath = user.thumbnailPath;
    self.email = user.email;
}



@end