//
//  XZPlainMenuItemView.h
//  XZKit
//
//  Created by mlibai on 2016/11/21.
//  Copyright © 2016年 mlibai. All rights reserved.
//

#import "XZPlainMenuItemView.h"

static NSString *const XZPlainMenuItemViewAnimationKey = @"XZPlainMenuItemViewAnimationKey";

static CALayer *XZPlainMenuItemViewContentLayer(XZPlainMenuItemView * _Nonnull view, BOOL lazyLoad);
static CFMutableDictionaryRef XZPlainMenuItemViewStateColors(XZPlainMenuItemView * _Nonnull view, BOOL lazyLoad);

/** 查询 XZPlainMenuItemView 当前是否需要更新动画效果，并同时设置新值。 */
static BOOL XZPlainMenuItemViewNeedsUpdateAnimation(XZPlainMenuItemView * _Nonnull view, BOOL setNeeds);




@interface XZPlainMenuItemView () <CAAnimationDelegate>

@end

@implementation XZPlainMenuItemView

- (void)dealloc {
    CFMutableDictionaryRef dictRef = XZPlainMenuItemViewStateColors(self, NO);
    if (dictRef != NULL) {
        CFRelease(dictRef);
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame transitionOptions:(XZPlainMenuItemViewTransitionOptionNone)];
}

- (instancetype)initWithFrame:(CGRect)frame transitionOptions:(XZPlainMenuItemViewTransitionOptions)transitionOptions {
    self = [super initWithFrame:frame];
    if (self) {
        [self XZ_viewDidInitializeWithTransitionOptions:transitionOptions];
    }
    return self;
}

- (instancetype)initWithTransitionOptions:(XZPlainMenuItemViewTransitionOptions)transitionOptions {
    return [self initWithFrame:CGRectMake(0, 0, 44.0, 44.0) transitionOptions:transitionOptions];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self XZ_viewDidInitializeWithTransitionOptions:(XZPlainMenuItemViewTransitionOptionNone)];
    }
    return self;
}

- (void)XZ_viewDidInitializeWithTransitionOptions:(XZPlainMenuItemViewTransitionOptions)transitionOptions {
    self.backgroundColor = [UIColor clearColor];
    _transitionOptions = transitionOptions;
    
    [CATransaction setDisableActions:YES];
    CALayer *contentLayer = XZPlainMenuItemViewContentLayer(self, YES);
    contentLayer.frame = self.bounds;
    [self.layer addSublayer:contentLayer];
    
    
    _contentView = [[UIView alloc] initWithFrame:contentLayer.bounds];
    _contentView.layer.backgroundColor = [UIColor clearColor].CGColor;
    contentLayer.mask = _contentView.layer;
    [CATransaction setDisableActions:NO];
    
    [self setNeedsTransitonAppearanceUpdate];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [CATransaction setDisableActions:YES];
    CALayer *contentLayer = XZPlainMenuItemViewContentLayer(self, NO);
    contentLayer.frame = self.bounds;
    [CATransaction setDisableActions:NO];
    
    _contentView.frame = contentLayer.bounds;
    [_contentView layoutIfNeeded];
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
}

- (void)setTextColor:(UIColor *)textColor forState:(UIControlState)state {
    CFDictionarySetValue(XZPlainMenuItemViewStateColors(self, YES), (__bridge const void *)(@(state)), (__bridge const void *)(textColor));
    [self setNeedsTransitonAppearanceUpdate];
}

- (UIColor *)textColorForState:(UIControlState)state {
    CFMutableDictionaryRef dictRef = XZPlainMenuItemViewStateColors(self, NO);
    if (dictRef != NULL) {
        return CFDictionaryGetValue(dictRef, (__bridge const void *)(@(state)));
    }
    return nil;
}

- (void)setSelected:(BOOL)selected {
    if (_selected != selected) {
        _selected = selected;
        if (_selected) {
            self.transition = 1.0;
        } else {
            self.transition = 0;
        }
    }
}

- (void)setTransition:(CGFloat)transition {
    if (_transition != transition) {
        _transition = transition;
        CALayer *contentLayer = XZPlainMenuItemViewContentLayer(self, NO);
        CAAnimation *animation = [contentLayer animationForKey:XZPlainMenuItemViewAnimationKey];
        contentLayer.timeOffset = animation.beginTime + transition;
    }
}

- (UILabel *)textLabel {
    if (_textLabel != nil) {
        return _textLabel;
    }
    _textLabel = [[UILabel alloc] initWithFrame:_contentView.bounds];
    _textLabel.textColor = [UIColor whiteColor];
    _textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _textLabel.textAlignment = NSTextAlignmentCenter;
    [_contentView addSubview:_textLabel];
    return _textLabel;
}

