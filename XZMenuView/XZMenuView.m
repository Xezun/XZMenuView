//
//  XZMenuView.m
//  XZKit
//
//  Created by mlibai on 2016/11/21.
//  Copyright © 2016年 mlibai. All rights reserved.
//

#import "XZMenuView.h"

NSInteger const XZMenuViewNoSelection = -1;


@interface _PDMenuViewItemCell : UICollectionViewCell <XZMenuItemView>

@property (nonatomic, strong) UIView<XZMenuItemView> *menuItemView;

@property (nonatomic, weak) UIView *indicatorView;

@end



@interface _XZMenuViewTransitionLink : NSObject

@property (nonatomic, weak) UIView *view;
@property (nonatomic) CGRect rect;
@property (nonatomic) CGRect transitingRect;

+ (instancetype)transitionLinkWithTarget:(id)target selector:(SEL)selector;

@property (getter=isPaused, nonatomic) BOOL paused;
@property (nonatomic) NSInteger preferredFramesPerSecond;

@end



@class UICollectionViewFlowLayout;

@interface _XZMenuViewLayout : UICollectionViewLayout


@property (nonatomic) UIUserInterfaceLayoutDirection userInterfaceLayoutDirection;

@end

@protocol UICollectionViewDelegateXZMenuViewLayout <UICollectionViewDelegate>

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(_XZMenuViewLayout *)collectionViewLayout widthForItemAtIndex:(NSInteger)index;

@end




@interface XZMenuView () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateXZMenuViewLayout> {
    UICollectionView *_menuItemsView;
    UIImageView *_indicatorImageView;
}

@property (nonatomic, strong, readonly) _XZMenuViewTransitionLink *transitionLink;

@end

static NSString *const XZMenuViewCellIdentifier = @"XZMenuViewCellIdentifier";

@implementation XZMenuView

- (void)dealloc {
    
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self XZ_viewDidInitialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self XZ_viewDidInitialize];
    }
    return self;
}

