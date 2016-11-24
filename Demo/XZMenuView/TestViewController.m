//
//  TestViewController.m
//  XZMenuView
//
//  Created by mlibai on 2016/11/23.
//  Copyright © 2016年 mlibai. All rights reserved.
//

#import "TestViewController.h"
#import "XZTextMenuItemView.h"

@interface TestViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>


@property (strong, nonatomic) XZTextMenuItemView *textItemView;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

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
    
//    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
//    layout.itemSize = CGSizeMake(60, 40);
//    layout.minimumLineSpacing = 0;
//    layout.minimumInteritemSpacing = 0;
//    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
//    UICollectionView *view = [[UICollectionView alloc] initWithFrame:self.collectionView.frame collectionViewLayout:layout];
//    view.delegate = self;
//    view.dataSource = self;
//    
//    view.backgroundColor = [UIColor whiteColor];
//    [self.view addSubview:view];
//    [self.collectionView removeFromSuperview];
//    self.collectionView = view;
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view_cachedItemFrames	__NSDictionaryM *	0 key/value pairs	0x00006000000496f0 controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)valueChanged:(UISlider *)sender {
    self.textItemView.transition = sender.value;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 20;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    UILabel *label = [[cell contentView] viewWithTag:100];
    if (label == nil) {
        label = [[UILabel alloc] initWithFrame:cell.contentView.bounds];
        label.tag = 100;
        [cell.contentView addSubview:label];
    }
    [label setText:[NSString stringWithFormat:@"%ld", indexPath.item]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(50 + arc4random() % 50, collectionView.frame.size.height);
}

@end
