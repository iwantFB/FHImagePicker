//
//  HFCameraSetting.m
//  FHImagePicker
//
//  Created by 胡斐 on 2019/4/30.
//  Copyright © 2019 jackson. All rights reserved.
//

#import "HFCameraSetting.h"
#import <AVFoundation/AVFoundation.h>
@implementation HFCameraSetting

+ (instancetype)defalutConfig
{
    CGFloat bottomBarHeight = 150;
    
    HFCameraSetting *setting = [[HFCameraSetting alloc] init];
    setting.cameraDevice = HFCameraDeviceBack;
    setting.cameraMode = HFCameraModePhoto;
    setting.cameraRect = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - NavigationBar_Height);
    setting.cameraGravity = HFCameraVideoGravityAspectFill;
    setting.bottomBarRect = CGRectMake(0, SCREEN_HEIGHT - NavigationBar_Height - bottomBarHeight, SCREEN_WIDTH, bottomBarHeight);
    return setting;
}

#pragma mark- setter/getter
- (NSString *)videoGravity
{
    NSString *currentVideoGravity = AVLayerVideoGravityResizeAspect;
    switch (_cameraGravity) {
        case HFCameraVideoGravityAspect:
            currentVideoGravity = AVLayerVideoGravityResizeAspect;
            break;
        case HFCameraVideoGravityAspectFill:
            currentVideoGravity = AVLayerVideoGravityResizeAspectFill;
        default:
            currentVideoGravity = AVLayerVideoGravityResize;
            break;
    }
    
    return currentVideoGravity;
}

@end
