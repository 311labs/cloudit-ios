//
//  CIWebPopup.m
//  Pods
//
//  Created by Ian Starnes on 9/28/14.
//
//

#import "CIWebPopup.h"
#import "CIEXT.h"

@interface CIWebPopup ()

@property(retain, nonatomic) NSArray* closeURLs;

@property(copy) CIWebPopupClose closeBlock;
@property(copy) CIWebPopupError errorBlock;

@end

@implementation CIWebPopup


-(id)initWithVC:(UIViewController*)vc title:(NSString*)title closeOnURLS:(NSArray*)urls
{
    CGRect screenFrame = [[UIScreen mainScreen] bounds];
    self = [super initWithFrame:screenFrame];
    if (self) {
        [self createViews:title];
        [vc.view addSubview:self];
        self.closeURLs = urls;
    }
    return self;
}

-(void)createActivityView
{
    CGRect screenFrame = [[UIScreen mainScreen] bounds];
    CGRect viewFrame = CGRectMake(screenFrame.size.width/4.0, screenFrame.size.height/2.0, screenFrame.size.width/2.0, 60.0);
    CGRect titleFrame = CGRectMake(0, 0, viewFrame.size.width, 20.0);
    CGPoint center = CGPointMake(viewFrame.size.width/2.0, 40.0);
    
    
    UIView* view = [[UIView alloc] initWithFrame: viewFrame];
    view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4];

    UILabel *label = [[UILabel alloc]initWithFrame:titleFrame];
    label.text = @"loading...";
    label.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    label.adjustsFontSizeToFitWidth = NO;
    label.clipsToBounds = YES;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    [view addSubview:label];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [view addSubview:self.activityIndicator];

    [view setHidden:YES];
    self.activityView = view;
    [self addSubview:view];
    
    [self.activityIndicator setHidesWhenStopped:NO];
    [self.activityIndicator startAnimating];
    [self.activityIndicator setHidden:NO];
    
    [self.activityIndicator setCenter:center];
//    [view bringSubviewToFront:self.activityIndicator];

}

-(void)createViews:(NSString*)title
{
    CGRect screenFrame = [[UIScreen mainScreen] bounds];
    CGRect mainFrame = CGRectMake(0, screenFrame.size.height, screenFrame.size.width, screenFrame.size.height);
    
    self.frame = mainFrame;
    
    CGRect titleFrame = CGRectMake(0, 0, screenFrame.size.width, 40);
    CGRect webFrame = CGRectMake(0, 40, screenFrame.size.width, screenFrame.size.height-40);
    // build title bar
    UIView* tview = [[UIView alloc] initWithFrame: titleFrame];
    tview.backgroundColor = [UIColor whiteColor];
    [self addSubview:tview];
    
    CALayer* layer = [tview layer];
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.borderColor = [UIColor darkGrayColor].CGColor;
    bottomBorder.borderWidth = 1;
    bottomBorder.frame = CGRectMake(-1, layer.frame.size.height-1, layer.frame.size.width, 1);
    [bottomBorder setBorderColor:[UIColor blackColor].CGColor];
    [layer addSublayer:bottomBorder];
    
    UILabel *label = [[UILabel alloc]initWithFrame:titleFrame];
    label.text = title;
    label.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    label.adjustsFontSizeToFitWidth = NO;
    label.clipsToBounds = YES;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    [tview addSubview:label];
    self.title = label;
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(cancel:)
     forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"x" forState:UIControlStateNormal];
    button.tintColor = [UIColor blackColor];
    button.frame = CGRectMake(screenFrame.size.width-40, 0.0, 40.0, 40.0);
    button.titleLabel.font = [UIFont systemFontOfSize:26];
    [tview addSubview:button];
    
    self.webView = [[UIWebView alloc] initWithFrame:webFrame];
    [self addSubview:self.webView];
    
    [self createActivityView];
    
    self.webView.delegate = self;
//    [self.webView loadHTMLString:@"<h1>loading...</h1>" baseURL:nil];
}

- (IBAction)cancel:(id)sender
{
    self.errorBlock([NSError errorWithDomain:@"cloudit" code:404 userInfo:nil]);
    [self hide];
}


-(void)show
{
    CGRect screenFrame = [[UIScreen mainScreen] bounds];
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    if (statusBarFrame.size.height > 20) {
        screenFrame.size.height -= (statusBarFrame.size.height - 20);
        screenFrame.origin.y = (statusBarFrame.size.height - 20);
    } else {
        screenFrame.size.height -= 20;
        screenFrame.origin.y = 20;
    }

    [UIView animateWithDuration:0.3
                     animations:^{
                         self.frame = screenFrame;
                     }
                     completion:^(BOOL finished){
                         
                         
                     }];
}

-(void)hide
{
    CGRect mainFrame = CGRectMake(0, self.frame.size.height, self.frame.size.width, self.frame.size.height);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.frame = mainFrame;
                     }
                     completion:^(BOOL finished){
                         [self removeFromSuperview];
                         self.webView = nil;
                     }];
}


- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *urlString = [request.URL absoluteString];
    for (NSString* url in self.closeURLs)
    {
        if ([urlString rangeOfString:url].location != NSNotFound)
        {
            self.closeBlock(request.URL.host, request.URL.path);
            [self hide];
            return NO;
        }
    }
    return YES;
}

- (void)timedOut
{
    [self.webView stopLoading];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.activityView setHidden: NO];
    [NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(timedOut) userInfo:nil repeats:NO];

}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.activityView setHidden: YES];
}

-(void)loadURL:(NSString*)url close:(CIWebPopupClose)closeBlock error:(CIWebPopupError)errorBlock
{
    self.closeBlock = closeBlock;
    self.errorBlock = errorBlock;
    [self show];
    NSURL *sendToServer = [NSURL URLWithString: [url stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    [self.webView loadRequest:[NSURLRequest requestWithURL:sendToServer]];
}


@end
