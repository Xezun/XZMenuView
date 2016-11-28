# XZMenuView

## Auto adjusts user interface layout dirction

### Left To Right Layout Direction
![Left To Right Layout Direction](Demo/LTR.gif "Left To Right Layout Direction") 

### Right To Left Layout Direction
![Right To Left Layout Direction](Demo/RTL.gif "Right To Left Layout Direction") 

## How to use
````Objective-C
// create
self.menuView = [[XZMenuView alloc] initWithFrame:frame];
self.menuView.delegate = self;
self.menuView.dataSource = self;
self.menuView.indicatorStyle = XZMenuViewIndicatorStyleDefault;
self.menuView.indicatorPosition = XZMenuViewIndicatorPositionBottom;
self.menuView.indicatorColor = [UIColor orangeColor];
[self.view addSubview:self.menuView];
    
// dataSource
- (NSInteger)numberOfItemsInMenuView:(XZMenuView *)meunView {
  return self.menuItems.count;
}

- (UIView *)menuView:(XZMenuView *)menuView viewForItemAtIndex:(NSInteger)index reusingView:(__kindof UIView *)reusingView {
    XZTextMenuItemView *menuItemView = (XZTextMenuItemView *)reusingView;
    if (menuItemView == nil) {
        menuItemView = [[XZTextMenuItemView alloc] initWithTransitionOptions:XZTextMenuItemViewTransitionOptionScale | XZTextMenuItemViewTransitionOptionColor];
        [menuItemView setTextColor:[UIColor darkTextColor] forState:(UIControlStateNormal)];
        [menuItemView setTextColor:[UIColor orangeColor] forState:(UIControlStateSelected)];
    }
    
    NSString *menuItem = [self menuItems][index];
    menuItemView.textLabel.text = menuItem;
    
    return menuItemView;
}
````

## Customlize menu item view
````Objective-C
// `XZTextMenuItemView` is an example for pure text menu. You can use it directly or subclassing of it.
// The setter of property `transition` will receive the transition value when the view needs show a transition appearance.
- (void)setTransition:(CGFloat)transition {
    if (_transition != transition) {
        _transition = transition;
        CALayer *contentLayer = XZTextMenuItemViewContentLayer(self, NO);
        CAAnimation *animation = [contentLayer animationForKey:XZTextMenuItemViewAnimationKey];
        contentLayer.timeOffset = animation.beginTime + transition;
    }
}
````

## Transiting animation.
````Objective-C
// if you use the `UIPageViewController` you may just do like this.
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
    [self.menuView beginTransition:[self viewControllerAtPage:self.menuView.selectedIndex].view]; // transition beigins
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<ContentViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    [self.menuView endTransition]; // transition ended.
    if (finished && completed) {
        NSInteger currentPage = [self pageOfViewController:pageViewController.viewControllers.lastObject];
        [self.menuView setSelectedIndex:currentPage animated:YES];
    }
}
````
