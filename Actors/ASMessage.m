//
//  ASMessage.m
//  MEGA
//
//  Created by Andrei Stoleru on 29/07/14.
//  Copyright (c) 2014 MEGA. All rights reserved.
//

#import "ASMessage.h"

@interface ASMessage ()

@property (nonatomic, assign) SEL selector;

@end

@implementation ASMessage

- (id)initWithSelector:(SEL)selector
{
    self = [super init];
    if (self) {
        _selector = selector;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

@end
