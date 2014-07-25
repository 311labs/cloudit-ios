//
//  CIVideoChannel.m
//  ThreeDMe
//
//  Created by Ian Starnes on 6/24/14.
//  Copyright (c) 2014 Ian Starnes. All rights reserved.
//

#import "CIVideoChannel.h"

@implementation CIVideoChannel

-(NSString*) name
{
    return [self.data objectForKey:@"name"];
}

-(NSString*) description
{
    return [self.data objectForKey:@"description"];
}

-(int) pk
{
    return [self intForKey:@"id"];
}

@end
