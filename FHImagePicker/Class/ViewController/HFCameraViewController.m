//
//  HFCameraViewController.m
//  FHImagePicker
//
//  Created by 胡斐 on 2019/4/30.
//  Copyright © 2019 jackson. All rights reserved.
//

#import "HFCameraViewController.h"

#import "HFCameraPreview.h"
#import "HFCameraBottomBar.h"

#import "HFCameraSetting.h"
#import "HFDeviceOrientationMonitor.h"


@interface HFCameraViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate,HFCameraBottomBarDelegate,AVCapturePhotoCaptureDelegate,HFCameraBottomBarDelegate>

@property (nonatomic, strong) HFCameraPreview *preview;
@property (nonatomic, strong) HFCameraBottomBar *bottomBar;
@property (nonatomic, strong) HFCameraSetting *cameraSetting;

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *backCameraDeviceInput;
@property (nonatomic, strong) AVCaptureDeviceInput *frontCameraDeviceInput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *cameraOutput;
@property (nonatomic, strong) AVCapturePhotoOutput *capturePhotoOutput;

@property (nonatomic, strong) dispatch_queue_t videoQueue;

@property (nonatomic, strong) HFDeviceOrientationMonitor *orientationMonitor;
@property (nonatomic, assign) HFDeviceOrientation deviceOrient;
///应该中断一下，用在旋转摄像头和其他暂时没有考虑到的情况，不写入照片中
@property (nonatomic, assign) BOOL shouldInterrupt;
@end

@implementation HFCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initConfig];
    [self _configSubView];
    [self _setupCamera];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    WS(weakSelf)
    [self.orientationMonitor beginMonitorWithChange:^(HFDeviceOrientation orientation) {
        //如果设备朝向和检测到的朝向一致的时候无需操作
        if(weakSelf.deviceOrient == orientation || orientation > 4)return;
        NSLog(@"朝向%ld",orientation);
        [weakSelf rotateDeviceUIWithTargetOrient:orientation];
        weakSelf.deviceOrient = orientation;
        AVCaptureConnection *connection = [weakSelf.capturePhotoOutput connectionWithMediaType:AVMediaTypeVideo];
        if([connection isVideoOrientationSupported]){
            AVCaptureVideoOrientation videoOrientation = AVCaptureVideoOrientationPortrait;
            switch (orientation) {
                case HFDeviceOrientationLandscapeLeft:
                    videoOrientation = AVCaptureVideoOrientationLandscapeRight;
                    break;
                case HFDeviceOrientationLandscapeRight:
                    videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
                    break;
                    case HFDeviceOrientationPortraitUpsideDown:
                    videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
                    break;
                default:
                    videoOrientation = AVCaptureVideoOrientationPortrait;
                    break;
            }
            [connection setVideoOrientation:videoOrientation];
        }
    }];
    [self.session startRunning];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.orientationMonitor endMonitor];
    [self.session stopRunning];
}

#pragma mark- private method
- (void)_initConfig
{
    _deviceOrient = HFDeviceOrientationPortrait;
}

- (void)_configSubView
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    
    self.preview.session = self.session;
    self.preview.frame = self.cameraSetting.cameraRect;
    self.preview.videoGravity = self.cameraSetting.videoGravity;
    [self.view addSubview:_preview];
    
    [self.view addSubview:self.bottomBar];
    self.bottomBar.frame = self.cameraSetting.bottomBarRect;
}

//根据配置信息设置相机
- (void)_setupCamera
{
    AVCaptureDeviceInput *deviceInput;
    //除非指定需要前置相机，否则默认使用后置相机
    if(self.cameraSetting.cameraDevice == HFCameraDeviceFront){
        deviceInput = self.frontCameraDeviceInput;
    }else{
        deviceInput = self.backCameraDeviceInput;
    }
    
    if([self.session canAddInput:deviceInput]){
        [self.session addInput:deviceInput];
    }
    
    [self.cameraOutput setSampleBufferDelegate:self queue:self.videoQueue];
    if([self.session canAddOutput:self.cameraOutput]){
        [self.session addOutput:self.cameraOutput];
    }
    
    if([self.session canAddOutput:self.capturePhotoOutput]){
        [self.session addOutput:self.capturePhotoOutput];
    }
}

