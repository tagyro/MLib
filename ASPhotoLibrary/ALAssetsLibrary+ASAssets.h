//
//  ALAssetsLibrary+ASAssets.h
//  MEGA
//
//  Created by Andrei Stoleru on 24/07/14.
//  Copyright (c) 2014 MEGA. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

#import <AVFoundation/AVFoundation.h>

@interface ALAssetsLibrary (ASAssets)

- (void)asassets_enumerateGroupsWithTypes:(ALAssetsGroupType)types usingBlock:(ALAssetsLibraryGroupsEnumerationResultsBlock)enumerationBlock failureBlock:(ALAssetsLibraryAccessFailureBlock)failureBlock;

- (void)lastPhoto:(void (^)(ALAsset *))returnBlock;

-(void)export:(ALAsset*)asset withHandler:(void (^)(NSURL* url, NSError* error))handler;

@end
