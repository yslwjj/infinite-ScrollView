//
//  SAMInfiniteScrollView.h
//  ScrollView定时滚动完美版
//
//  Created by 杨森 on 15/5/31.
//  Copyright (c) 2015年 samyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SAMInfinitePageView : UIView

/** 所有滚动图片名字 */
@property (nonatomic, strong) NSArray *imageNames;

/** 分页 */
@property (nonatomic, weak, readonly) UIPageControl *pageControl;

/** 判断横竖滚动 */
@property (nonatomic, assign, getter=isScrollDirectionPortrait) BOOL
*scrollDirectionPortrait;

//快速构造方法
+(instancetype)pageViewWithFrame:(CGRect)frame;

+(instancetype)pageView;
@end
