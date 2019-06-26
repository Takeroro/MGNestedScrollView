//
//  ViewController.m
//  MGNestedScrollViewDemo
//
//  Created by Caotingjun on 2019/6/26.
//  Copyright © 2019 yy. All rights reserved.
//

#import "ViewController.h"
#import "MGNestedScrollView.h"
#import "TableViewController.h"


@interface ViewController ()<MGNestedScrollViewDataSource, MGNestedScrollViewDelegate>

@property (nonatomic, strong) MGNestedScrollView *nestedScrollView;
@property (nonatomic, strong) NSMutableArray<UIViewController<ICatogeryView> *> *categories;//分类页
@property (nonatomic, assign) UISegmentedControl *segmentView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.categories = [NSMutableArray new];
    for (int i = 0; i < 3; i++) {
        TableViewController *vc = [TableViewController new];
        [self.categories addObject:vc];
    }
    
    [self.nestedScrollView reloadData];
}

- (void)viewDidLayoutSubviews {
    self.nestedScrollView.frame = self.view.bounds;
}

#pragma mark - MGNestedScrollViewDataSource, MGNestedScrollViewDelegate

- (UIView *)headerInNestedScrollView:(MGNestedScrollView *)nsScrollView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 100)];
    view.backgroundColor = [UIColor yellowColor];
    
    UISegmentedControl *segmentView = [[UISegmentedControl alloc] initWithItems:@[@"1",@"2",@"3"]];
    segmentView.frame = CGRectMake(0, 50, self.view.bounds.size.width, 50);
    segmentView.selectedSegmentIndex = 0;
    [segmentView addTarget:self action:@selector(segmentViewDidSelect:) forControlEvents:UIControlEventValueChanged];
    [view addSubview:segmentView];
    
    self.segmentView = segmentView;
    return view;
}

- (void)segmentViewDidSelect:(UISegmentedControl *)segmentView {
    NSInteger selectedIndx = segmentView.selectedSegmentIndex;
    [self.nestedScrollView scrollToIndex:selectedIndx animate:YES];
}

- (CGFloat)headerExpandedHeightForNestedScrollView:(MGNestedScrollView *)nsScrollView {
    return 100;
}

- (CGFloat)headerShrinkedHeightForNestedScrollView:(MGNestedScrollView *)nsScrollView {
    return 50;
}

- (NSUInteger)numberOfCategoryInNestedScrollView:(MGNestedScrollView *)nsScrollView {
    return self.categories.count;
}

- (UIView *)nestedScrollView:(MGNestedScrollView *)nsScrollView
              contentAtIndex:(NSUInteger)index
                  scrollView:( UIScrollView * _Nullable *_Nullable)scrollView {
    UIViewController<ICatogeryView> *vc = [self.categories objectAtIndex:index];
    UIScrollView *contentScroll = [vc content];
    
    if (@available(iOS 11.0, *)) {
        contentScroll.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        vc.automaticallyAdjustsScrollViewInsets = NO;
    }
    UIView *ret = [vc view];
    *scrollView = contentScroll;
    return ret;
}

- (void)nestedScrollView:(MGNestedScrollView *)templateview didScrollToIndex:(NSUInteger)index animated:(BOOL)animated {
    self.segmentView.selectedSegmentIndex = index;
}

#pragma mark - getter
- (MGNestedScrollView *)nestedScrollView {
    if (!_nestedScrollView) {
        self.nestedScrollView = [[MGNestedScrollView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:self.nestedScrollView];

        self.nestedScrollView.delegate = self;
        self.nestedScrollView.dataSource = self;
    }
    return _nestedScrollView;
}
@end
