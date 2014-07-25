//
//  CIVideoRendition.h
//  ThreeDMe
//
//  Created by Ian Starnes on 6/24/14.
//  Copyright (c) 2014 Ian Starnes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CIModel.h"

@interface CIVideoRendition : CIModel

@property(readonly) NSString *name;
@property(readonly) NSString *path;

@property(readonly) NSNumber* width;
@property(readonly) NSNumber* height;
@property(readonly) NSNumber* bytes;

@end
