//
//  HFCameraPreview.h
//  FHImagePicker
//
//  Created by 胡斐 on 2019/4/30.
//  Copyright © 2019 jackson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

/*
 what this set below is influence layer's property
*/

NS_ASSUME_NONNULL_BEGIN

@interface HFCameraPreview : UIView

+ (instancetype)viewWithSession:(AVCaptureSession *)session;

+ (instancetype)viewWithSessionWithNoConnection:(AVCaptureSession *)session API_AVAILABLE(ios(8.0));

@property(nonatomic, retain, nullable) AVCaptureSession *session;

- (void)setSessionWithNoConnection:(AVCaptureSession *)session API_AVAILABLE(ios(8.0));

@property(nonatomic, readonly, nullable) AVCaptureConnection *connection API_AVAILABLE(ios(6.0));

@property (nonatomic, strong, readonly)AVCaptureVideoPreviewLayer *previewLayer;
@property(copy) AVLayerVideoGravity videoGravity;

- (CGPoint)captureDevicePointOfInterestForPoint:(CGPoint)pointInLayer API_AVAILABLE(ios(6.0)) API_UNAVAILABLE(macos);

- (CGPoint)pointForCaptureDevicePointOfInterest:(CGPoint)captureDevicePointOfInterest API_AVAILABLE(ios(6.0)) API_UNAVAILABLE(macos);

- (CGRect)metadataOutputRectOfInterestForRect:(CGRect)rectInLayerCoordinates API_AVAILABLE(ios(7.0)) API_UNAVAILABLE(macos);

- (CGRect)rectForMetadataOutputRectOfInterest:(CGRect)rectInMetadataOutputCoordinates API_AVAILABLE(ios(7.0)) API_UNAVAILABLE(macos);

- (nullable AVMetadataObject *)transformedMetadataObjectForMetadataObject:(AVMetadataObject *)metadataObject API_AVAILABLE(ios(6.0)) API_UNAVAILABLE(macos);

@end

NS_ASSUME_NONNULL_END
