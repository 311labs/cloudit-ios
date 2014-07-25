//
//  CIUser.m
//  ThreeDMe
//
//  Created by Ian Starnes on 6/24/14.
//  Copyright (c) 2014 Ian Starnes. All rights reserved.
//

#import "CIUser.h"

@implementation CIUser

+(NSString*) rpcPath
{
    return @"rpc/account/user";
}

// fetch a single object
+(void)fetch:(int)key onSuccess:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock
{
    [[CloudItService shared] fetch: [CIUser class] withKey: key onSuccess: successBlock onFailure: failBlock];
}
// fetch a list of objects
+(void)fetchList:(NSDictionary*)params onSuccess:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock
{
    [[CloudItService shared] fetchList: [CIUser class] params: params onSuccess: successBlock onFailure: failBlock];
}

-(NSString*) displayName
{
    return [self objectForKey:@"display_name"];
}

-(NSString*) username
{
    return [self objectForKey:@"username"];
}

-(NSString*) email
{
    return [self objectForKey:@"email"];
}

-(NSString*) firstName
{
    return [self objectForKey:@"first_name"];
}

-(NSString*) lastName
{
    return [self objectForKey:@"last_name"];
}

-(NSString*) thumbnailPath
{
    return [self objectForKey:@"thumbnail"];
}

-(NSString*) profilePath
{
    return [self objectForKey:@"profile_image"];
}

-(NSDate*) joined
{
    return [self dateForKey:@"created"];
}

-(NSDate*) modified
{
    // TODO save date object in a place holder
    return [self dateForKey:@"modified"];
}

-(BOOL) isStaff
{
    return [self boolForKey:@"is_staff"];
}

-(NSDictionary*) socialLinks
{
    return [self objectForKey:@"social_links"];
}

-(NSArray*) properties
{
    return [self objectForKey:@"properties"];
}

-(NSString*) getProperty:(NSString*)key
{
    NSArray* props = self.properties;
    for (NSDictionary* p in props) {
        if ([key isEqualToString:[p objectForKey:@"key"]]) {
            return p[@"value"];
        }
    }
    return nil;
}

@end