- (void)rotateDeviceUIWithTargetOrient:(HFDeviceOrientation)orientation
{
    CGFloat degress = 0;
    if(   (orientation == HFDeviceOrientationPortrait && _deviceOrient == HFDeviceOrientationLandscapeLeft)
       || (orientation == HFDeviceOrientationLandscapeLeft && _deviceOrient == HFDeviceOrientationPortraitUpsideDown)
       || (orientation == HFDeviceOrientationPortraitUpsideDown && _deviceOrient == HFDeviceOrientationLandscapeRight)
       || (orientation == HFDeviceOrientationLandscapeRight && _deviceOrient == HFDeviceOrientationPortrait)){
        degress = - M_PI_2;
    }else if(
             (orientation == HFDeviceOrientationPortrait && _deviceOrient == HFDeviceOrientationPortraitUpsideDown)
             || (orientation == HFDeviceOrientationLandscapeLeft && _deviceOrient == HFDeviceOrientationLandscapeRight)
             || (orientation == HFDeviceOrientationPortraitUpsideDown && _deviceOrient == HFDeviceOrientationPortrait)
             || (orientation == HFDeviceOrientationLandscapeRight && _deviceOrient == HFDeviceOrientationLandscapeLeft)
             ){
        degress = M_PI;
    }else{
        degress = M_PI_2;
    }
    [_bottomBar rotateUIWithDegress:degress animation:YES];
}

#pragma mark- AVCaptureDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    
}

#pragma mark- AVCapturePhotoCaptureDelegate
- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhotoSampleBuffer:(nullable CMSampleBufferRef)photoSampleBuffer previewPhotoSampleBuffer:(nullable CMSampleBufferRef)previewPhotoSampleBuffer resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings bracketSettings:(nullable AVCaptureBracketedStillImageSettings *)bracketSettings error:(nullable NSError *)error
{
    if(error){
        NSLog(@"拍照出问题%@",error.localizedDescription);
        return;
    }
    
#warning should crop image to the size you want
    NSData *imageData = [AVCapturePhotoOutput JPEGPhotoDataRepresentationForJPEGSampleBuffer:photoSampleBuffer previewPhotoSampleBuffer:previewPhotoSampleBuffer];
    UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:imageData], nil, nil, nil);
}

#pragma mark- HFCameraBottomBarDelegate
- (void)cameraBottomBarShouldStartRecord:(HFCameraBottomBar *)bottomBar
{
    //每次开始的时候都需要先创建一个新的assetwrite
}

- (void)cameraBottomBarShouldEndRecord:(HFCameraBottomBar *)bottomBar
{
    
}

#pragma mark- HFCameraBottomBarDelegate
- (void)cameraBottomBarShouldCapture:(HFCameraBottomBar *)bottomBar
{
    AVCapturePhotoSettings *setting = [AVCapturePhotoSettings photoSettings];
    [self.capturePhotoOutput capturePhotoWithSettings:setting delegate:self];
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

-(HFCameraBottomBar *)bottomBar
{
    if(!_bottomBar){
        _bottomBar = [[HFCameraBottomBar alloc] init];
        _bottomBar.delegate = self;
    }
    return _bottomBar;
}

- (HFCameraSetting *)cameraSetting
{
    if(!_cameraSetting){
        _cameraSetting = [HFCameraSetting defalutConfig];
    }
    return _cameraSetting;
}

- (AVCaptureDeviceInput *)backCameraDeviceInput
{
    if(!_backCameraDeviceInput){
        NSError *error;
        AVCaptureDevice *backDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
        _backCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:backDevice error:&error];
    }
    return _backCameraDeviceInput;
}

- (AVCaptureDeviceInput *)frontCameraDeviceInput
{
    if(!_frontCameraDeviceInput){
        NSError *error;
        AVCaptureDevice *frontDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
        _frontCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:frontDevice error:&error];
    }
    return _frontCameraDeviceInput;
}

- (AVCaptureVideoDataOutput *)cameraOutput
{
    if(!_cameraOutput){
        _cameraOutput = [[AVCaptureVideoDataOutput alloc] init];
        _cameraOutput.alwaysDiscardsLateVideoFrames = YES;
    }
    return _cameraOutput;
}

- (AVCapturePhotoOutput *)capturePhotoOutput
{
    if(!_capturePhotoOutput){
        _capturePhotoOutput = [AVCapturePhotoOutput new];
    }
    return _capturePhotoOutput;
}

-(dispatch_queue_t)videoQueue
{
    if(!_videoQueue){
        _videoQueue = dispatch_queue_create("HFCameraDataOutputQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _videoQueue;
}

-(HFDeviceOrientationMonitor *)orientationMonitor
{
    if(!_orientationMonitor){
        _orientationMonitor = [[HFDeviceOrientationMonitor alloc] init];
    }
    return _orientationMonitor;
}


@end
