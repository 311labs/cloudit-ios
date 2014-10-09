//
//  CIInstagram.m
//  Pods
//
//  Created by Ian Starnes on 9/24/14.
//
//

#import "CIInstagram.h"
#import "CIWebPopup.h"

@interface CIInstagram ()

@end

@implementation CIInstagram


// login with social and local viewcontroller
-(void)authenticateWithVC:(UIViewController*)vc onSuccess:(CIAuthSuccessCallback)successBlock onFailure:(CIAuthFailureCallback)failBlock
{
    
    NSString *url = [NSString stringWithFormat:@"%@%@", [[CloudItService shared] host], @"/login/instagram"];
    
    CIWebPopup* popup = [[CIWebPopup alloc] initWithVC:vc title:@"Instagram Share" closeOnURLS:@[@"model.me/logged-in"]];
    
    [popup loadURL:url close:^(NSString *host, NSString *path) {
        //
        successBlock(nil);
    } error:^(NSError *error) {
        //
        failBlock(error);
    }];
}

@end
