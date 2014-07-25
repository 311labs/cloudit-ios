//
//  CIVideoStats.h
//  ThreeDMe
//
//  Created by Ian Starnes on 6/24/14.
//  Copyright (c) 2014 Ian Starnes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CIModel.h"

@interface CIVideoStats : CIModel

@property(readonly) NSNumber* facebook;
@property(readonly) NSNumber* google;
@property(readonly) NSNumber* likes;
@property(readonly) NSNumber* pinterest;
@property(readonly) NSNumber* twitter;
@property(readonly) NSNumber* shares;
@property(readonly) NSNumber* views;
@property(readonly) NSNumber* comments;

@end
