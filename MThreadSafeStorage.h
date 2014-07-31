//
//  ASThreadSafeStorage.h
//  MEGA
//
//  Created by Andrei Stoleru on 29/07/14.
//  Copyright (c) 2014 MEGA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MThreadSafeStorage : NSObject

- (instancetype)initWithFile:(NSString *)path;

- (id)objectForKey:(NSString *)key;
- (void)addObject:(id)object forKey:(NSString *)key;
- (void)removeObjectForKey:(NSString *)key;

@end
