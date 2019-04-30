//
//  HFCameraSetting.m
//  FHImagePicker
//
//  Created by 胡斐 on 2019/4/30.
//  Copyright © 2019 jackson. All rights reserved.
//

#import "HFCameraSetting.h"

@implementation HFCameraSetting

+ (instancetype)defalutConfig
{
    HFCameraSetting *setting = [[HFCameraSetting alloc] init];
    setting.cameraDevice = HFCameraDeviceBack;
    setting.cameraMode = HFCameraModePhoto;
    return setting;
}

@end
