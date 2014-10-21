//
//  NSString+ASCategory.m
//  MEGA
//
//  Created by Andrei Stoleru on 15/10/14.
//  Copyright (c) 2014 MEGA. All rights reserved.
//

#import "NSString+ASCategory.h"

@implementation NSString (ASCategory)

- (NSString*) stringBetweenString:(NSString*)start andString:(NSString*)end {
    NSScanner* scanner = [NSScanner scannerWithString:self];
    [scanner setCharactersToBeSkipped:nil];
    [scanner scanUpToString:start intoString:NULL];
    if ([scanner scanString:start intoString:NULL]) {
        NSString* result = nil;
        if ([scanner scanUpToString:end intoString:&result]) {
            return result;
        }
    }
    return nil;
}

@end