- (void)XZ_viewDidInitialize {
    _selectedIndex = XZMenuViewNoSelection;
    
    _XZMenuViewLayout *flowLayout = [[_XZMenuViewLayout alloc] init];
    
    _menuItemsView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
    _menuItemsView.backgroundColor = [UIColor clearColor];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 100000
    if ([_menuItemsView respondsToSelector:@selector(setPrefetchingEnabled:)]) {
        [_menuItemsView setValue:@(NO) forKey:@"prefetchingEnabled"];
    }
#else
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_10_0
    if ([_menuItemsView respondsToSelector:@selector(setPrefetchingEnabled:)]) {
        _menuItemsView.prefetchingEnabled = NO;
    }
#else
    _menuItemsView.prefetchingEnabled = NO;
#endif /* __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_10_0 */
#endif /* __IPHONE_10_0 */
    _menuItemsView.allowsSelection                = YES;
    _menuItemsView.allowsMultipleSelection        = NO;
    _menuItemsView.clipsToBounds                  = YES;
    _menuItemsView.showsHorizontalScrollIndicator = NO;
    _menuItemsView.showsVerticalScrollIndicator   = NO;
    _menuItemsView.alwaysBounceVertical           = NO;
    _menuItemsView.alwaysBounceHorizontal         = YES;
    [_menuItemsView registerClass:[_PDMenuViewItemCell class] forCellWithReuseIdentifier:XZMenuViewCellIdentifier];
    [self addSubview:_menuItemsView];
    _menuItemsView.delegate   = self;
    _menuItemsView.dataSource = self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    //NSLog(@"%s", __func__);
    
    CGRect bounds = self.bounds, leftFrame = CGRectZero, rightFrame = CGRectZero;
    CGFloat menuHeight = CGRectGetHeight(bounds);
    CGFloat menuWidth = CGRectGetWidth(bounds);
    
    if (_leftView != nil) {
        CGRect frame    = _leftView.frame;
        CGFloat height  = CGRectGetHeight(frame);
        CGFloat width   = CGRectGetWidth(frame);
        if (height > menuHeight) {
            width = menuHeight * width / height;
            height = menuHeight;
        }
        leftFrame       = CGRectMake(0, (menuHeight - height) / 2.0, width, height);
        _leftView.frame = leftFrame;
    }
    
    if (_rightView != nil) {
        CGRect frame     = _rightView.frame;
        CGFloat height   = CGRectGetHeight(frame);
        CGFloat width    = CGRectGetWidth(frame);
        if (height > menuHeight) {
            width = menuHeight * width / height;
            height = menuHeight;
        }
        rightFrame       = CGRectMake(menuWidth - width, (menuHeight - height) / 2.0, width, height);
        _rightView.frame = rightFrame;
    }
    
    CGRect centerFrame = CGRectMake(CGRectGetMaxX(leftFrame), 0, menuWidth - CGRectGetWidth(leftFrame) - CGRectGetWidth(rightFrame), menuHeight);
    _menuItemsView.frame = centerFrame;
    
    switch (_indicatorStyle) {
        case XZMenuViewIndicatorStyleDefault: {
            switch (_indicatorPosition) {
                case XZMenuViewIndicatorPositionTop:                    
                    if (_selectedIndex != XZMenuViewNoSelection) {
                        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_selectedIndex inSection:0];
                        UICollectionViewLayoutAttributes *attr = [_menuItemsView.collectionViewLayout layoutAttributesForItemAtIndexPath:indexPath];
                        CGRect frame = attr.frame;
                        frame.origin.y = 0;
                        frame.size.height = 2.0;
                        _indicatorImageView.frame = frame;
                    }
                    
                    break;
                case XZMenuViewIndicatorPositionBottom:
                    if (_selectedIndex != XZMenuViewNoSelection) {
                        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_selectedIndex inSection:0];
                        UICollectionViewLayoutAttributes *attr = [_menuItemsView.collectionViewLayout layoutAttributesForItemAtIndexPath:indexPath];
                        CGRect frame = attr.frame;
                        frame.origin.y = CGRectGetMaxY(frame);
                        frame.size.height = 2.0;
                        _indicatorImageView.frame = frame;
                    }
                    break;
            }
            break;
        }
        case XZMenuViewIndicatorStyleNone:
            _menuItemsView.contentInset = UIEdgeInsetsZero;
            break;
    }
    
    CGFloat minimumWidth = [self minimumItemWidth];
    CGFloat totalWith = menuWidth - CGRectGetWidth(leftFrame) - CGRectGetWidth(rightFrame);
    minimumWidth = (totalWith / floor(totalWith / minimumWidth));
    _minimumItemWidth = minimumWidth;
    
    if (_selectedIndex != XZMenuViewNoSelection) {
        [self XZ_selectItemAtIndex:_selectedIndex animated:YES];
    }
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_dataSource numberOfItemsInMenuView:self];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    _PDMenuViewItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:XZMenuViewCellIdentifier forIndexPath:indexPath];
    
    cell.menuItemView = [_dataSource menuView:self viewForItemAtIndex:indexPath.item reusingView:cell.menuItemView];
    
    return cell;
}

#pragma mark - <UICollectionViewDelegate>

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    return NO;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_selectedIndex != indexPath.item) {
        //[self XZ_deselectItemAtIndex:_selectedIndex animated:YES];
        
        _selectedIndex = indexPath.item;
        
        [self XZ_moveIndicatorToIndexPath:indexPath animated:YES];
        
        if ([_delegate respondsToSelector:@selector(menuView:didSelectItemAtIndex:)]) {
            [_delegate menuView:self didSelectItemAtIndex:_selectedIndex];
        }
    }
}

#pragma mark - <_XZMenuViewLayout>

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(_XZMenuViewLayout *)collectionViewLayout widthForItemAtIndex:(NSInteger)index {
    if ([_delegate respondsToSelector:@selector(menuView:widthForItemAtIndex:)]) {
        return [_delegate menuView:self widthForItemAtIndex:index];
    }
    return [self minimumItemWidth];
}

#pragma mark - Public Methods

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated {
    if (_selectedIndex != selectedIndex) {
        if (selectedIndex < [_menuItemsView numberOfItemsInSection:0]) {
            if (_selectedIndex != XZMenuViewNoSelection) {
                [self XZ_deselectItemAtIndex:_selectedIndex animated:animated];
            }
            _selectedIndex = selectedIndex;
            [self XZ_selectItemAtIndex:_selectedIndex animated:animated];
        } else {
            [self XZ_cleanSelection];
        }
    }
}

- (void)beginTransition:(UIView *)relatedView {
    self.transitionLink.view = relatedView;
    self.transitionLink.rect = [relatedView convertRect:relatedView.bounds toView:relatedView.window];
    self.transitionLink.transitingRect = self.transitionLink.rect;
    self.transitionLink.paused = (relatedView == nil);
}

