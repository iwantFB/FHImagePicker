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

#import <Photos/Photos.h>
#import "HFCameraSetting.h"
#import "HFDeviceOrientationMonitor.h"
#import "HFMediaWriter.h"
#import "HFFileManager.h"
#import "HFWriterUtilities.h"

typedef NS_ENUM(NSInteger, HFCameraStatus) {
    HFCameraStatusWait,
    HFCameraStatusShooting,
    HFCameraStatusPause,
    HFCameraStatusEnd
};


@interface HFCameraViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate,HFCameraBottomBarDelegate,AVCapturePhotoCaptureDelegate>

@property (nonatomic, strong) HFCameraPreview *preview;
@property (nonatomic, strong) HFCameraBottomBar *bottomBar;
@property (nonatomic, strong) HFCameraSetting *cameraSetting;

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *audioInput;
@property (nonatomic, strong) AVCaptureDeviceInput *backCameraDeviceInput;
@property (nonatomic, strong) AVCaptureDeviceInput *frontCameraDeviceInput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *cameraOutput;
@property (nonatomic, strong) AVCaptureAudioDataOutput *audioOutput;
@property (nonatomic, strong) AVCapturePhotoOutput *capturePhotoOutput;

@property (nonatomic, strong) dispatch_queue_t videoQueue;

@property (nonatomic, strong) HFDeviceOrientationMonitor *orientationMonitor;
@property (nonatomic, assign) HFDeviceOrientation deviceOrient;
///应该中断一下，用在旋转摄像头和其他暂时没有考虑到的情况，不写入照片中
@property (nonatomic, assign) HFCameraStatus cameraStatus;
//是否中断过
@property (nonatomic, assign) BOOL isInterrupt;

@property (nonatomic, strong) HFMediaWriter *mediaWriter;

///暂停的时间节点，用来做断点回删
@property (nonatomic, strong) NSArray *pauseTimeArr;
@end

