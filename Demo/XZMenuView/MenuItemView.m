//
//  MenuItemView.m
//  XZMenuView
//
//  Created by mlibai on 2016/11/23.
//  Copyright © 2016年 mlibai. All rights reserved.
//

#import "MenuItemView.h"

@interface MenuItemView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UIView *seperatorView;

@end

@implementation MenuItemView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIView *containerView = [[UIView alloc] initWithFrame:self.bounds];
        containerView.layer.backgroundColor = [UIColor clearColor].CGColor;
        [self.animationView addSubview:containerView];
        
        containerView.translatesAutoresizingMaskIntoConstraints = NO;
        {
            NSLayoutConstraint *const1 = [NSLayoutConstraint constraintWithItem:containerView attribute:(NSLayoutAttributeCenterX) relatedBy:(NSLayoutRelationEqual) toItem:self.animationView attribute:(NSLayoutAttributeCenterX) multiplier:1.0 constant:0];
            NSLayoutConstraint *const2 = [NSLayoutConstraint constraintWithItem:containerView attribute:(NSLayoutAttributeCenterY) relatedBy:(NSLayoutRelationEqual) toItem:self.animationView attribute:(NSLayoutAttributeCenterY) multiplier:1.0 constant:0];
            [self.animationView addConstraint:const1];
            [self.animationView addConstraint:const2];
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
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
}

- (NSString *)title {
    return _titleLabel.text;
}

- (void)setSubtitle:(NSString *)subtitle {
    self.subtitleLabel.text = subtitle;
}

- (NSString *)subtitle {
    return _subtitleLabel.text;
}

@end
