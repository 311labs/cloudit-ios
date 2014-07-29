// SIMPLE HELPER EXTENSIONS

#define ASYNC(...) dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{ __VA_ARGS__ })
#define ASYNC_MAIN(...) dispatch_async(dispatch_get_main_queue(), ^{ __VA_ARGS__ })

@interface NSString (EmptyIfNil)
+ (NSString*)emptyStringIfNil:(NSString*)s;
@end

@implementation NSString (EmptyIfNil)
+ (NSString*)emptyStringIfNil:(NSString*)s {
    return s ? s : @"";
}
@end

@interface NSMutableDictionary (Three11IgnoreNil)
- (void)setObjectIfNotNil:(id)obj forKey:(NSString*)key;
@end

@implementation NSMutableDictionary (Three11IgnoreNil)
- (void)setObjectIfNotNil:(id)obj forKey:(NSString*)key {
    if (obj != nil) {
        [self setObject: obj forKey: key];
    }
}
@end