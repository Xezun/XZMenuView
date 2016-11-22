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
@property (nonatomic) CGFloat transition;

@end

@interface XZMenuView () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *menuItemsView;

@property (nonatomic, strong, readonly) CADisplayLink *transitionLink;
@property (nonatomic, weak, readonly) UIView *transitionRelativeView;
@property (nonatomic) CGRect transitionOriginalRect;

@property (nonatomic) NSLocaleLanguageDirection languageDirection;

@end

static NSString *const XZMenuViewCellIdentifier = @"XZMenuViewCellIdentifier";

@implementation XZMenuView

- (void)dealloc {
    [_transitionLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [_transitionLink invalidate];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _selectedIndex = XZMenuViewNoSelection;
        _scrollDirection = XZMenuViewScrollDirectionHorizontal;
        [self menuItemsView];
        
        _languageDirection = [NSLocale characterDirectionForLanguage:[[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentLocaleDidChangeNotification:) name:NSCurrentLocaleDidChangeNotification object:nil];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
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
    self.menuItemsView.frame = centerFrame;
    
    CGFloat minimumWidth = [self minimumItemWidth];
    CGFloat totalWith = menuWidth - CGRectGetWidth(leftFrame) - CGRectGetWidth(rightFrame);
    minimumWidth = (totalWith / floor(totalWith / minimumWidth));
    [(UICollectionViewFlowLayout *)self.menuItemsView.collectionViewLayout setItemSize:CGSizeMake(minimumWidth, menuHeight)];
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
    
    if (_selectedIndex == indexPath.item) {
        cell.selected   = YES;
        cell.transition = 1.0;
    } else {
        cell.selected   = NO;
        cell.transition = 0;
    }
    
    return cell;
}

#pragma mark - <UICollectionViewDelegate>

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    return NO;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self PD_deselectItemAtIndex:_selectedIndex animated:YES];
    
    _selectedIndex = indexPath.item;
    
    _PDMenuViewItemCell *cell = (_PDMenuViewItemCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.transition = 1.0;
    
    if ([_delegate respondsToSelector:@selector(menuView:didSelectItemAtIndex:)]) {
        [_delegate menuView:self didSelectItemAtIndex:_selectedIndex];
    }
}

#pragma mark - Public Methods

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated {
    if (_selectedIndex != selectedIndex) {
        if (selectedIndex < [_menuItemsView numberOfItemsInSection:0]) {
            if (_selectedIndex != XZMenuViewNoSelection) {
                [self PD_deselectItemAtIndex:_selectedIndex animated:animated];
            }
            _selectedIndex = selectedIndex;
            [self PD_selectItemAtIndex:_selectedIndex animated:animated];
        } else {
            [self PD_cleanSelection];
        }
    }
}

- (void)beginTransition:(UIView *)relativeView {
    _transitionRelativeView = relativeView;
    _transitionOriginalRect = [relativeView convertRect:relativeView.bounds toView:relativeView.window];
    self.transitionLink.paused = NO;
}

- (void)endTransition {
    self.transitionLink.paused = YES;
    _transitionRelativeView = nil;
}

- (void)reloadData:(void (^)(BOOL))completion {
    [self.menuItemsView performBatchUpdates:^{
        [self.menuItemsView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    } completion:^(BOOL finished) {
        [self PD_cleanSelection];
        if (completion != nil) {
            completion(finished);
        }
    }];
}

- (void)insertItemAtIndex:(NSInteger)index {
    [self.menuItemsView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
}

- (void)removeItemAtIndex:(NSInteger)index {
    [self.menuItemsView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
}

- (UIView *)viewForItemAtIndex:(NSUInteger)index {
    _PDMenuViewItemCell *cell = (_PDMenuViewItemCell *)[self.menuItemsView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    return [cell menuItemView];
}

#pragma mark - actions

- (void)transitionLinkAction:(CADisplayLink *)displayLink {
    CGRect transitionViewRect = [_transitionRelativeView convertRect:_transitionRelativeView.bounds toView:_transitionRelativeView.window];
    NSUInteger pendingIndex = XZMenuViewNoSelection;
    CGFloat transition = 0;
    switch (_languageDirection) {
        case NSLocaleLanguageDirectionLeftToRight: {
            transition = (CGRectGetMinX(_transitionOriginalRect) - CGRectGetMinX(transitionViewRect)) / CGRectGetWidth(transitionViewRect);
            if (transition > 0) {
                pendingIndex = _selectedIndex + 1;
            } else {
                transition = -transition;
                pendingIndex = _selectedIndex - 1;
            }
            break;
        }
        default:
            break;
    }
    
    if (_selectedIndex != XZMenuViewNoSelection) {
        NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForItem:_selectedIndex inSection:0];
        _PDMenuViewItemCell *selectedCell = (_PDMenuViewItemCell *)[self.menuItemsView cellForItemAtIndexPath:selectedIndexPath];
        selectedCell.transition = MIN(1.0, MAX(0, 1.0 - transition));
        //NSLog(@"🔴->⚪️：%ld, %@, %f", _selectedIndex, ((XZMenuItemView *)[selectedCell menuItemView]).title, 1.0 - transition);
    }
    
    if (pendingIndex < [_menuItemsView numberOfItemsInSection:0]) {
        NSIndexPath *pendingIndexPath = [NSIndexPath indexPathForItem:pendingIndex inSection:0];
        _PDMenuViewItemCell *pendingCell = (_PDMenuViewItemCell *)[self.menuItemsView cellForItemAtIndexPath:pendingIndexPath];
        pendingCell.transition = MIN(1.0, MAX(0, transition));
        //NSLog(@"⚪️->🔴：%ld, %@, %f", pendingIndex, ((XZMenuItemView *)[pendingCell menuItemView]).title, transition);
    }
}

- (void)currentLocaleDidChangeNotification:(NSNotification *)notification {
    _languageDirection = [NSLocale characterDirectionForLanguage:[[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode]];
}

#pragma mark - Private Methods

- (void)PD_selectItemAtIndex:(NSInteger)index animated:(BOOL)animated {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [self PD_selectItemAtIndexPath:indexPath animated:animated];
}

- (void)PD_selectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
    [self.menuItemsView selectItemAtIndexPath:indexPath animated:animated scrollPosition:(UICollectionViewScrollPositionCenteredHorizontally)];
    _PDMenuViewItemCell *cell = (_PDMenuViewItemCell *)[self.menuItemsView cellForItemAtIndexPath:indexPath];
    cell.transition = 1.0;
}

- (void)PD_deselectItemAtIndex:(NSInteger)index animated:(BOOL)animated {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [self PD_deselectItemAtIndexPath:indexPath animated:animated];
}

- (void)PD_deselectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
    [self.menuItemsView deselectItemAtIndexPath:indexPath animated:animated];
    _PDMenuViewItemCell *cell = (_PDMenuViewItemCell *)[self.menuItemsView cellForItemAtIndexPath:indexPath];
    cell.transition = 0;
}

- (void)PD_cleanSelection {
    [[_menuItemsView indexPathsForSelectedItems] enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self PD_deselectItemAtIndexPath:obj animated:NO];
    }];
    _selectedIndex = XZMenuViewNoSelection;
}

#pragma mark - 属性

- (UICollectionView *)menuItemsView {
    if (_menuItemsView != nil) {
        return _menuItemsView;
    }
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection         = UICollectionViewScrollDirectionHorizontal;
    flowLayout.minimumLineSpacing      = 0;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.itemSize = CGSizeMake([self minimumItemWidth], CGRectGetHeight(self.bounds));
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
    _menuItemsView.delegate                       = self;
    _menuItemsView.dataSource                     = self;
    _menuItemsView.clipsToBounds                  = YES;
    _menuItemsView.showsHorizontalScrollIndicator = NO;
    _menuItemsView.showsHorizontalScrollIndicator = NO;
    _menuItemsView.alwaysBounceVertical           = NO;
    _menuItemsView.alwaysBounceHorizontal         = YES;
    [_menuItemsView registerClass:[_PDMenuViewItemCell class] forCellWithReuseIdentifier:XZMenuViewCellIdentifier];
    [self addSubview:_menuItemsView];
    [self setNeedsLayout];
    return _menuItemsView;
}

- (void)setDataSource:(id<XZMenuViewDataSource>)dataSource {
    if (_dataSource != dataSource) {
        [self PD_cleanSelection]; // if dataSource changed clear the selection.
        _dataSource = dataSource;
        [self.menuItemsView reloadData];
    }
}

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

- (CADisplayLink *)transitionLink {
    if (_transitionLink != nil) {
        return _transitionLink;
    }
    _transitionLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(transitionLinkAction:)];
    [_transitionLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    if ([UIDevice currentDevice].systemVersion.floatValue >= 10.0) {
        _transitionLink.preferredFramesPerSecond = 30;
    } else {
        _transitionLink.frameInterval = 0.03;
    }
    _transitionLink.paused = YES;
    return _transitionLink;
}

@end

@interface _PDMenuViewItemCell ()

@property (nonatomic, strong) UIView *animationView;

@end

@implementation _PDMenuViewItemCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)setMenuItemView:(UIView<XZMenuItemView> *)menuItemView {
    if (_menuItemView != menuItemView) {
        [_menuItemView removeFromSuperview]; // remove the old
        _menuItemView = menuItemView;
        
        if (_menuItemView != nil) {
            [self.contentView addSubview:_menuItemView];
            CGRect bounds = self.contentView.bounds;
            _menuItemView.center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
            if ([_menuItemView respondsToSelector:@selector(setTransition:)]) {
                _menuItemView.transition = _transition;
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
        if (_menuItemView != nil) {
            if ([_menuItemView respondsToSelector:@selector(setTransition:)]) {
                [_menuItemView setTransition:_transition];
            }
        }
    }
}

@end

