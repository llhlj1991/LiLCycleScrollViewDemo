//
//  LiLInfineScrollview.m
//  InfiniteScrollview
//
//  Created by lilei on 2018/6/25.
//  Copyright © 2018年 lilei. All rights reserved.
//

#import "LiLCycleScrollView.h"
NSString * const cellID = @"LILCycleScrollViewCell";
@interface LiLCycleScrollView()<UICollectionViewDelegate,UICollectionViewDataSource>
@property(nonatomic,strong)UICollectionViewFlowLayout *layout;
@property(nonatomic,strong)UICollectionView *collectionView;
@property(nonatomic,assign)NSInteger totalItemsCount;
@property(nonatomic,strong)NSTimer *timer;
@property(nonatomic,weak)UIView *pageControl;
@end
#define LiLCycleScrollViewInitialPageControlDotSize CGSizeMake(10, 10)

@implementation LiLCycleScrollView
+(instancetype)cycleScrollViewWithFrame:(CGRect)frame delegate:(id<LiLCycleScrollviewDelegate>)delegate{
    LiLCycleScrollView *cycleScrollView = [[self alloc]initWithFrame:frame];
    cycleScrollView.delegate = delegate;
    return cycleScrollView;
}
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initialization];
        [self setupUI];
    }
    return self;
}
- (void)initialization
{
    self.backgroundColor = [UIColor whiteColor];
    _pageControlAliment = LiLCycleScrollViewPageContolAlimentCenter;
    _autoScrollTimeInterval = 2.0;
    _autoScroll = YES;
    _infiniteLoop = YES;
    _showPageControl = YES;
    _pageControlDotSize = LiLCycleScrollViewInitialPageControlDotSize;
    _pageControlBottomOffset = 0;
    _pageControlRightOffset = 0;
    _pageControlStyle = LiLCycleScrollViewPageContolStyleClassic;
    _hidesForSinglePage = YES;
    _currentPageDotColor = [UIColor whiteColor];
    _pageDotColor = [UIColor lightGrayColor];
    _bannerImageViewContentMode = UIViewContentModeScaleToFill;
    
}
-(void)setupUI{
    self.layout = [[UICollectionViewFlowLayout alloc]init];
    self.layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.layout.itemSize = self.bounds.size;
    self.layout.minimumLineSpacing = 0;
    self.collectionView = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:self.layout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[LiLCycleImageViewCell class] forCellWithReuseIdentifier:cellID];
    [self addSubview:self.collectionView];
}
-(UIView *)pageControl{
    if (!_pageControl) {
        if (_pageControlStyle == LiLCycleScrollViewPageContolStyleClassic ) {
            UIPageControl *pageControl = [[UIPageControl alloc]init];
            pageControl.currentPageIndicatorTintColor = _currentPageDotColor;
            pageControl.pageIndicatorTintColor = _pageDotColor;
            pageControl.numberOfPages = _imageGroup.count;
            [self addSubview:pageControl];
            _pageControl = pageControl;
        }else if (_pageControlStyle == LiLCycleScrollViewPageContolStyleImage){
            UIImageView *pageControl = [[UIImageView alloc]init];
            pageControl.contentMode = UIViewContentModeScaleAspectFit;
            [self addSubview:pageControl];
            _pageControl = pageControl;
        }
    }
    return _pageControl;
}
#pragma mark - setProperties
-(void)setScrollViewBackView:(UIView *)backView{
    self.collectionView.backgroundView = backView;
}
-(void)setDelegate:(id<LiLCycleScrollviewDelegate>)delegate{
    _delegate = delegate;
    if ([delegate respondsToSelector:@selector(customCollectionViewCellClassForCycleScrollView:)]) {
        [self.collectionView registerClass:[delegate customCollectionViewCellClassForCycleScrollView:self] forCellWithReuseIdentifier:cellID];
    }else if ([delegate respondsToSelector:@selector(customCollectionViewCellNibForCycleScrollView:)]){
        [self.collectionView registerNib:[delegate customCollectionViewCellNibForCycleScrollView:self] forCellWithReuseIdentifier:cellID];
    }
}
- (void)setImageGroup:(NSArray *)imageGroup
{
    [self invalidateTimer];
    
    _imageGroup = imageGroup;
    if (imageGroup.count == 1) {
        _infiniteLoop = NO;
    }
    _totalItemsCount = self.infiniteLoop  ? self.imageGroup.count * 1024 : self.imageGroup.count;
    
    if (imageGroup.count > 1) { // 由于 !=1 包含count == 0等情况
        self.collectionView.scrollEnabled = YES;
        [self setAutoScroll:self.autoScroll];
    } else {
        self.collectionView.scrollEnabled = NO;
    }
    [self.collectionView reloadData];
}
-(void)setAutoScroll:(BOOL)autoScroll{
    _autoScroll = autoScroll;
    [self invalidateTimer];
    if (autoScroll) {
        [self setupTimer];
    }
}
-(void)setAutoScrollTimeInterval:(CGFloat)autoScrollTimeInterval{
    _autoScrollTimeInterval = autoScrollTimeInterval;
    [self setAutoScroll:self.autoScroll];
}
-(void)setScrollDirection:(UICollectionViewScrollDirection)scrollDirection{
    _scrollDirection = scrollDirection;
    self.layout.scrollDirection = scrollDirection;
}
-(void)setShowPageControl:(BOOL)showPageControl{
    _showPageControl = showPageControl;
    _pageControl.hidden = !showPageControl;
}

