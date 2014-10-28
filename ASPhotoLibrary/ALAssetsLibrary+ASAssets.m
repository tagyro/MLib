//
//  ALAssetsLibrary+ASLib.h
//  MEGA
//
//  Created by Andrei Stoleru on 24/07/14.
//  Copyright (c) 2014 MEGA. All rights reserved.
//

#import "ALAssetsLibrary+ASAssets.h"

static NSString *kErrorDomain = @"co.nz.mega";

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
    if ([[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
        //
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        NSString *filepath = [tmp stringByAppendingPathComponent:[self filenameForAsset:asset]];
        //
        [[NSFileManager defaultManager] createFileAtPath:filepath contents:nil attributes:nil];
        NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:filepath];
        if (!handle)
        {
            // failed try the memory way...
            BOOL res = NO;
            //
            if ([[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                // assset is photo; get orientation and export the cgimage
                NSLog(@"Using fullResolutionImage UIImageJPEGRepresentation to generate image");
                ALAssetRepresentation *rep = [asset defaultRepresentation];
                
                UIImageOrientation imageOrientation = UIImageOrientationUp;
                NSNumber* orientationValue = [asset valueForProperty:@"ALAssetPropertyOrientation"];
                if (orientationValue != nil) {
                    imageOrientation = [orientationValue intValue];
                } else {
                    ALAssetOrientation assetOrientation = [rep orientation];
                    switch (assetOrientation) {
                        case ALAssetOrientationDown:
                            imageOrientation = UIImageOrientationDown;
                            break;
                        case ALAssetOrientationDownMirrored:
                            imageOrientation = UIImageOrientationDownMirrored;
                            break;
                        case ALAssetOrientationLeft:
                            imageOrientation = UIImageOrientationLeft;
                            break;
                        case ALAssetOrientationLeftMirrored:
                            imageOrientation = UIImageOrientationLeftMirrored;
                            break;
                        case ALAssetOrientationRight:
                            imageOrientation = UIImageOrientationRight;
                            break;
                        case ALAssetOrientationRightMirrored:
                            imageOrientation = UIImageOrientationRightMirrored;
                            break;
                        case ALAssetOrientationUp:
                            imageOrientation = UIImageOrientationUp;
                            break;
                        case ALAssetOrientationUpMirrored:
                            imageOrientation = UIImageOrientationUpMirrored;
                            break;
                        default:
                            break;
                    }
                }
                
                if (!rep) {
                    handler(nil, [NSError errorWithDomain:kErrorDomain code:-1 userInfo:nil]);
                    return;
                }
                UIImage *img = [UIImage imageWithCGImage:[rep fullResolutionImage] scale:[rep scale] orientation:imageOrientation];
                NSData *dt = UIImageJPEGRepresentation(img, 1);
                res = [dt writeToFile:filepath atomically:YES];
                if (res) {
                    handler([NSURL fileURLWithPath:filepath],nil);
                    return;
                } else {
                    handler(nil, [NSError errorWithDomain:kErrorDomain code:-1 userInfo:nil]);
                }
            } else {
                [self export:asset withHandler:^(NSURL *url, NSError *error) {
                    //
                    if (error) {
                        handler(nil, [NSError errorWithDomain:kErrorDomain code:-1 userInfo:nil]);
                        return;
                    }
                    //
                    BOOL cp = [[NSFileManager defaultManager] moveItemAtURL:url toURL:[NSURL fileURLWithPath:filepath isDirectory:NO] error:nil];
                    if (cp) {
                        handler([NSURL fileURLWithPath:filepath],nil);
                    } else {
                        handler(nil, [NSError errorWithDomain:kErrorDomain code:-1 userInfo:nil]);
                    }
                }];
            }
            return;
        }
        //
        static const NSUInteger kBufferSize = 10 * 1024;
        uint8_t *buffer = calloc(kBufferSize, sizeof(*buffer));
        NSUInteger offset = 0, bytesRead = 0;
        
        do
        {
            @try
            {
                bytesRead = [rep getBytes:buffer fromOffset:offset length:kBufferSize error:nil];
                [handle writeData:[NSData dataWithBytesNoCopy:buffer length:bytesRead freeWhenDone:NO]];
                
                offset += bytesRead;
            }
            @catch (NSException *exception)
            {
                free(buffer);
                // failed try the memory way...
                handler(nil, [NSError errorWithDomain:kErrorDomain code:-1 userInfo:nil]);
                return;
            }
        }
        while (bytesRead > 0);
        
        free(buffer);
        [handle closeFile];
        //
        handler([NSURL fileURLWithPath:filepath], nil);
        //
        return;
    }
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

- (void)lastPhoto:(void (^)(ALAsset *))returnBlock {
    //
    NSMutableArray *groups = [NSMutableArray array];
    NSMutableArray *assets = [NSMutableArray array];
    //
    [self enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group!=nil) {
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result!=nil) {
                    if ([result valueForProperty:ALAssetPropertyType]==ALAssetTypePhoto) {
                        [assets addObject:result];
                    }
                }
            }];
            [groups addObject:group];
        } else {
            [assets sortUsingComparator:^NSComparisonResult(ALAsset *obj1, ALAsset *obj2) {
                if ([[obj1 valueForProperty:ALAssetPropertyDate] earlierDate:[obj2 valueForProperty:ALAssetPropertyDate]]==[obj1 valueForProperty:ALAssetPropertyDate]) {
                    return NSOrderedDescending;
                } else if ([[obj1 valueForProperty:ALAssetPropertyDate] earlierDate:[obj2 valueForProperty:ALAssetPropertyDate]]==[obj2 valueForProperty:ALAssetPropertyDate]) {
                    return NSOrderedAscending;
                }
                return NSOrderedSame;
            }];
            //
            returnBlock([assets firstObject]);
        }
    } failureBlock:^(NSError *error) {
        returnBlock(nil);
    }];
    //
}

//

- (NSString *)filenameForAsset:(ALAsset*)p {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:newDateFormat];
    
    NSString *f = [formatter stringFromDate:[p valueForProperty:ALAssetPropertyDate]];
    NSString *ext = @"";
    //
    if ([[p valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
        ext = @"jpg";
    } else if ([[p valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
        ext = @"mov";
    } else {
        ext = [[[p defaultRepresentation] url] pathExtension];
    }
    //
    NSString *fullPath = [[tmp stringByAppendingPathComponent:f] stringByAppendingPathExtension:ext];
    //
    if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath]) {
        BOOL exists = YES;
        int index = 1;
        do {
            fullPath = [[NSString stringWithFormat:@"%@_%i",[tmp stringByAppendingPathComponent:f],index] stringByAppendingPathExtension:ext];
            exists = [[NSFileManager defaultManager] fileExistsAtPath:fullPath];
            if (!exists) {
                f = [[f stringByAppendingString:[NSString stringWithFormat:@"_%i",index]] stringByAppendingPathExtension:ext];
            }
            index++;
        } while (exists == YES);
        //
    } else {
        f = [f stringByAppendingPathExtension:ext];
    }
    //
    return f;
}

@end
