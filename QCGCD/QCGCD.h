//
//  QCGCD.h
//  QCGCD
//
//  Created by EricZhang on 2018/3/5.
//  Copyright © 2018年 BYX. All rights reserved.
//

#import <Foundation/Foundation.h>

//带参宏定义
//传入对应的名称id，方便debug
#define CMSerialQueue(label)     [QCGCD queueWithLabel:label]
#define CMConCurrentQueue(label) [QCGCD sync_queueWithLabel:label]


//返回值、名字、参数, 是否执行下一个操作
typedef BOOL(^IS_Excute_Next_ActionBlock)(void);

@interface QCGCD : NSObject

@property (strong, nonatomic) dispatch_queue_t queue;

+ (instancetype)shareQueue;


#pragma mark - Create a queue
//返回一个queue,上面调用即可 ` CMSerialQueue(label) `
/*
 label : 队列标签
 Example: dispatch_queue_t queue = CMSerialQueue("com.Manoboo.Inc");
 */
+ (dispatch_queue_t)queueWithLabel:(const char *)label;



//返回一个queue,上面调用即可 ` CMConCurrentQueue(label) `
+ (dispatch_queue_t)sync_queueWithLabel:(const char *)label;


#pragma mark - Queue Operation

//同步添加到主线程中
+ (void)cmSync_mainQueueWithAction:(dispatch_block_t)action;

//同步添加到线程中
+ (void)cmSyncWithQueue:(dispatch_queue_t)queue ActiobBlock:(dispatch_block_t)action;


//异步添加到主线程中
+ (void)cmAsync_mainQueueWithAction:(dispatch_block_t)action;

//异步添加到线程中
+ (void)cmAsyncWithQueue:(dispatch_queue_t)queue ActionBlock:(dispatch_block_t)action;


//延迟delayTime秒之后提交任务到queue中
+ (void)queue:(dispatch_queue_t)queue Action:(dispatch_block_t)action Delay:(NSTimeInterval)delayTime;

//主线程动作
+ (void)mainQueueWithAction:(dispatch_block_t)action Delay:(NSTimeInterval)delayTime;

#pragma mark - Queue's Action execute according to the order of submission
//MARK:测试有条件的同步串行
//添加代码块和条件,//线程中添加的操作按提交的顺序依次执行, 不开新线程
- (void)addAction:(dispatch_block_t)action ExecuteSignal:(IS_Excute_Next_ActionBlock)isExcuteBlock;


- (void)start;

//清空数据
- (void) clearData;



//添加代码块
-(void)addAction:(dispatch_block_t)action;

//线程中添加的操作并行
-(void)async_start;

@end


