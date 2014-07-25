//
//  ThreedBundle.h
//  ThreeDMe
//
//  Created by Ian Starnes on 7/19/14.
//  Copyright (c) 2014 Ian Starnes. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CIModel.h"

@interface CIThreeDBundle : CIModel<NSURLSessionDelegate, NSURLSessionTaskDelegate,
NSURLSessionDownloadDelegate>

// DATA FROM SERVER
@property (nonatomic) NSString *uuid;
@property (nonatomic) NSString *name;
@property (nonatomic) NSNumber *version;
@property (nonatomic) NSNumber *state;
@property (nonatomic) NSNumber *orderWeight;

@property (nonatomic) NSNumber *channelID;

//some items may only be active for a short while.
@property(nonatomic, assign) BOOL isActive;
//checks to see if the bundle is still downloaded
@property(nonatomic, readonly) BOOL isContentDownloaded;
//do we need to download again, update or no longer there
@property(nonatomic, readonly) BOOL isContentStale;


// localized marketing text
@property (nonatomic) NSString *marketingText;
// returns the marketingImage for the current device
@property (nonatomic) NSString *marketingImage;
// remote path to the marketing video
@property (nonatomic) NSString *marketingVideoPreviewPath;

// the store of all marketing data
@property (nonatomic) NSMutableDictionary *marketing;

// remote path to the bundle zip
@property(nonatomic) NSString *remotePath;


// =======================================================
// download task
@property (nonatomic) NSURLSessionDownloadTask *downloadTask;
// initiates a download
-(NSURLSessionDownloadTask*)downloadBundle;

@end
