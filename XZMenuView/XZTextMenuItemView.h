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

typedef NS_OPTIONS(NSUInteger, XZTextMenuItemViewTransitionType) {
    XZTextMenuItemViewTransitionTypeNone = 0,
    XZTextMenuItemViewTransitionTypeTextColor = 1 << 0,
    XZTextMenuItemViewTransitionTypeTextScale = 1 << 1
};

@interface XZTextMenuItemView : UIView <XZMenuItemView>

@property (nonatomic) XZTextMenuItemViewTransitionType transitionType;

@property (nonatomic, getter=isSelected) BOOL selected;
@property (nonatomic, getter=isHighlighted) BOOL highlighted;
@property (nonatomic) CGFloat transition;

@property (nonatomic, strong, readonly) UIView *contentView;

@property (nonatomic, strong) UILabel *textLabel;

- (void)setTextColor:(UIColor *)titleColor forState:(UIControlState)state;
- (UIColor *)textColorForState:(UIControlState)state;


@end
