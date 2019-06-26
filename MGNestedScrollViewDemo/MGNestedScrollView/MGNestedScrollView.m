//
//  MGNestScrollView.m
//  ZNovel
//
//  Created by Caotingjun on 2019/6/25.
//  Copyright © 2019 ZNovel. All rights reserved.
//

#import "MGNestedScrollView.h"

@interface MGNestedScrollView() <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *categoryContainer;//分类 scrollView, 是 scrollContainer 的 subView
@property (nonatomic, strong) UIView *header;
@property (nonatomic, assign) CGFloat expandedHeight;
@property (nonatomic, assign) CGFloat shrinkedHeight;

@property (nonatomic ,strong) NSMutableDictionary *kvoCtrlDict;
@property (nonatomic ,strong) NSMutableDictionary *contentDict;
@property (nonatomic ,strong) NSMutableDictionary *scrollViewDict;
@property (nonatomic ,strong) NSMutableDictionary *userInfoDict;
@end

@implementation MGNestedScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self doInits];
    }
    return self;
}

- (void)doInits
{
    self.kvoCtrlDict = [NSMutableDictionary dictionary];
    self.contentDict = [NSMutableDictionary dictionary];
    self.userInfoDict = [NSMutableDictionary dictionary];
    self.scrollViewDict = [NSMutableDictionary dictionary];
    
    self.categoryContainer = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.categoryContainer.pagingEnabled = YES;
    self.categoryContainer.delegate = self;
    self.categoryContainer.showsHorizontalScrollIndicator = NO;
    self.categoryContainer.showsVerticalScrollIndicator = NO;
    if (@available(iOS 11.0, *)) {
        self.categoryContainer.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        self.scrollContainer.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    
    self.scrollContainer = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.scrollContainer.delegate = self;
    
    [self addSubview:self.scrollContainer];
    [self.scrollContainer addSubview:self.categoryContainer];
}

- (void)dealloc {
    for (UIScrollView *scrollView in self.scrollViewDict.allValues) {
        [scrollView removeObserver:self forKeyPath:@"contentSize"];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self _reframe];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (scrollView == self.categoryContainer) {
        if (self.frame.size.width <= 0) {
            return;
        }
        NSInteger index = self.categoryContainer.contentOffset.x / self.frame.size.width;
        [self _didScrollToIndex:index animated:YES force:NO];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.categoryContainer) {
        if (self.frame.size.width <= 0) {
            return;
        }
        NSInteger index = self.categoryContainer.contentOffset.x / self.frame.size.width;
        [self _didScrollToIndex:index animated:YES force:NO];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint currentOffset = scrollView.contentOffset;
    
    UIScrollView *currentContent = [self _scrollViewOfContentAtIndex:self.selectedIndex];
    
    if (scrollView == self.categoryContainer) {
        if ([self.delegate respondsToSelector:@selector(nestedScrollView:categoryTemplateScrollViewDidScroll:)]) {
            [self.delegate nestedScrollView:self categoryTemplateScrollViewDidScroll:scrollView];
        }
    } else if (scrollView == self.scrollContainer) {
        [self setNeedsLayout];
        [self layoutIfNeeded];
        currentOffset.y -= (self.expandedHeight - self.shrinkedHeight);
        currentOffset.y = MAX(currentOffset.y, 0);
        [currentContent setContentOffset:currentOffset animated:NO];
    }
}

#pragma mark - Public
- (void)reloadData
{
    NSArray *indexes = [self.contentDict allKeys];
    for (NSNumber *index in indexes) {
        UIView *view = self.contentDict[index];
        NSDictionary *userInfo = self.userInfoDict[index];
        [view removeFromSuperview];
        if ([self.delegate respondsToSelector:@selector(nestedScrollView:didRemoveContentViewAtIndex:userInfo:)]) {
            [self.delegate nestedScrollView:self didRemoveContentViewAtIndex:index.integerValue userInfo:userInfo];
        }
    }
    
    [self.contentDict removeAllObjects];
    [self.scrollViewDict removeAllObjects];
    [self.kvoCtrlDict removeAllObjects];
    [self.userInfoDict removeAllObjects];
    
    [self _addHeaderView];
    
    [self scrollToIndex:self.selectedIndex animate:NO];
    
    [self _reframe];
}

- (void)scrollToIndex:(NSUInteger)index animate:(BOOL)animate
{
    CGFloat offset = CGRectGetWidth(self.frame) * index;
    [self.categoryContainer setContentOffset:CGPointMake(offset, 0) animated:animate];
    if (!animate) {
        [self _didScrollToIndex:index animated:animate force:YES];
    }
}

#pragma mark - Private
- (void)_didScrollToIndex:(NSUInteger)index animated:(BOOL)animated force:(BOOL)force
{
    if (self.selectedIndex != index || force) {
        [self _showContentAtIndex:index];
        self.selectedIndex = index;
        if ([self.delegate respondsToSelector:@selector(nestedScrollView:didScrollToIndex:animated:)]) {
            [self.delegate nestedScrollView:self didScrollToIndex:index animated:animated];
        }
    }
}

- (void)_reframe
{
    CGRect headerFrame = self.header.frame;
    headerFrame.size.height = self.expandedHeight;
    headerFrame.origin.y = MAX(0, self.scrollContainer.contentOffset.y - (self.expandedHeight - self.shrinkedHeight));
    self.header.frame = headerFrame;
    CGRect frame = self.categoryContainer.bounds;
    //不断更改 categoryContainer 的 origin.y
    frame.origin.x = 0;
    frame.origin.y = CGRectGetMaxY(headerFrame);
    self.categoryContainer.frame = frame;
    self.categoryContainer.contentSize = CGSizeMake(CGRectGetWidth(self.bounds)* [self.dataSource numberOfCategoryInNestedScrollView:self], CGRectGetHeight(frame));
    NSArray *indexes = [self.contentDict allKeys];
    
    for (NSNumber *index in indexes) {
        UIView *view = self.contentDict[index];
        CGRect aFrame = view.frame;
        aFrame.origin = CGPointMake([index integerValue] * frame.size.width, 0);
        aFrame.size = frame.size;
        view.frame = aFrame;
    }
}

- (void)_addHeaderView
{
    if (![self.header isDescendantOfView:self]) {
        [self.scrollContainer addSubview:self.header];
    }
    
    CGRect frame = self.header.frame;
    frame.size.width = CGRectGetWidth(self.bounds);
    self.header.frame = frame;
}

- (void)_showContentAtIndex:(NSInteger)index
{
    CGRect frame = CGRectMake(index*CGRectGetWidth(self.frame), 0,  CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    
    UIView *content = [self dequeueContentViewAtIndex:index];
    content.frame = frame;
}

- (void)_setupKVOForScrollView:(UIScrollView *)scrollView
{
    if (scrollView && ![self.kvoCtrlDict objectForKey:@(scrollView.hash)]) {
        [scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
        [self.kvoCtrlDict setObject:scrollView forKey:@(scrollView.hash)];
    }
}

- (UIScrollView *)_scrollViewOfContentAtIndex:(NSInteger)index
{
    return self.scrollViewDict[@(index)];
}

- (UIView *)dequeueContentViewAtIndex:(NSInteger)index
{
    UIView *content = self.contentDict[@(index)];
    if (index >=0 && index < [self.dataSource numberOfCategoryInNestedScrollView:self]) {
        
        UIScrollView *scrollView = nil;
        content = [self.dataSource nestedScrollView:self contentAtIndex:index scrollView:&scrollView];
        if (![content isDescendantOfView:self.categoryContainer] && content.superview != self.categoryContainer) {
            
            [self.categoryContainer addSubview:content];
            
            scrollView.scrollEnabled = false;
            
            if ([self.delegate respondsToSelector:@selector(nestedScrollView:didShowContentViewAtIndex:userInfo:)]) {
                NSDictionary *userInfo = nil;
                [self.delegate nestedScrollView:self didShowContentViewAtIndex:index userInfo:&userInfo];
                self.userInfoDict[@(index)] = userInfo;
            }
        }
        
        self.contentDict[@(index)] = content;
        self.scrollViewDict[@(index)] = scrollView;
        [self _setupKVOForScrollView:scrollView];
    }
    return content;
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentSize"]) {
        NSValue *newValue = [change objectForKey:NSKeyValueChangeNewKey];
        if (object == [self _scrollViewOfContentAtIndex:self.selectedIndex]) {
            CGFloat contentHeight = self.expandedHeight + [newValue CGSizeValue].height + self.shrinkedHeight;
            contentHeight = MAX(self.bounds.size.height + self.expandedHeight - self.shrinkedHeight, contentHeight);
            self.scrollContainer.contentSize = CGSizeMake(self.bounds.size.width, contentHeight);
        }
    }
}

#pragma mark - Getter
- (UIView *)header {
    if (!_header && [self.dataSource respondsToSelector:@selector(headerInNestedScrollView:)]) {
        _header = [self.dataSource headerInNestedScrollView:self];
    }
    return _header;
}

- (CGFloat)expandedHeight {
    if ([self.dataSource respondsToSelector:@selector(headerExpandedHeightForNestedScrollView:)]) {
        _expandedHeight = [self.dataSource headerExpandedHeightForNestedScrollView:self];
    }
    return _expandedHeight;
}

- (CGFloat)shrinkedHeight {
    if ([self.dataSource respondsToSelector:@selector(headerShrinkedHeightForNestedScrollView:)]) {
        _shrinkedHeight = [self.dataSource headerShrinkedHeightForNestedScrollView:self];
    }
    return _shrinkedHeight;
}

@end
