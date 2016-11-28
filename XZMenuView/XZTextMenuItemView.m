//
//  XZTextMenuItemView.h
//  XZKit
//
//  Created by mlibai on 2016/11/21.
//  Copyright © 2016年 mlibai. All rights reserved.
//

#import "XZTextMenuItemView.h"

static NSString *const XZTextMenuItemViewAnimationKey = @"XZTextMenuItemViewAnimationKey";

static CALayer *XZTextMenuItemViewContentLayer(XZTextMenuItemView * _Nonnull view, BOOL lazyLoad);
static CFMutableDictionaryRef XZTextMenuItemViewStateColors(XZTextMenuItemView * _Nonnull view, BOOL lazyLoad);

/** 查询 XZTextMenuItemView 当前是否需要更新动画效果，并同时设置新值。 */
static BOOL XZTextMenuItemViewNeedsUpdateAnimation(XZTextMenuItemView * _Nonnull view, BOOL setNeeds);


@interface _XZTextMenuItemViewLabel : UILabel

@end

@interface XZTextMenuItemView () <CAAnimationDelegate>

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

- (instancetype)initWithTransitionOptions:(XZTextMenuItemViewTransitionOptions)transitionOptions {
    return [self initWithFrame:CGRectMake(0, 0, 44.0, 44.0) transitionOptions:transitionOptions];
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
    _transitionOptions = transitionOptions;
    
    [CATransaction setDisableActions:YES];
    CALayer *contentLayer = XZTextMenuItemViewContentLayer(self, YES);
    contentLayer.frame = self.bounds;
    [self.layer addSublayer:contentLayer];
    
    
    _animationView = [[UIView alloc] initWithFrame:contentLayer.bounds];
    _animationView.layer.backgroundColor = [UIColor clearColor].CGColor;
    contentLayer.mask = _animationView.layer;
    [CATransaction setDisableActions:NO];
    
    [self setNeedsTransitonAppearanceUpdate];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [CATransaction setDisableActions:YES];
    CALayer *contentLayer = XZTextMenuItemViewContentLayer(self, NO);
    contentLayer.frame = self.bounds;
    [CATransaction setDisableActions:NO];
    
    _animationView.frame = contentLayer.bounds;
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    
    
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
        CALayer *contentLayer = XZTextMenuItemViewContentLayer(self, NO);
        CAAnimation *animation = [contentLayer animationForKey:XZTextMenuItemViewAnimationKey];
        contentLayer.timeOffset = animation.beginTime + transition;
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
    [_animationView addSubview:_textLabel];
    return _textLabel;
}

- (void)setTransitionOptions:(XZTextMenuItemViewTransitionOptions)transitionOptions {
    if (_transitionOptions != transitionOptions) {
        _transitionOptions = transitionOptions;
        [self setNeedsTransitonAppearanceUpdate];
    }
}

#pragma mark - <CAAnimationDelegate>

- (void)animationDidStart:(CAAnimation *)anim {
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    CALayer *contentLayer = XZTextMenuItemViewContentLayer(self, NO);
    contentLayer.speed = 0;
    contentLayer.timeOffset = anim.beginTime + _transition;
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
        
        CALayer *contentLayer = XZTextMenuItemViewContentLayer(self, NO);
        contentLayer.timeOffset = 0;
        contentLayer.speed = 0;
        contentLayer.beginTime = 0;
        
        UIColor *normalColor = [self textColorForState:(UIControlStateNormal)];
        if (normalColor == nil) {
            normalColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
        }
        
        contentLayer.backgroundColor = normalColor.CGColor;
        
        NSMutableArray<CAAnimation *> *animations = nil;
        
        [contentLayer removeAnimationForKey:XZTextMenuItemViewAnimationKey];
        
        if ((_transitionOptions & XZTextMenuItemViewTransitionOptionColor) == XZTextMenuItemViewTransitionOptionColor) {
            CABasicAnimation *backgroundcolorAnimation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
            backgroundcolorAnimation.fromValue         = (__bridge id _Nullable)(normalColor.CGColor);
            
            UIColor *selectedColor = [self textColorForState:(UIControlStateSelected)];
            if (selectedColor == nil) {
                selectedColor = [UIColor colorWithRed:0.8 green:0.2 blue:0.2 alpha:1.0];
            }
            backgroundcolorAnimation.toValue = (__bridge id _Nullable)(selectedColor.CGColor);
            
            animations = [[NSMutableArray alloc] init];
            [animations addObject:backgroundcolorAnimation];
        }
        
        if ((_transitionOptions & XZTextMenuItemViewTransitionOptionScale) == XZTextMenuItemViewTransitionOptionScale) {
            CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
            transformAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeAffineTransform(CGAffineTransformIdentity)];
            transformAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeAffineTransform(CGAffineTransformMakeScale(1.10, 1.10))];
            
            if (animations == nil) {
                animations = [[NSMutableArray alloc] init];
            }
            [animations addObject:transformAnimation];
        }
        
        if (animations != nil) {
            CAAnimationGroup *groupAnimation = [CAAnimationGroup animation];
            groupAnimation.animations          = animations;
            groupAnimation.duration            = 1.0;
            groupAnimation.autoreverses        = NO;
            groupAnimation.beginTime           = 0;
            groupAnimation.timeOffset          = 0;
            groupAnimation.removedOnCompletion = NO;
            groupAnimation.fillMode            = kCAFillModeBoth;
            groupAnimation.delegate            = self;
            [contentLayer addAnimation:groupAnimation forKey:XZTextMenuItemViewAnimationKey];
        }
        
        [CATransaction setDisableActions:NO];
        
        // 如果 transiton
        if (_transition > 0) {
            contentLayer.speed = 100.0f;
        }
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%p: %@, %f>", self, _textLabel.text, _transition];
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

