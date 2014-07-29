//
//  CIModel.h
//  ThreeDMe
//
//  Created by Ian Starnes on 6/24/14.
//  Copyright (c) 2014 Ian Starnes. All rights reserved.
//
// DON'T FORGET TO ADD THIS LOGIC TO YOUR APP DELEGAGE
//
//    Goto Facebook App page and configure with BundleID
//
//    Goto Project settings->INFO and add a URL TYPE
//        with the identifier and Scheme as your bundleID
//
//    Create a key called FacebookAppID with a string value, and add the app ID there.
//    Create a key called FacebookDisplayName with a string value, and add the Display Name you configured in the App Dashboard.
//    Create an array key called URL types with a single array sub-item called URL Schemes. Give this a single item with your app ID prefixed with fb. This is used to ensure the application will receive the callback URL of the web-based OAuth flow.
//
//
//  ADD TO APPDELEGATE
//
//    - (BOOL)application: (UIApplication *)application
//    openURL: (NSURL *)url
//    sourceApplication: (NSString *)sourceApplication
//    annotation: (id)annotation {
//        
//        // first try facebook
//        BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
//        
//        // next try google
//        if !(wasHandled) {
//            wasHandled = [GPPURLHandler handleURL:url
//                                sourceApplication:sourceApplication
//                                       annotation:annotation];
//        }
//        
//        
//        return wasHandled;
//    }

#import <Foundation/Foundation.h>

#import "CIAuthProvider.h"

@interface CIFacebook : CIAuthProvider


@end
