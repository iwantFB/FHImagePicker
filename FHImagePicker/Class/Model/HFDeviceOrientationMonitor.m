//
//  HFDeviceOrientationMonitor.m
//  FHImagePicker
//
//  Created by 胡斐 on 2019/5/7.
//  Copyright © 2019 jackson. All rights reserved.
//

#import "HFDeviceOrientationMonitor.h"
#import <CoreMotion/CoreMotion.h>

@interface HFDeviceOrientationMonitor ()

@property (strong, nonatomic) CMMotionManager *motionManager;

@end

@implementation HFDeviceOrientationMonitor

#pragma mark- public method
- (void)beginMonitorWithChange:(DeviceOrientationChange)changeBlock
{
    //查看设备是否可以使用
    __weak typeof(self) weakSelf = self;
    if(self.motionManager.isDeviceMotionAvailable){
        [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
            if(error){
                changeBlock(HFDeviceOrientationPortrait);
            }else
            {
             if(changeBlock)[weakSelf monitorChangedWithMotion:accelerometerData block:changeBlock];
            }
        }];
    }else{
        changeBlock(HFDeviceOrientationPortrait);
    }

}

- (void)endMonitor
{
    [self.motionManager stopDeviceMotionUpdates];
}

#pragma mark- private method
- (void)monitorChangedWithMotion:(CMAccelerometerData *)motion
                           block:(DeviceOrientationChange)changeBlock
{
    double x = motion.acceleration.x;
    double y = motion.acceleration.y;
    
    HFDeviceOrientation deviceOrientation;
    
    if ((fabs(y) + 0.1f) >= fabs(x))
    {
        if (y >= 0.1f)
        {
            deviceOrientation = HFDeviceOrientationPortraitUpsideDown;
        }
        else
        {
            deviceOrientation = HFDeviceOrientationPortrait;
        }
    }
    else
    {
        if (x >= 0.1f)
        {
            deviceOrientation = HFDeviceOrientationLandscapeRight;
        }
        else if (x <= 0.1f)
        {
            deviceOrientation = HFDeviceOrientationLandscapeLeft;
        }
        else
        {
            deviceOrientation = HFDeviceOrientationPortrait;
        }
    }
    
    changeBlock(deviceOrientation);
}

#pragma mark-setter/getter
- (CMMotionManager *)motionManager
{
    if(!_motionManager){
        _motionManager = [[CMMotionManager alloc] init];
    }
    return _motionManager;
}

- (void)setUpdateInterval:(NSTimeInterval)updateInterval
{
    _updateInterval = updateInterval;
    self.motionManager.accelerometerUpdateInterval = _updateInterval;
}

@end
