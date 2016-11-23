//
//  PDMenuItemView.m
//  Daily
//
//  Created by mlibai on 2016/10/20.
//  Copyright © 2016年 People's Daily Online. All rights reserved.
//

#import "PDMenuItemView.h"

static NSString *kPDMenuItemViewBackgroundColorAnimationKey = @"kPDMenuItemViewAnimationKey.backgroundColor";
static NSString *kPDMenuItemViewTransformAnimationKey = @"kPDMenuItemViewAnimationKey.transform";

@interface PDMenuItemView ()

@property (nonatomic, strong) CALayer *contentLayer;

@property (nonatomic, strong) UIView *contentMaskView;
@property (nonatomic, strong, readonly) UILabel *titleLabel;
@property (nonatomic, strong, readonly) UILabel *subtitleLabel;
@property (nonatomic, strong, readonly) UIView *seperatorView;

@property (nonatomic) BOOL needsUpdateAnimation;

@end

@implementation PDMenuItemView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self PD_viewDidInitialize];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _contentLayer.frame = self.bounds;
    _contentMaskView.frame = _contentLayer.bounds;
    [_contentMaskView layoutIfNeeded];
}

- (void)PD_setNeedsUpdateAnimation {
    if (!_needsUpdateAnimation) {
        _needsUpdateAnimation = YES;
        typeof(self) __weak weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf PD_updateAnimationIfNeed];
        });
    }
}

- (void)PD_updateAnimationIfNeed {
    if (_needsUpdateAnimation) {
        [_contentLayer removeAnimationForKey:kPDMenuItemViewBackgroundColorAnimationKey];
        CABasicAnimation *backgroundcolorAnimation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
        backgroundcolorAnimation.fromValue         = (__bridge id _Nullable)(self.normalColor.CGColor);
        backgroundcolorAnimation.toValue           = (__bridge id _Nullable)(self.selectedColor.CGColor);
        backgroundcolorAnimation.duration          = 1.0;
        backgroundcolorAnimation.autoreverses      = NO;
        [_contentLayer addAnimation:backgroundcolorAnimation forKey:kPDMenuItemViewBackgroundColorAnimationKey];
        
        CABasicAnimation *transformAnimation = (CABasicAnimation *)[_contentLayer animationForKey:kPDMenuItemViewTransformAnimationKey];
        if (transformAnimation == nil) {
            transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
            transformAnimation.fromValue    = [NSValue valueWithCATransform3D:CATransform3DMakeAffineTransform(CGAffineTransformIdentity)];
            transformAnimation.toValue      = [NSValue valueWithCATransform3D:CATransform3DMakeAffineTransform(CGAffineTransformMakeScale(1.20, 1.20))];
            transformAnimation.duration     = 1.0;
            transformAnimation.autoreverses = NO;
            [_contentLayer addAnimation:transformAnimation forKey:kPDMenuItemViewTransformAnimationKey];
        }
    }
}

