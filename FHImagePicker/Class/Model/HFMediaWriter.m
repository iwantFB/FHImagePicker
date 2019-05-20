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

@property (nonatomic, strong) AVAssetWriterInput *assetWriterAudioInput;
@property (nonatomic, strong) AVAssetWriterInput *assetWriterVideoInput;

@property (nonatomic, copy) NSURL *outputURL;

@end

@implementation HFMediaWriter

#pragma mark- public method
- (instancetype)initWithOutputURL:(NSURL *)outputURL
{
    if(self = [super init]){
        NSError *error = nil;
        _assetWriter = [AVAssetWriter assetWriterWithURL:outputURL fileType:AVFileTypeMPEG4 error:&error];
        if (error) {
            _assetWriter = nil;
            return nil;
        }
        
        
        _assetWriter.shouldOptimizeForNetworkUse = YES;
        
        _outputURL = outputURL;
        
        _audioTimestamp = kCMTimeInvalid;
        _videoTimestamp = kCMTimeInvalid;
        NSLog(@"创建自己");
    }
    
    return self;
}

#pragma mark- public method
- (BOOL)setupAudioWithSettings:(NSDictionary *)audioSettings{
    if (!_assetWriterAudioInput && [_assetWriter canApplyOutputSettings:audioSettings forMediaType:AVMediaTypeAudio]) {
        
        _assetWriterAudioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:audioSettings];
        _assetWriterAudioInput.expectsMediaDataInRealTime = YES;
        
        if (_assetWriterAudioInput && [_assetWriter canAddInput:_assetWriterAudioInput]) {
            [_assetWriter addInput:_assetWriterAudioInput];
            
            NSLog(@"setup audio input with settings sampleRate (%f) channels (%lu) bitRate (%ld)",
                 [[audioSettings objectForKey:AVSampleRateKey] floatValue],
                 (unsigned long)[[audioSettings objectForKey:AVNumberOfChannelsKey] unsignedIntegerValue],
                 (long)[[audioSettings objectForKey:AVEncoderBitRateKey] integerValue]);
            
        } else {
            NSLog(@"couldn't add asset writer audio input");
        }
        
    } else {
        
        _assetWriterAudioInput = nil;
        NSLog(@"couldn't apply audio output settings");
        
    }
    return NO;
}

- (BOOL)setupVideoWithSettings:(NSDictionary *)videoSettings withAdditional:(NSDictionary *)additional{
    if (!_assetWriterVideoInput && [_assetWriter canApplyOutputSettings:videoSettings forMediaType:AVMediaTypeVideo]) {
        
        _assetWriterVideoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
        _assetWriterVideoInput.expectsMediaDataInRealTime = YES;
        _assetWriterVideoInput.transform = CGAffineTransformIdentity;
        
        
        if (_assetWriterVideoInput && [_assetWriter canAddInput:_assetWriterVideoInput]) {
            [_assetWriter addInput:_assetWriterVideoInput];
            
#if !defined(NDEBUG) && LOG_WRITER
            NSDictionary *videoCompressionProperties = videoSettings[AVVideoCompressionPropertiesKey];
            if (videoCompressionProperties) {
                NSLog(@"setup video with compression settings bps (%f) frameInterval (%ld)",
                     [videoCompressionProperties[AVVideoAverageBitRateKey] floatValue],
                     (long)[videoCompressionProperties[AVVideoMaxKeyFrameIntervalKey] integerValue]);
            } else {
                NSLog(@"setup video");
            }
#endif
            
        } else {
            NSLog(@"couldn't add asset writer video input");
        }
        
    } else {
        
        _assetWriterVideoInput = nil;
        NSLog(@"couldn't apply video output settings");
        
    }
    
    return NO;
}

- (void)writeSampleBuffer:(CMSampleBufferRef)sampleBuffer withMediaTypeVideo:(BOOL)video{
    if (!CMSampleBufferDataIsReady(sampleBuffer)) {
        return;
    }
    
    // setup the writer
    if ( _assetWriter.status == AVAssetWriterStatusUnknown ) {
        
        if ([_assetWriter startWriting]) {
            CMTime timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
            [_assetWriter startSessionAtSourceTime:timestamp];
            NSLog(@"started writing with status (%ld)", (long)_assetWriter.status);
        } else {
            NSLog(@"error when starting to write (%@)", [_assetWriter error]);
            return;
        }
        
    }
    
    // check for completion state
    if ( _assetWriter.status == AVAssetWriterStatusFailed ) {
        NSLog(@"writer failure, (%@)", _assetWriter.error.localizedDescription);
        return;
    }
    
    if (_assetWriter.status == AVAssetWriterStatusCancelled) {
        NSLog(@"writer cancelled");
        return;
    }
    
    if ( _assetWriter.status == AVAssetWriterStatusCompleted) {
        NSLog(@"writer finished and completed");
        return;
    }
    
    // perform write
    if ( _assetWriter.status == AVAssetWriterStatusWriting ) {
        
        CMTime timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        CMTime duration = CMSampleBufferGetDuration(sampleBuffer);
        if (duration.value > 0) {
            timestamp = CMTimeAdd(timestamp, duration);
        }
        
        if (video) {
            if (_assetWriterVideoInput.readyForMoreMediaData) {
                if ([_assetWriterVideoInput appendSampleBuffer:sampleBuffer]) {
                    _videoTimestamp = timestamp;
                } else {
                    NSLog(@"writer error appending video (%@)", _assetWriter.error);
                }
            }else
            {
                NSLog(@"not ready for video %@ %@",_assetWriterAudioInput,_assetWriter);
            }
        } else {
            if (_assetWriterAudioInput.readyForMoreMediaData) {
                if ([_assetWriterAudioInput appendSampleBuffer:sampleBuffer]) {
                    _audioTimestamp = timestamp;
                } else {
                    NSLog(@"writer error appending audio (%@)", _assetWriter.error);
                }
            }else
            {
                NSLog(@"not ready for audio %@ %@",_assetWriterAudioInput,_assetWriter);
            }
        }
    }
}

- (void)finishWritingWithCompletionHandler:(void (^)(void))handler{
    if (_assetWriter.status == AVAssetWriterStatusUnknown ||
        _assetWriter.status == AVAssetWriterStatusCompleted) {
        NSLog(@"asset writer was in an unexpected state (%@)", @(_assetWriter.status));
        return;
    }
    [_assetWriterVideoInput markAsFinished];
    [_assetWriterAudioInput markAsFinished];
    [_assetWriter finishWritingWithCompletionHandler:handler];
}

#pragma mark- setter/getter
- (NSError *)error
{
    return _assetWriter.error;
}

@end