- (void)setTransitionOptions:(XZPlainMenuItemViewTransitionOptions)transitionOptions {
    if (_transitionOptions != transitionOptions) {
        _transitionOptions = transitionOptions;
        [self setNeedsTransitonAppearanceUpdate];
    }
}

@synthesize scaleAspect = _scaleAspect;

- (CGSize)scaleAspect {
    if (_scaleAspect.height > 0 && _scaleAspect.width > 0) {
        return _scaleAspect;
    }
    _scaleAspect = CGSizeMake(1.10, 1.10);
    return _scaleAspect;
}

- (void)setScaleAspect:(CGSize)scaleAspect {
    if (CGSizeEqualToSize(_scaleAspect, scaleAspect)) {
        _scaleAspect = scaleAspect;
        [self setNeedsTransitonAppearanceUpdate];
    }
}

#pragma mark - <CAAnimationDelegate>

- (void)animationDidStart:(CAAnimation *)anim {
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    CALayer *contentLayer = XZPlainMenuItemViewContentLayer(self, NO);
    contentLayer.speed = 0;
    contentLayer.timeOffset = anim.beginTime + _transition;
}

#pragma mark - Private Methods

- (void)setNeedsTransitonAppearanceUpdate {
    if (!XZPlainMenuItemViewNeedsUpdateAnimation(self, YES)) {
        typeof(self) __weak weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf updateTransitonAppearanceIfNeeded];
        });
    }
}

- (void)updateTransitonAppearanceIfNeeded {
    if (XZPlainMenuItemViewNeedsUpdateAnimation(self, NO)) {
        [CATransaction setDisableActions:YES];
        
        CALayer *contentLayer = XZPlainMenuItemViewContentLayer(self, NO);
        contentLayer.timeOffset = 0;
        contentLayer.speed = 0;
        contentLayer.beginTime = 0;
        
        UIColor *normalColor = [self textColorForState:(UIControlStateNormal)];
        if (normalColor == nil) {
            normalColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
        }
        
        contentLayer.backgroundColor = normalColor.CGColor;
        
        NSMutableArray<CAAnimation *> *animations = nil;
        
        [contentLayer removeAnimationForKey:XZPlainMenuItemViewAnimationKey];
        
        if ((_transitionOptions & XZPlainMenuItemViewTransitionOptionColor) == XZPlainMenuItemViewTransitionOptionColor) {
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
        
        if ((_transitionOptions & XZPlainMenuItemViewTransitionOptionScale) == XZPlainMenuItemViewTransitionOptionScale) {
            CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
            transformAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeAffineTransform(CGAffineTransformIdentity)];
            transformAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeAffineTransform(CGAffineTransformMakeScale([self scaleAspect].width, [self scaleAspect].height))];
            
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
            [contentLayer addAnimation:groupAnimation forKey:XZPlainMenuItemViewAnimationKey];
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


#import <objc/runtime.h>

static CFMutableDictionaryRef XZPlainMenuItemViewStateColors(XZPlainMenuItemView *view, BOOL lazyLoad) {
    static const void *const _stateColorKey = &_stateColorKey;
    CFMutableDictionaryRef dictRef = (__bridge CFMutableDictionaryRef)(objc_getAssociatedObject(view, _stateColorKey));
    if (dictRef == NULL && lazyLoad) {
        dictRef = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        objc_setAssociatedObject(view, _stateColorKey, (__bridge id)(dictRef), OBJC_ASSOCIATION_ASSIGN);
    }
    return dictRef;
}

static BOOL XZPlainMenuItemViewNeedsUpdateAnimation(XZPlainMenuItemView * _Nonnull view, BOOL setNeeds) {
    static const void *const _animationNeedsUpdateKey = &_animationNeedsUpdateKey;
    BOOL needs = (objc_getAssociatedObject(view, _animationNeedsUpdateKey) != nil);
    if (needs != setNeeds) {
        objc_setAssociatedObject(view, _animationNeedsUpdateKey, (setNeeds ? @(YES) : nil), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return needs;
}

static CALayer *XZPlainMenuItemViewContentLayer(XZPlainMenuItemView * _Nonnull view, BOOL lazyLoad) {
    static const void *const _contentLayer = &_contentLayer;
    CALayer *layer = objc_getAssociatedObject(view, _contentLayer);
    if (layer == nil && lazyLoad) {
        layer = [[CALayer alloc] init];
        objc_setAssociatedObject(view, _contentLayer, layer, OBJC_ASSOCIATION_ASSIGN);
    }
    return layer;
}

