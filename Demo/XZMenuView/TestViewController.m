//
//  TestViewController.m
//  XZMenuView
//
//  Created by mlibai on 2016/11/23.
//  Copyright © 2016年 mlibai. All rights reserved.
//

#import "TestViewController.h"
#import "XZTextMenuItemView.h"

@interface TestViewController ()


@property (strong, nonatomic) XZTextMenuItemView *textItemView;
@property (weak, nonatomic) IBOutlet UISlider *slider;

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.textItemView = [[XZTextMenuItemView alloc] initWithFrame:CGRectMake(0, 100, CGRectGetWidth(self.view.bounds), 40) transitionOptions:(XZTextMenuItemViewTransitionOptionColor | XZTextMenuItemViewTransitionOptionScale)];
    [self.textItemView setTextColor:[UIColor greenColor] forState:(UIControlStateNormal)];
    [self.textItemView setTextColor:[UIColor orangeColor] forState:(UIControlStateSelected)];
    [self.view addSubview:self.textItemView];
    self.textItemView.textLabel.text = @"XZTextMenuItemView";
    self.textItemView.transition = 1.0;
    self.slider.value = 1.0;
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
- (IBAction)valueChanged:(UISlider *)sender {
    self.textItemView.transition = sender.value;
}

@end
