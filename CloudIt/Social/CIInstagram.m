//
//  CIInstagram.m
//  Pods
//
//  Created by Ian Starnes on 9/24/14.
//
//

#import "CIInstagram.h"
#import "CIWebPopup.h"
#import "CloudItService.h"
#import "CloudItAccount.h"

@interface CIInstagram ()

@property(nonatomic, strong) UIDocumentInteractionController* dc;

@end

@implementation CIInstagram

+ (id)shared {
    static dispatch_once_t pred = 0; \
    __strong static id _sharedObject = nil; \
    dispatch_once(&pred, ^{ \
        _sharedObject = [[self alloc] init]; \
    }); \
    return _sharedObject;
}

-(BOOL)appAvailable
{
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    return [[UIApplication sharedApplication] canOpenURL:instagramURL];
}

-(BOOL)isLinked
{
    return [[CloudItAccount shared] hasSocialLink:@"instagram"];
}

- (NSString*)createShareLink:(UIImage*)image
{
    
    NSData *imageData = UIImagePNGRepresentation(image);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString* savePath = [documentsPath stringByAppendingPathComponent:@"selfie.igo"];
    [imageData writeToFile:savePath atomically:YES];
    return savePath;
}

// post an image to instagram via the app
-(void)openImage:(UIImage*)image caption:(NSString*)caption inView:(UIView*)view onSuccess:(CISocialPostSuccessCallback)successBlock onFailure:(CISocialPostFailureCallback)failBlock
{
//    if (!self.appAvailable) {
//        failBlock([CIAuthProvider errorWithCode:404 localizedDescription:@"instagram not install"]);
//        return;
//    }
    ASYNC_MAIN({
        NSString* path = [self createShareLink:image];
        if (!self.dc) {
            self.dc = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:path]];
            self.dc.UTI = @"com.instagram.exclusivegram";
        }
        self.dc.annotation = [NSDictionary dictionaryWithObjectsAndKeys:caption,@"InstagramCaption", nil];
        successBlock(@"instagram");
        [self.dc presentOpenInMenuFromRect: CGRectMake(0, 0, 0, 0) inView: view animated: YES ];
    });
}

// post an image via a url to the app
-(void)openRemoteImage:(NSString*)imageLink caption:(NSString*)caption inView:(UIView*)view onSuccess:(CISocialPostSuccessCallback)successBlock onFailure:(CISocialPostFailureCallback)failBlock
{
//    if (!self.appAvailable) {
//        failBlock([CIAuthProvider errorWithCode:404 localizedDescription:@"instagram not install"]);
//        return;
//    }
    
    NSURL *URL = [NSURL URLWithString:imageLink];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    requestOperation.responseSerializer = [AFImageResponseSerializer serializer];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self openImage:responseObject caption:caption inView:view onSuccess:successBlock onFailure:failBlock];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failBlock(error);
    }];
    [requestOperation start];
}


// login with social and local viewcontroller
-(void)authenticateWithVC:(UIViewController*)vc onSuccess:(CIAuthSuccessCallback)successBlock onFailure:(CIAuthFailureCallback)failBlock
{
    
    NSString *url = [NSString stringWithFormat:@"%@%@", [[CloudItService shared] host], @"/login/instagram"];
    
    CIWebPopup* popup = [[CIWebPopup alloc] initWithVC:vc title:@"Link Instagram" closeOnURLS:@[@"model.me/logged-in"]];
    
    [popup loadURL:url close:^(NSString *host, NSString *path) {
        //
        successBlock(nil);
    } error:^(NSError *error) {
        //
        failBlock(error);
    }];
}

@end
