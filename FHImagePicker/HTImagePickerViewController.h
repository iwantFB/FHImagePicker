//
//  HTImagePickerViewController.h
//  FHImagePicker
//
//  Created by 胡斐 on 2019/1/11.
//  Copyright © 2019年 jackson. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HTImagePickerViewController;

@protocol HTImagePickerViewController <NSObject>

- (void)imagePickerController:(HTImagePickerViewController *)picker
didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info;

- (void)imagePickerControllerDidCancel:(HTImagePickerViewController *)picker;

@end

typedef NS_ENUM(NSInteger, HTImagePickerSourceType) {
    ///只能拍照，只能获取相片
    HTImagePickerSourceTypeCamera,
    ///直接跳转相册
    HTImagePickerSourceTypePhotoLibary,
    ///只能拍摄视频，暂时没有处理该逻辑，方便后期扩展
    HTImagePickerSourceTypeVideo,
    ///拍照+拍摄 ，可以选择的有照片+视频
    HTImagePickerSourceTypeAny
};

NS_ASSUME_NONNULL_BEGIN

@interface HTImagePickerViewController : UINavigationController

@property (nonatomic, weak) id<HTImagePickerViewController> pickerDelegate;

/// 是否需要编辑
@property (nonatomic, assign) BOOL editAble;

/// 所需要的相机类型
@property (nonatomic, assign) HTImagePickerSourceType sourceType;

@end

NS_ASSUME_NONNULL_END
