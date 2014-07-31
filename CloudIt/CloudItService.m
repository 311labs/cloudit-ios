//
//  CloudItService.m
//  ThreeDMe
//
//  Created by Ian Starnes on 6/24/14.
//  Copyright (c) 2014 Ian Starnes. All rights reserved.
//

#import "CloudItService.h"
#import "CIVideo.h"

#import "CIMultipartInputStream.h"


@interface CloudItService ()

@property(nonatomic, strong) NSString *host;
@property(nonatomic, strong) NSString *csrf_token;
@property(nonatomic) AFHTTPSessionManager *manager;
@property(nonatomic) NSMutableDictionary *activeTasks;

@end

@implementation CloudItService

+ (id)shared {
    static dispatch_once_t pred = 0; \
    __strong static id _sharedObject = nil; \
    dispatch_once(&pred, ^{ \
        _sharedObject = [[self new] init]; \
    }); \
    return _sharedObject;
}

-(id)initWithHost: (NSString*)host
{
    self.host = host;
    self.duplicateRequestPolicy = DUP_REQ_CANCEL_EXISTING;
    self.activeTasks = [NSMutableDictionary dictionary];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    [config setHTTPAdditionalHeaders:@{ @"User-Agent" : @"CloudIT 1.0", @"Accept": @"application/json, text/javascript, */*; q=0.01"}];
    
//    NSURLCache *cache = [[NSURLCache alloc] initWithMemoryCapacity:10 * 1024 * 1024
//                                                      diskCapacity:50 * 1024 * 1024
//                                                          diskPath:nil];
//    
//    [config setURLCache:cache];
    
    self.manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:host] sessionConfiguration:config];
    self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];

    return self;
}

-(void)setCSRF: (NSString*)csrf
{
    self.csrf_token = csrf;
}

# pragma CORE SERVICES

-(void)updateCSRF: (id)response
{
//    NSArray* cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields] forURL:[NSURL URLWithString:self.host]];
//    NSLog(@"dumping cookies");
//    for (NSHTTPCookie* cookie in cookies) {
//        NSLog(@"%@", cookie.name);
//    }
    
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:self.host]];
    for (NSHTTPCookie *cookie in cookies) {
        // Here I see the correct rails session cookie
        if ([cookie.name isEqualToString: @"csrftoken"]) {
            self.csrf_token = cookie.value;
            NSLog(@"CSRF TOKEN SET: %@", self.csrf_token);
        }
    }

    
}

# pragma CIModel Fetchers
// fetch a CIModels by ID
-(NSURLSessionDataTask*)fetch:(Class)model withKey:(int)pk onSuccess:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock
{
    NSString* path = [NSString stringWithFormat:@"%@/%d", [model rpcPath], pk];
    return [self GET:path params:nil onSuccess:successBlock onFailure:failBlock model:model];
}

// fetch a list of CIModels
-(NSURLSessionDataTask*)fetchList:(Class)model params:(NSDictionary*)params onSuccess:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock
{
    return [self GET:[model rpcPath] params:params onSuccess:successBlock onFailure:failBlock model:model];
}

-(void)cancelRequestsWithPath:(NSString*)path
{
    for (NSString* taskPath in self.activeTasks) {
        if ([taskPath isEqualToString: path])
        {
            NSURLSessionDataTask *task = [self.activeTasks objectForKey:taskPath];
            if (task)
            {
                [task cancel];
                [self.activeTasks removeObjectForKey:taskPath];
            }
            return;

        }
    }
}


# pragma HTTP METHOD ABSTRACTION

-(NSURLSessionDataTask*)GET: (NSString*)path params:(NSDictionary*)params onSuccess:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock model:(Class)model
{
    if (self.duplicateRequestPolicy != DUP_REQ_ALLOW) {
        if (self.duplicateRequestPolicy == DUP_REQ_CANCEL_EXISTING)
        {
            [self cancelRequestsWithPath:path];
        } else {
            failBlock([NSError errorWithDomain:@"cloudit" code:404 userInfo:nil]);
            return nil;
        }
        
    }
    
    NSURLSessionDataTask *task = [self.manager GET:path parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        if (self.duplicateRequestPolicy != DUP_REQ_ALLOW) {
            [self.activeTasks removeObjectForKey:path];
        }
        if (httpResponse.statusCode == 200) {
            [self updateCSRF:responseObject];
            NSLog(@"response: %@", responseObject);
            if (model) {
                successBlock([[CloudItResponse new] initWithClass:model andResponse:responseObject]);
            } else {
                successBlock([[CloudItResponse new] initWithResponse:responseObject]);
            }
        } else {
            failBlock([NSError errorWithDomain:@"cloudit" code:httpResponse.statusCode userInfo:nil]);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        // ignore canceled tasks
        if (error.code != -999)
        {
            // unknown error
            if (self.duplicateRequestPolicy != DUP_REQ_ALLOW) {
                [self.activeTasks removeObjectForKey:path];
            }
            failBlock(error);
        }
        NSLog(@"Error: %@", error);
    }];
    if (self.duplicateRequestPolicy != DUP_REQ_ALLOW) {
        [self.activeTasks setObject:task forKey:path];
    }
    return task;
}

-(NSURLSessionDataTask*)GET: (NSString*)path params:(NSDictionary*)params onSuccess:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock
{
    return [self GET:path params:params onSuccess:successBlock onFailure:failBlock model:nil];
}

