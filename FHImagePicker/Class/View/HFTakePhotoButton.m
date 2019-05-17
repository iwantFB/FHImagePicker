//
//  HFTakePhotoButton.m
//  FHImagePicker
//
//  Created by 胡斐 on 2019/5/17.
//  Copyright © 2019 jackson. All rights reserved.
//

#import "HFTakePhotoButton.h"

@interface HFTakePhotoButton()

/// inside white layer
@property (nonatomic, strong) CALayer *insideLayer;

/// outside opcity layer
@property (nonatomic, strong) CALayer *outsideLayer;

@property (nonatomic, assign) CGPoint startPoint;

@property (nonatomic, strong) dispatch_block_t afterBlock;

@end

@implementation HFTakePhotoButton
{
    ///放大的倍数，适配iPhoneX
    CGFloat _kitemScale;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]){
        [self configData];
        [self _setupUI];
    }
    return self;
}

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    [super layoutSublayersOfLayer:layer];
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat layerWidth = 60*_kitemScale;
    CGFloat x = (width - layerWidth)/2.0;
    _outsideLayer.frame = CGRectMake(x, x, layerWidth, layerWidth);
    
    layerWidth = 42*_kitemScale;
    x = (width - layerWidth)/2.0;
    _insideLayer.frame = CGRectMake(x, x, layerWidth, layerWidth);
}

#pragma mark- private method
- (void)_setupUI
{
    [self.layer addSublayer:self.insideLayer];
    [self.layer addSublayer:self.outsideLayer];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tapGestureAction:)];
    UILongPressGestureRecognizer *longGest = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_longPressAction:)];
    longGest.minimumPressDuration = 0.25;
    [self addGestureRecognizer:tap];
    [self addGestureRecognizer:longGest];
}

- (void)configData
{
    _kitemScale = iPHONE_X ? 1.2 : 1.0;
}

- (void)_tapGestureAction:(UITapGestureRecognizer *)sender
{
    [self photoAnimation];
    switch (sender.state) {
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateEnded:{
            [self endAnimation];
            if(_delegate && [_delegate respondsToSelector:@selector(photoButtonTakePhoto:)]){
                [_delegate photoButtonTakePhoto:self];
            }
            
        }
        default:
            break;
    }
}

- (void)_longPressAction:(UILongPressGestureRecognizer *)sender
{
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
        {
            [self startAnimation];
            [self videoAnimation];
            if(_delegate && [_delegate respondsToSelector:@selector(photoButtonStartRecording:)]){
                [_delegate photoButtonStartRecording:self];
            }
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateEnded:{
            [self endAnimation];
            if(_delegate && [_delegate respondsToSelector:@selector(photoButtonEndRecording:)]){
                [_delegate photoButtonEndRecording:self];
            }
            
        }
        default:
            break;
    }
}

#pragma mark- private method
- (void)startAnimation
{
    if(_disableAnimation)return;
    CABasicAnimation *zoomAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    zoomAnimation.toValue = @0.8;
    zoomAnimation.duration = 0.1;
    zoomAnimation.fillMode = kCAFillModeForwards;
    zoomAnimation.removedOnCompletion = NO;
    [_insideLayer addAnimation:zoomAnimation forKey:@""];
}

/// 在录制视频的时候需要呼吸动画
- (void)videoAnimation
{
    if(_disableAnimation)return;
    CABasicAnimation *zoomUpAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    zoomUpAnimation.toValue = @1.6;
    zoomUpAnimation.duration = 0.8;
    zoomUpAnimation.fillMode = kCAFillModeForwards;
    zoomUpAnimation.removedOnCompletion = NO;
    [_outsideLayer addAnimation:zoomUpAnimation forKey:@""];
    
    WS(weakSelf)
    self.afterBlock = dispatch_block_create(0, ^{
        CABasicAnimation *zoomDownAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        zoomDownAnimation.toValue = @1.2;
        zoomDownAnimation.duration = 0.8;
        zoomDownAnimation.fillMode = kCAFillModeForwards;
        zoomDownAnimation.removedOnCompletion = NO;
        zoomDownAnimation.autoreverses = YES;
        zoomDownAnimation.repeatCount = CGFLOAT_MAX;
        [weakSelf.outsideLayer addAnimation:zoomDownAnimation forKey:@""];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(),self.afterBlock);
}

- (void)endAnimation
{
    if(_afterBlock){
        dispatch_cancel(_afterBlock);
        _afterBlock = nil;
    }
    
    CGFloat duration = 0.15;
    
    CABasicAnimation *identifyAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    identifyAnimation.toValue = @1;
    identifyAnimation.duration = duration;
    identifyAnimation.fillMode = kCAFillModeForwards;
    identifyAnimation.removedOnCompletion = NO;
    [_insideLayer addAnimation:identifyAnimation forKey:@""];
    
    CABasicAnimation *outidentifyAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    outidentifyAnimation.toValue = @1;
    outidentifyAnimation.duration = duration;
    outidentifyAnimation.fillMode = kCAFillModeForwards;
    outidentifyAnimation.removedOnCompletion = NO;
    [_outsideLayer addAnimation:outidentifyAnimation forKey:@""];
}

- (void)photoAnimation
{
    CABasicAnimation *zoomAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    zoomAnimation.toValue = @0.6;
    zoomAnimation.duration = 0.1;
    //    zoomAnimation.fillMode = kCAFillModeForwards;
    //    zoomAnimation.removedOnCompletion = NO;
    [_insideLayer addAnimation:zoomAnimation forKey:@""];
}

#pragma mark- setter/getter
-(CALayer *)insideLayer
{
    if(!_insideLayer){
        _insideLayer = [CALayer layer];
        _insideLayer.backgroundColor = [UIColor whiteColor].CGColor;
        _insideLayer.cornerRadius = 21.0*_kitemScale;
        _insideLayer.masksToBounds = YES;
    }
    return _insideLayer;
}

- (CALayer *)outsideLayer
{
    if(!_outsideLayer){
        _outsideLayer = [CALayer layer];
        _outsideLayer.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3].CGColor;
        _outsideLayer.cornerRadius = 30.0*_kitemScale;
        _outsideLayer.masksToBounds = YES;
    }
    return _outsideLayer;
}


@end
