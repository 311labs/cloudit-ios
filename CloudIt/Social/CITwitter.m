//
//  CIUser.m
//  ThreeDMe
//
//  Created by Ian Starnes on 6/24/14.
//  Copyright (c) 2014 Ian Starnes. All rights reserved.
//

#import "CITwitter.h"

#import "UIActionSheet+Blocks.h"

#import <Accounts/Accounts.h>
#import <Social/Social.h>

#include "CIEXT.h"

@interface CITwitter ()
@property(copy) CIAuthSuccessCallback successCallback;
@property(copy) CIAuthFailureCallback failCallback;
@end

@implementation CITwitter

// initialize provider with settings
-(id)initWithSettings:(NSDictionary*)settings
{

    return self;
}

-(void)grantAccess
{
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:
                                  ACAccountTypeIdentifierTwitter];
    
    [account requestAccessToAccountsWithType:accountType options:nil
                                  completion:^(BOOL granted, NSError *error)
    {
        if (granted == YES)
        {
            [self reverseAuth];
        } else {
            self.failCallback(error);
        }
    }];
}

-(void)reverseAuth
{
    
    NSURL *url = [NSURL URLWithString:@"http://api.twitter.com/1/account/verify_credentials.json"];

    SLRequest * slReq = [SLRequest
        requestForServiceType:SLServiceTypeTwitter
        requestMethod:SLRequestMethodPOST
        URL:url parameters:nil];
    
    NSURLRequest* reqTemp = [slReq preparedURLRequest];
    NSDictionary * dictHeaders = [reqTemp allHTTPHeaderFields];
    
    NSString * authString = dictHeaders[@"Authorization"];
    NSArray * arrayAuth = [authString componentsSeparatedByString:@","];
    NSString * accessToken = nil;
    for( NSString * val in arrayAuth ) {
        if( [val rangeOfString:@"oauth_token"].length > 0 ) {
            accessToken =
            [val stringByReplacingOccurrencesOfString:@"\""
                                           withString:@""];
            accessToken =
            [accessToken stringByReplacingOccurrencesOfString:@"oauth_token="
                                                   withString:@""];
            break;
        }
    }
    
    if (accessToken) {
        NSLog(@"we have the access token!");
    }
}

-(void)handleAccount:(ACAccount*)account
{
//    [account cre]
}

- (void)showActionSheetForAccounts:(NSArray *)accounts
{
    CITwitter *blockSelf = self;
    
    NSMutableArray* buttons = [NSMutableArray array];
    for (ACAccount *account in accounts) {
        NSString *username = [NSString stringWithFormat:@"@%@", account.username];
        [buttons addObject:username];
    }
    
    
    //just in case the keyboard is visible
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    
    UIActionSheet *actionSheet = [UIActionSheet showInView:self.vc.view withTitle:nil cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:buttons tapBlock:^(UIActionSheet *sheet, NSInteger buttonIndex) {
        // handle
//        if (sheet.cancelButtonIndex == buttonIndex) {
//            blockSelf.failCallback([CIAuthProvider errorWithCode:202 localizedDescription:@"user cancled request"]);
//            return;
//        }
        [blockSelf handleAccount: accounts[0]];
    }];
}

// login with social and local view controller
-(void)authenticateWithVC:(UIViewController*)vc onSuccess:(CIAuthSuccessCallback)successBlock onFailure:(CIAuthFailureCallback)failBlock
{
    self.vc = vc;
    [self authenticate:successBlock onFailure:failBlock];
}

-(void)authenticate:(CIAuthSuccessCallback)successBlock onFailure:(CIAuthFailureCallback)failBlock
{
    self.successCallback = successBlock;
    self.failCallback = failBlock;
    
    if (![SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        self.failCallback([CIAuthProvider errorWithCode:202 localizedDescription:@"no twitter account configured"]);
    }
    else {
        ACAccountStore *accountStore = [[ACAccountStore alloc] init];
        ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!granted) {
                    self.failCallback([CIAuthProvider errorWithCode:202 localizedDescription:@"permission denied"]);
                    return;
                }
                
                NSArray *accounts = [accountStore accountsWithAccountType:accountType];
                if (accounts.count == 1) {
                    [self handleAccount:accounts[0]];
                } else if (accounts.count > 1) {
                    [self showActionSheetForAccounts:accounts];
                } else {
                    self.failCallback([CIAuthProvider errorWithCode:404 localizedDescription:@"no twitter account configured"]);
                }
            });
            
        }];
    }
    
    
}
                                                       
                                                       

-(void)trySilentAuthentication:(CIAuthSuccessCallback)successBlock onFailure:(CIAuthFailureCallback)failBlock
{
//    GPPSignIn *signIn = [GPPSignIn sharedInstance];
//    signIn.scopes = @[kGTLAuthScopePlusMe];
//    [signIn trySilentAuthentication];
}

-(void)logout
{

}


@end