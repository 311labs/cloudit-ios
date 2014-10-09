//
//  CICrashReporter.h
//  Pods
//
//  Created by Ian Starnes on 9/19/14.
//
//

#import <Foundation/Foundation.h>

@interface CICrashReporter : NSObject

+(id)shared;

-(void)reportEvent:(NSString*)event;
-(void)reportException:(NSException*)exception;

@end
