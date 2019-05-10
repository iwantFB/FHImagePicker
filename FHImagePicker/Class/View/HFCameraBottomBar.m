//
//  HFCameraBottomBar.m
//  FHImagePicker
//
//  Created by 胡斐 on 2019/5/5.
//  Copyright © 2019 jackson. All rights reserved.
//

#import "HFCameraBottomBar.h"

@interface HFCameraBottomBar()

@property (nonatomic, strong) UIButton *takePhotoBtn;

@end

@implementation HFCameraBottomBar

- (instancetype)initWithFrame:(CGRect )frame
{
    if(self = [super initWithFrame:frame]){
        [self _configSubView];
    }
    return self;
}

- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

#pragma mark- action
- (void)_takePhotoBtnAction
{
    if(_delegate && [_delegate respondsToSelector:@selector(cameraBottomBarShouldCapture:)]){
        [_delegate cameraBottomBarShouldCapture:self];
    }
}

#pragma mark- public method
- (void)rotateUIWithDegress:(CGFloat )degress
                  animation:(BOOL)animation
{
    NSTimeInterval animationDuration = animation ? 1.0 : 0.0;
    self.takePhotoBtn.transform = CGAffineTransformIdentity;
    [UIView animateWithDuration:animationDuration animations:^{
        self.takePhotoBtn.transform = CGAffineTransformRotate(self.takePhotoBtn.transform, degress);
    }];
}

#pragma mark- private method
- (void)_configSubView
{
    self.alpha = 0.5;
    self.backgroundColor = [UIColor blackColor];
    
    [self addSubview:self.takePhotoBtn];
    _takePhotoBtn.frame = CGRectMake(0, 0, 60, 60);
}

#pragma mark- setter/getter
- (UIButton *)takePhotoBtn
{
    if(!_takePhotoBtn){
        _takePhotoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_takePhotoBtn setTitle:@"拍照" forState:UIControlStateNormal];
        [_takePhotoBtn addTarget:self action:@selector(_takePhotoBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _takePhotoBtn;
}

@end
