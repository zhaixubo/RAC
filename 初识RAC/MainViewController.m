//
//  MainViewController.m
//  初识RAC
//
//  Created by 翟旭博 on 2023/2/7.
//

#import "MainViewController.h"
#import "ReactiveCocoa.h"
#import "RACReturnSignal.h"
#import "SecondViewController.h"
@interface MainViewController ()
@property (nonatomic, strong) UIButton *firstButton;
@property (nonatomic, strong) UILabel *firstLabel;
@property (nonatomic, strong) UITextField *firstTextField;

//宏操作测试
@property (nonatomic, strong) UITextField *hongTextField;
@property (nonatomic, strong) UILabel *hongLabel;
@property (nonatomic, strong) RACSignal *signal;

//定时器
@property (nonatomic, strong) UIButton *timeButton;
@property (nonatomic, strong) RACDisposable *disposable;
@property (nonatomic, assign) int count;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
//    [self addButton];
//    [self racSignal];
//    [self racSubject];
//    [self addKVOandTapGesture];
//    [self addTextField];
    
//    [self skipRACSubject];
//    NSLog(@"--------------------");
//    [self takeRACSubject];
//    NSLog(@"--------------------");
//    [self takeLastRACSubject];
//    NSLog(@"--------------------");
//    [self ignoreRACSubject];
    
//    [self map];
//    NSLog(@"--------------------");
//    [self flatMap];
//    NSLog(@"--------------------");
//    [self flattenMap2];
    
//    [self hongTest];
//    NSLog(@"--------------------");
//    [self hongTestKVO];
//    NSLog(@"--------------------");
//    [self hongTest3];
//    NSLog(@"--------------------");
//    [self hongTest4];
//    NSLog(@"--------------------");
    
    [self countdown];
}

- (void)addButton {   //button点击和传值
    self.firstButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.firstButton.frame = CGRectMake(0, 0, 100, 100);
    [self.firstButton setTitle:@"未获" forState:UIControlStateNormal];
    self.firstButton.backgroundColor = [UIColor purpleColor];
    [self.view addSubview:self.firstButton];
    [[self.firstButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        SecondViewController *secondViewController = [[SecondViewController alloc] init];
        secondViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        secondViewController.subject = [RACSubject subject];
        [secondViewController.subject subscribeNext:^(id x) {
            NSLog(@"%@",x);
            [self.firstButton setTitle:x forState:UIControlStateNormal];
        }];
        [self presentViewController:secondViewController animated:YES completion:nil];
    }];
}

- (void)racSignal {   //RACSignal用法
    // 1.创建信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 3.发送信号
        [subscriber sendNext:@"牛逼"];
        [subscriber sendNext:@"牛逼2"];
        // 4.取消信号，如果信号想要被取消，就必须返回一个RACDisposable
        // 信号什么时候被取消：1.自动取消，当一个信号的订阅者被销毁的时候机会自动取消订阅，2.手动取消，
        //block什么时候调用：一旦一个信号被取消订阅就会调用
        //block作用：当信号被取消时用于清空一些资源
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"取消订阅");
        }];
    }];
    // 2. 订阅信号
    // subscribeNext
    // 把nextBlock保存到订阅者里面
    // 只要订阅信号就会返回一个取消订阅信号的类
    RACDisposable *disposable = [signal subscribeNext:^(id x) {
        // block的调用时刻：只要信号内部发出数据就会调用这个block
        NSLog(@"======%@", x);
    }];
    // 取消订阅
    [disposable dispose];
    
    /*
    RACSignal总结：
    一.核心：
       1.核心：信号类
       2.信号类的作用：只要有数据改变就会把数据包装成信号传递出去
       3.只要有数据改变就会有信号发出
       4.数据发出，并不是信号类发出，信号类不能发送数据
    一.使用方法：
       1.创建信号
       2.订阅信号
    二.实现思路：
       1.当一个信号被订阅，创建订阅者，并把nextBlock保存到订阅者里面。
       2.创建的时候会返回 [RACDynamicSignal createSignal:didSubscribe];
       3.调用RACDynamicSignal的didSubscribe
       4.发送信号[subscriber sendNext:value];
       5.拿到订阅者的nextBlock调用
    */
}

- (void)racSubject {
    RACSubject *subject = [RACSubject subject];
    [subject subscribeNext:^(id x) {
        // block:当有数据发出的时候就会调用
        // block:处理数据
        NSLog(@"%@",x);
    }];
    [subject sendNext:@"123"];
}

