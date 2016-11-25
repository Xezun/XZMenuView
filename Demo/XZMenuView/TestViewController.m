//
//  TestViewController.m
//  XZMenuView
//
//  Created by mlibai on 2016/11/23.
//  Copyright © 2016年 mlibai. All rights reserved.
//

#import "TestViewController.h"
#import "XZTextMenuItemView.h"
#import "TestLayout.h"

@interface TestViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) XZTextMenuItemView *textItemView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer"];
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
        CGRect bounds = cell.contentView.bounds;
        bounds.origin.x += 1;
        bounds.size.width -= 2;
        label = [[UILabel alloc] initWithFrame:bounds];
        label.tag = 100;
        label.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:label];
        label.backgroundColor = [UIColor purpleColor];
    }
    cell.contentView.backgroundColor = [UIColor blackColor];
    [label setText:[NSString stringWithFormat:@"%ld", indexPath.item]];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *view = nil;
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"header" forIndexPath:indexPath];
        view.backgroundColor = [UIColor redColor];
    } else {
        view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"footer" forIndexPath:indexPath];
        view.backgroundColor = [UIColor orangeColor];
    }
    return view;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(44.0, 44.0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(44.0, 44.0);
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    return CGSizeMake(50 + arc4random() % 50, collectionView.frame.size.height);
//}

@end
