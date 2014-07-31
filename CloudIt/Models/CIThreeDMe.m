#import "CIThreeDMe.h"
#import <SSZipArchive.h>

@interface CIThreeDMe()
@property(retain) CIDetector* faceDetector;
@property(assign) int faceCount;

@property(copy) CIThreeDMeSuccessCallback renderSuccessCallback;
@property(copy) CIThreeDMeFailureCallback renderFailCallback;

@property (retain) NSThread* renderThread;
@property (retain) NSString* lastError;

@end

@implementation CIThreeDMe

+(NSString*) rpcPath
{
    return @"rpc/threed/me";
}

// fetch a single object
+(void)fetch:(int)key onSuccess:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock
{
    [[CloudItService shared] fetch: [CIThreeDMe class] withKey: key onSuccess: successBlock onFailure: failBlock];
}
// fetch a list of objects
+(void)fetchList:(NSDictionary*)params onSuccess:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock
{
    [[CloudItService shared] fetchList: [CIThreeDMe class] params: params onSuccess: successBlock onFailure: failBlock];
}

-(id)initWithImage:(UIImage *)image
{
    return [self initWithImage:image andName:nil];
}

-(id)initWithImage:(UIImage *)image andName:(NSString*)name
{
    self = [super init];
    if (self)
    {
        self.image = image;
        self.name = name;
        self.data = [NSMutableDictionary dictionary];
        if (self.name == nil)
        {
            self.name = [[NSUUID UUID] UUIDString];
            [self setValue:self.name forKey:@"uuid"];
        }
        
        [self configurePaths];
    }
    return self;
}

-(void)loadData:(id)data
{
    [super loadData:data];
    NSLog(@"data: %@", data);
    if (self.title)
    {
        NSLog(@"title: %@", self.title);
        NSUInteger numberOfOccurrences = [[self.title componentsSeparatedByString:@"-"] count] - 1;
        if (numberOfOccurrences > 1)
        {
            [self setValue:self.title forKey:@"uuid"];
            [self setValue:@"SET NAME" forKey:@"title"];
        }
    }
    
    self.name = self.uuid;
    [self configurePaths];
    
    NSDictionary* media = (NSDictionary*)[self objectForKey:@"media"];
    if (media)
    {
        for (NSDictionary* item in media)
        {
            NSString* use = [item objectForKey:@"use"];
            if ([use isEqualToString:@"original"])
            {
                self.remoteImagePath = [item objectForKey:@"url"];
            } else if ([use isEqualToString:@"head"])
            {
                self.remoteBundlePath = [item objectForKey:@"url"];
            }
        }
    }
}

-(NSString*) title
{
    return [self.data objectForKey:@"title"];
}

-(NSString*) uuid
{
    return [self.data objectForKey:@"uuid"];
}

-(NSString*) gender
{
    return [self.data objectForKey:@"gender"];
}

-(NSString*) race
{
    return [self.data objectForKey:@"race"];
}

-(NSNumber*) age
{
    return [self.data objectForKey:@"age"];
}

-(NSNumber*) state
{
    return [self.data objectForKey:@"state"];
}

-(BOOL)isProcessing
{
    int state = [self intForKey:@"state"];
    return (state >= 0) && (state < 50) ;
}

-(BOOL)isReady
{
    return [self intForKey:@"state"] == 50;
}

-(void)checkIfProcessed
{
    // TODO see if is updating?
    [self refresh:^(CloudItResponse *response) {
        // response
        
    } onFailure:^(NSError *error) {
        // error
        self.lastError = [error localizedDescription];
    }];
}

-(void)waitForRender
{
	while (self.isProcessing)
    {
        [NSThread sleepForTimeInterval:5.0];
        [self checkIfProcessed];
    }
    
    // check if we can download
    if (self.isReady)
    {
        // this means we have are rendered and just need to download it
        [self download:^(CloudItResponse *response) {
            // download complete
            self.renderSuccessCallback();
        } onFailure:^(NSError *error) {
            // failed
            self.lastError = [error localizedDescription];
            self.renderFailCallback(self.lastError);
        }];
        
    } else {
        // this means something went wrong.. check last error
        self.renderFailCallback(self.lastError);
    }
}

