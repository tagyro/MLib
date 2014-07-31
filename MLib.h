//
//  ASLib.h
//  MEGA
//
//  Created by Andrei Stoleru on 01/04/14.
//  Copyright (c) 2014 MEGA. All rights reserved.
//

#ifndef ASLib
#define ASLib

#import "ASActor.h"

#import "MThreadSafeStorage.h"

#import "ALAssetsLibrary+ASAssets.h"

#import "UIImage+ASCategory.h"

#define UIColorFromHex(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#endif
