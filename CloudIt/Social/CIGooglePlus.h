//
//  CIModel.h
//  ThreeDMe
//
//  Created by Ian Starnes on 6/24/14.
//  Copyright (c) 2014 Ian Starnes. All rights reserved.
//
// DON'T FORGET TO ADD THIS LOGIC TO YOUR APP DELEGAGE
//
//    Goto GOOGLE Console and add GoogleID for Client Application (IOS)
//
//    Goto Project settings->INFO and add a URL TYPE
//        with the identifier and Scheme as your bundleID
//
// #import <GooglePlus/GooglePlus.h>
//    - (BOOL)application: (UIApplication *)application
//    openURL: (NSURL *)url
//    sourceApplication: (NSString *)sourceApplication
//    annotation: (id)annotation {
//        return [GPPURLHandler handleURL:url
//                      sourceApplication:sourceApplication
//                             annotation:annotation];
//    }

#import <Foundation/Foundation.h>
#import <GooglePlus/GooglePlus.h>

#import "CIAuthProvider.h"

@interface CIGooglePlus : CIAuthProvider<GPPSignInDelegate>

-(void)authForYouTube:(CIAuthSuccessCallback)successBlock onFailure:(CIAuthFailureCallback)failBlock;

@end
