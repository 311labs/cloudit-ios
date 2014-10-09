//
//  CIModel.h
//  ThreeDMe
//
//  Created by Ian Starnes on 6/24/14.
//  Copyright (c) 2014 Ian Starnes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CloudItAccount.h"

typedef void (^CIAuthSuccessCallback)(NSDictionary *account);
typedef void (^CIAuthFailureCallback)(NSError *error);


@interface CIAuthProvider : NSObject

@property(nonatomic, strong) NSDictionary* properties;
@property(nonatomic, strong) NSDictionary* settings;
@property(nonatomic, strong) UIViewController* vc;

// initialize provider with settings
-(id)initWithSettings:(NSDictionary*)settings;

// login with social
-(void)authenticate:(CIAuthSuccessCallback)successBlock onFailure:(CIAuthFailureCallback)failBlock;

// login with social and local view controller
-(void)authenticateWithVC:(UIViewController*)vc onSuccess:(CIAuthSuccessCallback)successBlock onFailure:(CIAuthFailureCallback)failBlock;

// try silent authentication if provider supports it
-(void)trySilentAuthentication:(CIAuthSuccessCallback)successBlock onFailure:(CIAuthFailureCallback)failBlock;

+ (NSError *)errorWithCode:(int)code localizedDescription:(NSString *)description;

+ (void) showWebShare:(NSString*)link withVC:(UIViewController*)vc;

@end
