//
//  ViewController.m
//  Demo
//
//  Created by mlibai on 2016/11/21.
//  Copyright © 2016年 mlibai. All rights reserved.
//

#import "ViewController.h"
#import "XZMenuView.h"
#import "XZTextMenuItemView.h"

@interface ViewController () <XZMenuViewDelegate, XZMenuViewDataSource, UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@property (nonatomic, strong) XZMenuView *menuView;

@property (nonatomic, strong) UIPageViewController *pageViewController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _menuView = [[XZMenuView alloc] initWithFrame:CGRectMake(10, 100, CGRectGetWidth([UIScreen mainScreen].bounds) - 20, 45.0)];
    [self.view addSubview:_menuView];
    _menuView.delegate = self;
    _menuView.dataSource = self;
    
    //_menuView.backgroundColor = [UIColor orangeColor];
    
    _pageViewController = [[UIPageViewController alloc] init];
}


- (NSInteger)numberOfItemsInMenuView:(XZMenuView *)meunView {
    return 20;
}

- (UIView<XZMenuItemView> *)menuView:(XZMenuView *)menuView viewForItemAtIndex:(NSInteger)index reusingView:(__kindof UIView<XZMenuItemView> *)reusingView {
    XZTextMenuItemView *textMenuItemView = reusingView;
    if (textMenuItemView == nil) {
        textMenuItemView = [[XZTextMenuItemView alloc] initWithFrame:CGRectMake(0, 0, 40, 45.0)];
        [textMenuItemView setTextColor:[UIColor orangeColor] forState:(UIControlStateSelected)];
        [textMenuItemView setTextColor:[UIColor brownColor] forState:(UIControlStateNormal)];
    }
    textMenuItemView.textLabel.text = [NSString stringWithFormat:@"%ld", (long)index];
    return textMenuItemView;
}

- (void)menuView:(XZMenuView *)menuView didSelectItemAtIndex:(NSInteger)index {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sliderValueChanged:(UISlider *)sender {
    
}

@end
