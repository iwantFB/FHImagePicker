//
//  ViewController.m
//  FHImagePicker
//
//  Created by 胡斐 on 2019/1/11.
//  Copyright © 2019年 jackson. All rights reserved.
//

#import "ViewController.h"
#import "HFCameraViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)showTheCamera {
    HFCameraViewController *cameraVC = [[HFCameraViewController alloc] init];
    [self.navigationController pushViewController:cameraVC animated:YES];
}

@end
