//
//  LiLInfineScrollview.h
//  InfiniteScrollview
//
//  Created by lilei on 2018/6/25.
//  Copyright © 2018年 lilei. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    LiLCycleScrollViewPageContolAlimentRight,
    LiLCycleScrollViewPageContolAlimentCenter
} LiLCycleScrollViewPageContolAliment;

typedef enum {
    LiLCycleScrollViewPageContolStyleClassic,        // 系统自带经典样式
    LiLCycleScrollViewPageContolStyleImage,          // 选中图片pagecontrol
} LiLCycleScrollViewPageContolStyle;

@class LiLCycleScrollView;

@protocol LiLCycleScrollviewDelegate<NSObject>
@optional
/** 点击图片回调 */
- (void)cycleScrollView:(LiLCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index;

/** 图片滚动回调 */
- (void)cycleScrollView:(LiLCycleScrollView *)cycleScrollView didScrollToIndex:(NSInteger)index;

/** 点击图片回调 */
- (NSString *)getImageUrlCycleScrollView:(LiLCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index;


// 不需要自定义轮播cell的请忽略以下两个的代理方法

// ========== 轮播自定义cell ==========

/** 如果你需要自定义cell样式，请在实现此代理方法返回你的自定义cell的class。 */
- (Class)customCollectionViewCellClassForCycleScrollView:(LiLCycleScrollView *)view;

/** 如果你需要自定义cell样式，请在实现此代理方法返回你的自定义cell的Nib。 */
- (UINib *)customCollectionViewCellNibForCycleScrollView:(LiLCycleScrollView *)view;

/** 如果你自定义了cell样式，请在实现此代理方法为你的cell填充数据以及其它一系列设置 */
- (void)setupCustomCell:(UICollectionViewCell *)cell forIndex:(NSInteger)index cycleScrollView:(LiLCycleScrollView *)view;
@end



@interface LiLCycleScrollView : UIView
/** 网络图片 url string 数组 */
@property (nonatomic, strong) NSArray *imageGroup;

/** 自动滚动间隔时间,默认2s */
@property (nonatomic, assign) CGFloat autoScrollTimeInterval;

/** 是否无限循环,默认Yes */
@property (nonatomic,assign) BOOL infiniteLoop;

/** 是否自动滚动,默认Yes */
@property (nonatomic,assign) BOOL autoScroll;

/** 轮播图片的ContentMode，默认为 UIViewContentModeScaleToFill */
@property (nonatomic, assign) UIViewContentMode bannerImageViewContentMode;

/** 图片滚动方向，默认为水平滚动 */
@property (nonatomic, assign) UICollectionViewScrollDirection scrollDirection;

/** 是否在只有一张图时隐藏pagecontrol，默认为YES */
@property(nonatomic) BOOL hidesForSinglePage;

/** 是否显示分页控件 */
@property (nonatomic, assign) BOOL showPageControl;

/** pagecontrol 样式，默认为动画样式 */
@property (nonatomic, assign) LiLCycleScrollViewPageContolStyle pageControlStyle;

/** 分页控件位置 */
@property (nonatomic, assign) LiLCycleScrollViewPageContolAliment pageControlAliment;

/** 分页控件距离轮播图的底部间距（在默认间距基础上）的偏移量 */
@property (nonatomic, assign) CGFloat pageControlBottomOffset;

/** 分页控件距离轮播图的右边间距（在默认间距基础上）的偏移量 */
@property (nonatomic, assign) CGFloat pageControlRightOffset;

/** 分页控件小圆标大小 */
@property (nonatomic, assign) CGSize pageControlDotSize;

/** 当前分页控件小圆标颜色 */
@property (nonatomic, strong) UIColor *currentPageDotColor;

/** 其他分页控件小圆标颜色 */
@property (nonatomic, strong) UIColor *pageDotColor;
@property(nonatomic,strong)NSArray *pageControlImages;


@property(nonatomic,weak)id<LiLCycleScrollviewDelegate> delegate;

/** 初始轮播图 */
+(instancetype)cycleScrollViewWithFrame:(CGRect)frame delegate:(id<LiLCycleScrollviewDelegate>)delegate;

/** 解决viewWillAppear时出现时轮播图卡在一半的问题，在控制器viewWillAppear时调用此方法 */
- (void)adjustWhenControllerViewWillAppera;
-(void)setScrollViewBackView:(UIView *)backView;
@end


@interface LiLCycleImageViewCell:UICollectionViewCell
@property(nonatomic,strong)UIImageView *imgView;
@end
