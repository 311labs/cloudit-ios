//
//  CIModel.m
//  ThreeDMe
//
//  Created by Ian Starnes on 6/24/14.
//  Copyright (c) 2014 Ian Starnes. All rights reserved.
//

#import "CIModel.h"

@interface CIModel ()

@property(nonatomic) NSURLSessionDataTask *activeTask;

@end

@implementation CIModel

+(NSString*) rpcPath
{
    return nil;
}

// fetch a single object
+(void)fetch:(int)key onSuccess:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock
{
//    [[CloudItService shared] fetch: [CIModel class] withKey: key onSuccess: successBlock onFailure: failBlock];
}
// fetch a list of objects
+(void)fetchList:(NSDictionary*)params onSuccess:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock
{
//    [[CloudItService shared] fetchList: [CIModel class] params: params onSuccess: successBlock onFailure: failBlock];
}

+ (NSMutableDictionary*)shared {
    static NSMutableDictionary *cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [NSMutableDictionary new];
    });
    return cache;
}

+(id)create:(Class)model withData:(NSMutableDictionary*)data
{
    CIModel* obj = [model new];
    return [obj initWithData:data];
}


+(id)getOrCreate:(Class)model withData:(NSMutableDictionary*)data
{
    // FUTURE WE WILL IMPLEMENT CACHING HERE!!
    CIModel* obj = [model new];
    return [obj initWithData:data];
}

-(id)initBlank
{
    self = [super init];
    self.isUpdating = NO;
    if (self)
    {
        self.data = [NSMutableDictionary dictionary];
    }
    return self;
}

-(id)initWithData:(NSMutableDictionary*)data
{
    self.isUpdating = NO;
    [self loadData:data];
    return self;
}

-(void)loadData:(id)data
{
    if ([data isKindOfClass:[NSMutableDictionary class]]) {
        self.data = data;
    } else if ([data isKindOfClass:[NSDictionary class]]) {
        self.data = [(NSDictionary*)data mutableCopy];
    } else if (data == nil) {
        NSLog(@"WARNING CIModel loadData should not be nil");
        self.data = [NSMutableDictionary dictionary];
    }
}

-(void)setValue:(id)obj forKey:(NSString*)key
{
    if (obj == nil)
    {
        return;
    }
    
    // check if we have to parse dot notation
    NSRange pos = [key rangeOfString:@"."];
    if (pos.location > 0) {
        // we need to parse the string
        NSArray* keys = [key componentsSeparatedByString:@"."];
        id object = self.data;
        id lobject = self.data;
        NSString* lk = [keys lastObject];
        for (NSString *k in keys) {
            lobject = object;
            object = [object objectForKey:k];
            
            if ([k isEqualToString:lk]) {
                [lobject setValue:obj forKey:key];
                return;
            }

            if (object == nil)
            {
                object = [NSMutableDictionary dictionary];
                [lobject setValue:object forKey:key];
            }
        }
        return;
    }
    
    [self.data setValue:obj forKey:key];
}

-(NSString*)path
{
    NSString* root = [[self class] rpcPath];
    return [root stringByAppendingPathComponent:[self.key stringValue]];
}

// fetch the latest version of this object from the server
-(void)refresh:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock
{
    self.isUpdating = YES;
    NSLog(@"path: %@", self.path);
    self.activeTask = [[CloudItService shared] GET:self.path params:nil onSuccess:^(CloudItResponse *response) {
        // update data
        self.isUpdating = NO;
        [self loadData:response.data];
        response.model = self;
        if (self.activeTask) {
            self.activeTask = nil;
        }
        successBlock(response);
    } onFailure:^(NSError *error) {
        self.isUpdating = NO;
        if (self.activeTask) {
            self.activeTask = nil;
        }
        // push error
        failBlock(error);
    }];
}

-(void)cancel
{
    self.isUpdating = NO;
    [[CloudItService shared] cancelRequestsWithPath:self.path];
    if (self.activeTask) {
        [self.activeTask cancel];
    }
}

// post any changes to this object to the server
-(void)post:(NSDictionary*)changes onSuccess:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock
{
    [[CloudItService shared] POST:self.path params:changes onSuccess:^(CloudItResponse *response) {
        // update data
        // the server does not always return the updates object
        for (NSString* key in changes) {
            [self setValue:changes[key] forKey:key];
        }
        successBlock(response);
    } onFailure:^(NSError *error) {
        // push error
        failBlock(error);
    }];
}

-(id)objectForKey:(NSString*)key
{
    // check if we have to parse dot notation
    NSRange pos = [key rangeOfString:@"."];
    if (pos.location > 0) {
        // we need to parse the string
        NSArray* keys = [key componentsSeparatedByString:@"."];
        id object = self.data;
        for (NSString *k in keys) {
            object = [object objectForKey:k];
            if (object == nil) {
                return nil;
            }
        }
        return object;
    }
    return [self.data objectForKey:key];
}

-(NSDate*)dateForKey:(NSString *)key
{
    NSNumber* value = [self objectForKey:key];
    if (value != nil)
    {
        NSTimeInterval seconds = [value doubleValue];
        return [[NSDate alloc] initWithTimeIntervalSince1970:seconds];
    }
    return nil;
}

-(BOOL)boolForKey:(NSString *)key
{
    NSNumber* value = [self objectForKey:key];
    if (value != nil)
    {
        return [value intValue];
    }
    return 0;
}

-(int)intForKey:(NSString *)key
{
    NSNumber* value = [self objectForKey:key];
    if (value != nil)
    {
        return [value intValue];
    }
    return 0;
}

-(double)doubleForKey:(NSString *)key
{
    NSNumber* value = [self objectForKey:key];
    if (value != nil)
    {
        return [value doubleValue];
    }
    return 0.0;
}

-(NSNumber*) key
{
    return [self.data objectForKey:@"id"];
}

//////////////////////////////////////////////////////////////
#pragma mark NSCoding impl
//////////////////////////////////////////////////////////////

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self)
    {
        self = [self initWithData:[coder decodeObjectForKey:@"self.data"]];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.data forKey:@"self.data"];
}
//////////////////////////////////////////////////////////////
#pragma mark NSCopying impl
//////////////////////////////////////////////////////////////

- (id)copyWithZone:(NSZone *)zone
{
    CIModel* obj = [CIModel create:[self class] withData:[self.data copy]];
    return obj;
}


@end
