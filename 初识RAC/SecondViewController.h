//
//  SecondViewController.h
//  初识RAC
//
//  Created by 翟旭博 on 2023/2/7.
//

#import "ViewController.h"
#import "ReactiveCocoa.h"
NS_ASSUME_NONNULL_BEGIN

@interface SecondViewController : ViewController
@property(nonatomic, strong)RACSubject *subject;
@end

NS_ASSUME_NONNULL_END
