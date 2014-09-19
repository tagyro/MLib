//
//  ASThreadSafeStorage.m
//  MEGA
//
//  Created by Andrei Stoleru on 29/07/14.
//  Copyright (c) 2014 MEGA. All rights reserved.
//

#import "MThreadSafeStorage.h"

@interface MThreadSafeStorage()

@property (nonatomic, strong) NSMutableDictionary *data;
@property (nonatomic, strong) dispatch_queue_t lockQueue;
@property (nonatomic, strong) NSString *filepath;

@end

@implementation MThreadSafeStorage

- (instancetype)init
{
    if (self = [super init]) {
        _lockQueue = dispatch_queue_create("co.nz.mega", DISPATCH_QUEUE_SERIAL);
        _data = [NSMutableDictionary new];
    }
    return self;
}

- (instancetype)initWithFile:(NSString *)path {
    if (self = [super init]) {
        _lockQueue = dispatch_queue_create("co.nz.mega", DISPATCH_QUEUE_SERIAL);
        _filepath = path;
        _data = [NSMutableDictionary dictionaryWithContentsOfURL:[NSURL fileURLWithPath:_filepath]];
        if (!_data) {
            _data = [NSMutableDictionary new];
            [_data writeToFile:_filepath atomically:YES];
        }
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

- (NSArray*)allKeys {
    __block id retVal = nil;
    dispatch_sync(self.lockQueue, ^{
        retVal = [self.data allKeys];
    });
    return retVal;
}

- (NSArray *)allObjects {
    __block id retVal = nil;
    dispatch_sync(self.lockQueue, ^{
        retVal = [self.data allValues];
    });
    return retVal;
}

- (void)addObject:(id)object forKey:(NSString *)key
{
    dispatch_async(self.lockQueue, ^{
        if (!object) {
            return ;
        }
        [self.data setObject:object forKey:key];
        [self.data writeToFile:_filepath atomically:YES];
    });
}

- (void)removeObjectForKey:(NSString *)key
{
    dispatch_async(self.lockQueue, ^{
        [self.data removeObjectForKey:key];
    });
}

@end
