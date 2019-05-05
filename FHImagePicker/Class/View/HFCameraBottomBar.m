//
//  HFCameraBottomBar.m
//  FHImagePicker
//
//  Created by 胡斐 on 2019/5/5.
//  Copyright © 2019 jackson. All rights reserved.
//

#import "HFCameraBottomBar.h"

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

#pragma mark- private method
- (void)_configSubView
{
    self.alpha = 0.5;
    self.backgroundColor = [UIColor blackColor];
}

@end
