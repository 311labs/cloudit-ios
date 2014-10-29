//
//  CIInstagram.h
//  Pods
//
//  Created by Ian Starnes on 9/24/14.
//
//

#import <Foundation/Foundation.h>
#import "CIAuthProvider.h"

@interface CIInstagram : CIAuthProvider

+ (id)shared;

@property(readonly) BOOL appAvailable;
@property(readonly) BOOL isLinked;

// to properly handle a instagram share the server should be setup to receive
// instagram posts for your app, this will tell the app what to link to
//-(void)reportShare;

// post an image to instagram via the app
-(void)openImage:(UIImage*)image caption:(NSString*)caption inView:(UIView*)view onSuccess:(CISocialPostSuccessCallback)successBlock onFailure:(CISocialPostFailureCallback)failBlock;

// post an image via a url to the app
-(void)openRemoteImage:(NSString*)imageLink caption:(NSString*)caption inView:(UIView*)view onSuccess:(CISocialPostSuccessCallback)successBlock onFailure:(CISocialPostFailureCallback)failBlock;

@end
