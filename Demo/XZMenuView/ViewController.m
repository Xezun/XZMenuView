//
//  ViewController.m
//  XZMenuView
//
//  Created by mlibai on 2016/11/23.
//  Copyright © 2016年 mlibai. All rights reserved.
//

#import "ViewController.h"
#import "ContentViewController.h"

#import "XZMenuView.h"
#import "XZTextMenuItemView.h"

@interface ViewController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource, XZMenuViewDelegate, XZMenuViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *menuViewWrapper;
@property (weak, nonatomic) UIPageViewController *pageViewController;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, ContentViewController *> *viewControllers;

@property (nonatomic, strong) NSArray<NSString *> *menuItems;

@property (nonatomic, strong) XZMenuView *menuView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.menuItems = @[@"新闻联播", @"焦点访谈", @"生活圈梦想星搭档", @"人口", @"了不起的挑战", @"客从何处来", @"中国味道", @"我爱妈妈", @"挑战不可能", @"出彩中国人", @"等着我", @"舞出我人生", @"吉尼斯中国之夜", @"今日说法", @"人与自然", @"撒贝宁时间", @"喜乐街"];
    CGRect frame = self.menuViewWrapper.frame;
    frame.size.height -= 5.0;
    self.menuView = [[XZMenuView alloc] initWithFrame:frame];
    self.menuView.delegate = self;
    self.menuView.dataSource = self;
    self.menuView.indicatorStyle = XZMenuViewIndicatorStyleDefault;
    self.menuView.indicatorPosition = XZMenuViewIndicatorPositionBottom;
    self.menuView.indicatorColor = [UIColor orangeColor];
    [self.view addSubview:self.menuView];
    
    UIPageViewControllerNavigationDirection d = UIPageViewControllerNavigationDirectionForward;
    if ([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft) {
        d = UIPageViewControllerNavigationDirectionReverse;
    }
    [self.pageViewController setViewControllers:@[[self viewControllerAtPage:0]] direction:d animated:NO completion:nil];
    [self.menuView setSelectedIndex:0 animated:NO];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    if ([segue.identifier isEqualToString:@"UIPageViewController"]) {
        self.pageViewController = segue.destinationViewController;
        self.pageViewController.delegate = self;
        self.pageViewController.dataSource = self;
        
    }
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSInteger index = [self pageOfViewController:viewController];
    
    return [self viewControllerAtPage:(index - 1)];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSInteger index = [self pageOfViewController:viewController];
    
    return [self viewControllerAtPage:(index + 1)];
}

#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
    [self.menuView beginTransition:[self viewControllerAtPage:self.menuView.selectedIndex].view];
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<ContentViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    [self.menuView endTransition];
    if (finished && completed) {
        NSInteger currentPage = [self pageOfViewController:pageViewController.viewControllers.lastObject];
        [self.menuView setSelectedIndex:currentPage animated:YES];
    }
}

#pragma mark - XZMenuViewDataSource

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

#pragma mark - XZMenuViewDelegate

- (void)menuView:(XZMenuView *)menuView didSelectItemAtIndex:(NSInteger)index {
    NSInteger oldIndex = [self pageOfViewController:self.pageViewController.viewControllers.firstObject];
    UIViewController *vc = [self viewControllerAtPage:index];
    
    UIPageViewControllerNavigationDirection direction = (oldIndex < index ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse);
    if ([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft) {
        direction = (direction == UIPageViewControllerNavigationDirectionReverse ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse);
    }
    [self.pageViewController setViewControllers:@[vc] direction:(direction) animated:YES completion:NULL];
}

- (CGFloat)menuView:(XZMenuView *)menuView widthForItemAtIndex:(NSInteger)index {
    NSString *menuItem = [self menuItems][index];
    return menuItem.length * 17.0 + 20.0;
}

#pragma mark - custom method

- (UIViewController *)viewControllerAtPage:(NSUInteger)page {
    if (page < self.menuItems.count) {
        NSNumber *key = [NSNumber numberWithUnsignedInteger:page];
        UIViewController *vc = self.viewControllers[key];
        if (vc == nil) {
            ContentViewController *tmpVC = [[ContentViewController alloc] init];
            self.viewControllers[key] = tmpVC;
            vc = tmpVC;
        }
        return vc;
    }
    return nil;
}

- (NSUInteger)pageOfViewController:(UIViewController *)viewController {
    NSNumber *key = [_viewControllers allKeysForObject:(ContentViewController *)viewController].firstObject;
    if (key != nil) {
        return [key unsignedIntegerValue];
    }
    return NSNotFound;
}



- (NSMutableDictionary<NSNumber *, ContentViewController *> *)viewControllers {
    if (_viewControllers != nil) {
        return _viewControllers;
    }
    _viewControllers = [[NSMutableDictionary alloc] init];
    return _viewControllers;
}

@end
