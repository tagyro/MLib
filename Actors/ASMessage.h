//
//  ASMessage.h
//  MEGA
//
//  Created by Andrei Stoleru on 29/07/14.
//  Copyright (c) 2014 MEGA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASMessage : NSObject <NSCopying>

@property (nonatomic, readonly) SEL selector;

- (id)initWithSelector:(SEL)aSelector;

@end
