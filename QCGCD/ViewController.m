//
//  ViewController.m
//  QCGCD
//
//  Created by EricZhang on 2018/3/5.
//  Copyright © 2018年 BYX. All rights reserved.
//

#import "ViewController.h"
#import "QCGCD.h"
@interface ViewController ()
@property (assign, nonatomic) float x1;
@property (assign, nonatomic) float x2;
@property (assign, nonatomic) float x3;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self QCGCDDemo];
    
    
}

- (void)QCGCDDemo {
    _x1 = _x2 = _x3 = 0.0;
    
    __weak typeof(self) weakSekf = self;
    
    //MARK:测试一下同步串行行方法,条件递进的方式
    
    //这些都采用了同步串行的方法   得到x1 = 1;
    [[QCGCD shareQueue] addAction:^{
        weakSekf.x1 += 1.0;
        NSLog(@"x1 = %.1f",weakSekf.x1);
    } ExecuteSignal:^BOOL{
        return true;
    }];
    
    
    //判断x1 = 1；得到x2 = 2；
    [[QCGCD shareQueue] addAction:^{
        weakSekf.x2 += 2.0;
        NSLog(@"x2 = %.1f",weakSekf.x2);
    } ExecuteSignal:^BOOL{
        return weakSekf.x1 == 1.0;
    }];
    
    //判断x2 = 1，最终没有添加，执行到这一步截止
    [[QCGCD shareQueue] addAction:^{
        weakSekf.x3 += 1.0;
        NSLog(@"x3 = %.1f",weakSekf.x3);
    } ExecuteSignal:^BOOL{
        return weakSekf.x2 == 1.0;
    }];
    
    //输出结果预测为： x1 = 1.0;  x2 = 2.0;  x3 = 0.0;
    [[QCGCD shareQueue] addAction:^{
        NSLog(@"x1 = %f",weakSekf.x1);
        NSLog(@"x2 = %f",weakSekf.x2);
        NSLog(@"x3 = %f",weakSekf.x3);
    } ExecuteSignal:^BOOL{
        return true;
    }];
    
    [[QCGCD shareQueue] start];
    
    
    
    
    
    
    
    //MARK:测试一下异步并行
    //先清空一下之前的数据重新添加
    [[QCGCD shareQueue] clearData];
    
    [[QCGCD shareQueue] addAction:^{
        NSLog(@"我是谁");
        NSLog(@"======线程:%@",[NSThread currentThread]);
    }];
    
    [[QCGCD shareQueue] addAction:^{
        NSLog(@"我从哪里来");
        NSLog(@"$$$$$$线程:%@",[NSThread currentThread]);
    }];
    
    
    [[QCGCD shareQueue] addAction:^{
        NSLog(@"我要到哪里去");
        NSLog(@"@@@@@@线程:%@",[NSThread currentThread]);
    }];
    
    //执行顺序并没有先后分
    [[QCGCD shareQueue] async_start];
    
    
    
    
    
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
