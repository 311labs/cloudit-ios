//
//  CloudItResponse.h
//  ThreeDMe
//
//  Created by Ian Starnes on 6/24/14.
//  Copyright (c) 2014 Ian Starnes. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CIModel;

@interface CloudItResponse : NSObject

@property(nonatomic, strong) Class ModelClass;

@property(nonatomic, strong) NSNumber *status;
@property(nonatomic, strong) NSNumber *errorCode;
@property(nonatomic, copy) NSString *error;
@property(nonatomic, copy) NSString *info;
@property(readonly) BOOL isSuccessful;

@property(nonatomic, strong) NSMutableDictionary* data;
@property(nonatomic, strong) CIModel* model;

@property(nonatomic, strong) NSArray *items;
@property(nonatomic, assign) int count;
@property(nonatomic, assign) int size;
@property(nonatomic, assign) int start;
@property (copy, nonatomic) NSString *previousPageKey;
@property (copy, nonatomic) NSString *nextPageKey;

-(id)initWithClass:(Class)ModelClass andResponse:(NSMutableDictionary*)response;
-(id)initWithResponse:(NSMutableDictionary*)response;

@end
