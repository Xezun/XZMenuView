//
//  TestLayout.m
//  XZMenuView
//
//  Created by mlibai on 2016/11/25.
//  Copyright © 2016年 mlibai. All rights reserved.
//

#import "TestLayout.h"

@implementation TestLayout

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *layoutAttributesArrayM = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    
    NSMutableIndexSet *visiableSections = [NSMutableIndexSet indexSet];
    for (NSUInteger idx=0; idx<[layoutAttributesArrayM count]; idx++) {
        UICollectionViewLayoutAttributes *layoutAttributes = layoutAttributesArrayM[idx];
        
        if (layoutAttributes.representedElementCategory == UICollectionElementCategoryCell) {
            [visiableSections addIndex:layoutAttributes.indexPath.section];  // remember that we need to layout header for this section
        }
        if ([layoutAttributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
            [layoutAttributesArrayM removeObjectAtIndex:idx];  // remove layout of header done by our super, we will do it right later
            idx--;
        }
    }
    
    // layout all headers needed for the rect using self code
    [visiableSections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:idx];
        UICollectionViewLayoutAttributes *layoutAttributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath];
        if (layoutAttributes != nil) {
            [layoutAttributesArrayM addObject:layoutAttributes];
        }
    }];
    
    return layoutAttributesArrayM;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [super layoutAttributesForSupplementaryViewOfKind:kind atIndexPath:indexPath];
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionView * const cv = self.collectionView;
        CGPoint const contentOffset = cv.contentOffset;
        CGPoint nextHeaderOrigin = CGPointMake(INFINITY, INFINITY);
        
        if (indexPath.section+1 < [cv numberOfSections]) {
            UICollectionViewLayoutAttributes *nextHeaderAttributes = [super layoutAttributesForSupplementaryViewOfKind:kind atIndexPath:[NSIndexPath indexPathForItem:0 inSection:indexPath.section+1]];
            nextHeaderOrigin = nextHeaderAttributes.frame.origin;
        }
        
        CGRect frame = attributes.frame;
        if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
            frame.origin.y = MIN(MAX(contentOffset.y, frame.origin.y), nextHeaderOrigin.y - CGRectGetHeight(frame));
        }
        else { // UICollectionViewScrollDirectionHorizontal
            frame.origin.x = MIN(MAX(contentOffset.x, frame.origin.x), nextHeaderOrigin.x - CGRectGetWidth(frame));
        }
        attributes.zIndex = 1024;
        attributes.frame = frame;
    }
    return attributes;
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForSupplementaryViewOfKind:kind atIndexPath:indexPath];
    return attributes;
}
- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForSupplementaryViewOfKind:kind atIndexPath:indexPath];
    return attributes;
}


- (BOOL) shouldInvalidateLayoutForBoundsChange:(CGRect)newBound {
    return YES;
}
//
//- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
//    return YES;
//}
//
//- (CGSize)collectionViewContentSize {
//    return [super collectionViewContentSize];
//}
//
//- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
//    NSMutableArray *arrayM = [NSMutableArray arrayWithArray:[super layoutAttributesForElementsInRect:rect]];
//    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
//    [arrayM addObject:[self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath]];
//    [arrayM addObject:[self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter atIndexPath:indexPath]];
//    return arrayM;
//}
//
//- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
//    UICollectionViewLayoutAttributes *layoutAttributes = [super layoutAttributesForSupplementaryViewOfKind:elementKind atIndexPath:indexPath];
//    CGRect frame = layoutAttributes.frame;
//    CGPoint contentOffset = self.collectionView.contentOffset;
//    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
//        frame.origin = contentOffset;
//    } else {
//        contentOffset.y += CGRectGetHeight(self.collectionView.bounds);
//        frame.origin = contentOffset;
//    }
//    layoutAttributes.zIndex = 1;
//    return layoutAttributes;
//}

//- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
//    UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForSupplementaryViewOfKind:kind atIndexPath:indexPath];
//    return attributes;
//}
//- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
//    UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForSupplementaryViewOfKind:kind atIndexPath:indexPath];
//    return attributes;
//}

@end
