//
//  XZTextMenuItemView.h
//  XZKit
//
//  Created by mlibai on 2016/11/21.
//  Copyright © 2016年 mlibai. All rights reserved.
//

#import "XZTextMenuItemView.h"


static NSString *const XZTextMenuItemViewTextColorAnimationKey = @"XZTextMenuItemViewAnimationKey.Color";
static NSString *const XZTextMenuItemViewTextScaleAnimationKey = @"XZTextMenuItemViewAnimationKey.Scale";

static CALayer *XZTextMenuItemViewContentLayer(XZTextMenuItemView * _Nonnull view, BOOL lazyLoad);
static CFMutableDictionaryRef XZTextMenuItemViewStateColors(XZTextMenuItemView * _Nonnull view, BOOL lazyLoad);

/** 查询 XZTextMenuItemView 当前是否需要更新动画效果，并同时设置新值。 */
static BOOL XZTextMenuItemViewNeedsUpdateAnimation(XZTextMenuItemView * _Nonnull view, BOOL setNeeds);




@interface _XZTextMenuItemViewLabel : UILabel

@end

@interface XZTextMenuItemView ()

@end

@implementation XZTextMenuItemView

- (void)dealloc {
    CFMutableDictionaryRef dictRef = XZTextMenuItemViewStateColors(self, NO);
    if (dictRef != NULL) {
        CFRelease(dictRef);
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame transitionOptions:(XZTextMenuItemViewTransitionOptionNone)];
}

- (instancetype)initWithFrame:(CGRect)frame transitionOptions:(XZTextMenuItemViewTransitionOptions)transitionOptions {
    self = [super initWithFrame:frame];
    if (self) {
        [self XZ_viewDidInitializeWithTransitionOptions:transitionOptions];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self XZ_viewDidInitializeWithTransitionOptions:(XZTextMenuItemViewTransitionOptionNone)];
    }
    return self;
}

- (void)XZ_viewDidInitializeWithTransitionOptions:(XZTextMenuItemViewTransitionOptions)transitionOptions {
    self.backgroundColor = [UIColor clearColor];
    
    [CATransaction setDisableActions:YES];
    CALayer *contentLayer = XZTextMenuItemViewContentLayer(self, YES);
    contentLayer.frame = self.bounds;
    contentLayer.speed = 0;
    [self.layer addSublayer:contentLayer];
    
    
    _animationView = [[UIView alloc] initWithFrame:contentLayer.bounds];
    _animationView.layer.backgroundColor = [UIColor clearColor].CGColor;
    contentLayer.mask = _animationView.layer;
    [CATransaction setDisableActions:NO];
    
    _transitionOptions = transitionOptions;
    //[self setNeedsTransitonAppearanceUpdate];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NSLog(@"<%p: %@>: %s", self, _textLabel.text, __func__);
    
    [CATransaction setDisableActions:YES];
    CALayer *contentLayer = XZTextMenuItemViewContentLayer(self, NO);
    contentLayer.timeOffset = 0;
    contentLayer.frame = self.bounds; // CGRectApplyAffineTransform(self.bounds, CGAffineTransformMakeScale(1 + 0.1 * _transition, 1.0 + 0.1 * _transition));
    //[contentLayer layoutIfNeeded];
    [CATransaction setDisableActions:NO];
    _animationView.frame = contentLayer.bounds;
    [self setNeedsTransitonAppearanceUpdate];
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    
    XZTextMenuItemViewContentLayer(self, NO).timeOffset = _transition;
}

- (void)setTextColor:(UIColor *)titleColor forState:(UIControlState)state {
    CFDictionarySetValue(XZTextMenuItemViewStateColors(self, YES), (__bridge const void *)(@(state)), (__bridge const void *)(titleColor));
    [self setNeedsTransitonAppearanceUpdate];
}

- (UIColor *)textColorForState:(UIControlState)state {
    CFMutableDictionaryRef dictRef = XZTextMenuItemViewStateColors(self, NO);
    if (dictRef != NULL) {
        return CFDictionaryGetValue(dictRef, (__bridge const void *)(@(state)));
    }
    return nil;
}


- (void)setTransition:(CGFloat)transition {
    if (_transition != transition) {
        _transition = transition;
        NSLog(@"<%p: %@>: (%f)[%f -> %f]", self, _textLabel.text, XZTextMenuItemViewContentLayer(self, NO).beginTime, XZTextMenuItemViewContentLayer(self, NO).timeOffset, _transition);
        if (self.window != nil) {
            XZTextMenuItemViewContentLayer(self, NO).timeOffset = _transition;
        }
    }
}

- (UILabel *)textLabel {
    if (_textLabel != nil) {
        return _textLabel;
    }
    _textLabel = [[_XZTextMenuItemViewLabel alloc] initWithFrame:_animationView.bounds];
    _textLabel.textColor = [UIColor whiteColor];
    _textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _textLabel.textAlignment = NSTextAlignmentCenter;
    //_textLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    //_textLabel.layer.borderWidth = 1.0;
    [_animationView addSubview:_textLabel];
    return _textLabel;
}

