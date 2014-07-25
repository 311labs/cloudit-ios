//
//  CIVideoStats.m
//  ThreeDMe
//
//  Created by Ian Starnes on 6/24/14.
//  Copyright (c) 2014 Ian Starnes. All rights reserved.
//

#import "CIVideoStats.h"

@implementation CIVideoStats

-(id)initBlank
{
    self = [super init];
    if (self)
    {
        [self loadData:[NSMutableDictionary dictionaryWithDictionary:@{@"facebook":@(0),@"google":@(0),
                         @"twitter":@(0),@"pinterest":@(0),
                         @"shares":@(0),@"views":@(0),
                         @"likes":@(0)
                         }]];

    }
    return self;
}


-(NSNumber*) facebook
{
    return [self objectForKey:@"facebook"];
}

-(NSNumber*) google
{
    return [self objectForKey:@"google"];
}

-(NSNumber*) twitter
{
    return [self objectForKey:@"twitter"];
}

-(NSNumber*) pinterest
{
    return [self objectForKey:@"pinterest"];
}

-(NSNumber*) shares
{
    return [self objectForKey:@"shares"];
}

-(NSNumber*) likes
{
    return [self objectForKey:@"likes"];
}

-(NSNumber*) views
{
    return [self objectForKey:@"views"];
}

@end
