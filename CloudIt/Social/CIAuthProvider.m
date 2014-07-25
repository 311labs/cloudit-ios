//
//  CIUser.m
//  ThreeDMe
//
//  Created by Ian Starnes on 6/24/14.
//  Copyright (c) 2014 Ian Starnes. All rights reserved.
//

#import "CIAuthProvider.h"

@implementation CIAuthProvider


// initialize provider with settings
-(id)initWithSettings:(NSDictionary*)settings
{
    return self;
}

// login with social
-(void)authenticate:(CIAuthSuccessCallback)successBlock onFailure:(CIAuthFailureCallback)failBlock
{
    // TODO UPDATE THESE ERRORS TO REPORT CORRECTLY 
    failBlock([NSError errorWithDomain:@"world" code:200 userInfo:nil]);
}
// try silent authentication if provider supports it
-(void)trySilentAuthentication:(CIAuthSuccessCallback)successBlock onFailure:(CIAuthFailureCallback)failBlock
{
    failBlock([NSError errorWithDomain:@"world" code:200 userInfo:nil]);
}

@end