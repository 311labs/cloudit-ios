// SIMPLE HELPER EXTENSIONS

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