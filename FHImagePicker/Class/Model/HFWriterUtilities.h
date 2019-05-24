//
//  HFWriterUtilities.h
//  FHImagePicker
//
//  Created by 胡斐 on 2019/5/24.
//  Copyright © 2019 jackson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HFWriterUtilities : NSObject

+ (CMSampleBufferRef)createOffsetSampleBufferWithSampleBuffer:(CMSampleBufferRef)sampleBuffer withTimeOffset:(CMTime)timeOffset;

@end

NS_ASSUME_NONNULL_END
