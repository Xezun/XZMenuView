//
//  PDMenuView.h
//  Daily
//
//  Created by mlibai on 2016/10/19.
//  Copyright © 2016年 People's Daily Online. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDBorderedView.h"

@class UISegmentedControl;

UIKIT_EXTERN NSInteger const kPDMenuViewNoSelection;

@protocol PDMenuViewDataSource, PDMenuViewDelegate, PDMenuItemView;

@interface PDMenuView : UIView

@property (nonatomic, strong) __kindof UIView *leftView;
@property (nonatomic, strong) __kindof UIView *rightView;

@property (nonatomic) CGFloat minimumItemWidth; // default 49.0

@property (nonatomic) NSInteger selectedIndex; // default kPDMenuViewNoSelection, no item selected.

@property (nonatomic, weak) id<PDMenuViewDataSource> dataSource;
@property (nonatomic, weak) id<PDMenuViewDelegate> delegate;

/**
 Set the specific item to be selected. If the index is beyond menu range, selection will be cleared.

 @param selectedIndex the index you wish to set
 @param animated enable animation duration transition
 */
- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated;

/**
 Set the progress of the transition to select a new item.

 @param transition the progress，0 ～ 1.0
 @param index the index of item will be selected
 */
- (void)setTransition:(CGFloat)transition toIndex:(NSUInteger)pendingIndex;

- (void)reloadData:(void (^)(BOOL finished))completion;; // will clean the selection
//- (void)performBatchUpdates:(void (^)(void))updates completion:(void (^)(BOOL finished))completion;

- (void)insertItemAtIndex:(NSInteger)index;
- (void)removeItemAtIndex:(NSInteger)index;

- (__kindof UIView<PDMenuItemView> *)viewForItemAtIndex:(NSUInteger)index;

@end





@protocol PDMenuItemView <NSObject>

@optional
@property (nonatomic, getter=isSelected) BOOL selected;
@property (nonatomic, getter=isHighlighted) BOOL highlighted;
@property (nonatomic) CGFloat transition;

@end


@protocol PDMenuViewDataSource <NSObject>

@required
- (NSInteger)numberOfItemsInMenuView:(PDMenuView *)meunView;
- (__kindof UIView<PDMenuItemView> *)menuView:(PDMenuView *)menuView viewForItemAtIndex:(NSInteger)index reusingView:(__kindof UIView<PDMenuItemView> *)reusingView;

@end


@protocol PDMenuViewDelegate <NSObject>

- (void)menuView:(PDMenuView *)menuView didSelectItemAtIndex:(NSInteger)index;

@end

