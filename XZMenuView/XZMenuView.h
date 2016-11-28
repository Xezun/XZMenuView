//
//  XZMenuView.h
//  XZKit
//
//  Created by mlibai on 2016/11/21.
//  Copyright © 2016年 mlibai. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN NSInteger const XZMenuViewNoSelection; // -1

@protocol XZMenuViewDataSource, XZMenuViewDelegate, XZMenuItemView;

@class UICollectionView, UICollectionViewFlowLayout, UILabel;

// Indicator Style
typedef NS_ENUM(NSInteger, XZMenuViewIndicatorStyle) {
    XZMenuViewIndicatorStyleNone,
    XZMenuViewIndicatorStyleDefault
};

// Indicator Position
typedef NS_ENUM(NSInteger, XZMenuViewIndicatorPosition) {
    XZMenuViewIndicatorPositionBottom = 1,
    XZMenuViewIndicatorPositionTop
};

@interface XZMenuView : UIView

@property (nonatomic, strong) __kindof UIView *leftView;
@property (nonatomic, strong) __kindof UIView *rightView;

@property (nonatomic) UIUserInterfaceLayoutDirection userInterfaceLayoutDirection; // -[UIApplication userInterfaceLayoutDirection] default.

@property (nonatomic) XZMenuViewIndicatorStyle indicatorStyle;
@property (nonatomic) XZMenuViewIndicatorPosition indicatorPosition;
@property (nonatomic, strong) UIImage *indicatorImage;
@property (nonatomic, strong) UIColor *indicatorColor;

@property (nonatomic) CGFloat minimumItemWidth; // default 49.0

@property (nonatomic, weak) id<XZMenuViewDataSource> dataSource;
@property (nonatomic, weak) id<XZMenuViewDelegate> delegate;

@property (nonatomic) NSInteger selectedIndex; // default XZMenuViewNoSelection, no item selected.

/**
 Set the specific item to be selected. If the index is beyond menu range, selection will be cleared.
 
 @param selectedIndex the index you wish to set
 @param animated enable animation duration transition
 */
- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated;

- (void)beginTransition:(UIView *)relativeView;
- (void)endTransition;

- (void)reloadData:(void (^)(BOOL finished))completion;;

- (void)insertItemAtIndex:(NSInteger)index;
- (void)removeItemAtIndex:(NSInteger)index;

- (__kindof UIView<XZMenuItemView> *)viewForItemAtIndex:(NSUInteger)index;

@end


@protocol XZMenuItemView <NSObject>

@optional
@property (nonatomic, getter=isSelected) BOOL selected;
@property (nonatomic, getter=isHighlighted) BOOL highlighted;
@property (nonatomic) CGFloat transition;

@end


@protocol XZMenuViewDataSource <NSObject>

@required
- (NSInteger)numberOfItemsInMenuView:(XZMenuView *)meunView;
- (__kindof UIView *)menuView:(XZMenuView *)menuView viewForItemAtIndex:(NSInteger)index reusingView:(__kindof UIView *)reusingView;

@end


@protocol XZMenuViewDelegate <NSObject>

- (void)menuView:(XZMenuView *)menuView didSelectItemAtIndex:(NSInteger)index;
- (CGFloat)menuView:(XZMenuView *)menuView widthForItemAtIndex:(NSInteger)index;

@end


