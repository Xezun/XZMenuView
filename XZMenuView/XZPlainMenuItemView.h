//
//  XZPlainMenuItemView.h
//  XZKit
//
//  Created by mlibai on 2016/11/21.
//  Copyright © 2016年 mlibai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XZMenuView.h"

@class UITableViewCell;

typedef NS_OPTIONS(NSUInteger, XZPlainMenuItemViewTransitionOptions) {
    XZPlainMenuItemViewTransitionOptionNone = 0,
    XZPlainMenuItemViewTransitionOptionColor = 1 << 0,
    XZPlainMenuItemViewTransitionOptionScale = 1 << 1
};

@interface XZPlainMenuItemView : UIView <XZMenuItemView>

@property (nonatomic) XZPlainMenuItemViewTransitionOptions transitionOptions;
@property (nonatomic, strong, readonly) UIView *contentView;

@property (nonatomic, getter=isSelected) BOOL selected;
@property (nonatomic, getter=isHighlighted) BOOL highlighted;
@property (nonatomic) CGFloat transition;

- (void)updateTransitonAppearanceIfNeeded;
- (void)setNeedsTransitonAppearanceUpdate;

@property (nonatomic, strong) UILabel *textLabel;

- (void)setTextColor:(UIColor *)titleColor forState:(UIControlState)state;
- (UIColor *)textColorForState:(UIControlState)state;

- (instancetype)initWithTransitionOptions:(XZPlainMenuItemViewTransitionOptions)transitionOptions;
- (instancetype)initWithFrame:(CGRect)frame transitionOptions:(XZPlainMenuItemViewTransitionOptions)transitionOptions NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@end