-(void)waitForProcessing:(CIThreeDMeSuccessCallback)successBlock onFailure:(CIThreeDMeFailureCallback)failBlock
{
	self.renderFailCallback = failBlock;
	self.renderSuccessCallback = successBlock;

	// spawn a threed to handle all of this processing
	self.renderThread = [[NSThread alloc] initWithTarget:self
	                                             selector:@selector(waitForRender)
	                                               object:nil];
	[self.renderThread start];  // Actually create the thread
}

- (BOOL)isContentDownloaded
{
    return [[NSFileManager defaultManager] fileExistsAtPath: self.objPath];
}

-(AFHTTPRequestOperation*)download:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock
{
    NSURL *URL = [NSURL URLWithString:self.remoteBundlePath];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    self.isUpdating = YES;
    AFHTTPRequestOperation *downloadRequest = [[AFHTTPRequestOperation alloc] initWithRequest:request];

    [self createPaths];
    
    NSString* path=[self.localPath stringByAppendingPathComponent: @"bundle.zip"];
    downloadRequest.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];

    // Step 4: set handling for answer from server and errors with request
    [downloadRequest setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // here we must create NSData object with received data...
        [SSZipArchive unzipFileAtPath:path toDestination:self.localPath];
        self.isUpdating = NO;
        if (self.isContentDownloaded)
        {
            // unzip worked!
            NSLog(@"unzip worked");
            successBlock(nil);
        } else {
            // unzip failed
            NSLog(@"files did not unzip where expected!");
            failBlock(nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"file downloading error : %@", [error localizedDescription]);
        self.isUpdating = NO;
        failBlock(error);
    }];
    
    // Step 5: begin asynchronous download
    [downloadRequest start];
    return downloadRequest;
}


-(void)configurePaths
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *rootPath = [documentsDirectory stringByAppendingPathComponent:@"faces"];
    self.localPath = [rootPath stringByAppendingPathComponent:self.name];
    self.objPath = [self.localPath stringByAppendingPathComponent:@"inputImage.obj"];
    self.mtlPath = [self.localPath stringByAppendingPathComponent:@"inputImage.mtl"];
    self.texturePath = [self.localPath stringByAppendingPathComponent:@"inputImage_tex.jpeg"];
    self.imagePath = [self.localPath stringByAppendingPathComponent:@"face.jpg"];
}

#define rad(angle) ((angle) / 180.0 * M_PI)
- (CGAffineTransform)orientationTransformedRectOfImage:(UIImage *)img
{
    CGAffineTransform rectTransform;
    switch (img.imageOrientation)
    {
        case UIImageOrientationLeft:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(90)), 0, -img.size.height);
            break;
        case UIImageOrientationRight:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-90)), -img.size.width, 0);
            break;
        case UIImageOrientationDown:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-180)), -img.size.width, -img.size.height);
            break;
        default:
            rectTransform = CGAffineTransformIdentity;
    };
    
    return CGAffineTransformScale(rectTransform, img.scale, img.scale);
}

- (UIImage *)fixrotation:(UIImage *)image{
    if (image.imageOrientation == UIImageOrientationUp) return image;
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
    
}

-(void)cropToFace: (CIFaceFeature*) face
{
    CGAffineTransform transform = CGAffineTransformMakeScale(1, -1);
    transform = CGAffineTransformTranslate(transform,
                                           0, -self.image.size.height);
    const CGRect faceRect = CGRectApplyAffineTransform(face.bounds, transform);

    CGFloat height = faceRect.size.height;
    CGFloat width = faceRect.size.width;
    CGFloat dx = (width*0.3);
    CGFloat dy = (height*0.5);
    
    CGRect biggerRectangle = CGRectInset(faceRect, -1*dx, -1*dy);
    CGImageRef imageRef = CGImageCreateWithImageInRect([self.image CGImage], biggerRectangle);
    self.image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    [self save];
}

