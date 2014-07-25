//
//  CIVideo.h
//  ThreeDMe
//
//  Created by Ian Starnes on 6/24/14.
//  Copyright (c) 2014 Ian Starnes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CloudItService.h"
#import "CIUser.h"
#import "CIVideoStats.h"
#import "CIVideoRendition.h"
#import "CIVideoChannel.h"

typedef enum {
    OVVideoStateInactive = 0,
    OVVideoStateDeleted = 1,
    OVVideoStateArchived = 5,
    OVVideoStatePending = 100,
    OVVideoStateNotApproved = 100,
    OVVideoStateActive = 200,
} OVVideoState;


typedef enum {
    CIVideoQualityNone,
    CIVideoQualityOriginal,
    CIVideoQuality360p,
    CIVideoQuality480p,
    CIVideoQuality720p,
} CIVideoQuality;

@class CIVideo;

@interface CIVideo : CIModel

@property(readonly) NSString *uuid; //this is the key as per project file

@property(readonly) NSString *title;
@property(readonly) NSString *description;

@property(readonly) NSString *thumbnailPath;
@property(readonly) NSString *posterPath;
@property(readonly) NSString *youtubePath;
@property(readonly) int mediaID;

@property(readonly) NSArray *advisory;
@property(readonly) OVVideoState state;
@property(readonly) double duration;
@property(readonly) NSDate *created;

//@property(readonly) BOOL isMine;

@property(retain, nonatomic) CIUser* owner;

@property(retain, nonatomic) CIVideoChannel* channel;
@property(retain, nonatomic) CIVideoStats* stats;

@property(retain, nonatomic) NSArray* renditions;

-(CIVideoRendition*)originalRendtion;
-(CIVideoRendition*)renditionWithName:(NSString*)name;
-(NSURL*)renditionURLWithQuality:(CIVideoQuality)quality;

// share to youtube
-(void)shareToYoutube:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock;


// log events to the server
-(void)logView:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock;
-(void)logShare:(NSString*)sharedTo onSuccess:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock;

// ========= CLASS METHODS =========
// fetch a single object
+(void)fetch:(int)key onSuccess:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock;
// fetch a list of objects
+(void)fetchList:(NSDictionary*)params onSuccess:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock;

// upload video video file to server
+(AFHTTPRequestOperation*)upload:(NSURL*)filePath title:(NSString*)title channel:(int)channel onSuccess:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock progress:(CloudItProgressCallback)progressBlock;
+(AFHTTPRequestOperation*)upload:(NSURL*)filePath title:(NSString*)title channel:(int)channel uuid:(NSString*)uuid onSuccess:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock progress:(CloudItProgressCallback)progressBlock;
+(AFHTTPRequestOperation*)upload:(NSURL*)filePath filename:(NSString*)filename title:(NSString*)title channel:(int)channel uuid:(NSString*)uuid onSuccess:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock progress:(CloudItProgressCallback)progressBlock;

// get quality by rendition name
+(CIVideoQuality)qualityByName:(NSString*)name;

@end
