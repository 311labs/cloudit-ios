//
//  CloudItService.h
//  ThreeDMe
//
//  Created by Ian Starnes on 6/24/14.
//  Copyright (c) 2014 Ian Starnes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CloudItService.h"
#import "CIUser.h"


@interface CloudItAccount : NSObject <NSCoding>

+(id)shared;

@property(nonatomic, strong) CIUser *user;
- (void)syncUser:(CIUser *)user;
@property(nonatomic, strong) NSString *displayName;
@property(nonatomic, strong) NSString *firstName;
@property(nonatomic, strong) NSString *lastName;
@property(nonatomic, strong) NSString *email;
@property(nonatomic, strong) NSString *thumbnailPath;


@property(nonatomic, strong) NSString *lastSocialProvider;

@property(nonatomic, strong) NSMutableDictionary *socialCredentials;


// check if authenticated
-(void)checkIfAuthenticated:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock;

// will fetch a new user object for current authenticated user if one exists
-(void)fetchMe:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock;

// loads auth provider with settings
// this most be called before any provider can be used
-(void)loadAuthProvider:(NSString*)provider withSettings:(NSDictionary*)settings;

// we will want to be able to login
-(void)loginWithUsername:(NSString*)username andPassword:(NSString*)password onSuccess:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock;

// login with social
-(void)loginWithSocial:(NSString*)provider onSuccess:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock;

// login with social and local viewcontroller
-(void)loginWithSocialVC:(UIViewController*)vc provider:(NSString*)provider onSuccess:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock;


// link a social account with your current account
-(void)linkSocial:(UIViewController*)viewController provider:(NSString*)provider onSuccess:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock;

// logout
-(void)logout:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock;

// get my data
-(void)fetch:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock;

@end
