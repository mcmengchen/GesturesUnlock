//
//  DrawView.m
//  手势解锁
//
//  Created by MENGCHEN on 15/8/23.
//  Copyright (c) 2015年 Mcking. All rights reserved.
//

#import "DrawView.h"

@interface DrawView()


@property(nonatomic,strong)NSMutableArray * btnArray;
/**
 *
 */
@property(nonatomic,strong)NSMutableArray * selectArray;
/**
 *
 */
@property(nonatomic,assign)CGPoint  startP;

/**
 *
 */
@property(nonatomic,assign)CGPoint currentP;
/**
 *
 */
@property(nonatomic,strong)UIBezierPath * path;




@end

@implementation DrawView

-(void)awakeFromNib
{
    [self createBtns];
    
    
}
#pragma mark ------------------ 懒加载按钮 ------------------
- (NSMutableArray *)btnArray{
    if (!_btnArray) {
        _btnArray = [NSMutableArray array];
    }
    return _btnArray;
    
}
#define btnW 74
#define btnH 74
#define mScreenW [UIScreen mainScreen].bounds.size.width
#define SPACEW (self.bounds.size.width -3*74)/4.0
#define SPACEH (self.bounds.size.height -3*74)/4.0

#pragma mark ------------------ 创建按钮 ------------------
- (void)createBtns{    
    for (int i = 0; i<9; i++) {

        
        float x = (i%3+1)*SPACEW+i%3*btnW;
        float y = (i/3+1)*SPACEH+i/3*btnH;
        /**
         *  i = 0
            x = SPACEW   y =SPACEH
            i = 1
            x = 2*SPACEW y =
         
         */
        UIButton*btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(x, y, btnW, btnH);
        //将btn的交互关闭意味着不希望触发 点击事件
        btn.userInteractionEnabled = NO;
        [btn setImage:[UIImage imageNamed:@"gesture_node_normal"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"gesture_node_highlighted"] forState:UIControlStateSelected];
        btn.tag = i;
        [self addSubview:btn];
        [self.btnArray addObject:btn];
        
    }
    
    
    
}
#pragma mark ------------------ 懒加载slectArray ------------------

-(NSMutableArray *)selectArray{
    if (!_selectArray) {
        _selectArray = [NSMutableArray array];
    }
    return _selectArray;
}
#pragma mark ------------------ 开始触摸 ------------------
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //设置一个初始的标示符
    _currentP = CGPointMake(-10, -10);
    
    //获取触摸点
   CGPoint point = [self getCurrentP:touches];
    //查看触摸点是否在btn上
   UIButton*btn  = [self checkPoint:point];
    if (btn&&btn.selected == NO) {
        btn.selected  = YES;
        if (![_selectArray containsObject:btn]) {
            [_selectArray addObject:btn];
        }
    }

    [self setNeedsDisplay];

    
}
#pragma mark ------------------ 触碰移动 ------------------
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    CGPoint point = [self getCurrentP:touches];
    UIButton*btn  = [self checkPoint:point];
    if (btn&&btn.selected == NO) {
        btn.selected  = YES;
        if (![_selectArray containsObject:btn]) {
            [_selectArray addObject:btn];
        }
    }else{
        _currentP = point;
    }
    [self setNeedsDisplay];
    
    
}
#pragma mark ------------------ 触碰结束后清除痕迹 ------------------
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    //获得密码字符串
    NSMutableString*string = [NSMutableString string];
    for (int i =0; i<_selectArray.count; i++) {
        UIButton*btn = [_selectArray objectAtIndex:i];
        [string appendString:[NSString stringWithFormat:@"%ld",btn.tag]];
    }
    NSLog(@"%@",string);
    
    //清除痕迹
    for (UIButton*btn in _selectArray) {

        btn.selected = NO;
    }
    [_selectArray removeAllObjects];
    
    [self setNeedsDisplay];
    
    
}


#pragma mark ------------------ 获取当前点 ------------------
- (CGPoint)getCurrentP:(NSSet*)touches{
    UITouch*touch = [touches anyObject];
    CGPoint curP  = [touch locationInView:self];
    return curP;
}
#pragma mark ------------------ 查看点在哪个按钮上 ------------------
-(UIButton*)checkPoint:(CGPoint)point{
    
    for (int i =0; i<_btnArray.count; i++) {
        UIButton*btn = [_btnArray objectAtIndex:i];
        if (CGRectContainsPoint(btn.frame, point)) {
            return btn;
        }
    }
    
    return nil;
    
}


#pragma mark ------------------ 重绘 ------------------
- (void)drawRect:(CGRect)rect {

    if (self.selectArray.count==0)return;
    UIBezierPath*path = [UIBezierPath bezierPath];
        for (int i = 0; i<_selectArray.count; i++) {
            UIButton*btn = _selectArray[i];
            if (i==0) {
                [path moveToPoint:btn.center];
            }else{
                [path addLineToPoint:btn.center];
            }
        }
    //在刚开始触碰的时候初始化了currentP，因为有了这个初始化的点所以当我们没有触碰到按钮的时候默认是不划线的。
    if (!CGPointEqualToPoint(_currentP, CGPointMake(-10, -10))) {
        [path addLineToPoint:_currentP];
    }
    path.lineWidth = 8;
    path.lineJoinStyle = kCGLineJoinBevel;
    [[UIColor greenColor] set];
    [path stroke];


}

@end
