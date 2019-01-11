//
//  HTImagePickerViewController.m
//  FHImagePicker
//
//  Created by 胡斐 on 2019/1/11.
//  Copyright © 2019年 jackson. All rights reserved.
//

#import "HTImagePickerViewController.h"

@interface HTImagePickerViewController ()

@end

@implementation HTImagePickerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self _initConfigData];
}

#pragma mark- private method
- (void)_initConfigData
{
    _sourceType = HTImagePickerSourceTypeAny;
    _editAble = NO;
}

- (void)setSourceType:(HTImagePickerSourceType)sourceType
{
    switch (sourceType) {
        case HTImagePickerSourceTypePhotoLibary:
        {
            
        }
            break;
        case HTImagePickerSourceTypeCamera:
        {
            
        }
            break;
        case HTImagePickerSourceTypeVideo:
        {
            
        }
            break;
        case HTImagePickerSourceTypeAny:
        {
            
        }
            break;
    }
}

@end
