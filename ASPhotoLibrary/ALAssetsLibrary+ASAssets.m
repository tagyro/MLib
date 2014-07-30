//
//  ALAssetsLibrary+ASLib.h
//  MEGA
//
//  Created by Andrei Stoleru on 24/07/14.
//  Copyright (c) 2014 MEGA. All rights reserved.
//

#import "ALAssetsLibrary+ASAssets.h"

@implementation ASAssetsPhoto
@end

@implementation ASAssetsAlbum
@end

@implementation ALAssetsLibrary (ASAssets)

- (void)asassets_enumerateGroupsWithTypes:(ALAssetsGroupType)types usingBlock:(ALAssetsLibraryGroupsEnumerationResultsBlock)enumerationBlock failureBlock:(ALAssetsLibraryAccessFailureBlock)failureBlock {
    //
    NSAssert(![NSThread isMainThread], @"This would create a deadlock (main thread waiting for main thread to complete)");
    //
    enum
    {
        ASAssetsLibraryDone,
        ASAssetsLibraryBusy
    };
    
    NSConditionLock *assetsLibraryConditionLock = [[NSConditionLock alloc] initWithCondition:ASAssetsLibraryBusy];
    
    __block NSUInteger numberOfGroups = 0;
    [self enumerateGroupsWithTypes:types
                        usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                            enumerationBlock(group, stop);
                            if (group) numberOfGroups++;
                            if (!group || *stop)
                            {
                                [assetsLibraryConditionLock lock];
                                [assetsLibraryConditionLock unlockWithCondition:ASAssetsLibraryDone];
                            }
                        }
                      failureBlock:^(NSError *error) {
                          failureBlock(error);
                          [assetsLibraryConditionLock lock];
                          [assetsLibraryConditionLock unlockWithCondition:ASAssetsLibraryDone];
                      }];
    
    [assetsLibraryConditionLock lockWhenCondition:ASAssetsLibraryDone];
    [assetsLibraryConditionLock unlock];
    //
}

@end
