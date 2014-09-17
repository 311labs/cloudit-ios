//
//  CIVideoStats.h
//  ThreeDMe
//
//  Created by Ian Starnes on 6/24/14.
//  Copyright (c) 2014 311Labs. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "CIModel.h"

typedef void (^CIThreeDMeSuccessCallback)();
typedef void (^CIThreeDMeFailureCallback)(NSString *error);

@interface CIThreeDMe : CIModel

-(id)initWithImage:(UIImage*)image;
-(id)initWithImage:(UIImage*)image andName:(NSString*)name;


@property (readonly) NSString* title;
@property (readonly) NSString* uuid;

@property (readonly) NSString* gender;
@property (readonly) NSString* race;
@property (readonly) NSNumber* age;
@property (readonly) NSNumber* weight;
@property (readonly) NSNumber* height;
@property (readonly) NSString* eye_color;
@property (readonly) NSString* hair_color;
@property (readonly) NSString* skin_color;

@property (readonly) NSString* age_category;

@property (nonatomic) NSString* remoteImagePath;

@property (nonatomic) NSString* remoteBundlePath;
@property (nonatomic) NSString* remoteHeadPath;

@property (readonly) NSNumber* state;

@property (readonly) BOOL isProcessing;
@property (readonly) BOOL isReady;
@property (readonly) BOOL isContentDownloaded;

@property (readonly) BOOL isImageDownloaded;

@property (readonly) NSMutableDictionary* properties;

@property (strong) NSString* name;
@property (strong) UIImage* image;
// local path for this bundle
@property(nonatomic) NSString *localPath;
// local path to obj
@property(nonatomic) NSString *objPath;
// local path to obj
@property(nonatomic) NSString *headPath;
// local path to mtl
@property(nonatomic) NSString *mtlPath;
// local path to texture
@property(nonatomic) NSString *texturePath;
@property(nonatomic) NSString *faceTexturePath;

// local path to texture
@property(nonatomic) NSString *imagePath;
-(UIImage*) loadImage;


// will detect and only if a face is detected... (saves cropped image)
-(BOOL)detectFaces;
// save the avatar to disk
-(void)save;
// delete the avatar from local disk
-(void)deleteLocal;

// configure the paths
-(void)configurePaths;

// this will
// 1. send the image to the server
// 2. wait for rendering 
// 3. download the result
//-(void)render:(CIThreeDMeSuccessCallback)uploadBlock
//	onSuccess:(CIThreeDMeSuccessCallback)successBlock
//	onFailure:(CIThreeDMeFailureCallback)failBlock 
//	progress:(CloudItProgressCallback)progressBlock;

// upload the image for rendering
-(AFHTTPRequestOperation*)upload:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock progress:(CloudItProgressCallback)progressBlock;
// wait for processing to be complete
-(void)waitForProcessing:(CIThreeDMeSuccessCallback)successBlock onUpdate:(CIThreeDMeSuccessCallback)updateBlock onFailure:(CIThreeDMeFailureCallback)failBlock;
// use this to download the bundle
-(AFHTTPRequestOperation*)download:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock;

// ========= CLASS METHODS =========
// fetch a single object
+(void)fetch:(int)key onSuccess:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock;
// fetch a list of objects
+(void)fetchList:(NSDictionary*)params onSuccess:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock;

@end
