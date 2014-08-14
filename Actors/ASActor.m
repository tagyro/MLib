//
//  ASActor.m
//  MEGA
//
//  Created by Andrei Stoleru on 29/07/14.
//  Copyright (c) 2014 MEGA. All rights reserved.
//

#import "ASActor.h"

#import <objc/message.h>

@interface ASActor ()

@property (nonatomic, copy, readwrite) NSString *uuid;

- (void)_processMessage:(ASMessage *)message;

@end

@implementation ASActor

- (instancetype)init
{
    self = [super init];
    if (self) {
        _uuid = [[NSUUID UUID] UUIDString];
    }
    
    return self;
}

- (void)main
{
    @autoreleasepool {
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        
        BOOL shouldKeepRunning = YES;
        
        while (shouldKeepRunning && !self.isCancelled) {
            shouldKeepRunning = [runLoop runMode:NSDefaultRunLoopMode
                                      beforeDate:[NSDate distantFuture]];
        }
    }
}

- (void)executeMessage:(ASMessage *)message
{
    [self performSelector:@selector(_processMessage:)
                 onThread:self
               withObject:[message copy] //copy to avoid shared state
            waitUntilDone:NO];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ %p %@", NSStringFromClass([self class]), self, self.uuid];
}

#pragma mark - Private Methods

- (void)_processMessage:(ASMessage *)message
{
    if ([self respondsToSelector:message.selector]) {
        objc_msgSend(self, message.selector, message);
    }
}

@end
