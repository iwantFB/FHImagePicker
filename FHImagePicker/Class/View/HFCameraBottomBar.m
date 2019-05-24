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
@property (nonatomic, strong) UIButton *deleteBtn;
@property (nonatomic, strong) UIButton *doneBtn;

///拍摄过视频
@property (nonatomic, assign) BOOL recorded;

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
- (void)_deleteBtnAction
{
    
}

- (void)_doneBtnAction
{
    _recorded = NO;
    if([self canSafeCallDelegateWithAction:@selector(cameraBottomBarShouldEndRecord:)]){
        [_delegate cameraBottomBarShouldEndRecord:self];
    }
}

#pragma mark- public method
- (void)rotateUIWithDegress:(CGFloat )degress
                  animation:(BOOL)animation
{
    NSTimeInterval animationDuration = animation ? 0.25 : 0.0;
    [UIView animateWithDuration:animationDuration animations:^{
        self.takePhotoBtn.transform = CGAffineTransformRotate(self.takePhotoBtn.transform, degress);
    }];
}

- (void)originUI{
    _doneBtn.hidden = YES;
    _deleteBtn.hidden = YES;
}

- (void)beginRecordingUI
{
    _doneBtn.hidden = NO;
    _deleteBtn.hidden = NO;
}

#pragma mark- HFTakePhotoButtonDelegate
- (void)photoButtonTakePhoto:(HFTakePhotoButton *)photoButton
{
    if([self canSafeCallDelegateWithAction:@selector(cameraBottomBarShouldCapture:)]){
        [_delegate cameraBottomBarShouldCapture:self];
    }
}

- (void)photoButtonTouchDown:(HFTakePhotoButton *)photoButton
{
    if(_recorded){
        if([self canSafeCallDelegateWithAction:@selector(cameraBottomBarShouldResumeRecord:)]){
            [_delegate cameraBottomBarShouldResumeRecord:self];
        }
    }else{
        if([self canSafeCallDelegateWithAction:@selector(cameraBottomBarShouldStartRecord:)]){
            [_delegate cameraBottomBarShouldStartRecord:self];
            _recorded = YES;
        }
        
    }
    
}

- (void)photoButtonTouchUp:(HFTakePhotoButton *)photoButton
{
    if([self canSafeCallDelegateWithAction:@selector(cameraBottomBarShouldPauseRecord:)]){
        [_delegate cameraBottomBarShouldPauseRecord:self];
    }
}


#pragma mark- private method
- (void)_configSubView
{
    self.alpha = 0.5;
    self.backgroundColor = [UIColor blackColor];
    
    [self addSubview:self.deleteBtn];
    [self addSubview:self.takePhotoBtn];
    [self addSubview:self.doneBtn];
    
    CGFloat selfWidth = CGRectGetWidth(self.bounds);
    CGFloat selfHeight = CGRectGetHeight(self.bounds);
    CGFloat btnWidthHeight = 60;
    CGFloat btn_Y = (selfHeight - btnWidthHeight)/2.0;
    
    _deleteBtn.frame = CGRectMake(15, btn_Y, btnWidthHeight, btnWidthHeight);
    _takePhotoBtn.frame = CGRectMake((selfWidth - btnWidthHeight)/2.0, btn_Y, btnWidthHeight, btnWidthHeight);
    _doneBtn.frame = CGRectMake(selfWidth - 15 - btnWidthHeight, btn_Y, btnWidthHeight, btnWidthHeight);
    
}

- (BOOL)canSafeCallDelegateWithAction:(SEL)action
{
    if(_delegate && [_delegate respondsToSelector:action]){
        return YES;
    }
    return NO;
}

- (UIButton *)buttonForTitle:(NSString *)title target:(id)target action:(SEL)action
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    if([target respondsToSelector:action]){
        [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    }
    return btn;
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

- (UIButton *)deleteBtn
{
    if(!_deleteBtn){
        _deleteBtn = [self buttonForTitle:@"删除" target:self action:@selector(_deleteBtnAction)];
    }
    return _deleteBtn;
}

- (UIButton *)doneBtn
{
    if(!_doneBtn){
        _doneBtn = [self buttonForTitle:@"完成" target:self action:@selector(_doneBtnAction)];
    }
    return _doneBtn;
}

@end
