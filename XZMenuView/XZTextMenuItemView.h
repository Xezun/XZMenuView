//
//  XZTextMenuItemView.h
//  XZKit
//
//  Created by mlibai on 2016/11/21.
//  Copyright © 2016年 mlibai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XZMenuView.h"

@class UITableViewCell;

typedef NS_OPTIONS(NSUInteger, XZTextMenuItemViewTransitionOptions) {
    XZTextMenuItemViewTransitionOptionNone = 0,
    XZTextMenuItemViewTransitionOptionColor = 1 << 0,
    XZTextMenuItemViewTransitionOptionScale = 1 << 1
};

@interface XZTextMenuItemView : UIView <XZMenuItemView>

@property (nonatomic) XZTextMenuItemViewTransitionOptions transitionOptions;
@property (nonatomic, strong, readonly) UIView *animationView;

@property (nonatomic, getter=isSelected) BOOL selected;
@property (nonatomic, getter=isHighlighted) BOOL highlighted;
@property (nonatomic) CGFloat transition;

- (void)updateTransitonAppearanceIfNeeded;
- (void)setNeedsTransitonAppearanceUpdate;

@property (nonatomic, strong) UILabel *textLabel;

- (void)setTextColor:(UIColor *)titleColor forState:(UIControlState)state;
- (UIColor *)textColorForState:(UIControlState)state;

- (instancetype)initWithFrame:(CGRect)frame transitionOptions:(XZTextMenuItemViewTransitionOptions)transitionOptions;

@end
