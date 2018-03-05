//
//  QCGCD.m
//  QCGCD
//
//  Created by EricZhang on 2018/3/5.
//  Copyright © 2018年 BYX. All rights reserved.
//

#import "QCGCD.h"

//如果执行代码不为空，再添加
#define SafeAction(action) if(action != nil) { action(); }


@interface QCGCD ()

@property (strong, nonatomic) NSMutableArray <dispatch_block_t> *actionArray;

@property (strong, nonatomic) NSMutableArray <IS_Excute_Next_ActionBlock> *isExcuteBlockArray;

@end

@implementation QCGCD


//
static QCGCD *cm_GCD;
+ (instancetype)shareQueue {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cm_GCD = [[QCGCD alloc] init];
        cm_GCD.queue = CMSerialQueue("com.QCGCD.shareQueue");
        //初始化数据
        cm_GCD.actionArray = [NSMutableArray array];
        cm_GCD.isExcuteBlockArray = [NSMutableArray array];
    });
    return cm_GCD;
}



//返回一个串行队列

+ (dispatch_queue_t)queueWithLabel:(const char *)label {
    
    dispatch_queue_t queue = dispatch_queue_create(label, DISPATCH_QUEUE_SERIAL);
    return queue;
}


//返回一个并行队列
+ (dispatch_queue_t)sync_queueWithLabel:(const char *)label {
    
    dispatch_queue_t queue = dispatch_queue_create(label, DISPATCH_QUEUE_CONCURRENT);
    return queue;
}


#pragma mark - Add action to queue

//--------------------------------Sync---------------------------------------------//

//同步执行+主队列。 没有开启新线程，串行执行任务，action是执行的代码块
+ (void)cmSync_mainQueueWithAction:(dispatch_block_t)action {
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        action();
    });
}


//同步执行+其他队列(并发|串行)，
+ (void)cmSyncWithQueue:(dispatch_queue_t)queue ActiobBlock:(dispatch_block_t)action {
    dispatch_sync(queue, ^{
        SafeAction(action);
    });
}

//--------------------------------Async---------------------------------------------//

//异步执行 + 主队列 没有开启新线程，串行执行任务
+ (void)cmAsync_mainQueueWithAction:(dispatch_block_t)action {
    dispatch_async(dispatch_get_main_queue(), ^{
        SafeAction(action);
    });
}


//异步执行 + 其他队列（并发|串行）
//(1):加并发的话 有开启新线程，并发执行任务
//(2):加串行的话 有开启新线程(1条)，串行执行任务
+ (void)cmAsyncWithQueue:(dispatch_queue_t)queue ActionBlock:(dispatch_block_t)action {
    dispatch_async(queue, ^{
        SafeAction(action);
    });
}

//--------------------------------Delay---------------------------------------------//

//线程延后执行
+ (void)queue:(dispatch_queue_t)queue Action:(dispatch_block_t)action Delay:(NSTimeInterval)delayTime {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), queue, ^{
        SafeAction(action);
    });
}


//主线程延后执行
+ (void)mainQueueWithAction:(dispatch_block_t)action Delay:(NSTimeInterval)delayTime {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        SafeAction(action);
    });
}

//---------------------------Action excute by order--------------------------------//

//add action
- (void)addAction:(dispatch_block_t)action ExecuteSignal:(IS_Excute_Next_ActionBlock)isExcuteBlock {
    //添加代码块
    [[QCGCD shareQueue].actionArray addObject:action];
    //添加代码块执行判断条件数组添加元素
    [[QCGCD shareQueue].isExcuteBlockArray addObject:isExcuteBlock];
}

// start
- (void)start {
    
    QCGCD *actionQueue = [QCGCD shareQueue];
    for (int i = 0; i < actionQueue.actionArray.count; i++) {
        
        //代码块执行判断条件获取
        IS_Excute_Next_ActionBlock isExcuteBlock = [self.isExcuteBlockArray objectAtIndex:i];
        //代码块获取
        dispatch_block_t action = [self.actionArray objectAtIndex:i];
        
        //如果是true的话执行，采用的是同步+串并执行的方法
        if (isExcuteBlock() == true) {
            [QCGCD cmSyncWithQueue:self.queue ActiobBlock:^{
                action();
            }];
        }else {
            //end action
            NSLog(@"the %d 'th action not excute",i);
            break;
        }
        
    }
}

-(void)clearData{
    
    if ([QCGCD shareQueue].actionArray.count > 0) {
        [[QCGCD shareQueue].actionArray removeAllObjects];
    }
    
    if ([QCGCD shareQueue].isExcuteBlockArray.count > 0) {
        [[QCGCD shareQueue].isExcuteBlockArray removeAllObjects];
    }
    
    
    
}


-(void)addAction:(dispatch_block_t)action{
    
    [[QCGCD shareQueue].actionArray addObject:action];
    
}

-(void)async_start{
    
    QCGCD *actionQueue = [QCGCD shareQueue];
    for (int i = 0; i < actionQueue.actionArray.count; i++) {
        
        //代码块获取
        dispatch_block_t action = [self.actionArray objectAtIndex:i];
        
        //不需要判断,执行方法采用异步并发
        
        [QCGCD cmAsyncWithQueue:CMConCurrentQueue("") ActionBlock:^{
            //执行上边的action
            action();
        }];
        
    }
    
}



@end
