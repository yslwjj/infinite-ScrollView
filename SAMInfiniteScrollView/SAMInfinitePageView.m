//
//  SAMInfiniteScrollView.m
//  ScrollView定时滚动完美版
//
//  Created by 杨森 on 15/5/31.
//  Copyright (c) 2015年 samyang. All rights reserved.
//

#import "SAMInfinitePageView.h"

static int const ImageViewCount = 3;

@interface SAMInfinitePageView ()<UIScrollViewDelegate>

/** ScrollView */
@property (nonatomic, weak) UIScrollView *scrollView;
/** 定时计 */
@property (nonatomic, weak) NSTimer *time;

@end

@implementation SAMInfinitePageView

#pragma mark- 快速构造方法
+(instancetype)pageView{
    SAMInfinitePageView *pageView = [[self alloc] initWithFrame:CGRectZero];
    return pageView;
}

+ (instancetype)pageViewWithFrame:(CGRect)frame{
    SAMInfinitePageView *pageView = [[self alloc] initWithFrame:frame];
    return pageView;
}

#pragma mark 初始化
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        /** 横向滚动条禁止 */
        scrollView.showsHorizontalScrollIndicator = NO;
        /** 竖向滚动条禁止 */
        scrollView.showsVerticalScrollIndicator = NO;
        /** 分页 */
        scrollView.pagingEnabled = YES;
        /** 关闭弹簧效果 */
        scrollView.bounces = NO;
        scrollView.delegate = self;
        [self addSubview:scrollView];
        self.scrollView = scrollView;
        
        /**
         *  imageView控件，因为要做到视图重复利用，所以图片View只创建三个
         */
        for (int i = 0; i < ImageViewCount; i++) {
            UIImageView *imageView = [[UIImageView alloc] init];
            
            [scrollView addSubview:imageView];
        }
        
        /**
         *  页码视图
         */
        UIPageControl *pageControl = [[UIPageControl alloc] init];
        [self addSubview:pageControl];
        _pageControl = pageControl;
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    /**
     *  设置scrollView的frame,contentsize,contentoffset
     */
    self.scrollView.frame = self.bounds;
    if (self.isScrollDirectionPortrait) {
        self.scrollView.contentSize = CGSizeMake(0 , ImageViewCount * self.bounds.size.height);
        self.scrollView.contentOffset = CGPointMake(0, self.bounds.size.height);
        self.pageControl.currentPage = 0;
    }else{
        self.scrollView.contentSize = CGSizeMake(ImageViewCount * self.bounds.size.width, 0);
        self.scrollView.contentOffset = CGPointMake(self.bounds.size.width, 0);
        self.pageControl.currentPage = 0;
    }
    
    /**
     *  设置滚动视图上面的图片视图位置
     */
    for (int i = 0; i < ImageViewCount; i++) {
        UIImageView *imageView = self.scrollView.subviews[i];
        if (self.isScrollDirectionPortrait) {
            imageView.frame =CGRectMake(0, i *self.scrollView.frame.size.height,
              self.scrollView.frame.size.width, self.scrollView.frame.size.height);
        } else {
            imageView.frame = CGRectMake(i *self.scrollView.frame.size.width,0,
             self.scrollView.frame.size.width, self.scrollView.frame.size.height);
        }
    }
    
    /**
     *  设置pageControl位置
     */
    CGFloat pageW = 80;
    CGFloat pageH = 20;
    CGFloat pageX = self.scrollView.frame.size.width - pageW;
    CGFloat pageY = self.scrollView.frame.size.height - pageH;
    self.pageControl.frame = CGRectMake(pageX, pageY, pageW,pageH);

}

- (void)setImageNames:(NSArray *)imageNames{
    _imageNames = imageNames;
    
    /** 设置页码 */
    self.pageControl.numberOfPages = imageNames.count;
    self.pageControl.currentPage = 0;
    
    //设置内容
    [self updateContent];
    
    /** 开始定时器 */
    [self startTimer];
}

#pragma mark - 内容更新
- (void)updateContent{
    /** 设置图片 */
    for (int i = 0; i < self.scrollView.subviews.count; i++) {
        /** 获取子视图 */
        UIImageView *imageView = self.scrollView.subviews[i];
        /** 获取当前页 */
        NSInteger index = self.pageControl.currentPage;
        if (i == 0) {
            /** 设置前一页的视图 */
            index--;
        }else if (i == 2){
            /** 设置后一页的视图 */
            index++;
        }
        
        if (index < 0){
            /** 定位到下次显示 */
            index = self.pageControl.numberOfPages - 1;
        }else if(index >= self.pageControl.numberOfPages) {
            index = 0;
        }
        /** 给视图添加tag标记 */
        imageView.tag = index;
        /** 给当前视图图片属性赋值 */
        imageView.image = [UIImage imageNamed:self.imageNames[index]];
    }
    
    //设置偏移量在中间，这样每次刷新左右都有视图
    if (self.isScrollDirectionPortrait) {
        self.scrollView.contentOffset = CGPointMake(0, self.scrollView.frame.size.height);
    }else {
        self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width, 0);
    }
}

#pragma mark - 开启定时器
- (void)startTimer{
    /** 设置定时器，ua */
    NSTimer *time = [NSTimer timerWithTimeInterval:2.0 target:self selector:
                     @selector(nextPage) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:time forMode:NSRunLoopCommonModes];
    self.time = time;
}

#pragma mark - 停止定时器
- (void)stopTimer
{
    [self.time invalidate];
    self.time = nil;
}

#pragma mark - 下一页
- (void)nextPage
{
    if (self.isScrollDirectionPortrait) {
        [self.scrollView setContentOffset:CGPointMake(0, 2 * self.scrollView.
                       frame.size.height) animated:YES];
    }else{
        [self.scrollView setContentOffset:CGPointMake(2 *self.scrollView.
                  frame.size.width, 0) animated:YES];
    }
}

#pragma mark - <UIScrollViewDelegate>
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger page = 0;
    CGFloat minDistan = MAXFLOAT;
    for (int i = 0 ; i < ImageViewCount; i++) {
        UIImageView *imageView = self.scrollView.subviews[i];
        CGFloat distance = 0;
        if (self.isScrollDirectionPortrait) {
            distance = ABS(imageView.frame.origin.y - scrollView.contentOffset.y);
        } else {
            distance = ABS(imageView.frame.origin.x - scrollView.contentOffset.x);
        }
        if (distance < minDistan) {
            minDistan = distance;
            page = imageView.tag;
        }
    }
    self.pageControl.currentPage = page;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self stopTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self startTimer];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self updateContent];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self updateContent];
}

@end































