//
//  CIUser.h
//  ThreeDMe
//
//  Created by Ian Starnes on 6/24/14.
//  Copyright (c) 2014 Ian Starnes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CIModel.h"

@interface CIUser : CIModel

@property(readonly) NSString *displayName;
@property(readonly) NSString *username;
@property(readonly) NSString *email;
@property(readonly) NSString *firstName;
@property(readonly) NSString *lastName;

@property(readonly) NSDate *joined;
@property(readonly) NSDate *modified;

@property(readonly) BOOL isStaff;

@property(readonly) NSString *thumbnailPath;
@property(readonly) NSString *profilePath;

@property(readonly) NSArray *properties;
@property(readonly) NSDictionary *socialLinks;

-(NSString*)getProperty:(NSString*)key;

@end
