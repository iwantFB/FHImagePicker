//
//  HFCameraPreview.m
//  FHImagePicker
//
//  Created by 胡斐 on 2019/4/30.
//  Copyright © 2019 jackson. All rights reserved.
//

#import "HFCameraPreview.h"

@implementation HFCameraPreview

+ (Class)layerClass
{
    return AVCaptureVideoPreviewLayer.class;
}

+ (instancetype)viewWithSession:(AVCaptureSession *)session{
    HFCameraPreview *preview = [[HFCameraPreview alloc] init];
    preview.previewLayer.session = session;
    return preview;
}

+ (instancetype)viewWithSessionWithNoConnection:(AVCaptureSession *)session API_AVAILABLE(ios(8.0)){
    HFCameraPreview *preview = [[HFCameraPreview alloc] init];
    [preview.previewLayer setSessionWithNoConnection:session];
    return preview;
}

- (void)setSessionWithNoConnection:(AVCaptureSession *)session API_AVAILABLE(ios(8.0)){
    [self.previewLayer setSessionWithNoConnection:session];
}

- (CGPoint)captureDevicePointOfInterestForPoint:(CGPoint)pointInLayer API_AVAILABLE(ios(6.0)) API_UNAVAILABLE(macos){
    return [self.previewLayer captureDevicePointOfInterestForPoint:pointInLayer];
}

- (CGPoint)pointForCaptureDevicePointOfInterest:(CGPoint)captureDevicePointOfInterest API_AVAILABLE(ios(6.0)) API_UNAVAILABLE(macos){
    return [self.previewLayer pointForCaptureDevicePointOfInterest:captureDevicePointOfInterest];
}

- (CGRect)metadataOutputRectOfInterestForRect:(CGRect)rectInLayerCoordinates API_AVAILABLE(ios(7.0)) API_UNAVAILABLE(macos){
    return [self.previewLayer metadataOutputRectOfInterestForRect:rectInLayerCoordinates];
}

- (CGRect)rectForMetadataOutputRectOfInterest:(CGRect)rectInMetadataOutputCoordinates API_AVAILABLE(ios(7.0)) API_UNAVAILABLE(macos){
    return [self.previewLayer rectForMetadataOutputRectOfInterest:rectInMetadataOutputCoordinates];
}

- (nullable AVMetadataObject *)transformedMetadataObjectForMetadataObject:(AVMetadataObject *)metadataObject API_AVAILABLE(ios(6.0)) API_UNAVAILABLE(macos){
    return [self.previewLayer transformedMetadataObjectForMetadataObject:metadataObject];
}

#pragma mark- setter/getter
- (AVCaptureSession *)session
{
    return self.previewLayer.session;
}

- (void)setSession:(AVCaptureSession *)session
{
    self.previewLayer.session = session;
}

- (AVCaptureConnection *)connection
{
    return self.previewLayer.connection;
}

- (void)setVideoGravity:(AVLayerVideoGravity)videoGravity
{
    self.previewLayer.videoGravity = videoGravity;
}

- (AVLayerVideoGravity)videoGravity
{
    return self.previewLayer.videoGravity;
}

- (AVCaptureVideoPreviewLayer *)previewLayer
{
    return (AVCaptureVideoPreviewLayer *)self.layer;
}

@end
