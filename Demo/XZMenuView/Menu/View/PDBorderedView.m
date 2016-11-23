//
//  PDBorderedView.m
//  Daily
//
//  Created by mlibai on 2016/11/15.
//  Copyright © 2016年 People's Daily Online. All rights reserved.
//

#import "PDBorderedView.h"

@implementation PDBorderedView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGRect r = self.bounds;
    r.size.width -= self.borderWidth;
    r.size.height -= self.borderWidth;
    r.origin.x += self.borderWidth * 0.5;
    r.origin.y += self.borderWidth * 0.5;
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:r cornerRadius:self.cornerRadius];
    path.lineWidth = self.borderWidth;
    [self.borderColor setStroke];
    [path stroke];
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    if (_borderWidth != borderWidth) {
        _borderWidth = MAX(borderWidth, 0);
        [self setNeedsDisplay];
    }
}

- (void)setBorderColor:(UIColor *)borderColor {
    if (_borderColor != borderColor) {
        _borderColor = borderColor;
        [self setNeedsDisplay];
    }
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    if (_cornerRadius != cornerRadius) {
        _cornerRadius = MAX(0, cornerRadius);
        [self setNeedsDisplay];
    }
}

@end
