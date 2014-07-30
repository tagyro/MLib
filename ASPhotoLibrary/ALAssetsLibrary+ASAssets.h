//
//  ALAssetsLibrary+ASAssets.h
//  MEGA
//
//  Created by Andrei Stoleru on 24/07/14.
//  Copyright (c) 2014 MEGA. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

@interface ASAssetsPhoto : NSObject
@end

@interface ASAssetsAlbum : NSObject
@end

@interface ALAssetsLibrary (ASAssets)

- (void)asassets_enumerateGroupsWithTypes:(ALAssetsGroupType)types usingBlock:(ALAssetsLibraryGroupsEnumerationResultsBlock)enumerationBlock failureBlock:(ALAssetsLibraryAccessFailureBlock)failureBlock;

@end
