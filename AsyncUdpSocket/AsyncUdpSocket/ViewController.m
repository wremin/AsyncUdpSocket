//
//  ViewController.m
//  AsyncUdpSocket
//
//  Created by 陈凡 on 15/7/7.
//  Copyright (c) 2015年 湖南省 永州市 零陵区 湖南科技学院. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController{
    
    // 接收
    AsyncUdpSocket *recvSocket;
    
    // 接收
    AsyncUdpSocket *recvSocket2;
    
    // 发送
    AsyncUdpSocket *sendSocket;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 发送
    AsyncUdpSocket *sendSocket;
    
    // 创建发送
    [self createSender];
    
    
    [self sendMsg];
}

- (void) createReceiver {
    recvSocket = [[AsyncUdpSocket alloc] initWithDelegate:self];
    // 把 recvSocket绑定到0x1234端口
    // http, 80 1024--2^16
    // 知名端口 http 80
    [recvSocket bindToPort:0x1234 error:nil];
    
    
    recvSocket2 = [[AsyncUdpSocket alloc] initWithDelegate:self];
    [recvSocket2 bindToPort:0x1235 error:nil];
    [recvSocket2 receiveWithTimeout:-1 tag:201];
    
    // 接收数据包 -1表示一直等接收
    // tag 200表示当前接收数据包
    [recvSocket receiveWithTimeout:-1 tag:200];
    // 上面这个函数不会等待
    // 不会阻塞blocked
    NSLog(@"after recv");
}


- (void) createSender {
    sendSocket = [[AsyncUdpSocket alloc] initWithDelegate:self];
    [sendSocket bindToPort:9876 error:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL) onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port {
    // data 对方出过来的数据
    // tag == 200
    // host从哪里来数据 ip
    // port 对象的端口
    NSLog(@"recv data from %@:%d", host, port);
    if (tag == 200) {
        NSString *sData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSString *s = [NSString stringWithFormat:@"%@:%d %@", host, port, sData];
        //
        [sock receiveWithTimeout:-1 tag:tag];
    }
    return YES;
}

- (void)sendMsg{
    
    // char *
    NSString *ip = @"192.168.2.2";
    NSString *msg = @"gaga";
    // 我想给ip的机器发送消息msg
    NSData *msgData = [msg dataUsingEncoding:NSUTF8StringEncoding];
    // ip = 192.168.1.22
    // ip = localhost
    [sendSocket sendData:msgData toHost:ip port:0x1234 withTimeout:-1 tag:100];
    NSLog(@"数据还没有发完");
    // 给ip的机器端口0x1234发送数据msgData;
    // sendData只是告诉系统发送，但是这个内容还没有发完
    // 我们怎么知道什么时候发送完成
}

- (void) onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
    // 当前tag这个数据包发送完成
    if (tag == 100) {
        // 证明tag 100
        NSLog(@"tag 100 packet send finished");
    }
}

@end