- (void)endTransition {
    _transitionLink.paused = YES;
    _transitionLink.view = nil;
    _transitionLink.rect = CGRectZero;
    _transitionLink.transitingRect = CGRectZero;
}

- (void)reloadData:(void (^)(BOOL))completion {
    [_menuItemsView performBatchUpdates:^{
        [_menuItemsView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    } completion:^(BOOL finished) {
        if (completion != nil) {
            completion(finished);
        }
    }];
}

- (void)insertItemAtIndex:(NSInteger)index {
    [_menuItemsView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
}

- (void)removeItemAtIndex:(NSInteger)index {
    [_menuItemsView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
}

- (UIView *)viewForItemAtIndex:(NSUInteger)index {
    _PDMenuViewItemCell *cell = (_PDMenuViewItemCell *)[_menuItemsView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    return [cell menuItemView];
}

#pragma mark - actions

- (void)transitionLinkAction:(_XZMenuViewTransitionLink *)transitionLink {
    CGRect transitionViewRect = [transitionLink.view convertRect:transitionLink.view.bounds toView:transitionLink.view.window];
    if (CGRectEqualToRect(transitionLink.transitingRect, transitionViewRect)) {
        return;
    }
    transitionLink.transitingRect = transitionViewRect;
    
    NSUInteger pendingIndex = XZMenuViewNoSelection;
    CGFloat transition = 0;
    switch ([UIApplication sharedApplication].userInterfaceLayoutDirection) {
        case UIUserInterfaceLayoutDirectionLeftToRight:
            transition = (CGRectGetMinX(transitionLink.rect) - CGRectGetMinX(transitionViewRect)) / CGRectGetWidth(transitionViewRect);
            break;
        
        case UIUserInterfaceLayoutDirectionRightToLeft:
            transition = (CGRectGetMinX(transitionViewRect) - CGRectGetMinX(transitionLink.rect)) / CGRectGetWidth(transitionViewRect);
            break;
    }
    
    if (transition > 0) {
        pendingIndex = _selectedIndex + 1;
    } else {
        transition = -transition;
        pendingIndex = _selectedIndex - 1;
    }
    
    CGRect rect1, rect2, rect = _indicatorImageView.frame;
    
    if (_selectedIndex != XZMenuViewNoSelection) {
        NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForItem:_selectedIndex inSection:0];
        _PDMenuViewItemCell *selectedCell = (_PDMenuViewItemCell *)[_menuItemsView cellForItemAtIndexPath:selectedIndexPath];
        selectedCell.transition = MIN(1.0, MAX(0, 1.0 - transition));
        rect1 = selectedCell.frame;
    }
    
    if (pendingIndex < [_menuItemsView numberOfItemsInSection:0]) {
        NSIndexPath *pendingIndexPath = [NSIndexPath indexPathForItem:pendingIndex inSection:0];
        _PDMenuViewItemCell *pendingCell = (_PDMenuViewItemCell *)[_menuItemsView cellForItemAtIndexPath:pendingIndexPath];
        pendingCell.transition = MIN(1.0, MAX(0, transition));
        rect2 = pendingCell.frame;
    }
    
    rect.origin.x = CGRectGetMinX(rect1) + (CGRectGetMinX(rect2) - CGRectGetMinX(rect1)) * transition;
    rect.size.width = CGRectGetWidth(rect1) + (CGRectGetWidth(rect2) - CGRectGetWidth(rect1)) * transition;
    _indicatorImageView.frame = rect;
}

#pragma mark - Private Methods

- (void)XZ_selectItemAtIndex:(NSInteger)index animated:(BOOL)animated {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [self XZ_selectItemAtIndexPath:indexPath animated:animated];
}

- (void)XZ_selectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
    [_menuItemsView selectItemAtIndexPath:indexPath animated:animated scrollPosition:(UICollectionViewScrollPositionCenteredHorizontally)];
    [self XZ_moveIndicatorToIndexPath:indexPath animated:animated];
}

- (void)XZ_moveIndicatorToIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
    if (_indicatorImageView) {
        CGRect cellFrame = ([_menuItemsView.collectionViewLayout layoutAttributesForItemAtIndexPath:indexPath]).frame;
        CGRect frame = _indicatorImageView.frame;
        frame.origin.x = CGRectGetMinX(cellFrame);
        frame.size.width = CGRectGetWidth(cellFrame);
        [UIView animateWithDuration:(animated ? 0.25 : 0) animations:^{
            _indicatorImageView.frame = frame;
        }];
    }
}

- (void)XZ_deselectItemAtIndex:(NSInteger)index animated:(BOOL)animated {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [self XZ_deselectItemAtIndexPath:indexPath animated:animated];
}

- (void)XZ_deselectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
    [_menuItemsView deselectItemAtIndexPath:indexPath animated:animated];
}

