//
//  XZTextMenuItemView.h
//  XZKit
//
//  Created by mlibai on 2016/11/21.
//  Copyright © 2016年 mlibai. All rights reserved.
//

#import "XZTextMenuItemView.h"
#import <objc/runtime.h>

static NSString *const XZTextMenuItemViewTextColorAnimationKey = @"XZTextMenuItemViewAnimationKey.textColor";
static NSString *const XZTextMenuItemViewTextScaleAnimationKey = @"XZTextMenuItemViewAnimationKey.textScale";

static const void *const _contentLayer = &_contentLayer;
static const void *const _animationUpdateKey = &_animationUpdateKey;
static const void *const _stateColorKey = &_stateColorKey;

@interface XZTextMenuItemView ()

@end

@implementation XZTextMenuItemView

- (void)dealloc {
    CFMutableDictionaryRef dictRef = (__bridge CFMutableDictionaryRef)objc_getAssociatedObject(self, _stateColorKey);
    if (dictRef != NULL) {
        CFRelease(dictRef);
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self PD_viewDidInitialize];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CALayer *contentLayer = objc_getAssociatedObject(self, _contentLayer);
    contentLayer.frame = self.bounds;
    _contentView.frame = contentLayer.bounds;
    [_contentView layoutIfNeeded];
}

- (void)PD_viewDidInitialize {
    self.backgroundColor = [UIColor clearColor];
    
    CALayer *contentLayer = [[CALayer alloc] init];
    contentLayer.frame = self.bounds;
    contentLayer.speed = 0;
    [self.layer addSublayer:contentLayer];
    objc_setAssociatedObject(self, _contentLayer, contentLayer, OBJC_ASSOCIATION_ASSIGN);
    
    _contentView = [[UIView alloc] initWithFrame:contentLayer.bounds];
    _contentView.layer.backgroundColor = [UIColor clearColor].CGColor;
    contentLayer.mask = _contentView.layer;
    
    [self XZ_setNeedsAnimationUpdate];
    
//    UIView *containerView = [[UIView alloc] initWithFrame:self.bounds];
//    containerView.layer.backgroundColor = [UIColor clearColor].CGColor;
//    [_contentView addSubview:containerView];
//    
//    containerView.translatesAutoresizingMaskIntoConstraints = NO;
//    {
//        NSLayoutConstraint *const1 = [NSLayoutConstraint constraintWithItem:containerView attribute:(NSLayoutAttributeCenterX) relatedBy:(NSLayoutRelationEqual) toItem:_contentView attribute:(NSLayoutAttributeCenterX) multiplier:1.0 constant:0];
//        NSLayoutConstraint *const2 = [NSLayoutConstraint constraintWithItem:containerView attribute:(NSLayoutAttributeCenterY) relatedBy:(NSLayoutRelationEqual) toItem:_contentView attribute:(NSLayoutAttributeCenterY) multiplier:1.0 constant:0];
//        [_contentView addConstraint:const1];
//        [_contentView addConstraint:const2];
//    }
    
//    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
//    _titleLabel.backgroundColor = [UIColor clearColor];
//    _titleLabel.textColor = [UIColor redColor];
//    _titleLabel.font = [UIFont systemFontOfSize:18.0];
//    [containerView addSubview:_titleLabel];
//    
//    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
//    {
//        NSArray *consts1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_titleLabel]" options:(NSLayoutFormatAlignAllLeft) metrics:nil views:NSDictionaryOfVariableBindings(_titleLabel)];
//        NSArray *consts2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_titleLabel]|" options:(NSLayoutFormatAlignAllLeft) metrics:nil views:NSDictionaryOfVariableBindings(_titleLabel)];
//        [containerView addConstraints:consts1];
//        [containerView addConstraints:consts2];
//    }
//    
//    _seperatorView = [[UIView alloc] init];
//    _seperatorView.backgroundColor = [UIColor whiteColor];
//    [containerView addSubview:_seperatorView];
//    
//    _seperatorView.translatesAutoresizingMaskIntoConstraints = NO;
//    {
//        NSArray *consts1 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_seperatorView]|" options:(NSLayoutFormatAlignAllLeft) metrics:nil views:NSDictionaryOfVariableBindings(_seperatorView)];
//        NSArray *consts2 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[_titleLabel]-3-[_seperatorView(==0.5)]" options:(NSLayoutFormatDirectionLeadingToTrailing) metrics:nil views:NSDictionaryOfVariableBindings(_titleLabel, _seperatorView)];
//        [containerView addConstraints:consts1];
//        [containerView addConstraints:consts2];
//    }
//    
//    _subtitleLabel = [[UILabel alloc] init];
//    _subtitleLabel.backgroundColor = [UIColor clearColor];
//    _subtitleLabel.textColor = [UIColor whiteColor];
//    _subtitleLabel.adjustsFontSizeToFitWidth = YES;
//    _subtitleLabel.numberOfLines = 0;
//    [_subtitleLabel setContentCompressionResistancePriority:(UILayoutPriorityDefaultLow) forAxis:(UILayoutConstraintAxisVertical)];
//    _subtitleLabel.font = [UIFont systemFontOfSize:9.0];
//    [containerView addSubview:_subtitleLabel];
//    
//    _subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
//    {
//        NSLayoutConstraint *const1 = [NSLayoutConstraint constraintWithItem:_subtitleLabel attribute:(NSLayoutAttributeHeight) relatedBy:(NSLayoutRelationEqual) toItem:_titleLabel attribute:(NSLayoutAttributeHeight) multiplier:1.0 constant:0];
//        NSLayoutConstraint *const2 = [NSLayoutConstraint constraintWithItem:_subtitleLabel attribute:(NSLayoutAttributeCenterY) relatedBy:(NSLayoutRelationEqual) toItem:_titleLabel attribute:(NSLayoutAttributeCenterY) multiplier:1.0 constant:0];
//        [containerView addConstraint:const1];
//        [containerView addConstraint:const2];
//        
//        NSArray *consts2 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[_seperatorView]-3-[_subtitleLabel(<=12)]|" options:(NSLayoutFormatDirectionLeadingToTrailing) metrics:nil views:NSDictionaryOfVariableBindings(_seperatorView, _subtitleLabel)];
//        [containerView addConstraints:consts2];
//    }
}