- (void)PD_viewDidInitialize {
    self.backgroundColor = [UIColor clearColor];
    
    _contentLayer = [[CALayer alloc] init];
    _contentLayer.backgroundColor = [self normalColor].CGColor;
    _contentLayer.frame = self.bounds;
    [self.layer addSublayer:_contentLayer];
    
    [self PD_setNeedsUpdateAnimation];
    _contentLayer.speed = 0;

    _contentMaskView = [[UIView alloc] initWithFrame:_contentLayer.bounds];
    _contentMaskView.layer.backgroundColor = [UIColor clearColor].CGColor;
    _contentLayer.mask = _contentMaskView.layer;
    
    UIView *containerView = [[UIView alloc] initWithFrame:self.bounds];
    containerView.layer.backgroundColor = [UIColor clearColor].CGColor;
    [_contentMaskView addSubview:containerView];
    
    containerView.translatesAutoresizingMaskIntoConstraints = NO;
    {
        NSLayoutConstraint *const1 = [NSLayoutConstraint constraintWithItem:containerView attribute:(NSLayoutAttributeCenterX) relatedBy:(NSLayoutRelationEqual) toItem:_contentMaskView attribute:(NSLayoutAttributeCenterX) multiplier:1.0 constant:0];
        NSLayoutConstraint *const2 = [NSLayoutConstraint constraintWithItem:containerView attribute:(NSLayoutAttributeCenterY) relatedBy:(NSLayoutRelationEqual) toItem:_contentMaskView attribute:(NSLayoutAttributeCenterY) multiplier:1.0 constant:0];
        [_contentMaskView addConstraint:const1];
        [_contentMaskView addConstraint:const2];
    }
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = [UIColor redColor];
    _titleLabel.font = [UIFont systemFontOfSize:18.0];
    [containerView addSubview:_titleLabel];
    
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    {
        NSArray *consts1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_titleLabel]" options:(NSLayoutFormatAlignAllLeft) metrics:nil views:NSDictionaryOfVariableBindings(_titleLabel)];
        NSArray *consts2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_titleLabel]|" options:(NSLayoutFormatAlignAllLeft) metrics:nil views:NSDictionaryOfVariableBindings(_titleLabel)];
        [containerView addConstraints:consts1];
        [containerView addConstraints:consts2];
    }
    
    _seperatorView = [[UIView alloc] init];
    _seperatorView.backgroundColor = [UIColor whiteColor];
    [containerView addSubview:_seperatorView];
    
    _seperatorView.translatesAutoresizingMaskIntoConstraints = NO;
    {
        NSArray *consts1 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_seperatorView]|" options:(NSLayoutFormatAlignAllLeft) metrics:nil views:NSDictionaryOfVariableBindings(_seperatorView)];
        NSArray *consts2 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[_titleLabel]-3-[_seperatorView(==0.5)]" options:(NSLayoutFormatDirectionLeadingToTrailing) metrics:nil views:NSDictionaryOfVariableBindings(_titleLabel, _seperatorView)];
        [containerView addConstraints:consts1];
        [containerView addConstraints:consts2];
    }
    
    _subtitleLabel = [[UILabel alloc] init];
    _subtitleLabel.backgroundColor = [UIColor clearColor];
    _subtitleLabel.textColor = [UIColor whiteColor];
    _subtitleLabel.adjustsFontSizeToFitWidth = YES;
    _subtitleLabel.numberOfLines = 0;
    [_subtitleLabel setContentCompressionResistancePriority:(UILayoutPriorityDefaultLow) forAxis:(UILayoutConstraintAxisVertical)];
    _subtitleLabel.font = [UIFont systemFontOfSize:9.0];
    [containerView addSubview:_subtitleLabel];
    
    _subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    {
        NSLayoutConstraint *const1 = [NSLayoutConstraint constraintWithItem:_subtitleLabel attribute:(NSLayoutAttributeHeight) relatedBy:(NSLayoutRelationEqual) toItem:_titleLabel attribute:(NSLayoutAttributeHeight) multiplier:1.0 constant:0];
        NSLayoutConstraint *const2 = [NSLayoutConstraint constraintWithItem:_subtitleLabel attribute:(NSLayoutAttributeCenterY) relatedBy:(NSLayoutRelationEqual) toItem:_titleLabel attribute:(NSLayoutAttributeCenterY) multiplier:1.0 constant:0];
        [containerView addConstraint:const1];
        [containerView addConstraint:const2];
        
        NSArray *consts2 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[_seperatorView]-3-[_subtitleLabel(<=12)]|" options:(NSLayoutFormatDirectionLeadingToTrailing) metrics:nil views:NSDictionaryOfVariableBindings(_seperatorView, _subtitleLabel)];
        [containerView addConstraints:consts2];
    }
}

- (void)setTransition:(CGFloat)transition {
    if (_transition != transition) {
        _transition = transition;
        _contentLayer.timeOffset = _transition;
    }
}

- (void)setSelected:(BOOL)selected {
    if (_selected != selected) {
        _selected = selected;
    }
}

@synthesize normalColor = _normalColor;

- (UIColor *)normalColor {
    if (_normalColor != nil) {
        return _normalColor;
    }
    _normalColor = [UIColor blackColor];
    return _normalColor;
}

- (void)setNormalColor:(UIColor *)normalColor {
    if (_normalColor != normalColor) {
        _normalColor = normalColor;
        [self PD_setNeedsUpdateAnimation];
    }
}

@synthesize selectedColor = _selectedColor;

- (UIColor *)selectedColor {
    if (_selectedColor != nil) {
        return _selectedColor;
    }
    _selectedColor = [UIColor colorWithRed:1.0 green:0x33 / 255.0 blue:0x33 / 255.0 alpha:1.0];
    return _selectedColor;
}

- (void)setSelectedColor:(UIColor *)selectedColor {
    if (_selectedColor != selectedColor) {
        _selectedColor = selectedColor;
        [self PD_setNeedsUpdateAnimation];
    }
}

- (void)setTitleFont:(UIFont *)titleFont {
    self.titleLabel.font = titleFont;
}

- (UIFont *)titleFont {
    return self.titleLabel.font;
}

- (UIFont *)subtitleFont {
    return _subtitleLabel.font;
}

- (void)setSubtitleFont:(UIFont *)subtitleFont {
    self.subtitleLabel.font = subtitleFont;
}

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
}

- (NSString *)title {
    return self.titleLabel.text;
}

- (void)setSubtitle:(NSString *)subtitle {
    self.subtitleLabel.text = subtitle;
}

- (NSString *)subtitle {
    return self.subtitleLabel.text;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p; title = %@; subTitle = %@; isSelected = %@>", NSStringFromClass([self class]), self, self.titleLabel.text, self.subtitleLabel.text, (self.isSelected ? @"YES" : @"NO")];
}

@end