// ABSTRACT POST REQUESTS
-(NSURLSessionDataTask*)POST: (NSString*)path params:(NSDictionary*)params onSuccess:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock model:(Class)model
{
    [self.manager.requestSerializer setValue:self.csrf_token forHTTPHeaderField:@"X-CSRFToken"];
//    [self.manager.requestSerializer setValue:@"application/json, text/javascript, */*; q=0.01" forHTTPHeaderField:@"Accept"];
    [self.manager.requestSerializer setValue:self.host forHTTPHeaderField:@"Referer"];
    
    NSURLSessionDataTask *task = [self.manager POST:path parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        if (httpResponse.statusCode == 200) {
            [self updateCSRF:responseObject];
            if (model) {
                successBlock([[CloudItResponse new] initWithClass:model andResponse:responseObject]);
            } else {
                successBlock([[CloudItResponse new] initWithResponse:responseObject]);
            }
        } else {
            failBlock([NSError errorWithDomain:@"cloudit" code:httpResponse.statusCode userInfo:nil]);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failBlock(error);
        NSLog(@"Error: %@", error);
    }];
    // [task resume]; // is this needed???
    return task;
}

-(NSURLSessionDataTask*)POST: (NSString*)path params:(NSDictionary*)params onSuccess:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock
{
    return [self POST:path params:params onSuccess:successBlock onFailure:failBlock model:nil];
}

-(AFHTTPRequestOperation*)UPLOAD: (NSString*)path files:(NSDictionary*)files params:(NSDictionary*)params onSuccess:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock onProgress:(CloudItProgressCallback)progressBlock
{
    return [self UPLOAD:path files:files params:params onSuccess:successBlock onFailure:failBlock onProgress:progressBlock model: nil];
}

-(AFHTTPRequestOperation*)UPLOAD: (NSString*)path files:(NSDictionary*)files params:(NSDictionary*)params onSuccess:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock onProgress:(CloudItProgressCallback)progressBlock model:(Class)model
{
    CIMultipartInputStream *body = [[CIMultipartInputStream alloc] init];
    [body addParts: params];
    
    for (NSString* name in files){
        id obj = [files objectForKey:name];
        if([obj isKindOfClass:[NSArray class]]){
            //Is array
            NSArray* aobj = (NSArray*)obj;
            [body addPartWithName:name filename:aobj[0] path:aobj[1]];
        }else if([obj isKindOfClass:[NSDictionary class]]){
            //is dictionary
            NSDictionary* dobj = (NSDictionary*)obj;
            [body addPartWithName:name filename:[dobj objectForKey:@"filename"] path:[dobj objectForKey:@"path"]];
        }else{
            //is something else
            [body addPartWithName:name path:[files objectForKey:name]];
        }
        
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", self.host, path];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", [body boundary]] forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[body length]] forHTTPHeaderField:@"Content-Length"];
    [request setValue:self.csrf_token forHTTPHeaderField:@"X-CSRFToken"];
    [request setHTTPBodyStream:body];
    [request setHTTPMethod:@"POST"];
    
    
    [request setValue:self.csrf_token forHTTPHeaderField:@"X-CSRFToken"];
    [request setValue:self.host forHTTPHeaderField:@"Referer"];
    [request setValue:@"application/json, text/javascript, */*; q=0.01" forHTTPHeaderField:@"Accept"];
    
    if (model == nil) {
        model = [CIModel class];
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestOperation *operation =
    [manager HTTPRequestOperationWithRequest:request
                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         successBlock([[CloudItResponse new] initWithClass:model andResponse:responseObject]);
                                         NSLog(@"Success %@", responseObject);
                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         NSLog(@"Failure %@", error.description);
                                         failBlock(error);
                                     }];
    
    // 4. Set the progress block of the operation.
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        progressBlock(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
    }];
    // 5. Begin!
    [operation start];
    return operation;
    
//    NSURLSession* session = [self.manager session];
//    session.configuration.HTTPAdditionalHeaders = @{@"X-CSRFToken": self.csrf_token};
//    NSURLSessionUploadTask *task = [self.manager uploadTaskWithStreamedRequest:request progress:nil
//                              completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
//                                  // code
//                                  NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
//                                  if (httpResponse.statusCode == 200) {
//                                      [self updateCSRF:responseObject];
//                                      if (model) {
//                                          successBlock([[CloudItResponse new] initWithClass:model andResponse:responseObject]);
//                                      } else {
//                                          successBlock([[CloudItResponse new] initWithResponse:responseObject]);
//                                      }
//                                  } else {
//                                      failBlock(error);
//                                  }
//                              }];
//
//    [task resume];
//    return task;
}


-(NSURLSessionDownloadTask*)DOWNLOAD: (NSURL*)url toFilename:(NSString*)filename onSuccess:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock progress:(NSProgress*)progress
{
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    NSURLSessionDownloadTask *downloadTask = [self.manager downloadTaskWithRequest:request progress:&progress destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
//        // return destination for file
//        NSURL *documentsDirectory = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]];
//        return [documentsDirectory URLByAppendingPathComponent:filename];
//    } completionHandler:<#^(NSURLResponse *response, NSURL *filePath, NSError *error)completionHandler#>]
//    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request progress:&progress destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
//        // …
//    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
//        [progress removeObserver:self forKeyPath:@"fractionCompleted" context:NULL];
//        // …
//    }];
//    
//    [downloadTask resume];
//    return downloadTask;
    return nil;
}

@end
