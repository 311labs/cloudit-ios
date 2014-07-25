//
//  CloudItResponse.m
//  ThreeDMe
//
//  Created by Ian Starnes on 6/24/14.
//  Copyright (c) 2014 Ian Starnes. All rights reserved.
//

#import "CloudItResponse.h"
#import "CIModel.h"
#import "CIUser.h"

@implementation CloudItResponse

-(BOOL)isSuccessful
{
    return ([self.status intValue] != 0);
}

-(void)parseError:(NSDictionary*)response
{
    self.errorCode = [response objectForKey:@"error_code"];
    self.error = [response objectForKey:@"error"];
    
}

-(void)parseList:(NSMutableDictionary*)response
{
    NSNumber *num = [response objectForKey:@"size"];
    self.size = [num intValue];
    
    self.previousPageKey = [response objectForKey:@"page_before"];
    self.nextPageKey = [response objectForKey:@"page_next"];
    
    self.items = [response objectForKey:@"data"];
    
    if ((self.ModelClass) && (self.items != nil)) {
        NSMutableArray* model_items = [NSMutableArray array];
        for (NSMutableDictionary* item in self.items) {
            [model_items addObject:[CIModel create:self.ModelClass withData:item]];
        }
        self.items = [NSArray arrayWithArray:model_items];
    }
}

-(void)parseData:(NSMutableDictionary*)response
{
    self.data = [response objectForKey:@"data"];
    if (self.data == nil)
    {
        // special use case that happens on authentication
        self.data = [response objectForKey:@"profile"];
        if (self.data) {
            self.ModelClass = [CIUser class];
        }
    }
    
    if ((self.ModelClass)&&(self.data != nil)) {
        self.model = [CIModel create:self.ModelClass withData:self.data];
    } else if (self.data != nil)  {
        self.model = [[CIModel new] initWithData:self.data];
    } else if ([response objectForKey:@"id"]) {
        self.data = [NSMutableDictionary dictionaryWithDictionary:@{@"id":[response objectForKey:@"id"]}];
    } else {
        NSLog(@"no data for response");
    }
}


-(id)initWithClass:(Class)ModelClass andResponse:(NSMutableDictionary*)response
{
    self.ModelClass = ModelClass;
    return [self initWithResponse:response];
}

-(id)initWithResponse:(NSMutableDictionary*)response
{
    self.status = [response objectForKey:@"status"];
    if (self.status != nil) {
//        NSLog(@"json: %@", response);
        if ([self.status isEqual:@0]) {
            [self parseError:response];
            return self;
        }
    }
    
    self.info = [response objectForKey:@"info"];

    NSNumber *num = [response objectForKey:@"count"];
    if (num == nil) {
        [self parseData:response];
    } else {
        self.status = @(1);
        self.count = [num intValue];
        [self parseList:response];
    }
    
    return self;
}


@end
