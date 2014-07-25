//
//  ThreedBundle.m
//  ThreeDMe
//
//  Created by Ian Starnes on 7/19/14.
//  Copyright (c) 2014 Ian Starnes. All rights reserved.
//

#import "CIThreeDBundle.h"

#define IDIOM    UI_USER_INTERFACE_IDIOM()
#define IPAD     UIUserInterfaceIdiomPad

@interface CIThreeDBundle()
    @property (nonatomic, retain) NSString *_local_path;
@end

@implementation CIThreeDBundle

+(NSString*) rpcPath
{
    return @"rpc/threed/bundle/";
}

// fetch a single object
+(void)fetch:(int)key onSuccess:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock
{
    [[CloudItService shared] fetch: [CIThreeDBundle class] withKey: key onSuccess: successBlock onFailure: failBlock];
}
// fetch a list of objects
+(void)fetchList:(NSDictionary*)params onSuccess:(CloudItSuccessCallback)successBlock onFailure:(CloudItFailureCallback)failBlock
{
    [[CloudItService shared] fetchList: [CIThreeDBundle class] params: params onSuccess: successBlock onFailure: failBlock];
}

-(NSString*) name
{
    return [self.data objectForKey:@"name"];
}

-(NSString*) uuid
{
    return [self.data objectForKey:@"uuid"];
}

-(NSString*) remotePath
{
    return [self.data objectForKey:@"url"];
}


-(NSNumber*) version
{
    return [self.data objectForKey:@"version"];
}

-(NSNumber*) state
{
    return [self.data objectForKey:@"state"];
}

-(NSNumber*) orderWeight
{
    return [self.data objectForKey:@"order_weight"];
}

-(NSNumber*) channelID
{
    return [self.data objectForKey:@"order_weight"];
}

-(NSMutableDictionary*)marketing
{
    return [self.data objectForKey:@"marketing"];
}

-(BOOL)isActive
{
    return [self.state intValue] == 100;
}

#pragma localization

- (NSString *)marketingText{
    // search our marketing data for the correct localized marketing text string
    NSString *curSysLang = [NSLocale preferredLanguages][0];
    NSDictionary *titles = [self.marketing objectForKey:@"titles"];
    NSString* title = [titles objectForKey:curSysLang];
    if (title == nil) {
        title = [self.marketing objectForKey:@"title"];
    }
    return title;
}






#pragma download logic


-(NSURLSessionDownloadTask*)downloadBundle
{
//    NSURLSessionConfiguration *configuration =
//    [NSURLSessionConfiguration
//     backgroundSessionConfiguration:@"tv.pdir"];
//    configuration.allowsCellularAccess = YES;
//    
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration
//                                             delegate:self delegateQueue:nil];
//    
//    NSURL *downloadURL = [NSURL URLWithString:self.bundlePath];
//    
//    NSURLRequest *request = [NSURLRequest requestWithURL:downloadURL];
//    
//    self.downloadTask = [session downloadTaskWithRequest:request];
//    [self.downloadTask resume];
//    return self.downloadTask;
    return nil;
}

# pragma SESSION Delegates

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{

    /*
     Report progress on the task.
     If you created more than one task, you might keep references to them and report on them individually.
     */
    
    if (downloadTask == self.downloadTask)
    {
        double progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
        NSLog(@"DownloadTask: %@ progress: %lf", downloadTask, progress);
//        dispatch_async(dispatch_get_main_queue(), ^{
//            self.progressView.progress = progress;
//        });
    }
}


- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)downloadURL
{
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    // get the local path for our bundle
//    NSURL* localURL = [NSURL fileURLWithPath:self.localPath];
//    // create the destination URL for our bundle
//    NSURL* destURL = [localURL URLByAppendingPathComponent:@"assets"]
//
//    
//    /*
//     The download completed, you need to copy the file at targetPath before the end of this block.
//     As an example, copy the file to the Documents directory of your app.
//     */
// 
//    NSArray *URLs = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
//    NSURL *documentsDirectory = [URLs objectAtIndex:0];
//    
//    NSURL *originalURL = [[downloadTask originalRequest] URL];
//    NSURL *destinationURL = [documentsDirectory URLByAppendingPathComponent:[originalURL lastPathComponent]];
//    NSError *errorCopy;
//    
//    // For the purposes of testing, remove any esisting file at the destination.
//    [fileManager removeItemAtURL:destinationURL error:NULL];
//    BOOL success = [fileManager copyItemAtURL:downloadURL toURL:destinationURL error:&errorCopy];
//    
//    if (success)
//    {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            UIImage *image = [UIImage imageWithContentsOfFile:[destinationURL path]];
//            self.imageView.image = image;
//            self.imageView.hidden = NO;
//            self.progressView.hidden = YES;
//        });
//    }
//    else
//    {
//        /*
//         In the general case, what you might do in the event of failure depends on the error and the specifics of your application.
//         */
//        BLog(@"Error during the copy: %@", [errorCopy localizedDescription]);
//    }
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
//    BLog();
//    
//    if (error == nil)
//    {
//        NSLog(@"Task: %@ completed successfully", task);
//    }
//    else
//    {
//        NSLog(@"Task: %@ completed with error: %@", task, [error localizedDescription]);
//    }
//    
//    double progress = (double)task.countOfBytesReceived / (double)task.countOfBytesExpectedToReceive;
//    dispatch_async(dispatch_get_main_queue(), ^{
//        self.progressView.progress = progress;
//    });
//    
//    self.downloadTask = nil;
}


/*
 If an application has received an -application:handleEventsForBackgroundURLSession:completionHandler: message, the session delegate will receive this message to indicate that all messages previously enqueued for this session have been delivered. At this time it is safe to invoke the previously stored completion handler, or to begin any internal updates that will result in invoking the completion handler.
 */
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
//    APLAppDelegate *appDelegate = (APLAppDelegate *)[[UIApplication sharedApplication] delegate];
//    if (appDelegate.backgroundSessionCompletionHandler) {
//        void (^completionHandler)() = appDelegate.backgroundSessionCompletionHandler;
//        appDelegate.backgroundSessionCompletionHandler = nil;
//        completionHandler();
//    }
    
//    NSLog(@"All tasks are finished");
}


-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
//    BLog();
}




@end
