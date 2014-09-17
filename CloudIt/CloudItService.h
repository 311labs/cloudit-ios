//
//  CloudItService.h
//  ThreeDMe
//
//  Created by Ian Starnes on 6/24/14.
//  Copyright (c) 2014 Ian Starnes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CloudItResponse.h"
#import "AFNetworking.h"

typedef void (^CloudItSuccessCallback)(CloudItResponse *response);
typedef void (^CloudItFailureCallback)(NSError *error);
typedef void (^CloudItProgressCallback)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite);


typedef NS_ENUM(NSInteger, DuplicateRequestPolicy) {
    DUP_REQ_ALLOW,
    DUP_REQ_CANCEL_EXISTING,
    DUP_REQ_CANCEL_NEW
};

@interface CloudItService : NSObject

@property (nonatomic) DuplicateRequestPolicy duplicateRequestPolicy;

+(id)shared;

//    We will want to keep the CSRF Token
-(id)initWithHost:(NSString*)host;



// CIMODEL HELPERS
// fetch a CIModel by UUID
-(NSURLSessionDataTask*)fetch:(Class)model withUUID:(NSString*)pk onSuccess:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock;
// fetch a CIModels by ID
-(NSURLSessionDataTask*)fetch:(Class)model withKey:(int)pk onSuccess:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock;
// fetch a list of CIModels
-(NSURLSessionDataTask*)fetchList:(Class)model params:(NSDictionary*)params onSuccess:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock;
// cancel all requests with path if policy is set
-(void)cancelRequestsWithPath:(NSString*)path;

// CORE HTTP METHOD HELPERS
// METHOD GET REQUESTS
-(NSURLSessionDataTask*)GET: (NSString*)path params:(NSDictionary*)params onSuccess:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock;
-(NSURLSessionDataTask*)GET: (NSString*)path params:(NSDictionary*)params onSuccess:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock model:(Class)model;


// METHOD POST REQUESTS
-(NSURLSessionDataTask*)POST: (NSString*)path params:(NSDictionary*)params onSuccess:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock;

// METHOD POST FOR UPLOADING FILES
-(AFHTTPRequestOperation*)UPLOAD: (NSString*)path files:(NSDictionary*)files params:(NSDictionary*)params onSuccess:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock onProgress:(CloudItProgressCallback)progressBlock;

-(AFHTTPRequestOperation*)UPLOAD: (NSString*)path files:(NSDictionary*)files params:(NSDictionary*)params onSuccess:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock onProgress:(CloudItProgressCallback)progressBlock model:(Class)model;


@end