@implementation HFCameraViewController
{
    //用以计算最大拍摄时长
    CMTime _startTime;
    CMTime _timeOffset;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initConfig];
    [self _configSubView];
    [self _setupCamera];
    [self _setupMicphone];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    WS(weakSelf)
    [self.orientationMonitor beginMonitorWithChange:^(HFDeviceOrientation orientation) {
        //如果设备朝向和检测到的朝向一致的时候无需操作
        if(weakSelf.deviceOrient == orientation || orientation > 4)return;
        [weakSelf rotateDeviceUIWithTargetOrient:orientation];
        weakSelf.deviceOrient = orientation;
        AVCaptureConnection *connection = [weakSelf.capturePhotoOutput connectionWithMediaType:AVMediaTypeVideo];
        
        AVCaptureVideoOrientation videoOrientation = [self deviceOrientToAVVideoOrient:orientation];
        
        if([connection isVideoOrientationSupported]){
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
    
    //初始化为基础UI
    [self.bottomBar originUI];
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

- (void)_setupMicphone
{
    if([self.session canAddInput:self.audioInput]){
        [self.session addInput:self.audioInput];
    }
    
    [self.audioOutput setSampleBufferDelegate:self queue:self.videoQueue];
    if([self.session canAddOutput:self.audioOutput]){
        [self.session addOutput:self.audioOutput];
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

- (void)_configWriter
{
    if(_mediaWriter)_mediaWriter = nil;
    [_orientationMonitor endMonitor];
    AVCaptureConnection *connection = [_cameraOutput connectionWithMediaType:AVMediaTypeVideo];
    
    AVCaptureVideoOrientation videoOrientation = [self deviceOrientToAVVideoOrient:_deviceOrient];
    
    if([connection isVideoOrientationSupported]){
        [connection setVideoOrientation:videoOrientation];
    }
    
    int videoWidth = _cameraSetting.videoSize.width;
    int videoHeight = _cameraSetting.videoSize.height;
    NSDictionary *videoSetting = @{
                                   AVVideoScalingModeKey : AVVideoScalingModeResizeAspectFill,
                                   AVVideoCodecKey : AVVideoCodecH264,
                                   AVVideoWidthKey : @(videoWidth),
                                   AVVideoHeightKey: @(videoHeight)
                                   };
    [self.mediaWriter setupAudioWithSettings:nil];
    [self.mediaWriter setupVideoWithSettings:videoSetting withAdditional:@{}];
}

- (AVCaptureVideoOrientation)deviceOrientToAVVideoOrient:(HFDeviceOrientation)deviceOrient
{
    AVCaptureVideoOrientation videoOrientation = AVCaptureVideoOrientationPortrait;
    switch (deviceOrient) {
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
    return videoOrientation;
}

#pragma mark- AVCaptureDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if(_cameraStatus != HFCameraStatusShooting){
        return;
    }
    
    //需要对产生的sampleBuffer引用，不然会被提前释放
    CFRetain(sampleBuffer);
    BOOL isVideo = _cameraOutput == output;
    BOOL isAudio = _audioOutput == output;

    CMTime currentTimeStamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);

    //中断过，则计算时间差
    if(_isInterrupt){
        if(isVideo){
            CFRelease(sampleBuffer);
            return;
        }
        
        if(CMTIME_IS_VALID(currentTimeStamp) && CMTIME_IS_VALID(_mediaWriter.audioTimestamp)){
            if(CMTIME_IS_VALID(_timeOffset)){
                currentTimeStamp = CMTimeSubtract(currentTimeStamp, _timeOffset);
            }
            CMTime offset = CMTimeSubtract(currentTimeStamp, _mediaWriter.audioTimestamp);
            _timeOffset = CMTIME_IS_INVALID(_timeOffset) ? offset : CMTimeAdd(_timeOffset, offset);
        }

        _isInterrupt = NO;
    }

    CMSampleBufferRef resultBuffer = NULL;
    if(CMTIME_IS_VALID(_timeOffset)){
        resultBuffer = [HFWriterUtilities createOffsetSampleBufferWithSampleBuffer:sampleBuffer withTimeOffset:_timeOffset];
    }else{
        resultBuffer = sampleBuffer;
        CFRetain(resultBuffer);
    }

    if(resultBuffer && !_isInterrupt){

        if(isVideo){
            [_mediaWriter writeSampleBuffer:resultBuffer withMediaTypeVideo:YES];
        }

        if(isAudio){
            [_mediaWriter writeSampleBuffer:resultBuffer withMediaTypeVideo:NO];
        }
    }
    if(resultBuffer){
        CFRelease(resultBuffer);
    }

    CFRelease(sampleBuffer);
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
- (void)cameraBottomBarShouldCapture:(HFCameraBottomBar *)bottomBar
{
    AVCapturePhotoSettings *setting = [AVCapturePhotoSettings photoSettings];
    [self.capturePhotoOutput capturePhotoWithSettings:setting delegate:self];
}

- (void)cameraBottomBarShouldStartRecord:(HFCameraBottomBar *)bottomBar
{
    //每次开始的时候都需要先创建一个新的assetwrite
    [self _configWriter];
    _cameraStatus = HFCameraStatusShooting;
}

- (void)cameraBottomBarShouldEndRecord:(HFCameraBottomBar *)bottomBar
{
    _cameraStatus = HFCameraStatusEnd;
    
    WS(weakSelf)
    void ( ^finishHandler)(void) = ^(){
        NSURL *fileUrl = weakSelf.mediaWriter.outputURL;
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            
            [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:fileUrl];
        } completionHandler:^(BOOL success, NSError * _Nullable error1) {
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Video Saved!" message:@"Saved to the camera roll." preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                    [alertController addAction:ok];
                    [weakSelf presentViewController:alertController animated:YES completion:nil];
                });
            } else if (error1) {
                NSLog(@"error is  %@", error1);
            }
        }];
    };
    
    [_mediaWriter finishWritingWithCompletionHandler:finishHandler];
}

- (void)cameraBottomBarShouldPauseRecord:(HFCameraBottomBar *)bottomBar
{
    _isInterrupt = YES;
    _cameraStatus = HFCameraStatusPause;
    [_bottomBar beginRecordingUI];
}

- (void)cameraBottomBarShouldResumeRecord:(HFCameraBottomBar *)bottomBar
{
    _cameraStatus = HFCameraStatusShooting;
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
        _bottomBar = [[HFCameraBottomBar alloc] initWithFrame:self.cameraSetting.bottomBarRect];
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

- (AVCaptureDeviceInput *)audioInput
{
    if(!_audioInput){
        NSError *audioError;
        AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        _audioInput = [[AVCaptureDeviceInput alloc] initWithDevice:audioDevice error:&audioError];
    }
    return _audioInput;
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

- (AVCaptureAudioDataOutput *)audioOutput
{
    if(!_audioOutput){
        _audioOutput = [[AVCaptureAudioDataOutput alloc] init];
    }
    return _audioOutput;
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

-(HFMediaWriter *)mediaWriter
{
    if(!_mediaWriter){
        NSURL *fileURL = [NSURL fileURLWithPath:[HFFileManager avaliableFilePathInCacheForDirName:@"MineVideo" fileType:@"mp4"]];
        _mediaWriter = [[HFMediaWriter alloc] initWithOutputURL:fileURL];
    }
    return _mediaWriter;
}

@end