- (void)addKVOandTapGesture {   //对于label的TapGesture和KVO测试
    self.firstLabel = [[UILabel alloc] init];
    self.firstLabel.text = @"未点击";
    self.firstLabel.frame = CGRectMake(0, 100, 100, 100);
    [self.view addSubview:self.firstLabel];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    self.firstLabel.userInteractionEnabled = YES;
    [self.firstLabel addGestureRecognizer:tap];
    [tap.rac_gestureSignal subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
        self.firstLabel.text = [NSString stringWithFormat:@"已点击----%d", arc4random()];
    }];
    
    //KVO
    [RACObserve(self, self.firstLabel.text) subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@", x);
    }];
//    [[self.firstLabel.text rac_valuesAndChangesForKeyPath:@"text" options:NSKeyValueObservingOptionNew observer:nil] subscribeNext:^(id x) {
//        NSLog(@"%@", x);
//    }];
}

- (void)addTextField {
    self.firstTextField = [[UITextField alloc] init];
    self.firstTextField.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:self.firstTextField];
    self.firstTextField.frame = CGRectMake(100, 100, 200, 30);
    [self.firstTextField.rac_textSignal subscribeNext:^(NSString * _Nullable x) {
        NSLog(@"%@", x);
    }];
    
    // 只有当文本框的内容长度大于5，才获取文本框里的内容
    [[self.firstTextField.rac_textSignal filter:^BOOL(id value) {
        // value 源信号的内容
        return [value length] > 5;
        // 返回值 就是过滤条件。只有满足这个条件才能获取到内容
    }] subscribeNext:^(id x) {
        NSLog(@"已过滤-----%@", x);
    }];
}

#pragma mark RACSubject过滤

