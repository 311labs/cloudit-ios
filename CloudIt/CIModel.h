//
//  CIModel.h
//  ThreeDMe
//
//  Created by Ian Starnes on 6/24/14.
//  Copyright (c) 2014 Ian Starnes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CloudItService.h"

@interface CIModel : NSObject<NSCoding, NSCopying>

@property(retain, strong) NSMutableDictionary *data; //this is the ID as per the server

// the remote path for this instance
@property(readonly) NSString *path;
// the remote key for this instance
@property(readonly) NSNumber *key;

// flag if the model is in the middle of updating
@property(readonly) BOOL *isUpdating;

// the rpc path that this model uses
+(NSString*)rpcPath;
// fetch a single object
+(void)fetch:(int)key onSuccess:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock;
// fetch a list of objects
+(void)fetchList:(NSDictionary*)params onSuccess:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock;

// create a new model instance and load it with data
+(id)create:(Class)model withData:(NSMutableDictionary*)data;
// update existing model if it exists with data
+(id)getOrCreate:(Class)model withData:(NSMutableDictionary*)data;


-(id)initBlank;
-(id)initWithData:(NSMutableDictionary*)data;
-(void)loadData:(id)data;
-(void)setValue:(id)obj forKey:(NSString*)key;
// supports nested objects via dot notation (ie: "video.renditions")
-(id)objectForKey:(NSString*)key;
// returns a date object for the key
-(NSDate*)dateForKey:(NSString*)key;
-(double)doubleForKey:(NSString*)key;
-(int)intForKey:(NSString*)key;
-(BOOL)boolForKey:(NSString*)key;

// fetch the latest version of this object from the server
-(void)refresh:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock;

// post any changes to this object to the server
-(void)post:(NSDictionary*)changes onSuccess:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock;

// cancel any refresh tasks currently active
-(void)cancel;

@end
