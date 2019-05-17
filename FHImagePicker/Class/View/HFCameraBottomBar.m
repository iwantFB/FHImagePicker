//
//  HFCameraBottomBar.m
//  FHImagePicker
//
//  Created by 胡斐 on 2019/5/5.
//  Copyright © 2019 jackson. All rights reserved.
//

#import "HFCameraBottomBar.h"
#import "HFTakePhotoButton.h"

@interface HFCameraBottomBar()<HFTakePhotoButtonDelegate>

@property (nonatomic, strong) HFTakePhotoButton *takePhotoBtn;

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

#pragma mark- public method
- (void)rotateUIWithDegress:(CGFloat )degress
                  animation:(BOOL)animation
{
    NSTimeInterval animationDuration = animation ? 0.25 : 0.0;
    [UIView animateWithDuration:animationDuration animations:^{
        self.takePhotoBtn.transform = CGAffineTransformRotate(self.takePhotoBtn.transform, degress);
    }];
}

#pragma mark- HFTakePhotoButtonDelegate
- (void)photoButtonTakePhoto:(HFTakePhotoButton *)photoButton
{
    if([self canSafeCallDelegateWithAction:@selector(cameraBottomBarShouldCapture:)]){
        [_delegate cameraBottomBarShouldCapture:self];
    }
}

- (void)photoButtonStartRecording:(HFTakePhotoButton *)photoButton
{
    if([self canSafeCallDelegateWithAction:@selector(cameraBottomBarShouldStartRecord:)]){
        [_delegate cameraBottomBarShouldStartRecord:self];
    }
}

- (void)photoButtonEndRecording:(HFTakePhotoButton *)photoButton
{
    if([self canSafeCallDelegateWithAction:@selector(cameraBottomBarShouldEndRecord:)]){
        [_delegate cameraBottomBarShouldEndRecord:self];
    }
}


#pragma mark- private method
- (void)_configSubView
{
    self.alpha = 0.5;
    self.backgroundColor = [UIColor blackColor];
    
    [self addSubview:self.takePhotoBtn];
    _takePhotoBtn.frame = CGRectMake(0, 0, 60, 60);
}

- (BOOL)canSafeCallDelegateWithAction:(SEL)action
{
    if(_delegate && [_delegate respondsToSelector:action]){
        return YES;
    }
    return NO;
}

#pragma mark- setter/getter
- (HFTakePhotoButton *)takePhotoBtn
{
    if(!_takePhotoBtn){
        _takePhotoBtn = [HFTakePhotoButton new];
        _takePhotoBtn.delegate = self;
    }
    return _takePhotoBtn;
}

@end
