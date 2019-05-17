//
//  HFTakePhotoButton.h
//  FHImagePicker
//
//  Created by 胡斐 on 2019/5/17.
//  Copyright © 2019 jackson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HFTakePhotoButton;


NS_ASSUME_NONNULL_BEGIN

@protocol HFTakePhotoButtonDelegate <NSObject>

@optional
///拍照响应
- (void)photoButtonTakePhoto:(HFTakePhotoButton *)photoButton;

///开始录像
- (void)photoButtonStartRecording:(HFTakePhotoButton *)photoButton;

- (void)photoButton:(HFTakePhotoButton *)photoButton movedForZoom:(CGFloat)scale;

///结束录像
- (void)photoButtonEndRecording:(HFTakePhotoButton *)photoButton;

/// 录像被打断
- (void)photoButtonCancelRecording:(HFTakePhotoButton *)photoButton;

@end

@interface HFTakePhotoButton : UIView

@property (nonatomic, weak)id<HFTakePhotoButtonDelegate> delegate;

@property (nonatomic, assign) BOOL disableAnimation;

@end

NS_ASSUME_NONNULL_END