- (void)setTextColor:(UIColor *)titleColor forState:(UIControlState)state {
    CFMutableDictionaryRef dictRef = (__bridge CFMutableDictionaryRef)objc_getAssociatedObject(self, _stateColorKey);
    if (dictRef == nil) {
        dictRef = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        objc_setAssociatedObject(self, _stateColorKey, (__bridge id)(dictRef), OBJC_ASSOCIATION_ASSIGN);
    }
    CFDictionarySetValue(dictRef, (__bridge const void *)(@(state)), (__bridge const void *)(titleColor));
}

- (UIColor *)textColorForState:(UIControlState)state {
    CFMutableDictionaryRef dictRef = (__bridge CFMutableDictionaryRef)objc_getAssociatedObject(self, _stateColorKey);
    if (dictRef != NULL) {
        return CFDictionaryGetValue((__bridge CFMutableDictionaryRef)objc_getAssociatedObject(self, _stateColorKey), (__bridge const void *)(@(state)));
    }
    return nil;
}


- (void)setTransition:(CGFloat)transition {
    if (_transition != transition) {
        _transition = transition;
        ((CALayer *)objc_getAssociatedObject(self, _contentLayer)).timeOffset = _transition;
    }
}

- (UILabel *)textLabel {
    if (_textLabel != nil) {
        return _textLabel;
    }
    _textLabel = [[UILabel alloc] initWithFrame:_contentView.bounds];
    _textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _textLabel.textAlignment = NSTextAlignmentCenter;
    [_contentView addSubview:_textLabel];
    return _textLabel;
}

- (void)setTransitionType:(XZTextMenuItemViewTransitionType)transitionType {
    if (_transitionType != transitionType) {
        _transitionType = transitionType;
        [self XZ_setNeedsAnimationUpdate];
    }
}

- (void)XZ_setNeedsAnimationUpdate {
    if (objc_getAssociatedObject(self, _animationUpdateKey) == nil) {
        objc_setAssociatedObject(self, _animationUpdateKey, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        typeof(self) __weak weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf XZ_updateAnimationIfNeed];
        });
    }
}

- (void)XZ_updateAnimationIfNeed {
    if (objc_getAssociatedObject(self, _animationUpdateKey) != nil) {
        objc_setAssociatedObject(self, _animationUpdateKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        CALayer *contentLayer = objc_getAssociatedObject(self, _contentLayer);
        
        [contentLayer removeAnimationForKey:XZTextMenuItemViewTextColorAnimationKey];
        if ((_transitionType & XZTextMenuItemViewTransitionTypeTextColor) == XZTextMenuItemViewTransitionTypeTextColor) {
            CABasicAnimation *backgroundcolorAnimation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
            UIColor *normalColor = ([self textColorForState:(UIControlStateNormal)] ?: [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0]);
            contentLayer.backgroundColor = normalColor.CGColor;
            backgroundcolorAnimation.fromValue         = (__bridge id _Nullable)(normalColor.CGColor);
            UIColor *selectedColor = ([self textColorForState:(UIControlStateNormal)] ?: [UIColor colorWithRed:0.8 green:0.2 blue:0.2 alpha:1.0]);
            backgroundcolorAnimation.toValue           = (__bridge id _Nullable)(selectedColor.CGColor);
            backgroundcolorAnimation.duration          = 1.0;
            backgroundcolorAnimation.autoreverses      = NO;
            [contentLayer addAnimation:backgroundcolorAnimation forKey:XZTextMenuItemViewTextColorAnimationKey];
        }
        
        [contentLayer removeAnimationForKey:XZTextMenuItemViewTextScaleAnimationKey];
        if ((_transitionType & XZTextMenuItemViewTransitionTypeTextScale) == XZTextMenuItemViewTransitionTypeTextScale) {
            CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
            transformAnimation.fromValue    = [NSValue valueWithCATransform3D:CATransform3DMakeAffineTransform(CGAffineTransformIdentity)];
            transformAnimation.toValue      = [NSValue valueWithCATransform3D:CATransform3DMakeAffineTransform(CGAffineTransformMakeScale(1.20, 1.20))];
            transformAnimation.duration     = 1.0;
            transformAnimation.autoreverses = NO;
            [contentLayer addAnimation:transformAnimation forKey:XZTextMenuItemViewTextScaleAnimationKey];
        }
    }
}

@end
