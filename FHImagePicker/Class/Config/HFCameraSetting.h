//
//  HFCameraSetting.h
//  FHImagePicker
//
//  Created by 胡斐 on 2019/4/30.
//  Copyright © 2019 jackson. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, HFCameraDevice) {
    HFCameraDeviceFront = 0,
    HFCameraDeviceBack
};

typedef NS_ENUM(NSInteger, HFCameraMode) {
    HFCameraModePhoto = 0,
    HFCameraModeVideo
};

NS_ASSUME_NONNULL_BEGIN

@interface HFCameraSetting : NSObject

@property (nonatomic, assign) HFCameraDevice cameraDevice;
@property (nonatomic, assign) HFCameraMode cameraMode;

+ (instancetype)defalutConfig;

@end

NS_ASSUME_NONNULL_END