- (void)XZ_cleanSelection {
    [[_menuItemsView indexPathsForSelectedItems] enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self XZ_deselectItemAtIndexPath:obj animated:NO];
    }];
    _selectedIndex = XZMenuViewNoSelection;
}

#pragma mark - 属性

- (void)setLeftView:(UIView *)leftView {
    if (_leftView != leftView) {
        [_leftView removeFromSuperview];
        _leftView = leftView;
        if (_leftView != nil) {
            _leftView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
            CGRect frame = _leftView.frame;
            frame.origin.x = -frame.size.width;
            frame.origin.y = (CGRectGetHeight(self.bounds) - CGRectGetHeight(frame)) * 0.5;
            _leftView.frame = frame;
            [self addSubview:_leftView];
            [self setNeedsLayout];
        }
    }
}

- (void)setRightView:(UIView *)rightView {
    if (_rightView != rightView) {
        [_rightView removeFromSuperview];
        _rightView = rightView;
        if (_rightView != nil) {
            _rightView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
            CGRect frame   = _rightView.frame;
            CGRect bounds = self.bounds;
            frame.origin.x = CGRectGetMaxX(bounds) + CGRectGetWidth(frame);
            frame.origin.y = (CGRectGetHeight(self.bounds) - CGRectGetHeight(frame)) * 0.5;
            _rightView.frame = frame;
            [self addSubview:_rightView];
            [self setNeedsLayout];
        }
    }
}

@synthesize selectedIndex = _selectedIndex;

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    [self setSelectedIndex:selectedIndex animated:NO];
}

@synthesize minimumItemWidth = _minimumItemWidth;

- (CGFloat)minimumItemWidth {
    if (_minimumItemWidth > 0) {
        return _minimumItemWidth;
    }
    _minimumItemWidth = 49.0;
    return _minimumItemWidth;
}

- (void)setMinimumItemWidth:(CGFloat)minimumItemWidth {
    if (_minimumItemWidth != minimumItemWidth) {
        _minimumItemWidth = minimumItemWidth;
        [self setNeedsLayout];
    }
}

@synthesize transitionLink = _transitionLink;

- (_XZMenuViewTransitionLink *)transitionLink {
    if (_transitionLink != nil) {
        return _transitionLink;
    }
    _transitionLink = [_XZMenuViewTransitionLink transitionLinkWithTarget:self selector:@selector(transitionLinkAction:)];
    _transitionLink.preferredFramesPerSecond = 50;
    _transitionLink.paused = YES;
    return _transitionLink;
}

- (void)setUserInterfaceLayoutDirection:(UIUserInterfaceLayoutDirection)userInterfaceLayoutDirection {
    [(_XZMenuViewLayout *)_menuItemsView.collectionViewLayout setUserInterfaceLayoutDirection:userInterfaceLayoutDirection];
}

- (UIUserInterfaceLayoutDirection)userInterfaceLayoutDirection {
    return [(_XZMenuViewLayout *)_menuItemsView.collectionViewLayout userInterfaceLayoutDirection];
}

- (void)setIndicatorStyle:(XZMenuViewIndicatorStyle)indicatorStyle {
    if (_indicatorStyle != indicatorStyle) {
        _indicatorStyle = indicatorStyle;
        switch (_indicatorStyle) {
            case XZMenuViewIndicatorStyleDefault: {
                if (_indicatorImageView == nil) {
                    _indicatorImageView = [[UIImageView alloc] init];
                }
                _indicatorImageView.image = _indicatorImage;
                _indicatorImageView.backgroundColor = _indicatorColor;
                [_menuItemsView addSubview:_indicatorImageView];
                break;
            }
            case XZMenuViewIndicatorStyleNone:
                [_indicatorImageView removeFromSuperview];
                break;
        }
    }
}

