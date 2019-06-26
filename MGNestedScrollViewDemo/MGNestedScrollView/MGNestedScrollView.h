//
//  MGNestScrollView.h
//  ZNovel
//
//  Created by Caotingjun on 2019/6/25.
//  Copyright © 2019 ZNovel. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MGNestedScrollView;

@protocol MGNestedScrollViewDataSource <NSObject>

@required

- (UIView *)headerInNestedScrollView:(MGNestedScrollView *)nsScrollView;

- (NSUInteger)numberOfCategoryInNestedScrollView:(MGNestedScrollView *)nsScrollView;

- (CGFloat)headerExpandedHeightForNestedScrollView:(MGNestedScrollView *)nsScrollView;

- (CGFloat)headerShrinkedHeightForNestedScrollView:(MGNestedScrollView *)nsScrollView;

@optional
- (UIView *)nestedScrollView:(MGNestedScrollView *)nsScrollView contentAtIndex:(NSUInteger)index scrollView:( UIScrollView * _Nullable *_Nullable)scrollView;
@end

@protocol MGNestedScrollViewDelegate <NSObject>

@optional
- (void)nestedScrollView:(MGNestedScrollView *)nsScrollView categoryTemplateScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)nestedScrollView:(MGNestedScrollView *)nsScrollView didShowContentViewAtIndex:(NSUInteger)index userInfo:(NSDictionary **)userInfo;
- (void)nestedScrollView:(MGNestedScrollView *)nsScrollView didRemoveContentViewAtIndex:(NSInteger)index userInfo:(NSDictionary *)userInfo;
- (void)nestedScrollView:(MGNestedScrollView *)templateview didScrollToIndex:(NSUInteger)index animated:(BOOL)animated;

@end

@interface MGNestedScrollView : UIView

@property (nonatomic ,weak) id <MGNestedScrollViewDataSource> dataSource;
@property (nonatomic ,weak) id <MGNestedScrollViewDelegate> delegate;
@property (nonatomic, strong) UIScrollView *scrollContainer;//最外层 scrollView

@property (nonatomic ,assign) NSInteger selectedIndex;


- (void)reloadData;

- (void)scrollToIndex:(NSUInteger)index animate:(BOOL)animate;

- (void)expandHeader;


@end

NS_ASSUME_NONNULL_END