- (void)skipRACSubject {
    // 跳跃 ： 如下，skip传入2 跳过前面两个值
    // 实际用处： 在实际开发中比如 后台返回的数据前面几个没用，我们想跳跃过去，便可以用skip
    RACSubject *subject = [RACSubject subject];
    [[subject skip:2] subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    [subject sendNext:@1];
    [subject sendNext:@2];
    [subject sendNext:@3];
}

- (void)distinctUntilChangedRACSubject {
    //distinctUntilChanged:-- 如果当前的值跟上一次的值一样，就不会被订阅到
    RACSubject *subject = [RACSubject subject];
    [[subject distinctUntilChanged] subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    // 发送信号
    [subject sendNext:@1];
    [subject sendNext:@2];
    [subject sendNext:@2]; // 不会被订阅
}

- (void)takeRACSubject {
    // take:可以屏蔽一些值,去前面几个值---这里take为2 则只拿到前两个值
    RACSubject *subject = [RACSubject subject];
    [[subject take:2] subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    // 发送信号
    [subject sendNext:@1];
    [subject sendNext:@2];
    [subject sendNext:@3];
}

- (void)takeLastRACSubject {
    //takeLast:和take的用法一样，不过他取的是最后的几个值，如下，则取的是最后两个值
    //注意点:takeLast 一定要调用sendCompleted，告诉他发送完成了，这样才能取到最后的几个值
    RACSubject *subject = [RACSubject subject];
    [[subject takeLast:2] subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    // 发送信号
    [subject sendNext:@1];
    [subject sendNext:@2];
    [subject sendNext:@3];
    [subject sendCompleted];
}

- (void)ignoreRACSubject {
    //ignore:忽略一些值
    //ignoreValues:表示忽略所有的值
    // 1.创建信号
    RACSubject *subject = [RACSubject subject];
    // 2.忽略一些值
    RACSignal *ignoreSignal = [subject ignore:@2]; // ignoreValues:表示忽略所有的值
    // 3.订阅信号
    [ignoreSignal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    // 4.发送数据
    [subject sendNext:@2];

}

#pragma mark 映射
- (void)map {
    // 创建信号
    RACSubject *subject = [RACSubject subject];
    // 绑定信号
    RACSignal *bindSignal = [subject map:^id(id value) {
        
        // 返回的类型就是你需要映射的值
        return [NSString stringWithFormat:@"ws:%@", value]; //这里将源信号发送的“123” 前面拼接了ws：
    }];
    // 订阅绑定信号
    [bindSignal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    // 发送信号
    [subject sendNext:@"123"];

}

- (void)flatMap {
    // 创建信号
    RACSubject *subject = [RACSubject subject];
    // 绑定信号
    RACSignal *bindSignal = [subject flattenMap:^RACStream *(id value) {
        // block：只要源信号发送内容就会调用
        // value: 就是源信号发送的内容
        // 返回信号用来包装成修改内容的值
        return [RACReturnSignal return:value];
        
    }];
    
    // flattenMap中返回的是什么信号，订阅的就是什么信号(那么，x的值等于value的值，如果我们操纵value的值那么x也会随之而变)
    // 订阅信号
    [bindSignal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    
    // 发送数据
    [subject sendNext:@"123"];
}

- (void)flattenMap2 {
    // flattenMap 主要用于信号中的信号
    // 创建信号
    RACSubject *signalofSignals = [RACSubject subject];
    RACSubject *signal = [RACSubject subject];
    
    // 订阅信号
    //方式1
    //    [signalofSignals subscribeNext:^(id x) {
    //
    //        [x subscribeNext:^(id x) {
    //            NSLog(@"%@", x);
    //        }];
    //    }];
    // 方式2
    //    [signalofSignals.switchToLatest  ];
    // 方式3
    //   RACSignal *bignSignal = [signalofSignals flattenMap:^RACStream *(id value) {
    //
    //        //value:就是源信号发送内容
    //        return value;
    //    }];
    //    [bignSignal subscribeNext:^(id x) {
    //        NSLog(@"%@", x);
    //    }];
    // 方式4--------也是开发中常用的
    [[signalofSignals flattenMap:^RACStream *(id value) {
        return value;
    }] subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    
    // 发送信号
    [signalofSignals sendNext:signal];
    [signal sendNext:@"123"];
}

#pragma mark 宏操作
- (void)hongTest {
    self.hongLabel = [[UILabel alloc] init];
    self.hongLabel.frame = CGRectMake(200, 500, 100, 100);
    self.hongLabel.text = @"宏测试";
    [self.view addSubview:self.hongLabel];
    
    self.hongTextField = [[UITextField alloc] init];
    self.hongTextField.frame = CGRectMake(200, 620, 100, 50);
    self.hongTextField.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:self.hongTextField];
    
    // RAC:把一个对象的某个属性绑定一个信号,只要发出信号,就会把信号的内容给对象的属性赋值
    // 给label的text属性绑定了文本框改变的信号
    RAC(self.hongLabel, text) = self.hongTextField.rac_textSignal;
//    [self.textField.rac_textSignal subscribeNext:^(id x) {
//        self.label.text = x;
//    }];
}

- (void)hongTestKVO {
    RAC(self.hongLabel, text) = self.hongTextField.rac_textSignal;
    [RACObserve(self.hongLabel, text) subscribeNext:^(id x) {
        NSLog(@"====label的文字变了");
    }];
}

//循环引用问题
- (void)hongTest3 {
    @weakify(self)
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        NSLog(@"%@",self.view);
        return nil;
    }];
    _signal = signal;
}

/**
 * 元祖
 * 快速包装一个元组
 * 把包装的类型放在宏的参数里面,就会自动包装
 */
- (void)hongTest4 {
    RACTuple *tuple = RACTuplePack(@1,@2,@4);
    // 宏的参数类型要和元祖中元素类型一致， 右边为要解析的元祖。
    RACTupleUnpack_(NSNumber *num1, NSNumber *num2, NSNumber * num3) = tuple;// 4.元祖
    // 快速包装一个元组
    // 把包装的类型放在宏的参数里面,就会自动包装
    NSLog(@"%@ %@ %@", num1, num2, num3);
}

#pragma mark 定时器
- (void)countdown {
    self.timeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.timeButton.frame = CGRectMake(200, 600, 100, 50);
    self.timeButton.backgroundColor = [UIColor yellowColor];
    [self.timeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.timeButton setTitle:@"发送验证码" forState:UIControlStateNormal];
    [self.view addSubview:self.timeButton];

    [[self.timeButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        self.count = 10;
        self.timeButton.enabled = NO;
        [self.timeButton setTitle:[NSString stringWithFormat:@"%d", self.count] forState:UIControlStateNormal];
        self.disposable = [[RACSignal interval:1.0 onScheduler:[RACScheduler mainThreadScheduler]]subscribeNext:^(id x) {
            if (self.count == 1) {
                [self.timeButton setTitle:[NSString stringWithFormat:@"重新发送"] forState:UIControlStateNormal];
                self.timeButton.enabled = YES;
                [self.disposable dispose];
            } else {
                self.count--;
                [self.timeButton setTitle:[NSString stringWithFormat:@"%d", self.count] forState:UIControlStateNormal];
                NSLog(@"%d",self.count);
            }
        }];
    }];

}
@end
