//
//  ALAssetsLibrary+ASLib.h
//  MEGA
//
//  Created by Andrei Stoleru on 24/07/14.
//  Copyright (c) 2014 MEGA. All rights reserved.
//

#import "ALAssetsLibrary+ASAssets.h"

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

-(void)export:(ALAsset*)asset withHandler:(void (^)(NSURL* url, NSError* error))handler
{
    ALAssetRepresentation* representation=asset.defaultRepresentation;
    //
    AVAssetExportSession *m_session = [AVAssetExportSession exportSessionWithAsset:[AVURLAsset URLAssetWithURL:representation.url options:nil] presetName:AVAssetExportPresetPassthrough];
    m_session.outputFileType=AVFileTypeQuickTimeMovie;
    m_session.outputURL=[NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%f.mov",[NSDate timeIntervalSinceReferenceDate]]]];
    [m_session exportAsynchronouslyWithCompletionHandler:^
     {
         if (m_session.status!=AVAssetExportSessionStatusCompleted)
         {
             NSError* error=m_session.error;
             __block m_session=nil;
             handler(nil,error);
             return;
         }
         NSURL* url=m_session.outputURL;
         __block m_session=nil;
         handler(url,nil);
     }];
}

@end
