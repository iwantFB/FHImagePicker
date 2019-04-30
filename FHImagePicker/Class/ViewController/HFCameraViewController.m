//
//  HFCameraViewController.m
//  FHImagePicker
//
//  Created by 胡斐 on 2019/4/30.
//  Copyright © 2019 jackson. All rights reserved.
//

#import "HFCameraViewController.h"
#import "HFCameraSetting.h"
#import "HFCameraPreview.h"

@interface HFCameraViewController ()

@property (nonatomic, strong) HFCameraPreview *preview;
@property (nonatomic, strong) HFCameraSetting *cameraSetting;

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *cameraDeviceInput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *cameraOutput;
@end

@implementation HFCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self _configSubView];
    [self _setupCamera];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.session startRunning];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.session stopRunning];
}

#pragma mark- private method
- (void)_configSubView
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.preview.session = self.session;
    self.preview.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [self.view addSubview:_preview];
}

- (void)_setupCamera
{
    [self.session beginConfiguration];
    
    [self.session commitConfiguration];
}

#pragma mark- setter/getter
- (AVCaptureSession *)session
{
    if(!_session){
        _session = [[AVCaptureSession alloc] init];
    }
    return _session;
}

- (HFCameraPreview *)preview
{
    if(!_preview){
        _preview = [[HFCameraPreview alloc] init];
    }
    return _preview;
}

- (HFCameraSetting *)cameraSetting
{
    if(!_cameraSetting){
        _cameraSetting = [HFCameraSetting defalutConfig];
    }
    return _cameraSetting;
}

@end
