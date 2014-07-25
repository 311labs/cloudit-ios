//
//  CIVideo.m
//  ThreeDMe
//
//  Created by Ian Starnes on 6/24/14.
//  Copyright (c) 2014 Ian Starnes. All rights reserved.
//

#import "CIVideo.h"
#include "CIEXT.h"

@implementation CIVideo

+(NSString*) rpcPath
{
    return @"rpc/video";
}

// fetch a single object
+(void)fetch:(int)key onSuccess:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock
{
    [[CloudItService shared] fetch: [CIVideo class] withKey: key onSuccess: successBlock onFailure: failBlock];
}
// fetch a list of objects
+(void)fetchList:(NSDictionary*)params onSuccess:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock
{
    [[CloudItService shared] fetchList: [CIVideo class] params: params onSuccess: successBlock onFailure: failBlock];
}

+(AFHTTPRequestOperation*)upload:(NSURL*)filePath title:(NSString*)title channel:(int)channel onSuccess:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock progress:(CloudItProgressCallback)progressBlock
{
    return [[self class]upload:filePath filename:nil title:title channel:channel uuid:nil onSuccess:successBlock onFailure:failBlock progress:progressBlock];
}

+(AFHTTPRequestOperation*)upload:(NSURL*)filePath title:(NSString*)title channel:(int)channel uuid:(NSString*)uuid onSuccess:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock progress:(CloudItProgressCallback)progressBlock
{
    return [[self class]upload:filePath title:title channel:channel uuid:uuid onSuccess:successBlock onFailure:failBlock progress:progressBlock];
}

+(AFHTTPRequestOperation*)upload:(NSURL*)filePath filename:(NSString*)filename title:(NSString*)title channel:(int)channel uuid:(NSString*)uuid onSuccess:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock progress:(CloudItProgressCallback)progressBlock
{
    NSMutableDictionary *params = [@{
                                     @"title" : title,
                                     @"agree" : @(1),
                                     @"state" : @(200),
                                     } mutableCopy];
    [params setObjectIfNotNil:uuid forKey:@"uuid"];
    NSDictionary* files;
    if (filename)
    {
        files = @{@"video":@{@"filename":filename, @"path":filePath}};
    } else {
        files = @{@"video":filePath};
    }
    
    return [[CloudItService shared] UPLOAD:@"rpc/video/" files:files params:params onSuccess:successBlock onFailure:failBlock onProgress:progressBlock];
}

//=============================
#pragma property mappings
-(NSString*) projectKey
{
    return [self.data objectForKey:@"uuid"];
}

-(NSString*) title
{
    return [self.data objectForKey:@"title"];
}

-(NSString*) descriptiion
{
    return [self.data objectForKey:@"descriptiion"];
}

-(NSString*) thumbnailPath
{
    return [self.data objectForKey:@"thumbnail_url"];
}

-(NSString*) posterPath
{
    return [self.data objectForKey:@"poster_url"];
}

-(NSString*) youtubePath
{
    return [self.data objectForKey:@"youtube_url"];
}

-(int) mediaID
{
    return [self intForKey:@"media.id"];
}

-(NSArray*) advisory
{
    return [self.data objectForKey:@"advisor"];
}

-(OVVideoState) state
{
    return [self intForKey:@"state.value"];
}

-(double) duration
{
    return [self doubleForKey:@"duration"];
}

-(NSDate*) created
{
    // TODO save date object in a place holder
    return [self dateForKey:@"created"];
}

-(BOOL) isMine
{
    // TODO save date object in a place holder
    return [self boolForKey:@"is_mine"];
}

-(CIVideoChannel*) channel
{
    if (_channel == nil) {
        self.channel = [CIModel getOrCreate:[CIVideoChannel class] withData:[self.data objectForKey:@"channel"]];
    }
    return _channel;
}

-(CIUser*) owner
{
    if (_owner == nil) {
        self.owner = [CIModel getOrCreate:[CIUser class] withData:[self.data objectForKey:@"owner"]];
    }
    return _owner;
}

-(CIVideoStats*) stats
{
    if (_stats == nil) {
        self.stats = [CIModel create:[CIVideoStats class] withData:[self.data objectForKey:@"stats"]];
    }
    return _stats;
}

#pragma rendtion filters

+(CIVideoQuality)qualityByName:(NSString*)name
{
    if ([name isEqualToString:@"360p"]) {
        return CIVideoQuality360p;
    } else if ([name isEqualToString:@"460p"]) {
        return CIVideoQuality480p;
    } else if ([name isEqualToString:@"720p"]) {
        return CIVideoQuality720p;
    }  else if ([name isEqualToString:@"Original"]) {
        return CIVideoQualityOriginal;
    } else{
        return CIVideoQualityNone;
    }
}

-(CIVideoRendition*) originalRendtion
{
    return [self renditionWithName:@"Original"];
}

-(CIVideoRendition*)renditionWithName:(NSString*)name
{
    NSArray* renditions = [self objectForKey:@"media.renditions"];
    if (renditions == nil) {
        return nil;
    }

    for (NSMutableDictionary* item in renditions) {
        NSString* n = [item objectForKey:@"name"];
        if ([name isEqualToString:n]) {
            return [CIModel create:[CIVideoRendition class] withData:item];
        }
    }
    return nil;
}

-(CIVideoRendition*)renditionWithQuality:(CIVideoQuality)quality
{
    NSArray* renditions = [self objectForKey:@"media.renditions"];
    if (renditions == nil) {
        return nil;
    }

    for (NSMutableDictionary* item in renditions) {
        NSString* n = [item objectForKey:@"name"];
        if ([CIVideo qualityByName:n] == quality) {
            return [CIModel create:[CIVideoRendition class] withData:item];
        }
    }
    return nil;
}

-(NSURL*)renditionURLWithQuality:(CIVideoQuality)quality
{
    NSArray* renditions = [self objectForKey:@"media.renditions"];
    if (renditions == nil) {
        return nil;
    }
    
    for (NSDictionary* item in renditions) {
        NSString* n = [item objectForKey:@"name"];
        if ([CIVideo qualityByName:n] == quality) {
            return [NSURL URLWithString:[item objectForKey:@"url"]];
        }
    }
    return nil;
}

#pragma remote logging of events

-(void)shareToYoutube:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock
{
    NSString *logPath = [NSString stringWithFormat:@"rpc/video/%@/youtube/",
                                   self.key];
    [[CloudItService shared] POST:logPath params:nil onSuccess:successBlock onFailure:failBlock];
}


-(void)logView:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock
{
    NSString* logPath = [NSString stringWithFormat:@"rpc/content/%@/log/view/", self.key];
    [[CloudItService shared] POST:logPath params:nil onSuccess:successBlock onFailure:failBlock];
}

-(void)logShare:(NSString*)sharedTo onSuccess:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock
{
    NSString* logPath = [NSString stringWithFormat:@"rpc/content/%@/log/share/", self.key];
    [[CloudItService shared] POST:logPath params:@{@"website":sharedTo} onSuccess:successBlock onFailure:failBlock];
}


@end
