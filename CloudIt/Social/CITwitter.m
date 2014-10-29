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

#import "CIWebPopup.h"

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

+ (BOOL) postURL:(NSString*)url withText:(NSString*)text onSuccess:(CISocialPostSuccessCallback)successBlock onFailure:(CISocialPostFailureCallback)failBlock
{
    // Create an account store object.
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    
    // Create an account type that ensures Twitter accounts are retrieved.
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    // Request access from the user to use their Twitter accounts.
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if(granted) {
            // Get the list of Twitter accounts.
            NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
            
            if ([accountsArray count] > 0) {
                // Grab the initial Twitter account to tweet from.
                ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
                SLRequest *postRequest = nil;
                
                // Post Text
                NSString *tweet = [NSString stringWithFormat:@"%@\n%@", text, url];
                NSDictionary *message = @{@"status": tweet};
                
                // URL
                NSURL *requestURL = [NSURL URLWithString:@"https://api.twitter.com/1/statuses/update.json"];
                
                // Request
                postRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:requestURL parameters:message];
                
                // Set Account
                postRequest.account = twitterAccount;
                
                // Post
                [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                        if (responseData)
                        {
                            if ([urlResponse statusCode] == 200) {
                                successBlock(@"twitter");
                            } else {
                                failBlock(error);
                            }
                        } else {
                            failBlock(error);
                        }
                }];
                return;
            } else {
                failBlock([CIAuthProvider errorWithCode:500 localizedDescription:@"no accounts setup"]);
                return;
            }
        }
        failBlock(error);
    }];
    return YES;
}

+ (BOOL) shareURL:(NSString*)url withText:(NSString*)text withVC:(UIViewController*)vc completion:(CISocialPostSuccessCallback)successBlock
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *sheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        [sheet setInitialText:text];
        // obfuscation hack
        [sheet addURL:[NSURL URLWithString:url]];
        [vc presentViewController:sheet animated:YES completion:^{
            successBlock(@"twitter");
        }];

    } else {
        NSString *twitterShare = [NSString stringWithFormat:@"https://twitter.com/intent/tweet?url=%@&text=%@", url, text];
        
        CIWebPopup* popup = [[CIWebPopup alloc] initWithVC:vc title:@"Share" closeOnURLS:@[@"intent/tweet/complete"]];
        
        [popup loadURL:twitterShare close:^(NSString *host, NSString *path) {
            //
            successBlock(@"twitter");
        } error:^(NSError *error) {
            //
            successBlock(@"twitter");
        }];
    }
    return YES;
}

@end