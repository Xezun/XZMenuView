//
//  XZMenuView.h
//  XZKit
//
//  Created by mlibai on 2016/11/21.
//  Copyright © 2016年 mlibai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

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

@property (nonatomic, strong, nullable) __kindof UIView *leftView;
@property (nonatomic, strong, nullable) __kindof UIView *rightView;

@property (nonatomic) UIUserInterfaceLayoutDirection userInterfaceLayoutDirection; // default value is -[UIApplication userInterfaceLayoutDirection].

@property (nonatomic, getter=isScrollEnabled) BOOL scrollEnabled;

@property (nonatomic) XZMenuViewIndicatorStyle indicatorStyle; // default none.
@property (nonatomic) XZMenuViewIndicatorPosition indicatorPosition;
@property (nonatomic, strong, nullable) UIImage *indicatorImage;
@property (nonatomic, strong, nullable) UIColor *indicatorColor;

@property (nonatomic) CGFloat minimumItemWidth; // default 49.0

@property (nonatomic, weak, nullable) id<XZMenuViewDataSource> dataSource;
@property (nonatomic, weak, nullable) id<XZMenuViewDelegate> delegate;

@property (nonatomic) NSInteger selectedIndex; // default XZMenuViewNoSelection, no item selected.

/**
 Set the specific item to be selected. If the index is beyond menu range, selection will be cleared.
 
 @param selectedIndex the index you wish to set
 @param animated enable animation duration transition
 */
- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated;

/**
 Menu view will select a new item. Call this method to tell menu view which view is related to the current selected item. Menu view will observe the related view's frame to figure out the transition animation progress.

 @param relatedView The selected item related view
 */
- (void)beginTransition:(nullable UIView *)relatedView;

/**
 Notice the menu view that the transition is finished.
 */
- (void)endTransition;

/**
 Reload data. The view will be updated in next runloop.

 @param completion The handler when view finish reload.
 */
- (void)reloadData:(void (^)(BOOL finished))completion;;

- (void)insertItemAtIndex:(NSInteger)index;
- (void)removeItemAtIndex:(NSInteger)index;

/**
 Maybe nil if the item is not visible.
 */
- (__kindof UIView<XZMenuItemView>  * _Nullable)viewForItemAtIndex:(NSUInteger)index;

@end

/**
 The protocol `XZMenuItemView` defines several methods that a custom munu item view can be able to get the menu events.
 */
@protocol XZMenuItemView <NSObject>

@optional
@property (nonatomic, getter=isSelected) BOOL selected;
@property (nonatomic, getter=isHighlighted) BOOL highlighted;

/**
 A progress from normal to selected. 0 ~ 1.0.
 */
@property (nonatomic) CGFloat transition;

@end


@protocol XZMenuViewDataSource <NSObject>

@required
- (NSInteger)numberOfItemsInMenuView:(XZMenuView *)meunView;

/**
 It is recommended that the custom item view comforms the `XZMenuItemView` protocol.
 */
- (__kindof UIView * _Nullable)menuView:(XZMenuView *)menuView viewForItemAtIndex:(NSInteger)index reusingView:(__kindof UIView * _Nullable)reusingView;

@end


@protocol XZMenuViewDelegate <NSObject>

@optional
- (void)menuView:(XZMenuView *)menuView didSelectItemAtIndex:(NSInteger)index;
- (CGFloat)menuView:(XZMenuView *)menuView widthForItemAtIndex:(NSInteger)index;

@end


NS_ASSUME_NONNULL_END