- (void)setIndicatorPosition:(XZMenuViewIndicatorPosition)indicatorPosition {
    if (_indicatorPosition != indicatorPosition) {
        _indicatorPosition = indicatorPosition;
        switch (_indicatorPosition) {
            case XZMenuViewIndicatorPositionBottom:
                _menuItemsView.contentInset = UIEdgeInsetsMake(0, 0, 2.0, 0);
                break;
            case XZMenuViewIndicatorPositionTop:
                _menuItemsView.contentInset = UIEdgeInsetsMake(2.0, 0, 0, 0);
                break;
        }
        [_menuItemsView invalidateIntrinsicContentSize];
    }
}

- (void)setIndicatorImage:(UIImage *)indicatorImage {
    if (_indicatorImage != indicatorImage) {
        _indicatorImage = indicatorImage;
        _indicatorImageView.image = _indicatorImage;
    }
}

- (void)setIndicatorColor:(UIColor *)indicatorColor {
    if (_indicatorColor != indicatorColor) {
        _indicatorColor = indicatorColor;
        _indicatorImageView.backgroundColor = _indicatorColor;
    }
}

@end







#pragma mark - ==================

@interface _PDMenuViewItemCell ()

@end

@implementation _PDMenuViewItemCell

@synthesize transition = _transition;

- (void)setMenuItemView:(UIView<XZMenuItemView> *)menuItemView {
    if (_menuItemView != menuItemView) {
        [_menuItemView removeFromSuperview]; // remove the old
        _menuItemView = menuItemView;
        
        if (_menuItemView != nil) {
            [self.contentView addSubview:_menuItemView];
            _menuItemView.frame = self.contentView.bounds;
            _menuItemView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            if ([_menuItemView respondsToSelector:@selector(setTransition:)]) {
                _menuItemView.transition = _transition;
            }
            if ([_menuItemView respondsToSelector:@selector(setSelected:)]) {
                _menuItemView.selected = [self isSelected];
            }
            if ([_menuItemView respondsToSelector:@selector(setHighlighted:)]) {
                _menuItemView.highlighted = [self isHighlighted];
            }
        }
    }
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if ([_menuItemView respondsToSelector:@selector(setSelected:)]) {
        [_menuItemView setSelected:selected];
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if ([_menuItemView respondsToSelector:@selector(setHighlighted:)]) {
        [_menuItemView setHighlighted:highlighted];
    }
}

- (void)setTransition:(CGFloat)transition {
    if (_transition != transition) {
        _transition = transition;
    }
    if (_menuItemView != nil) {
        if ([_menuItemView respondsToSelector:@selector(setTransition:)]) {
            [_menuItemView setTransition:_transition];
        }
    }
}

- (void)setIndicatorView:(UIView *)indicatorView {
    if (_indicatorView != indicatorView) {
        _indicatorView = indicatorView;
        CGRect bounds = self.bounds;
        bounds.origin.y += 2.0;
        bounds.size.height = 2.0;
        _indicatorView.frame = bounds;
        [self.contentView addSubview:_indicatorView];
        _indicatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
}

@end


#pragma mark - ==================

#import <objc/runtime.h>

@implementation _XZMenuViewTransitionLink {
    CADisplayLink *_displayLink;
    id __weak _target;
    SEL _selector;
    void (*_action)(id, SEL, id);
}

- (void)dealloc {
    [_displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [_displayLink invalidate];
}

+ (instancetype)transitionLinkWithTarget:(id)target selector:(SEL)selector {
    return [(_XZMenuViewTransitionLink *)[self alloc] initWithTarget:target selector:selector];
}

- (instancetype)initWithTarget:(id)target selector:(SEL)selector {
    self = [super init];
    if (self) {
        _target = target;
        _selector = selector;
        IMP imp = class_getMethodImplementation(object_getClass(_target), _selector);
        _action = (void *)imp;
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkAction:)];
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
    return self;
}

- (void)addToRunLoop:(NSRunLoop *)runloop forMode:(NSRunLoopMode)mode {
    [_displayLink addToRunLoop:runloop forMode:mode];
}

- (void)removeFromRunLoop:(NSRunLoop *)runloop forMode:(NSRunLoopMode)mode {
    [_displayLink removeFromRunLoop:runloop forMode:mode];
}

- (void)invalidate {
    [_displayLink invalidate];
}

- (BOOL)isPaused {
    return [_displayLink isPaused];
}

- (void)setPaused:(BOOL)paused {
    [_displayLink setPaused:paused];
}

- (NSInteger)preferredFramesPerSecond {
    if ([UIDevice currentDevice].systemVersion.floatValue >= 10.0) {
        return [_displayLink preferredFramesPerSecond];
    } else {
        return 1.0 / [_displayLink frameInterval];
    }
}

- (void)setPreferredFramesPerSecond:(NSInteger)preferredFramesPerSecond {
    if ([UIDevice currentDevice].systemVersion.floatValue >= 10.0) {
        [_displayLink setPreferredFramesPerSecond:preferredFramesPerSecond];
    } else {
        _displayLink.frameInterval = 1.0 / (CGFloat)preferredFramesPerSecond;
    }
}

- (void)displayLinkAction:(CADisplayLink *)diplayLink {
    _action(_target, _selector, self);
}

@end


#pragma mark - ==================

@interface _XZMenuViewLayout () {
    CGFloat _totalWidth;
    CGFloat _totalHeight;
    
    CGFloat _itemCount;
    
    NSMutableArray<UICollectionViewLayoutAttributes *> *_allLayoutAttributes;
}

@end

@implementation _XZMenuViewLayout

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        [self XZ_layoutDidInitialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self XZ_layoutDidInitialize];
    }
    return self;
}

