//
//  PDMenuItemView.h
//  Daily
//
//  Created by mlibai on 2016/10/20.
//  Copyright © 2016年 People's Daily Online. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDBorderedView.h"

@interface PDMenuItemView : PDBorderedView

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

//@property (nonatomic, weak, readonly) UIView *seperatorLineView;

@property (nonatomic, strong) UIColor *normalColor;
@property (nonatomic, strong) UIColor *selectedColor;

@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIFont *subtitleFont;

@property (nonatomic, getter=isSelected) BOOL selected;

@property (nonatomic) CGFloat transition;

@end
