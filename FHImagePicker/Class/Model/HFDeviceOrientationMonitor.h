//
//  HFDeviceOrientationMonitor.h
//  FHImagePicker
//
//  Created by 胡斐 on 2019/5/7.
//  Copyright © 2019 jackson. All rights reserved.
//

#import <Foundation/Foundation.h>

//和AVCaptureVideoOrientation一致，可以直接使用
typedef NS_ENUM(NSInteger, HFDeviceOrientation) {
    HFDeviceOrientationPortrait = 1,
    HFDeviceOrientationPortraitUpsideDown,
    HFDeviceOrientationLandscapeRight,
    HFDeviceOrientationLandscapeLeft,
    HFDeviceOrientationFaceUp,
    HFDeviceOrientationFaceDown,
    HFDeviceOrientationUnknown,
};

typedef void(^DeviceOrientationChange)(HFDeviceOrientation orientation);

NS_ASSUME_NONNULL_BEGIN

@interface HFDeviceOrientationMonitor : NSObject

@property (nonatomic, assign) NSTimeInterval updateInterval;

- (void)beginMonitorWithChange:(DeviceOrientationChange)changeBlock;

- (void)endMonitor;

@end

NS_ASSUME_NONNULL_END