- (void)setTransitionOptions:(XZTextMenuItemViewTransitionOptions)transitionOptions {
    if (_transitionOptions != transitionOptions) {
        _transitionOptions = transitionOptions;
        [self setNeedsTransitonAppearanceUpdate];
    }
}

#pragma mark - Private Methods

- (void)setNeedsTransitonAppearanceUpdate {
    if (!XZTextMenuItemViewNeedsUpdateAnimation(self, YES)) {
        typeof(self) __weak weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf updateTransitonAppearanceIfNeeded];
        });
    }
}

- (void)updateTransitonAppearanceIfNeeded {
    if (XZTextMenuItemViewNeedsUpdateAnimation(self, NO)) {
        [CATransaction setDisableActions:YES];
        NSLog(@"<%p: %@>: %s", self, _textLabel.text, __func__);
        CALayer *contentLayer = XZTextMenuItemViewContentLayer(self, NO);
        contentLayer.timeOffset = 0;
        
        UIColor *normalColor = [self textColorForState:(UIControlStateNormal)];
        if (normalColor == nil) {
            normalColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
        }
        
        contentLayer.backgroundColor = normalColor.CGColor;
        
        
        [contentLayer removeAnimationForKey:XZTextMenuItemViewTextColorAnimationKey];
        if ((_transitionOptions & XZTextMenuItemViewTransitionOptionColor) == XZTextMenuItemViewTransitionOptionColor) {
            CABasicAnimation *backgroundcolorAnimation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
            backgroundcolorAnimation.fromValue         = (__bridge id _Nullable)(normalColor.CGColor);
            
            UIColor *selectedColor = [self textColorForState:(UIControlStateSelected)];
            if (selectedColor == nil) {
                selectedColor = [UIColor colorWithRed:0.8 green:0.2 blue:0.2 alpha:1.0];
            }
            
            backgroundcolorAnimation.toValue           = (__bridge id _Nullable)(selectedColor.CGColor);
            backgroundcolorAnimation.duration          = 1.0;
            backgroundcolorAnimation.autoreverses      = NO;
            backgroundcolorAnimation.beginTime         = 0;
            [contentLayer addAnimation:backgroundcolorAnimation forKey:XZTextMenuItemViewTextColorAnimationKey];
        }
        
        [contentLayer removeAnimationForKey:XZTextMenuItemViewTextScaleAnimationKey];
        if ((_transitionOptions & XZTextMenuItemViewTransitionOptionScale) == XZTextMenuItemViewTransitionOptionScale) {
            CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
            transformAnimation.fromValue    = [NSValue valueWithCATransform3D:CATransform3DMakeAffineTransform(CGAffineTransformIdentity)];
            transformAnimation.toValue      = [NSValue valueWithCATransform3D:CATransform3DMakeAffineTransform(CGAffineTransformMakeScale(1.20, 1.20))];
            transformAnimation.duration     = 1.0;
            transformAnimation.autoreverses = NO;
            transformAnimation.beginTime    = 0;
            [contentLayer addAnimation:transformAnimation forKey:XZTextMenuItemViewTextScaleAnimationKey];
        }
        
        contentLayer.timeOffset = _transition;
        [CATransaction setDisableActions:NO];
    }
}

@end

@implementation _XZTextMenuItemViewLabel

@end


#import <objc/runtime.h>

static CFMutableDictionaryRef XZTextMenuItemViewStateColors(XZTextMenuItemView *view, BOOL lazyLoad) {
    static const void *const _stateColorKey = &_stateColorKey;
    CFMutableDictionaryRef dictRef = (__bridge CFMutableDictionaryRef)(objc_getAssociatedObject(view, _stateColorKey));
    if (dictRef == NULL && lazyLoad) {
        dictRef = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        objc_setAssociatedObject(view, _stateColorKey, (__bridge id)(dictRef), OBJC_ASSOCIATION_ASSIGN);
    }
    return dictRef;
}

static BOOL XZTextMenuItemViewNeedsUpdateAnimation(XZTextMenuItemView * _Nonnull view, BOOL setNeeds) {
    static const void *const _animationNeedsUpdateKey = &_animationNeedsUpdateKey;
    BOOL needs = (objc_getAssociatedObject(view, _animationNeedsUpdateKey) != nil);
    if (needs != setNeeds) {
        objc_setAssociatedObject(view, _animationNeedsUpdateKey, (setNeeds ? @(YES) : nil), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return needs;
}

static CALayer *XZTextMenuItemViewContentLayer(XZTextMenuItemView * _Nonnull view, BOOL lazyLoad) {
    static const void *const _contentLayer = &_contentLayer;
    CALayer *layer = objc_getAssociatedObject(view, _contentLayer);
    if (layer == nil && lazyLoad) {
        layer = [[CALayer alloc] init];
        objc_setAssociatedObject(view, _contentLayer, layer, OBJC_ASSOCIATION_ASSIGN);
    }
    return layer;
}

