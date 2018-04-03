//
//  ViewController.m
//  ghost
//
//  Created by zhangyazhe on 2018/4/2.
//  Copyright © 2018年 zhangyazhe. All rights reserved.
//

#import "ViewController.h"
//残影数量
#define GHOST_NUM 4

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *tx;

@property(nonatomic,strong)NSMutableArray *ghostList;

@property(nonatomic,assign)CGPoint originalPoint;

@property(nonatomic,assign)CGPoint endPoint;
@end

@implementation ViewController

-(NSMutableArray *)ghostList{
    if (!_ghostList) {
        _ghostList = [NSMutableArray array];
    }
    return _ghostList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
    [self.tx addGestureRecognizer:pan];
}
/**
 *  实现拖动手势方法
 *
 *  @param panGestureRecognizer 手势本身
 */
- (void)panGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer{
    //获取拖拽手势在self.view 的拖拽姿态
    CGPoint translation = [panGestureRecognizer translationInView:self.view.window];
    switch (panGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:{
            //记录起始点位置
            _originalPoint = CGPointMake(panGestureRecognizer.view.center.x + translation.x, panGestureRecognizer.view.center.y + translation.y);
            [self addItem];
        }break;
        case UIGestureRecognizerStateEnded:{
            _endPoint = CGPointMake(panGestureRecognizer.view.center.x + translation.x, panGestureRecognizer.view.center.y + translation.y);
            [self removeItem];
        }break;
        default:
            break;
    }
    
    //改变panGestureRecognizer.view的中心点 就是self.imageView的中心点
    panGestureRecognizer.view.center = CGPointMake(panGestureRecognizer.view.center.x + translation.x, panGestureRecognizer.view.center.y + translation.y);
    //重置拖拽手势的姿态
    [panGestureRecognizer setTranslation:CGPointZero inView:self.view.window];
    
    [self.ghostList enumerateObjectsUsingBlock:^(UIImageView * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [UIView animateWithDuration:0.1 delay:0.1 * idx  options:UIViewAnimationOptionCurveEaseInOut animations:^{
            obj.center = CGPointMake(panGestureRecognizer.view.center.x + translation.x, panGestureRecognizer.view.center.y + translation.y);
        } completion:nil];
    }];
}
-(float)distanceFromPointX:(CGPoint)start distanceToPointY:(CGPoint)end{
    float distance;
    CGFloat xDist = (end.x - start.x);
    CGFloat yDist = (end.y - start.y);
    distance = sqrt((xDist * xDist) + (yDist * yDist));
    return distance;
}

/**
 添加残影
 */
-(void)addItem{
    
    for (int i = GHOST_NUM; i > 0; i--) {
        UIImageView *img = [[UIImageView alloc]initWithFrame:_tx.frame];
        img.image = _tx.image;
        img.layer.cornerRadius = _tx.layer.cornerRadius;
        img.layer.masksToBounds = YES;
        img.alpha = 1 - (i * 0.15);
        img.transform = CGAffineTransformMakeScale(1 - 0.1 * i,1 - 0.1 * i);
        [self.view.window addSubview:img];
        [self.ghostList addObject:img];
    }
}

/**
 置空残影
 */
-(void)removeItem{
    __weak typeof(self) weakSelf = self;
    CGFloat f = [self distanceFromPointX:weakSelf.originalPoint distanceToPointY:weakSelf.endPoint] / [UIScreen mainScreen].bounds.size.height;
    [UIView animateWithDuration:1 * f delay:0.1  options:UIViewAnimationOptionCurveEaseInOut animations:^{
        weakSelf.tx.center = weakSelf.originalPoint;
    } completion:nil];
    [self.ghostList enumerateObjectsUsingBlock:^(UIImageView * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [UIView animateWithDuration:1 * f delay:0.1 * idx usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            obj.center = weakSelf.originalPoint;
        } completion:^(BOOL finished) {
            if (idx == weakSelf.ghostList.count - 1) {
                [weakSelf.ghostList makeObjectsPerformSelector:@selector(removeFromSuperview)];
                [weakSelf.ghostList removeAllObjects];
            }
        }];
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
