//
//  HFCameraSetting.h
//  FHImagePicker
//
//  Created by 胡斐 on 2019/4/30.
//  Copyright © 2019 jackson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, HFCameraDevice) {
    HFCameraDeviceFront = 0,
    HFCameraDeviceBack
};

typedef NS_ENUM(NSInteger, HFCameraMode) {
    HFCameraModePhoto = 0,
    HFCameraModeVideo
};

typedef NS_ENUM(NSInteger, HFCameraVideoGravity) {
    HFCameraVideoGravityAspect,
    HFCameraVideoGravityAspectFill,
    HFCameraVideoGravityResize
};

NS_ASSUME_NONNULL_BEGIN

@interface HFCameraSetting : NSObject

@property (nonatomic, assign) HFCameraDevice cameraDevice;
@property (nonatomic, assign) HFCameraMode cameraMode;

@property (nonatomic, assign) CGRect cameraRect;
@property (nonatomic, assign) CGRect bottomBarRect;
@property(assign) HFCameraVideoGravity cameraGravity;
@property (copy, readonly) NSString *videoGravity;

+ (instancetype)defalutConfig;

@end

NS_ASSUME_NONNULL_END