-(BOOL)detectFaces
{
    if (self.faceDetector == nil) {
        self.faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace
                                          context:nil
                                          options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
        
    }
    self.image = [self fixrotation:self.image];
    CIImage *ci = [[CIImage alloc] initWithImage:self.image];
    NSArray *faces = [_faceDetector featuresInImage:ci];
    self.faceCount = faces.count;
    // TODO create new avatars for each face
    if (self.faceCount > 0)
    {
        [self cropToFace:faces[0]];
        return YES;
    }
    return NO;
//    return self.faceCount > 0;
    
//    CGPoint centroid = CGPointZero;
//    for (int i = 0; i < self.faceCount; i++)
//    {
//        CIFaceFeature *face = faces[i];
//        CGRect bounds = face.bounds;
//        
//        CGPoint center = CGPointMake(bounds.origin.x + bounds.size.width/2, bounds.origin.y + bounds.size.height/2);
//        
//        /* Move 75% towards the eyes, if detected */
//        int numberOfEyesDetected = face.hasLeftEyePosition + face.hasRightEyePosition;
//        CGPoint eyeCenter = CGPointMake((face.leftEyePosition.x + face.rightEyePosition.x)/numberOfEyesDetected,
//                                        (face.leftEyePosition.y + face.rightEyePosition.y)/numberOfEyesDetected);
//        if (!CGPointEqualToPoint(eyeCenter, CGPointZero))
//        {
//            center.x = (center.x + eyeCenter.x*3)/4;
//            center.y = (center.y + eyeCenter.y*3)/4;
//        }
//        
//        centroid.x += center.x;
//        centroid.y += center.y;
//    }
//    
//    if (self.faceCount > 0)
//    {
//        centroid.x /= faces.count;
//        centroid.y /= faces.count;
//    }

    
    return NO;
}

-(void)createPaths
{
    NSError* error;
    if (![[NSFileManager defaultManager] fileExistsAtPath: self.localPath])
    {
        BOOL res = [[NSFileManager defaultManager] createDirectoryAtPath:self.localPath
                                              withIntermediateDirectories:YES
                                                               attributes:nil
                                                                   error:&error];
        if (!res) {
             NSLog(@"Create directory error: %@", error);
        }
    }
}

-(void)deleteLocal
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL success = [fileManager removeItemAtPath:self.localPath error:nil];
    if (!success)
    {
        NSLog(@"Failed to remove avatar folder");
    }
}

-(void)save
{

    [self createPaths];
    
    NSData* data = UIImageJPEGRepresentation(self.image, 0.8);
    NSLog(@"image path %@", self.imagePath);
    NSLog(@"IMAGE SIZE %.2f bytes", (float)data.length);
    NSLog(@"IMAGE SIZE %.2f mb",(float)data.length/1024.0f/1024.0f);
    NSLog(@"Image to path: %@", self.imagePath);
    BOOL res = [data writeToFile:self.imagePath atomically:YES];
    if (!res) {
        NSLog(@"failed to write file");
    } else {
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:self.imagePath error:NULL];
        unsigned long long fileSize = [attributes fileSize];
        NSLog(@"IMAGE SIZE %lld bytes", fileSize);
    }
    
    
}

-(AFHTTPRequestOperation*)upload:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock progress:(CloudItProgressCallback)progressBlock
{
    NSMutableDictionary *params = [@{
                                     @"title" : self.title,
                                     @"uuid": self.name
                                     } mutableCopy];
    NSDictionary* files = @{@"picture":@{@"filename":@"face.jpg", @"path":self.imagePath}};
    
    return [[CloudItService shared] UPLOAD:@"rpc/threed/faceme" files:files params:params onSuccess:^(CloudItResponse *response) {
        // the data should be the new object
        [self loadData:response.data];
        response.model = self;
        successBlock(response);
    } onFailure:failBlock onProgress:progressBlock];
}

@end
