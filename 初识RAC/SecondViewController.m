//
//  SecondViewController.m
//  初识RAC
//
//  Created by 翟旭博 on 2023/2/7.
//

#import "SecondViewController.h"

@interface SecondViewController ()
@property (nonatomic, strong) UIButton *backButton;

//测试组合
@property (nonatomic, strong) UIButton *combinationButton;
@property (nonatomic, strong) UITextField *firstTextField;
@property (nonatomic, strong) UITextField *secondTextField;
@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    self.backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.backButton.backgroundColor = [UIColor redColor];
    self.backButton.frame = CGRectMake(0, 0, 100, 100);
    [self.backButton setTitle:@"返回" forState:UIControlStateNormal];
    [self.view addSubview:self.backButton];
    [[self.backButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [self.subject sendNext:@"已获"];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    self.combinationButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.combinationButton.frame = CGRectMake(200, 200, 100, 100);
    self.combinationButton.backgroundColor = [UIColor orangeColor];
    [self.combinationButton setTitle:@"测试组合" forState:UIControlStateNormal];
    [self.view addSubview:self.combinationButton];
    
    self.firstTextField = [[UITextField alloc] init];
    self.firstTextField.backgroundColor = [UIColor yellowColor];
    self.firstTextField.frame = CGRectMake(200, 350, 200, 70);
    [self.view addSubview:self.firstTextField];
    
    self.secondTextField = [[UITextField alloc] init];
    self.secondTextField.backgroundColor = [UIColor yellowColor];
    self.secondTextField.frame = CGRectMake(200, 450, 200, 70);
    [self.view addSubview:self.secondTextField];
    
    
    [self combineLatest];
    NSLog(@"--------------------");
    [self zipWith];
    NSLog(@"--------------------");
    [self merge];
    NSLog(@"--------------------");
    [self then];
    NSLog(@"--------------------");
    [self concat];
}

#pragma mark 组合
// 把多个信号聚合成你想要的信号,使用场景----：比如-当多个输入框都有值的时候按钮才可点击。
// 思路--- 就是把输入框输入值的信号都聚合成按钮是否能点击的信号。
- (void)combineLatest {
    
    RACSignal *combinSignal = [RACSignal combineLatest:@[self.firstTextField.rac_textSignal, self.secondTextField.rac_textSignal] reduce:^id(NSString *account, NSString *pwd){ //reduce里的参数一定要和combineLatest数组里的一一对应。
        // block: 只要源信号发送内容，就会调用，组合成一个新值。
        NSLog(@"%@ %@", account, pwd);
        return @(account.length && pwd.length);
    }];
    
//        // 订阅信号
//        [combinSignal subscribeNext:^(id x) {
//            self.combinationButton.enabled = [x boolValue];
//        }];    // ----这样写有些麻烦，可以直接用RAC宏
    RAC(self.combinationButton, enabled) = combinSignal;
}

- (void)zipWith {
    //zipWith:把两个信号压缩成一个信号，只有当两个信号同时发出信号内容时，并且把两个信号的内容合并成一个元祖，才会触发压缩流的next事件。
    // 创建信号A
    RACSubject *signalA = [RACSubject subject];
    // 创建信号B
    RACSubject *signalB = [RACSubject subject];
    // 压缩成一个信号
    // **-zipWith-**: 当一个界面多个请求的时候，要等所有请求完成才更新UI
    // 等所有信号都发送内容的时候才会调用
    RACSignal *zipSignal = [signalA zipWith:signalB];
    [zipSignal subscribeNext:^(id x) {
        NSLog(@"%@", x); //所有的值都被包装成了元组
    }];
    
    // 发送信号 交互顺序，元组内元素的顺序不会变，跟发送的顺序无关，而是跟压缩的顺序有关[signalA zipWith:signalB]---先是A后是B
    [signalA sendNext:@1];
    [signalB sendNext:@2];
}

// 任何一个信号请求完成都会被订阅到
// merge:多个信号合并成一个信号，任何一个信号有新值就会调用
- (void)merge {
    // 创建信号A
    RACSubject *signalA = [RACSubject subject];
    // 创建信号B
    RACSubject *signalB = [RACSubject subject];
    //组合信号
    RACSignal *mergeSignal = [signalA merge:signalB];
    // 订阅信号
    [mergeSignal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    // 发送信号---交换位置则数据结果顺序也会交换
    [signalB sendNext:@"下部分"];
    [signalA sendNext:@"上部分"];
}

// then --- 使用需求：有两部分数据：想让上部分先进行网络请求但是过滤掉数据，然后进行下部分的，拿到下部分数据
- (void)then {
    // 创建信号A
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 发送请求
        NSLog(@"----发送上部分请求---afn");
        
        [subscriber sendNext:@"上部分数据"];
        [subscriber sendCompleted]; // 必须要调用sendCompleted方法！
        return nil;
    }];
    
    // 创建信号B，
    RACSignal *signalsB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 发送请求
        NSLog(@"--发送下部分请求--afn");
        [subscriber sendNext:@"下部分数据"];
        return nil;
    }];
    // 创建组合信号
    // then;忽略掉第一个信号的所有值
    RACSignal *thenSignal = [signalA then:^RACSignal *{
        // 返回的信号就是要组合的信号
        return signalsB;
    }];
    
    // 订阅信号
    [thenSignal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];

}

// concat----- 使用需求：有两部分数据：想让上部分先执行，完了之后再让下部分执行（都可获取值）
- (void)concat {
    // 组合
    
    // 创建信号A
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 发送请求
        //        NSLog(@"----发送上部分请求---afn");
        
        [subscriber sendNext:@"上部分数据"];
        [subscriber sendCompleted]; // 必须要调用sendCompleted方法！
        return nil;
    }];
    
    // 创建信号B，
    RACSignal *signalsB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 发送请求
        //        NSLog(@"--发送下部分请求--afn");
        [subscriber sendNext:@"下部分数据"];
        return nil;
    }];
    
    
    // concat:按顺序去链接
    //**-注意-**：concat，第一个信号必须要调用sendCompleted
    // 创建组合信号
    RACSignal *concatSignal = [signalA concat:signalsB];
    // 订阅组合信号
    [concatSignal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];

}
@end
