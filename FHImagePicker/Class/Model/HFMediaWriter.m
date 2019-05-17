//
//  HFMediaWriter.m
//  FHImagePicker
//
//  Created by 胡斐 on 2019/5/17.
//  Copyright © 2019 jackson. All rights reserved.
//

#import "HFMediaWriter.h"
#import <MobileCoreServices/UTCoreTypes.h>

@interface HFMediaWriter ()

@property (nonatomic, strong) AVAssetWriter *assetWriter;

@end

@implementation HFMediaWriter

#pragma mark- public method
- (instancetype)initWithOutputURL:(NSURL *)outputURL
{
    NSError *error = nil;
    _assetWriter = [AVAssetWriter assetWriterWithURL:outputURL fileType:(NSString *)kUTTypeMPEG4 error:&error];
    if (error) {
        _assetWriter = nil;
        return nil;
    }
    
    
    _assetWriter.shouldOptimizeForNetworkUse = YES;
    //给拍摄的数据添加一些源数据，不需要
    
    _audioTimestamp = kCMTimeInvalid;
    _videoTimestamp = kCMTimeInvalid;
    
    return self;
}

#pragma mark- setter/getter
- (NSError *)error
{
    return _assetWriter.error;
}

@end
