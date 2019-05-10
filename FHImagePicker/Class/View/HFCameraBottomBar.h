//
//  HFCameraBottomBar.h
//  FHImagePicker
//
//  Created by 胡斐 on 2019/5/5.
//  Copyright © 2019 jackson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HFCameraBottomBar;

NS_ASSUME_NONNULL_BEGIN

@protocol HFCameraBottomBarDelegate <NSObject>

- (void)cameraBottomBarShouldCapture:(HFCameraBottomBar *)bottomBar;

@end

@interface HFCameraBottomBar : UIView

@property (weak, nonatomic) id<HFCameraBottomBarDelegate> delegate;

///degress == 只有0  M_PI_2  M_PI
- (void)rotateUIWithDegress:(CGFloat )degress
                  animation:(BOOL)animation;

@end

NS_ASSUME_NONNULL_END
