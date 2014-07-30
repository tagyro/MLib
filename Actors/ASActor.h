//
//  ASActor.h
//  MEGA
//
//  Created by Andrei Stoleru on 29/07/14.
//  Copyright (c) 2014 MEGA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ASMessage.h"

@interface ASActor : NSThread

@property (nonatomic, copy, readonly) NSString *uuid;

- (void)executeMessage:(ASMessage *)message;

@end
