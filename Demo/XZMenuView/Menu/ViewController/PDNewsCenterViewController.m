//
//  PDNewsCenterViewController.m
//  Daily
//
//  Created by mlibai on 2016/10/18.
//  Copyright © 2016年 People's Daily Online. All rights reserved.
//

#import "PDNewsCenterViewController.h"
//#import "PDHeaders.h"

// Models
//#import "PDApiManager.h"
//#import "PDApiRequest.h"
//#import "PDApiResponse.h"
#import "PDNewsCenterMenuItem.h"

// Views
#import "PDMenuView.h"
#import "PDMenuItemView.h"

// View Controllers
#import "PDNewsListViewController.h"


@interface PDNewsCenterViewController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource, PDMenuViewDelegate, PDMenuViewDataSource>

@property (nonatomic, strong) PDMenuView *menuView;
@property (nonatomic, strong) UIButton *menuEditButton;

@property (nonatomic, strong) NSArray<PDNewsCenterMenuItem *> *menuItems;

@property (nonatomic, strong) UIPageViewController *pageViewController;

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, PDNewsListViewController *> *viewControllers;

@property (nonatomic, strong) CADisplayLink *displayLink;

@end

@implementation PDNewsCenterViewController

- (void)dealloc {
    [_displayLink invalidate];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray<NSDictionary *> *json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"menu" ofType:@"json"]] options:(NSJSONReadingAllowFragments) error:NULL];
    NSMutableArray *arrayM = [[NSMutableArray alloc] initWithCapacity:json.count];
    [json enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PDNewsCenterMenuItem *item = [[PDNewsCenterMenuItem alloc] init];
        [item setValuesForKeysWithDictionary:obj];
        [arrayM addObject:item];
    }];
    self.menuItems = arrayM;
    
    self.menuView.delegate = self;
    self.menuView.dataSource = self;
    self.navigationItem.titleView = self.menuView;
    [self.menuEditButton addTarget:self action:@selector(editMenuButtonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    self.menuView.rightView = self.menuEditButton;
    
    self.pageViewController.delegate = self;
    self.pageViewController.dataSource = self;
    [self addChildViewController:self.pageViewController];
    self.pageViewController.view.frame = self.view.bounds;
    [self.view addSubview:self.pageViewController.view];
    
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    self.displayLink.paused = YES;
    
    [self.menuView reloadData:^(BOOL finished) {
        [self.menuView setSelectedIndex:0 animated:YES];
        [self.pageViewController setViewControllers:@[[self viewControllerAtPage:0]] direction:(UIPageViewControllerNavigationDirectionReverse) animated:NO completion:nil];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - <PPDMenuViewDataSource>

- (NSInteger)numberOfItemsInMenuView:(PDMenuView *)meunView {
    return self.menuItems.count;
}

- (UIView<PDMenuItemView> *)menuView:(PDMenuView *)menuView viewForItemAtIndex:(NSInteger)index reusingView:(UIView<PDMenuItemView> *)reusingView {
    PDMenuItemView *menuItemView = (PDMenuItemView *)reusingView;
    if (menuItemView == nil) {
        menuItemView = [[PDMenuItemView alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    }
    
    PDNewsCenterMenuItem *menuItem = [self menuItems][index];
    menuItemView.title = menuItem.alias_name;
    menuItemView.subtitle = menuItem.name;
    
    return (UIView<PDMenuItemView> *)menuItemView;
}

#pragma mark - <UIPageViewControllerDataSource>

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSInteger index = [self pageOfViewController:viewController];
    
    return [self viewControllerAtPage:(index - 1)];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSInteger index = [self pageOfViewController:viewController];
    
    return [self viewControllerAtPage:(index + 1)];
}

#pragma mark - PPDMenuViewDelegate

- (void)menuView:(PDMenuView *)menuView didSelectItemAtIndex:(NSInteger)index {
    NSInteger oldIndex = [self pageOfViewController:self.pageViewController.viewControllers.firstObject];
    UIViewController *vc = [self viewControllerAtPage:index];
    UIPageViewControllerNavigationDirection direction = (oldIndex < index ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse);
    [self.pageViewController setViewControllers:@[vc] direction:(direction) animated:YES completion:NULL];
}

#pragma mark - <UIPageViewControllerDelegate>

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
    self.displayLink.paused = NO;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<PDNewsListViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    self.displayLink.paused = finished;
    if (finished && completed) {
        NSInteger currentPage = [self pageOfViewController:pageViewController.viewControllers.lastObject];
        [self.menuView setSelectedIndex:currentPage animated:YES];
    }
}

#pragma mark - actions

- (void)editMenuButtonAction:(UIButton *)button {
    
}

- (void)showMenuTransitionAnimation:(CADisplayLink *)displayLink {
    NSInteger currentIndex = self.menuView.selectedIndex;
    UIView *view = [self viewControllerAtPage:currentIndex].view;
    CGRect rect = [view convertRect:view.bounds toView:view.window];
    CGFloat progress = CGRectGetMinX(rect) / CGRectGetWidth(rect);
    
    NSLocaleLanguageDirection lineDirection = [NSLocale characterDirectionForLanguage:[[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode]];
    if (lineDirection == kCFLocaleLanguageDirectionLeftToRight) {
        if (progress > 0) {
            [self.menuView setTransition:progress toIndex:currentIndex - 1];
        } else {
            [self.menuView setTransition:-progress toIndex:currentIndex + 1];
        }
    } else {
        if (progress < 0) {
            [self.menuView setTransition:-progress toIndex:currentIndex - 1];
        } else {
            [self.menuView setTransition:progress toIndex:currentIndex + 1];
        }
    }
}

#pragma mark - custom method

- (UIViewController *)viewControllerAtPage:(NSUInteger)page {
    if (page < self.menuItems.count) {
        NSNumber *key = [NSNumber numberWithUnsignedInteger:page];
        UIViewController *vc = self.viewControllers[key];
        if (vc == nil) {
            PDNewsListViewController *newsVC = [[PDNewsListViewController alloc] init];
            newsVC.identifier = _menuItems[page].category_id;
            self.viewControllers[key] = newsVC;
            vc = newsVC;
        }
        return vc;
    }
    return nil;
}

- (NSUInteger)pageOfViewController:(UIViewController *)viewController {
    NSNumber *key = [_viewControllers allKeysForObject:(PDNewsListViewController *)viewController].firstObject;
    if (key != nil) {
        return [key unsignedIntegerValue];
    }
    return NSNotFound;
}

#pragma mark - setters & getters

- (UIPageViewController *)pageViewController {
    if (_pageViewController != nil) {
        return _pageViewController;
    }
    _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:(UIPageViewControllerTransitionStyleScroll) navigationOrientation:(UIPageViewControllerNavigationOrientationHorizontal) options:nil];
    return _pageViewController;
}

- (PDMenuView *)menuView {
    if (_menuView != nil) {
        return _menuView;
    }
    CGRect frame = [UIScreen mainScreen].bounds;
    frame.size.height = 44.0;
    _menuView = [[PDMenuView alloc] initWithFrame:frame];
    return _menuView;
}

//- (PDApiManager *)menuApiManager {
//    if (_menuApiManager != nil) {
//        return _menuApiManager;
//    }
//    _menuApiManager = [PDApiManager apiManagerWithType:(PDApiManagerTypeNewsCenterMenu)];
//    return _menuApiManager;
//}

- (UIButton *)menuEditButton {
    if (_menuEditButton != nil) {
        return _menuEditButton;
    }
    _menuEditButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 46, 35)];
    _menuEditButton.adjustsImageWhenHighlighted = NO;
    [_menuEditButton setImageEdgeInsets:UIEdgeInsetsMake(0, 6, 0, -6)];
    return _menuEditButton;
}

- (NSMutableDictionary<NSNumber *,PDNewsListViewController *> *)viewControllers {
    if (_viewControllers != nil) {
        return _viewControllers;
    }
    _viewControllers = [[NSMutableDictionary alloc] init];
    return _viewControllers;
}

- (CADisplayLink *)displayLink {
    if (_displayLink != nil) {
        return _displayLink;
    }
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(showMenuTransitionAnimation:)];
    if ([UIDevice currentDevice].systemVersion.floatValue < 10.0) {
        _displayLink.frameInterval = 1.0 / 30.0;
    } else {
        _displayLink.preferredFramesPerSecond = 30;
    }
    return _displayLink;
}

@end
