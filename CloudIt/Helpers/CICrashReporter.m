//
//  CICrashReporter.m
//  Pods
//
//  Created by Ian Starnes on 9/19/14.
//
//

#import "CICrashReporter.h"

#import "CloudItService.h"

#include <libkern/OSAtomic.h>
#include <execinfo.h>

void HandleException(NSException *exception) {
    NSLog(@"App crashing with exception: %@", exception);
    [[CICrashReporter shared] reportException:exception];
}

void HandleSignal(int signal) {
    NSLog(@"We received a signal: %d", signal);
    //Save somewhere that your app has crashed.
    NSException* exception = [NSException
                              exceptionWithName:@"UncaughtException"
                              reason:
                              [NSString stringWithFormat:
                               NSLocalizedString(@"Signal %d was raised.", nil),
                               signal]
                              userInfo:
                              [NSDictionary
                               dictionaryWithObject:[NSNumber numberWithInt:signal]
                               forKey:@"UncaughtExceptionSignalKey"]];
    
    HandleException(exception);
}

@interface CICrashReporter ()

@property(nonatomic, strong) NSString *appID;
@property(nonatomic, strong) NSString *version;
@property(nonatomic, strong) NSString *osVersion;
@property(nonatomic, strong) NSString *hwID;

@end

@implementation CICrashReporter

+ (id)shared {
    static dispatch_once_t pred = 0; \
    __strong static id _sharedObject = nil; \
    dispatch_once(&pred, ^{ \
        _sharedObject = [[self alloc] init]; \
    }); \
    return _sharedObject;
}

-(id) init
{
    self = [super init];
    if (self) {
        [self readProperties];
        [self setupErrorCatching];
    }
    return self;
}

-(void)readProperties
{
    
    self.osVersion = [[UIDevice currentDevice] systemVersion];
    self.hwID = [UIDevice currentDevice].model;
    
    NSDictionary *infoDict = [[NSBundle mainBundle]infoDictionary];
    
    self.appID = [infoDict objectForKey:@"CFBundleIdentifier"];
    NSString* version = [infoDict objectForKey:@"CFBundleShortVersionString"];
    NSNumber* buildNumber = [infoDict objectForKey:@"CFBundleVersion"];
    self.version = [NSString stringWithFormat:@"%@.%@", version, buildNumber];
}

#pragma mark - Reporter

-(void)reportEvent:(NSString*)event
{
    
}

const NSInteger UncaughtExceptionHandlerSkipAddressCount = 4;
const NSInteger UncaughtExceptionMaxFrames = 14;

+ (NSArray *)backtrace
{
    void* callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);
    
    int i;
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    for (i = UncaughtExceptionHandlerSkipAddressCount; i < UncaughtExceptionMaxFrames;
         i++)
    {
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);
    
    return backtrace;
}

-(NSArray*)symbolicBacktrace:(NSException*)exception
{
    // Mac OS X 10.6 and iOS 4.0 provide this for us
    if ( [exception respondsToSelector: @selector(callStackSymbols)] )
        return ( [exception callStackSymbols] );
    
    NSArray * result = nil;
    
    // on earlier versions, we have to do the work ourselves
    NSArray * addresses = [exception callStackReturnAddresses];
    NSMutableArray * symbols = [[NSMutableArray alloc] initWithCapacity: [addresses count]];
    
    // get a list of void * addresses
    void ** addrs = malloc(addresses.count * sizeof(void*));
    
    
    NSUInteger idx = 0;
    for ( id obj in addresses )
    {
        addrs[idx++] = (void *)[obj integerValue];
    }
    
    // now get the symbols
    char ** symstrs = backtrace_symbols(addrs, [addresses count]);
    for ( int i = 0; i < [addresses count]; i++ )
    {
        [symbols addObject: [NSString stringWithCString: symstrs[i] encoding: NSASCIIStringEncoding]];
    }
    
    result = [symbols copy];

    return ( result );
}

-(void)reportException:(NSException*)exception
{
    NSArray *callStackArray = [self symbolicBacktrace:exception];
    
    NSError* error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:callStackArray options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSDictionary* data = @{
                            @"app_id":self.appID,
                            @"app_version":self.version,
                            @"os_id":@"IOS",
                            @"os_version":self.osVersion,
                            @"hw_id":self.hwID,
                            @"name": exception.name,
                            @"error":exception.reason,
                            @"stack":jsonString
                           };
    
    CloudItService* service = [CloudItService shared];
    [service POST:@"/rpc/errorcatcher/report" params:data onSuccess:^(CloudItResponse *response) {
        //
        NSLog(@"posted crash report");
    } onFailure:^(NSError *error) {
        //
    }];
    [NSThread sleepForTimeInterval:3.0];
}

#pragma mark - Exception Catcher

- (void)setupErrorCatching
{
    NSSetUncaughtExceptionHandler(&HandleException);
    
    struct sigaction signalAction;
    memset(&signalAction, 0, sizeof(signalAction));
    signalAction.sa_handler = &HandleSignal;
    
    sigaction(SIGABRT, &signalAction, NULL);
    sigaction(SIGILL, &signalAction, NULL);
    sigaction(SIGBUS, &signalAction, NULL);
}


@end