- (void)XZ_layoutDidInitialize {
    _userInterfaceLayoutDirection = [UIApplication sharedApplication].userInterfaceLayoutDirection;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

- (void)prepareLayout {
    [super prepareLayout];
    
    //NSLog(@"%s", __func__);
    
    _itemCount = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:0];
    
    CGRect bounds = self.collectionView.bounds;
    UIEdgeInsets contentInset = self.collectionView.contentInset;
    _totalHeight = CGRectGetHeight(bounds) - contentInset.bottom - contentInset.top;
    
    _totalWidth = 0;
    id<UICollectionViewDelegateXZMenuViewLayout> delegate = (id<UICollectionViewDelegateXZMenuViewLayout>)self.collectionView.delegate;
    
    if (_allLayoutAttributes != nil) {
        [_allLayoutAttributes removeAllObjects];
    } else {
        _allLayoutAttributes = [NSMutableArray arrayWithCapacity:_itemCount];
    }
    
    switch (_userInterfaceLayoutDirection) {
        case UIUserInterfaceLayoutDirectionRightToLeft: {
            CGFloat *widths = calloc(_itemCount, sizeof(CGFloat));
            for (NSInteger i = 0; i < _itemCount; i++) {
                CGFloat const width = [delegate collectionView:self.collectionView layout:self widthForItemAtIndex:i];
                widths[i] = width;
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
                UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
                [_allLayoutAttributes addObject:attr];
                
                _totalWidth += width;
            }
            
            CGFloat tmpWidth = _totalWidth;
            for (NSInteger i = 0; i < _itemCount; i++) {
                UICollectionViewLayoutAttributes *attr = _allLayoutAttributes[i];
                tmpWidth -= widths[i];
                attr.frame = CGRectMake(tmpWidth, 0, widths[i], _totalHeight);
            }
            free(widths);
            break;
        }
        case UIUserInterfaceLayoutDirectionLeftToRight: {
            for (NSInteger i = 0; i < _itemCount; i++) {
                CGFloat const width = [delegate collectionView:self.collectionView layout:self widthForItemAtIndex:i];
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
                UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
                attr.frame = CGRectMake(_totalWidth, 0, width, _totalHeight);
                [_allLayoutAttributes addObject:attr];
                
                _totalWidth += width;
            }
            break;
        }
        default:
            break;
    }
}

- (CGSize)collectionViewContentSize {
    return CGSizeMake(_totalWidth, _totalHeight);
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *arrayM = [NSMutableArray array];
    for (UICollectionViewLayoutAttributes *attr in _allLayoutAttributes) {
        if (CGRectIntersectsRect(rect, attr.frame)) {
            [arrayM addObject:attr];
        }
    }
    return arrayM;
}

- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [_allLayoutAttributes objectAtIndex:indexPath.item];
}

#pragma mark - setter & getter

- (void)setUserInterfaceLayoutDirection:(UIUserInterfaceLayoutDirection)userInterfaceLayoutDirection {
    if (_userInterfaceLayoutDirection != userInterfaceLayoutDirection) {
        _userInterfaceLayoutDirection = userInterfaceLayoutDirection;
        [self invalidateLayout];
    }
}

@end
