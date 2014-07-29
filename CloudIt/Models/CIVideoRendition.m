//
//  CIVideoRendition.m
//  ThreeDMe
//
//  Created by Ian Starnes on 6/24/14.
//  Copyright (c) 2014 Ian Starnes. All rights reserved.
//

#import "CIVideoRendition.h"
#import "CIVideo.h"

@implementation CIVideoRendition

-(NSString*) name
{
    return [self.data objectForKey:@"name"];
}

-(NSString*) path
{
    return [self.data objectForKey:@"url"];
}

-(NSNumber*) width
{
    return [self objectForKey:@"width"];
}

-(NSNumber*) height
{
    return [self objectForKey:@"height"];
}

-(NSNumber*) bytes
{
    return [self objectForKey:@"bytes"];
}

- (CIVideoQuality)quality
{
    if ([self.name isEqualToString:@"360p"]) {
        return CIVideoQuality360p;
    } else if ([self.name isEqualToString:@"460p"]) {
        return CIVideoQuality480p;
    } else if ([self.name isEqualToString:@"720p"]) {
        return CIVideoQuality720p;
    }  else if ([self.name isEqualToString:@"Original"]) {
        return CIVideoQualityOriginal;
    } else{
        return CIVideoQualityNone;
    }
}

@end
