//
//  CIWebPopup.h
//  Pods
//
//  Created by Ian Starnes on 9/28/14.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^CIWebPopupClose)(NSString *host, NSString* path);
typedef void (^CIWebPopupError)(NSError *error);

@interface CIWebPopup : UIView<UIWebViewDelegate>

@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) UILabel *title;

@property (strong, nonatomic) UIView *activityView;
@property (strong, nonatomic) UILabel *activityLabel;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;


-(id)initWithVC:(UIViewController*)vc title:(NSString*)title closeOnURLS:(NSArray*)urls;

-(void)loadURL:(NSString*)url close:(CIWebPopupClose)closeBlock error:(CIWebPopupError)errorBlock;

-(void)show;
-(void)hide;

@end
