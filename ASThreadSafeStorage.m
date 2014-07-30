//
//  ASThreadSafeStorage.m
//  MEGA
//
//  Created by Andrei Stoleru on 29/07/14.
//  Copyright (c) 2014 MEGA. All rights reserved.
//

#import "ASThreadSafeStorage.h"

@interface ASThreadSafeStorage()

@property (nonatomic, strong) NSMutableDictionary *data;
@property (nonatomic, strong) dispatch_queue_t lockQueue;

@end

@implementation ASThreadSafeStorage

- (instancetype)init
{
    if (self = [super init]) {
        _lockQueue = dispatch_queue_create("co.nz.mega", DISPATCH_QUEUE_SERIAL);
        _data = [NSMutableDictionary dictionary];
    }
    return self;
}

- (instancetype)initWithFile:(NSString *)path {
    if (self = [super init]) {
        _lockQueue = dispatch_queue_create("co.nz.mega", DISPATCH_QUEUE_SERIAL);
        _data = [NSMutableDictionary dictionaryWithContentsOfURL:[NSURL fileURLWithPath:path]];
    }
    return self;
}

- (id)objectForKey:(NSString *)key
{
    __block id retVal = nil;
    dispatch_sync(self.lockQueue, ^{
        retVal = [self.data objectForKey:key];
    });
    return retVal;
}

- (void)addObject:(id)object forKey:(NSString *)key
{
    dispatch_async(self.lockQueue, ^{
        [self.data setObject:object forKey:key];
    });
}

- (void)removeObjectForKey:(NSString *)key
{
    dispatch_async(self.lockQueue, ^{
        [self.data removeObjectForKey:key];
    });
}

@end