#pragma mark - actions
- (void)setupTimer
{
    [self invalidateTimer]; // 创建定时器前先停止定时器，不然会出现僵尸定时器，导致轮播频率错误
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:self.autoScrollTimeInterval target:self selector:@selector(automaticScroll) userInfo:nil repeats:YES];
    _timer = timer;
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)invalidateTimer
{
    [_timer invalidate];
    _timer = nil;
}
- (void)automaticScroll
{
    if (_totalItemsCount < 2) return;
    int currentIndex = [self currentIndex];
    int targetIndex = currentIndex + 1;
    [self scrollToIndex:targetIndex];
}
-(int)currentIndex{
    if (self.collectionView.bounds.size.width == 0 || self.collectionView.bounds.size.height == 0 ) {
        return 0;
    }
    int index = 0;
    if (self.layout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        index = (_collectionView.contentOffset.x+_layout.itemSize.width/2)/_layout.itemSize.width;
    }else{
        index = (_collectionView.contentOffset.y+_layout.itemSize.height/2)/_layout.itemSize.height;
    }
    return MAX(0, index);
}
- (void)scrollToIndex:(int)targetIndex
{
    if (targetIndex >= _totalItemsCount) {
        if (self.infiniteLoop) {
            targetIndex = _totalItemsCount * 0.5;
            [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        }
        return;
    }
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
}
- (int)pageControlIndexWithCurrentCellIndex:(NSInteger)index
{
    return (int)index % self.imageGroup.count;
}
-(void)setCurrentPageControl{
    if (!_pageControl)return;
    if (!self.imageGroup.count) return; // 解决清除timer时偶尔会出现的问题
    int itemIndex = [self currentIndex];
    int indexOnPageControl = [self pageControlIndexWithCurrentCellIndex:itemIndex];
    if ([_pageControl isKindOfClass:[UIImageView class]] && indexOnPageControl < self.pageControlImages.count) {
        ((UIImageView *)_pageControl).image = [UIImage imageNamed:self.pageControlImages[indexOnPageControl]];
    }else if([_pageControl isKindOfClass:[UIPageControl class]]){
        ((UIPageControl *)_pageControl).currentPage = indexOnPageControl;
    }
}
#pragma mark - system Actions
-(void)layoutSubviews{
    [super layoutSubviews];
    _layout.itemSize = self.bounds.size;
    _collectionView.frame = self.bounds;
    if (_collectionView.contentOffset.x == 0 &&  _totalItemsCount) {
        int targetIndex = 0;
        if (self.infiniteLoop) {
            targetIndex = _totalItemsCount * 0.5;
        }else{
            targetIndex = 0;
        }
        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
    
    if (!self.showPageControl || (self.imageGroup.count <2 && self.hidesForSinglePage)) {
        return;
    }
    if (_pageControlStyle == LiLCycleScrollViewPageContolStyleImage && _imageGroup.count != _pageControlImages.count) {
        _pageControlStyle = LiLCycleScrollViewPageContolStyleClassic;
    }
    CGSize size = CGSizeZero;
    if ([self.pageControl isKindOfClass:[UIImageView class]]) {
        size = self.pageControlDotSize;
    } else {
        size = CGSizeMake(self.imageGroup.count * self.pageControlDotSize.width * 1.5, self.pageControlDotSize.height);
    }
    CGFloat x = (self.bounds.size.width - size.width) * 0.5;
    if (self.pageControlAliment == LiLCycleScrollViewPageContolAlimentRight) {
        x = self.bounds.size.width - size.width - 10;
    }
    CGFloat y = self.bounds.size.height - size.height - 10;
    
    CGRect pageControlFrame = CGRectMake(x, y, size.width, size.height);
    pageControlFrame.origin.y -= self.pageControlBottomOffset;
    pageControlFrame.origin.x -= self.pageControlRightOffset;
    self.pageControl.frame = pageControlFrame;
    [self setCurrentPageControl];
}
-(void)willMoveToSuperview:(UIView *)newSuperview{
    if (!newSuperview) {
        [self invalidateTimer];
    }
}
-(void)dealloc{
    NSLog(@"LiLCycleScrollview--------------dealloc");
    _collectionView.delegate = nil;
    _collectionView.dataSource = nil;
}

#pragma mark - public Actions
-(void)adjustWhenControllerViewWillAppera{
    long targetIndex = [self currentIndex];
    if (targetIndex < _totalItemsCount) {
        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
}

#pragma mark - UICollectionViewDataSource -
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _totalItemsCount;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    LiLCycleImageViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    long itemIndex = [self pageControlIndexWithCurrentCellIndex:indexPath.item];
    if ([self.delegate respondsToSelector:@selector(setupCustomCell:forIndex:cycleScrollView:)] &&
        [self.delegate respondsToSelector:@selector(customCollectionViewCellClassForCycleScrollView:)] && [self.delegate customCollectionViewCellClassForCycleScrollView:self]) {
        [self.delegate setupCustomCell:cell forIndex:itemIndex cycleScrollView:self ];
        return cell;
    }else if ([self.delegate respondsToSelector:@selector(setupCustomCell:forIndex:cycleScrollView:)] &&
              [self.delegate respondsToSelector:@selector(customCollectionViewCellNibForCycleScrollView:)] && [self.delegate customCollectionViewCellNibForCycleScrollView:self]) {
        [self.delegate setupCustomCell:cell forIndex:itemIndex cycleScrollView:self];
        return cell;
    }
    if ([cell isKindOfClass:[LiLCycleImageViewCell class]]) {
        cell.imgView.contentMode = self.bannerImageViewContentMode;
        NSString *item = _imageGroup[itemIndex];
        NSString *imageUrl;
        if ([item isKindOfClass:[NSString class]]) {
            imageUrl = item;
        }else{
            if ([self.delegate respondsToSelector:@selector(getImageUrlCycleScrollView:didSelectItemAtIndex:)]) {
                imageUrl = [self.delegate getImageUrlCycleScrollView:self didSelectItemAtIndex:[self pageControlIndexWithCurrentCellIndex:indexPath.item]];
            }
        }
        if (imageUrl) {
            if ([imageUrl hasPrefix:@"http"]) {
//                [cell.imgView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:nil];
            }else{
                cell.imgView.image = [UIImage imageNamed:imageUrl];
            }
        }
    }
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate respondsToSelector:@selector(cycleScrollView:didSelectItemAtIndex:)]) {
        [self.delegate cycleScrollView:self didSelectItemAtIndex:[self pageControlIndexWithCurrentCellIndex:indexPath.item]];
    }

}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self setCurrentPageControl];
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (self.autoScroll) {
        [self invalidateTimer];
    }
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (self.autoScroll) {
        [self setupTimer];
    }
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self scrollViewDidEndScrollingAnimation:_collectionView];
}
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    if (!self.imageGroup.count) return; // 解决清除timer时偶尔会出现的问题
    int itemIndex = [self currentIndex];
    int indexOnPageControl = [self pageControlIndexWithCurrentCellIndex:itemIndex];
    
    if ([self.delegate respondsToSelector:@selector(cycleScrollView:didScrollToIndex:)]) {
        [self.delegate cycleScrollView:self didScrollToIndex:indexOnPageControl];
    }
}

@end

@implementation LiLCycleImageViewCell
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _imgView = [[UIImageView alloc]initWithFrame:self.bounds];
        [self.contentView addSubview:_imgView];
    }
    return self;
}
@end
