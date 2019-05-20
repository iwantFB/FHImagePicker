//
//  HFMediaWriter.h
//  FHImagePicker
//
//  Created by 胡斐 on 2019/5/17.
//  Copyright © 2019 jackson. All rights reserved.
//
/*
 用来对媒体数据进行写入和对记录的媒体进行设置
*/

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HFMediaWriter : NSObject

///writer's error
@property (nonatomic, readonly) NSError *error;

///audio and video frame timestamp
@property (nonatomic, readonly) CMTime audioTimestamp;
@property (nonatomic, readonly) CMTime videoTimestamp;

@property (nonatomic, copy, readonly) NSURL *outputURL;

///must set outputURL
-(instancetype) init __attribute__((unavailable("init not available, call initWithOutputURL instead")));

///每次使用完毕后需要销毁之后重新创建
- (instancetype)initWithOutputURL:(NSURL *)outputURL;

- (BOOL)setupAudioWithSettings:(NSDictionary *)audioSettings;

- (BOOL)setupVideoWithSettings:(NSDictionary *)videoSettings withAdditional:(NSDictionary *)additional;

- (void)writeSampleBuffer:(CMSampleBufferRef)sampleBuffer withMediaTypeVideo:(BOOL)video;
- (void)finishWritingWithCompletionHandler:(void (^)(void))handler;

@end

NS_ASSUME_NONNULL_END
